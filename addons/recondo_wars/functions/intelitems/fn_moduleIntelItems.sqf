/*
    Recondo_fnc_moduleIntelItems
    Main initialization for Intel Items module
    
    Description:
        Adds intel items to AI unit inventories based on classnames and probability.
        Processes existing units on mission start and monitors for new units via
        EntityCreated event handler. Syncs to Intel module to register as source.
        Also handles POW turn-in functionality if enabled.
    
    Priority: 3 (Feature module - after Intel core)
    
    Parameters:
        _logic - Module logic object
        _units - Synchronized units (unused)
        _activated - Whether module is activated
*/

params ["_logic", "_units", "_activated"];

// Server-only initialization
if (!isServer) exitWith {};

// Validate activation
if (!_activated) exitWith {
    diag_log "[RECONDO_INTELITEMS] Module not activated.";
};

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

private _intelChance = _logic getVariable ["intelchance", 0.5];
private _minItems = _logic getVariable ["minitems", 1];
private _maxItems = _logic getVariable ["maxitems", 1];
private _unitClassnamesRaw = _logic getVariable ["unitclassnames", ""];
private _targetSideNum = _logic getVariable ["targetside", 0];
private _intelItemsConfigRaw = _logic getVariable ["intelitemsconfig", ""];
private _takeActionText = _logic getVariable ["takeactiontext", "Take %1"];
private _debugLogging = _logic getVariable ["debuglogging", false];

// POW Settings
private _enablePOW = _logic getVariable ["enablepow", false];
private _powTargetSideNum = _logic getVariable ["powtargetside", 0];
private _powClassnamesRaw = _logic getVariable ["powclassnames", ""];
private _powTurnInRadius = _logic getVariable ["powturninradius", 10];
private _powIntelValue = _logic getVariable ["powintelvalue", 0.3];
private _powActionText = _logic getVariable ["powactiontext", "Turn In Prisoner"];

// ========================================
// VALIDATE SETTINGS
// ========================================

// Parse unit classnames (required whitelist)
private _unitClassnames = if (_unitClassnamesRaw != "") then {
    [_unitClassnamesRaw] call Recondo_fnc_parseClassnames
} else {
    [] // Empty = no units will receive intel
};

// Convert side number
private _targetSide = switch (_targetSideNum) do {
    case 0: { east };
    case 1: { west };
    case 2: { independent };
    case 3: { nil }; // Any side
    default { east };
};

// Parse intel items config
private _itemDefs = [_intelItemsConfigRaw] call Recondo_fnc_parseIntelItemsConfig;

if (count _itemDefs == 0) exitWith {
    diag_log "[RECONDO_INTELITEMS] ERROR: No intel items configured. Module disabled.";
};

// Validate min/max
_minItems = _minItems max 1;
_maxItems = _maxItems max _minItems;

// Parse POW settings
private _powTargetSide = switch (_powTargetSideNum) do {
    case 0: { east };
    case 1: { west };
    case 2: { independent };
    case 3: { civilian };
    case 4: { nil }; // Any side
    default { east };
};

private _powClassnames = if (_powClassnamesRaw != "") then {
    [_powClassnamesRaw] call Recondo_fnc_parseClassnames
} else {
    []
};

// ========================================
// STORE SETTINGS
// ========================================

RECONDO_INTELITEMS_SETTINGS = createHashMapFromArray [
    ["intelChance", _intelChance],
    ["minItems", _minItems],
    ["maxItems", _maxItems],
    ["unitClassnames", _unitClassnames],
    ["targetSide", _targetSide],
    ["itemDefs", _itemDefs],
    ["takeActionText", _takeActionText],
    ["debugLogging", _debugLogging],
    ["enablePOW", _enablePOW],
    ["powTargetSide", _powTargetSide],
    ["powClassnames", _powClassnames],
    ["powTurnInRadius", _powTurnInRadius],
    ["powIntelValue", _powIntelValue],
    ["powActionText", _powActionText]
];
publicVariable "RECONDO_INTELITEMS_SETTINGS";

RECONDO_INTELITEMS_ITEM_DEFS = _itemDefs;
publicVariable "RECONDO_INTELITEMS_ITEM_DEFS";

// ========================================
// CHECK SYNC TO INTEL MODULE
// ========================================

private _syncedModules = synchronizedObjects _logic;
private _linkedToIntel = false;

{
    if (typeOf _x == "Recondo_Module_Intel") exitWith {
        _linkedToIntel = true;
        if (_debugLogging) then {
            diag_log "[RECONDO_INTELITEMS] Linked to Intel System module";
        };
    };
} forEach _syncedModules;

