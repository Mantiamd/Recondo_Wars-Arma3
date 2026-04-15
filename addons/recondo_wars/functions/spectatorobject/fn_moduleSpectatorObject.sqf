/*
    Recondo_fnc_moduleSpectatorObject
    ACE Spectator Object Module - Server-side initialization
    
    Description:
        Reads module attributes and broadcasts spectator object settings to clients.
        Allows placing multiple modules for different spectator objects.
    
    Parameters:
        0: OBJECT - Logic module
        1: ARRAY - Synchronized units (unused)
        2: BOOL - Module activated
    
    Returns:
        Nothing
*/

params [["_logic", objNull, [objNull]], ["_units", [], [[]]], ["_activated", true, [true]]];

// Only run on server
if (!isServer) exitWith {};

// Check if module is activated
if (!_activated) exitWith {
    diag_log "[RECONDO_SPECTATOR] Module placed but not activated.";
};

// Create settings hashmap for this spectator object
private _settings = createHashMap;

// Debug
_settings set ["enableDebug", _logic getVariable ["enabledebug", false]];
if (RECONDO_MASTER_DEBUG) then { _settings set ["enableDebug", true]; };
private _debug = _settings get "enableDebug";

if (_debug) then {
    diag_log "[RECONDO_SPECTATOR] Module initializing...";
};

// Object settings
_settings set ["objectVarName", _logic getVariable ["objectvarname", ""]];
_settings set ["actionText", _logic getVariable ["actiontext", "Enter Spectator"]];

// Camera modes (0=free, 1=first person, 2=third person)
_settings set ["allowFreeCam", _logic getVariable ["allowfreecam", false]];
_settings set ["allowFirstPerson", _logic getVariable ["allowfirstperson", true]];
_settings set ["allowThirdPerson", _logic getVariable ["allowthirdperson", true]];

// Vision modes
_settings set ["allowNVG", _logic getVariable ["allownvg", false]];
_settings set ["allowThermal", _logic getVariable ["allowthermal", false]];

// Side and unit restrictions
_settings set ["restrictToOwnSide", _logic getVariable ["restricttoownside", true]];
_settings set ["playersOnly", _logic getVariable ["playersonly", true]];

// Store module position for reference
_settings set ["modulePos", getPosATL _logic];

// Validate object variable name
private _objectVarName = _settings get "objectVarName";
if (_objectVarName == "") exitWith {
    diag_log "[RECONDO_SPECTATOR] ERROR: No object variable name specified. Module will not function.";
};

// Initialize global array if needed
if (isNil "RECONDO_SPECTATOROBJECTS") then {
    RECONDO_SPECTATOROBJECTS = [];
};

// Add this spectator object config to the global array
RECONDO_SPECTATOROBJECTS pushBack _settings;
publicVariable "RECONDO_SPECTATOROBJECTS";

if (_debug) then {
    diag_log "[RECONDO_SPECTATOR] === MODULE SETTINGS ===";
    diag_log format ["[RECONDO_SPECTATOR] Object Variable: %1", _objectVarName];
    diag_log format ["[RECONDO_SPECTATOR] Action Text: %1", _settings get "actionText"];
    diag_log format ["[RECONDO_SPECTATOR] Camera - Free: %1, 1st: %2, 3rd: %3", 
        _settings get "allowFreeCam", 
        _settings get "allowFirstPerson", 
        _settings get "allowThirdPerson"];
    diag_log format ["[RECONDO_SPECTATOR] Vision - NVG: %1, Thermal: %2", 
        _settings get "allowNVG", 
        _settings get "allowThermal"];
    diag_log format ["[RECONDO_SPECTATOR] Restrict to Own Side: %1", _settings get "restrictToOwnSide"];
    diag_log format ["[RECONDO_SPECTATOR] Players Only: %1", _settings get "playersOnly"];
};

diag_log format ["[RECONDO_SPECTATOR] Module initialized for object: %1", _objectVarName];
