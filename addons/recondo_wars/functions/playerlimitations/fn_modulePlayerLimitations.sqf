/*
    Recondo_fnc_modulePlayerLimitations
    Main module initialization - runs on server only
    
    Description:
        Called when the Player Limitations module is activated.
        Reads all module attributes and broadcasts to clients for enforcement.
        Periodically checks player inventories and removes excess items.
    
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
    diag_log "[RECONDO_PLAYERLIMITS] Module attempted to run on non-server. Exiting.";
};

// Check if already initialized
if (!isNil "RECONDO_PLAYERLIMITS_INITIALIZED") exitWith {
    diag_log "[RECONDO_PLAYERLIMITS] WARNING: Module already initialized. Only one Player Limitations module should be placed.";
};

RECONDO_PLAYERLIMITS_INITIALIZED = true;

// Create settings hashmap
private _settings = createHashMap;

// Debug
_settings set ["enableDebug", _logic getVariable ["enabledebug", false]];
private _debug = _settings get "enableDebug";

// Side setting (0=OPFOR, 1=BLUFOR, 2=Independent, 3=Civilian, 4=Any)
private _sideNum = _logic getVariable ["allowedside", 1];
_settings set ["allowedSideNum", _sideNum];

// Check interval
private _checkInterval = _logic getVariable ["checkinterval", 60];
_settings set ["checkInterval", _checkInterval max 10]; // Minimum 10 seconds

// Teamkiller announcement setting
private _announceTeamkillers = _logic getVariable ["announceteamkillers", false];
_settings set ["announceTeamkillers", _announceTeamkillers];

// Build item limitations array from the 5 slots
private _limitations = [];

// Slot 1
private _item1Class = _logic getVariable ["item1class", ""];
private _item1Limit = _logic getVariable ["item1limit", 0];
if (_item1Class != "") then {
    _limitations pushBack [_item1Class, _item1Limit];
};

// Slot 2
private _item2Class = _logic getVariable ["item2class", ""];
private _item2Limit = _logic getVariable ["item2limit", 0];
if (_item2Class != "") then {
    _limitations pushBack [_item2Class, _item2Limit];
};

// Slot 3
private _item3Class = _logic getVariable ["item3class", ""];
private _item3Limit = _logic getVariable ["item3limit", 0];
if (_item3Class != "") then {
    _limitations pushBack [_item3Class, _item3Limit];
};

// Slot 4
private _item4Class = _logic getVariable ["item4class", ""];
private _item4Limit = _logic getVariable ["item4limit", 0];
if (_item4Class != "") then {
    _limitations pushBack [_item4Class, _item4Limit];
};

// Slot 5
private _item5Class = _logic getVariable ["item5class", ""];
private _item5Limit = _logic getVariable ["item5limit", 0];
if (_item5Class != "") then {
    _limitations pushBack [_item5Class, _item5Limit];
};

_settings set ["limitations", _limitations];

// Store settings globally and broadcast to clients
RECONDO_PLAYERLIMITS_SETTINGS = _settings;
publicVariable "RECONDO_PLAYERLIMITS_SETTINGS";

if (_debug) then {
    diag_log "[RECONDO_PLAYERLIMITS] === MODULE SETTINGS ===";
    diag_log format ["[RECONDO_PLAYERLIMITS] Allowed Side: %1", _sideNum];
    diag_log format ["[RECONDO_PLAYERLIMITS] Check Interval: %1 seconds", _checkInterval];
    diag_log format ["[RECONDO_PLAYERLIMITS] Announce Teamkillers: %1", _announceTeamkillers];
    diag_log format ["[RECONDO_PLAYERLIMITS] Limitations (%1 configured):", count _limitations];
    {
        _x params ["_pattern", "_limit"];
        diag_log format ["[RECONDO_PLAYERLIMITS]   - Pattern: '%1' | Max: %2", _pattern, _limit];
    } forEach _limitations;
};

// Set up teamkill detection if enabled
if (_announceTeamkillers) then {
    addMissionEventHandler ["EntityKilled", {
        params ["_unit", "_killer", "_instigator", "_useEffects"];
        
        // Get actual killer (instigator takes priority for vehicle kills)
        private _actualKiller = if (!isNull _instigator) then { _instigator } else { _killer };
        
        // Both must be players
        if (!isPlayer _unit) exitWith {};
        if (!isPlayer _actualKiller) exitWith {};
        if (_unit == _actualKiller) exitWith {}; // Ignore suicide
        
        // Get settings
        private _settings = RECONDO_PLAYERLIMITS_SETTINGS;
        if (isNil "_settings") exitWith {};
        
        private _sideNum = _settings get "allowedSideNum";
        
        // Determine target side
        private _targetSide = switch (_sideNum) do {
            case 0: { EAST };
            case 1: { WEST };
            case 2: { INDEPENDENT };
            case 3: { CIVILIAN };
            default { side group _actualKiller }; // "Any" (4) - use killer's side
        };
        
        // Get sides - use side group for reliability
        private _killerSide = side group _actualKiller;
        private _victimSide = side group _unit;
        
        // Check if both are of the target side
        if (_victimSide != _targetSide) exitWith {};
        if (_killerSide != _targetSide) exitWith {};
        
        // Same side kill detected - announce globally
        private _killerName = name _actualKiller;
        private _message = format ["%1 killed same side unit!", _killerName];
        
        // Broadcast to all clients via systemChat
        _message remoteExec ["systemChat", 0, false];
        
        diag_log format ["[RECONDO_PLAYERLIMITS] TEAMKILL: %1 (side: %2) killed %3 (side: %4)", 
            _killerName, _killerSide, name _unit, _victimSide];
    }];
    
    diag_log "[RECONDO_PLAYERLIMITS] Teamkill announcements enabled.";
};

diag_log format ["[RECONDO_PLAYERLIMITS] Module initialized. %1 item limitation(s) configured. Interval: %2s", count _limitations, _checkInterval];
