/*
    Recondo_fnc_modulePlayerIntelDrops
    Main module initialization - runs on server only
    
    Description:
        Called when the Player Intel Drops module is activated.
        Reads all module attributes and sets up the killed event handler.
        When configured players die, intel is added to their body.
    
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
    diag_log "[RECONDO_PLAYERINTELDROPS] Module attempted to run on non-server. Exiting.";
};

// Check if already initialized
if (!isNil "RECONDO_PLAYERINTELDROPS_INITIALIZED") exitWith {
    diag_log "[RECONDO_PLAYERINTELDROPS] WARNING: Module already initialized. Only one Player Intel Drops module should be placed.";
};

RECONDO_PLAYERINTELDROPS_INITIALIZED = true;

// Create settings hashmap
private _settings = createHashMap;

// Debug
_settings set ["enableDebug", _logic getVariable ["enabledebug", false]];
if (RECONDO_MASTER_DEBUG) then { _settings set ["enableDebug", true]; };
private _debug = _settings get "enableDebug";

// Side setting (0=OPFOR, 1=BLUFOR, 2=Independent, 3=Civilian)
private _sideNum = _logic getVariable ["affectedside", 1];
_settings set ["affectedSideNum", _sideNum];

// Convert side number to side type
private _affectedSide = switch (_sideNum) do {
    case 0: { east };
    case 1: { west };
    case 2: { independent };
    case 3: { civilian };
    default { west };
};
_settings set ["affectedSide", _affectedSide];

// Unit classnames filter (comma-separated, empty = all units of that side)
private _unitClassnamesRaw = _logic getVariable ["unitclassnames", ""];
private _unitClassnames = [_unitClassnamesRaw] call Recondo_fnc_parseClassnames;
_settings set ["unitClassnames", _unitClassnames];

// Drop chance (0-100)
private _dropChance = _logic getVariable ["dropchance", 100];
_dropChance = (_dropChance max 0) min 100;
_settings set ["dropChance", _dropChance];

// Parse intel items (format: DisplayName,Classname per line)
private _intelItemsRaw = _logic getVariable ["intelitems", ""];
private _intelItems = [];

// Normalize escaped newlines to actual newlines
private _normalized = _intelItemsRaw;
if (_normalized find "\n" == -1 && _normalized find "\\n" >= 0) then {
    _normalized = _normalized regexReplace ["\\\\n", toString [10]];
};

// Split by newlines and parse each line
private _lines = _normalized splitString toString [13, 10]; // CR LF
if (count _lines <= 1) then {
    _lines = _normalized splitString toString [10]; // LF only
};

{
    private _line = _x trim [" ", 0];
    if (_line != "" && !(_line select [0, 2] == "//")) then {
        private _parts = _line splitString ",";
        if (count _parts >= 2) then {
            private _displayName = (_parts select 0) trim [" ", 0];
            private _classname = (_parts select 1) trim [" ", 0];
            
            if (_displayName != "" && _classname != "") then {
                _intelItems pushBack [_displayName, _classname];
            };
        };
    };
} forEach _lines;

_settings set ["intelItems", _intelItems];

// Store settings globally
RECONDO_PLAYERINTELDROPS_SETTINGS = _settings;
publicVariable "RECONDO_PLAYERINTELDROPS_SETTINGS";

if (_debug) then {
    diag_log "[RECONDO_PLAYERINTELDROPS] === MODULE SETTINGS ===";
    diag_log format ["[RECONDO_PLAYERINTELDROPS] Affected Side: %1 (num: %2)", _affectedSide, _sideNum];
    diag_log format ["[RECONDO_PLAYERINTELDROPS] Unit Classnames Filter: %1", if (count _unitClassnames == 0) then {"(all units)"} else {_unitClassnames}];
    diag_log format ["[RECONDO_PLAYERINTELDROPS] Drop Chance: %1%%", _dropChance];
    diag_log format ["[RECONDO_PLAYERINTELDROPS] Intel Items (%1 configured):", count _intelItems];
    {
        _x params ["_displayName", "_classname"];
        diag_log format ["[RECONDO_PLAYERINTELDROPS]   - '%1' (%2)", _displayName, _classname];
    } forEach _intelItems;
};

// Exit if no intel items configured
if (count _intelItems == 0) exitWith {
    diag_log "[RECONDO_PLAYERINTELDROPS] WARNING: No intel items configured. Module disabled.";
};

// Add EntityKilled event handler to detect player deaths
private _ehId = addMissionEventHandler ["EntityKilled", {
    params ["_unit", "_killer", "_instigator", "_useEffects"];
    
    // Only process player deaths
    if (!isPlayer _unit) exitWith {};
    
    // Handle the death
    [_unit] call Recondo_fnc_handlePlayerIntelDrop;
}];

RECONDO_PLAYERINTELDROPS_EH = _ehId;

diag_log format ["[RECONDO_PLAYERINTELDROPS] Module initialized. %1 intel item(s) configured. Drop chance: %2%%", 
    count _intelItems, _dropChance];
