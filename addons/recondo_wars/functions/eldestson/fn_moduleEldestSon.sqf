/*
    Recondo_fnc_moduleEldestSon
    Main module initialization - runs on server only
    
    Description:
        Called when the Eldest Son module is activated.
        Simulates Operation Eldest Son - sabotaged enemy ammunition.
        Players place "poison" items in dead enemy bodies, which increases
        the chance that enemy units' weapons explode when fired.
    
    Parameters:
        0: OBJECT - Logic module
        1: ARRAY - Synced units (unused)
        2: BOOL - Is activated
        
    Returns:
        Nothing
*/

params ["_logic", "_units", "_activated"];

// Only run on server
if (!isServer) exitWith {
    diag_log "[RECONDO_ELDESTSON] Module attempted to run on non-server. Exiting.";
};

// Check if already initialized
if (!isNil "RECONDO_ELDESTSON_INITIALIZED") exitWith {
    diag_log "[RECONDO_ELDESTSON] WARNING: Module already initialized. Only one Eldest Son module should be placed.";
};

RECONDO_ELDESTSON_INITIALIZED = true;

// Create settings hashmap
private _settings = createHashMap;

// Debug
_settings set ["enableDebug", _logic getVariable ["enabledebug", false]];
if (RECONDO_MASTER_DEBUG) then { _settings set ["enableDebug", true]; };
private _debug = _settings get "enableDebug";

// Target side (0=OPFOR, 1=BLUFOR, 2=Independent, 3=Civilian)
private _sideNum = _logic getVariable ["targetside", 0];
_settings set ["targetSideNum", _sideNum];

private _targetSide = switch (_sideNum) do {
    case 0: { east };
    case 1: { west };
    case 2: { independent };
    case 3: { civilian };
    default { east };
};
_settings set ["targetSide", _targetSide];

// Chance per item (percentage)
private _chancePerItem = _logic getVariable ["chanceperitem", 1];
_chancePerItem = (_chancePerItem max 0.1) min 10;
_settings set ["chancePerItem", _chancePerItem];

// Max chance cap (percentage)
private _maxChance = _logic getVariable ["maxchance", 5];
_maxChance = (_maxChance max 1) min 100;
_settings set ["maxChance", _maxChance];

// Scan interval (seconds)
private _scanInterval = _logic getVariable ["scaninterval", 30];
_scanInterval = (_scanInterval max 5) min 300;
_settings set ["scanInterval", _scanInterval];

// Parse poison item classnames (comma-separated or newline-separated)
private _poisonItemsRaw = _logic getVariable ["poisonitems", ""];
private _poisonClassnames = [_poisonItemsRaw] call Recondo_fnc_parseClassnames;
_settings set ["poisonClassnames", _poisonClassnames];

// Store settings globally
RECONDO_ELDESTSON_SETTINGS = _settings;
publicVariable "RECONDO_ELDESTSON_SETTINGS";

if (_debug) then {
    diag_log "[RECONDO_ELDESTSON] === MODULE SETTINGS ===";
    diag_log format ["[RECONDO_ELDESTSON] Target Side: %1 (num: %2)", _targetSide, _sideNum];
    diag_log format ["[RECONDO_ELDESTSON] Chance Per Item: %1%%", _chancePerItem];
    diag_log format ["[RECONDO_ELDESTSON] Max Chance Cap: %1%%", _maxChance];
    diag_log format ["[RECONDO_ELDESTSON] Scan Interval: %1 seconds", _scanInterval];
    diag_log format ["[RECONDO_ELDESTSON] Poison Classnames (%1 configured): %2", count _poisonClassnames, _poisonClassnames];
};

// Exit if no poison items configured
if (count _poisonClassnames == 0) exitWith {
    diag_log "[RECONDO_ELDESTSON] WARNING: No poison items configured. Module disabled.";
};

// Load persisted sabotage chance
private _persistenceKey = "RECONDO_ELDESTSON";
private _savedChance = [_persistenceKey + "_CHANCE"] call Recondo_fnc_getSaveData;

// Ensure it's a valid number (not nil, array, or other type)
if (isNil "_savedChance") then {
    _savedChance = 0;
} else {
    if (typeName _savedChance != "SCALAR") then {
        _savedChance = 0;
    };
};

// Ensure within bounds
_savedChance = (_savedChance max 0) min _maxChance;

RECONDO_ELDESTSON_CHANCE = _savedChance;
publicVariable "RECONDO_ELDESTSON_CHANCE";

if (_debug) then {
    diag_log format ["[RECONDO_ELDESTSON] Loaded sabotage chance: %1%%", _savedChance];
};

// Initialize existing units of target side with Fired EH
{
    if (side group _x == _targetSide && {alive _x}) then {
        [_x] call Recondo_fnc_initEldestSonUnit;
    };
} forEach allUnits;

if (_debug) then {
    private _taggedCount = {
        side group _x == _targetSide && {alive _x} && {!isNil {_x getVariable "RECONDO_ELDESTSON_TAGGED"}}
    } count allUnits;
    diag_log format ["[RECONDO_ELDESTSON] Tagged %1 existing units", _taggedCount];
};

// Add EntityCreated event handler to tag new units
private _entityCreatedEH = addMissionEventHandler ["EntityCreated", {
    params ["_entity"];
    
    // Only process units (not vehicles, objects, etc.)
    if (!(_entity isKindOf "CAManBase")) exitWith {};
    
    private _settings = RECONDO_ELDESTSON_SETTINGS;
    if (isNil "_settings") exitWith {};
    
    private _targetSide = _settings get "targetSide";
    
    // Check if unit is of target side
    if (side group _entity == _targetSide) then {
        // Small delay to let unit fully initialize
        [{
            params ["_unit"];
            if (alive _unit && isNil {_unit getVariable "RECONDO_ELDESTSON_TAGGED"}) then {
                [_unit] call Recondo_fnc_initEldestSonUnit;
            };
        }, [_entity], 0.5] call CBA_fnc_waitAndExecute;
    };
}];

RECONDO_ELDESTSON_ENTITYCREATED_EH = _entityCreatedEH;

// Start the body scanner loop
[] spawn Recondo_fnc_scanEldestSonBodies;

diag_log format ["[RECONDO_ELDESTSON] Module initialized. %1 poison item(s) configured. Current sabotage: %2%% (max: %3%%)", 
    count _poisonClassnames, _savedChance, _maxChance];
