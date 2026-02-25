/*
    Recondo_fnc_modulePathPatrols
    Main module initialization - runs on server only
    
    Description:
        Called when the Path Patrols module is activated.
        Finds path markers matching the prefix (e.g., PATROLa_1, PATROLa_2, etc.),
        sorts them numerically, and creates a trigger at the path center.
        When activated, spawns patrol groups that ping-pong along the path.
    
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
    diag_log "[RECONDO_PP] Module attempted to run on non-server. Exiting.";
};

// Get all module attributes
private _settings = createHashMap;

// General Settings
private _aiSideNum = _logic getVariable ["aiside", 0];
private _sideMap = [east, west, independent, civilian];
_settings set ["aiSide", _sideMap select _aiSideNum];
_settings set ["markerPrefix", _logic getVariable ["markerprefix", ""]];
_settings set ["numberOfGroups", _logic getVariable ["numberofgroups", 1]];
_settings set ["spawnPercentage", _logic getVariable ["spawnpercentage", 1]];

// Unit Settings
private _unitClassnamesStr = _logic getVariable ["unitclassnames", ""];
private _unitClassnames = [_unitClassnamesStr] call Recondo_fnc_parseClassnames;
_settings set ["unitClassnames", _unitClassnames];
_settings set ["minGroupSize", _logic getVariable ["mingroupsize", 3]];
_settings set ["maxGroupSize", _logic getVariable ["maxgroupsize", 6]];

// Trigger Settings
_settings set ["triggerSide", _logic getVariable ["triggerside", "WEST"]];
_settings set ["triggerRadius", _logic getVariable ["triggerradius", 500]];
_settings set ["triggerHeight", _logic getVariable ["triggerheight", 20]];

// Performance Settings
_settings set ["simulationDistance", _logic getVariable ["simulationdistance", 1000]];
_settings set ["lambsReinforce", _logic getVariable ["lambsreinforce", true]];

// Debug
_settings set ["enableDebug", _logic getVariable ["enabledebug", false]];

// Store settings globally
RECONDO_PP_SETTINGS = _settings;
publicVariable "RECONDO_PP_SETTINGS";

private _debug = _settings get "enableDebug";
private _markerPrefix = _settings get "markerPrefix";
private _numberOfGroups = _settings get "numberOfGroups";

// Validate settings
if (_markerPrefix == "") exitWith {
    diag_log "[RECONDO_PP] ERROR: No marker prefix specified. Module disabled.";
};

if (count _unitClassnames == 0) exitWith {
    diag_log "[RECONDO_PP] ERROR: No unit classnames specified. Module disabled.";
};

if (_debug) then {
    diag_log format ["[RECONDO_PP] AI side: %1", _settings get "aiSide"];
    diag_log format ["[RECONDO_PP] Marker prefix: '%1'", _markerPrefix];
    diag_log format ["[RECONDO_PP] Number of groups: %1", _numberOfGroups];
    diag_log format ["[RECONDO_PP] Spawn percentage: %1%%", (_settings get "spawnPercentage") * 100];
    diag_log format ["[RECONDO_PP] Unit classnames: %1", _unitClassnames];
    diag_log format ["[RECONDO_PP] Group size: %1-%2", _settings get "minGroupSize", _settings get "maxGroupSize"];
    diag_log format ["[RECONDO_PP] Trigger side: %1, Radius: %2m, Height: %3m", _settings get "triggerSide", _settings get "triggerRadius", _settings get "triggerHeight"];
};

// Find all markers matching the prefix
private _allMarkers = allMapMarkers select {
    (_x find _markerPrefix) == 0
};

if (count _allMarkers == 0) exitWith {
    diag_log format ["[RECONDO_PP] WARNING: No markers found with prefix '%1'. Module disabled.", _markerPrefix];
};

if (_debug) then {
    diag_log format ["[RECONDO_PP] Found %1 markers with prefix '%2'", count _allMarkers, _markerPrefix];
};

// Sort markers numerically by extracting the number after the prefix
private _markersWithNumbers = [];

{
    private _marker = _x;
    private _numberStr = _marker select [count _markerPrefix]; // Get part after prefix
    private _number = parseNumber _numberStr;
    _markersWithNumbers pushBack [_number, _marker];
} forEach _allMarkers;

// Sort by number
_markersWithNumbers sort true;

// Extract sorted marker names
private _sortedMarkers = _markersWithNumbers apply { _x select 1 };

if (_debug) then {
    diag_log format ["[RECONDO_PP] Sorted markers: %1", _sortedMarkers];
};

// Store sorted path markers
_settings set ["pathMarkers", _sortedMarkers];

// Calculate center of all markers for trigger placement
private _centerX = 0;
private _centerY = 0;
{
    private _pos = getMarkerPos _x;
    _centerX = _centerX + (_pos select 0);
    _centerY = _centerY + (_pos select 1);
} forEach _sortedMarkers;

private _markerCount = count _sortedMarkers;
private _centerPos = [_centerX / _markerCount, _centerY / _markerCount, 0];

if (_debug) then {
    diag_log format ["[RECONDO_PP] Path center calculated at: %1", _centerPos];
};

// Store globals
RECONDO_PP_PATH_MARKERS = _sortedMarkers;
RECONDO_PP_SPAWNED_GROUPS = [];

// Create trigger at path center
private _trigger = [_centerPos, _settings] call Recondo_fnc_createPathTrigger;

if (!isNull _trigger) then {
    RECONDO_PP_ACTIVE_TRIGGER = _trigger;
} else {
    RECONDO_PP_ACTIVE_TRIGGER = objNull;
};

// Final log
diag_log format ["[RECONDO_PP] Initialized. Created trigger at path center for prefix '%1' with %2 markers.", _markerPrefix, _markerCount];