if (!_linkedToIntel) then {
    diag_log "[RECONDO_INTELITEMS] WARNING: Not synced to Intel System module. Turn-in functionality may not work.";
};

// ========================================
// SETUP POW TURN-IN (if enabled)
// ========================================

if (_enablePOW) then {
    if (_debugLogging) then {
        diag_log "[RECONDO_INTELITEMS] POW turn-in enabled, waiting for Intel turn-in points...";
    };
    
    // Wait for Intel module to populate turn-in objects
    [{
        !isNil "RECONDO_INTEL_TURNIN_OBJECTS" && {count RECONDO_INTEL_TURNIN_OBJECTS > 0}
    }, {
        params ["_debugLogging"];
        
        // Add POW turn-in action to all Intel turn-in objects
        {
            [_x] call Recondo_fnc_addPOWTurnIn;
        } forEach RECONDO_INTEL_TURNIN_OBJECTS;
        
        if (_debugLogging) then {
            diag_log format ["[RECONDO_INTELITEMS] Added POW turn-in action to %1 Intel turn-in points", count RECONDO_INTEL_TURNIN_OBJECTS];
        };
        
    }, [_debugLogging], 30, {
        diag_log "[RECONDO_INTELITEMS] WARNING: Timeout waiting for Intel turn-in objects. POW turn-in may not work.";
    }] call CBA_fnc_waitUntilAndExecute;
} else {
    if (_debugLogging) then {
        diag_log "[RECONDO_INTELITEMS] POW turn-in disabled";
    };
};

// ========================================
// PROCESS EXISTING UNITS
// ========================================

private _processedCount = 0;
private _intelAddedCount = 0;

{
    if (!isPlayer _x) then {
        private _result = [_x] call Recondo_fnc_processUnitForIntel;
        if (_result) then {
            _intelAddedCount = _intelAddedCount + 1;
        };
        _processedCount = _processedCount + 1;
    };
} forEach allUnits;

if (_debugLogging) then {
    diag_log format ["[RECONDO_INTELITEMS] Processed %1 existing units, %2 received intel", _processedCount, _intelAddedCount];
};

// ========================================
// SETUP ENTITYCREATED EVENT HANDLER
// ========================================

addMissionEventHandler ["EntityCreated", {
    params ["_entity"];
    
    // Only process AI units
    if (!(_entity isKindOf "CAManBase") || isPlayer _entity) exitWith {};
    
    // Small delay to ensure unit is fully initialized
    [{
        params ["_unit"];
        
        if (isNull _unit || !alive _unit) exitWith {};
        
        [_unit] call Recondo_fnc_processUnitForIntel;
        
    }, [_entity], 0.5] call CBA_fnc_waitAndExecute;
}];

// ========================================
// LOG INITIALIZATION
// ========================================

if (_debugLogging) then {
    diag_log "[RECONDO_INTELITEMS] === Intel Items Module Initialized ===";
    diag_log format ["[RECONDO_INTELITEMS] Intel chance: %1%", round(_intelChance * 100)];
    diag_log format ["[RECONDO_INTELITEMS] Items per unit: %1-%2", _minItems, _maxItems];
    diag_log format ["[RECONDO_INTELITEMS] Unit classnames: %1", if (count _unitClassnames == 0) then { "NONE (no units will receive intel)" } else { _unitClassnames }];
    diag_log format ["[RECONDO_INTELITEMS] Target side: %1", if (isNil "_targetSide") then { "ANY" } else { _targetSide }];
    diag_log format ["[RECONDO_INTELITEMS] Intel item definitions: %1", count _itemDefs];
    {
        _x params ["_name", "_class", "_weight"];
        diag_log format ["[RECONDO_INTELITEMS]   - %1 (%2) weight: %3", _name, _class, _weight];
    } forEach _itemDefs;
    
    // POW settings
    diag_log format ["[RECONDO_INTELITEMS] POW turn-in enabled: %1", _enablePOW];
    if (_enablePOW) then {
        diag_log format ["[RECONDO_INTELITEMS] POW target side: %1", if (isNil "_powTargetSide") then { "ANY" } else { _powTargetSide }];
        diag_log format ["[RECONDO_INTELITEMS] POW classnames: %1", if (count _powClassnames == 0) then { "NONE (side only)" } else { _powClassnames }];
        diag_log format ["[RECONDO_INTELITEMS] POW turn-in radius: %1m", _powTurnInRadius];
        diag_log format ["[RECONDO_INTELITEMS] POW intel value: %1", _powIntelValue];
    };
};

diag_log format ["[RECONDO_INTELITEMS] Module initialized. Intel chance: %1%, Items: %2-%3, Definitions: %4, POW: %5",
    round(_intelChance * 100), _minItems, _maxItems, count _itemDefs, _enablePOW];
