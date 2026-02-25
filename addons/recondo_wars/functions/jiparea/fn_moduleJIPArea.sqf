/*
    Recondo_fnc_moduleJIPArea
    JIP to Group Leader Area Module - Server-side initialization
    
    Description:
        Reads module attributes and broadcasts area configuration to all clients.
        Multiple modules can be placed to create multiple JIP teleport zones.
    
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
    diag_log "[RECONDO_JIPAREA] Module placed but not activated.";
};

// Get debug setting
private _debug = _logic getVariable ["enabledebug", false];

if (_debug) then {
    diag_log "[RECONDO_JIPAREA] Module initializing...";
};

// Get module position and direction
private _pos = getPosATL _logic;
private _dir = getDir _logic;

// Read module attributes
private _areaWidth = _logic getVariable ["areawidth", 100];
private _areaLength = _logic getVariable ["arealength", 100];
private _areaHeight = _logic getVariable ["areaheight", 25];

// Create area data entry
private _areaData = createHashMap;
_areaData set ["position", _pos];
_areaData set ["direction", _dir];
_areaData set ["width", _areaWidth];
_areaData set ["length", _areaLength];
_areaData set ["height", _areaHeight];
_areaData set ["debug", _debug];

// Add to global array
RECONDO_JIPAREAS pushBack _areaData;
publicVariable "RECONDO_JIPAREAS";

if (_debug) then {
    diag_log format ["[RECONDO_JIPAREA] Area registered at %1", _pos];
    diag_log format ["[RECONDO_JIPAREA]   Dimensions: %1 x %2 x %3", _areaWidth, _areaLength, _areaHeight];
    diag_log format ["[RECONDO_JIPAREA]   Direction: %1", _dir];
    diag_log format ["[RECONDO_JIPAREA]   Total areas registered: %1", count RECONDO_JIPAREAS];
};

diag_log format ["[RECONDO_JIPAREA] JIP teleport area initialized at %1", _pos];
