/*
    Recondo_fnc_moduleSoilSample
    Main initialization for Soil Sample module

    Description:
        Allows players to collect soil samples via ACE self-interaction
        when near a road/path/trail and carrying a required item.
        The required item is consumed and a sample item is given.
        Optional marker-based area restriction.
        Integrates with Intel Board for objective tracking and turn-in.

    Priority: 5 (Feature module)

    Parameters:
        _logic - Module logic object
        _units - Synchronized units (unused)
        _activated - Whether module is activated
*/

params ["_logic", "_units", "_activated"];

if (!isServer) exitWith {};

if (!_activated) exitWith {
    diag_log "[RECONDO_SOIL] Module not activated.";
};

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

private _requiredItem = _logic getVariable ["requireditem", ""];
private _rewardItem = _logic getVariable ["rewarditem", ""];
private _roadDistance = _logic getVariable ["roaddistance", 2];
private _collectDuration = _logic getVariable ["collectduration", 5];
private _cooldownSeconds = _logic getVariable ["cooldownseconds", 600];
private _markerPrefix = _logic getVariable ["markerprefix", ""];
private _debugLogging = _logic getVariable ["debuglogging", false];

// Objective settings
private _objectiveName = _logic getVariable ["objectivename", "Soil Sample"];
private _objectiveDescription = _logic getVariable ["objectivedescription", ""];
private _intelBoardCategoryName = _logic getVariable ["intelboardcategoryname", ""];
private _samplesRequired = _logic getVariable ["samplesrequired", 3];

// ========================================
// VALIDATE
// ========================================

if (_requiredItem == "") exitWith {
    diag_log "[RECONDO_SOIL] ERROR: No required item classname specified. Module disabled.";
};

if (_rewardItem == "") exitWith {
    diag_log "[RECONDO_SOIL] ERROR: No reward item classname specified. Module disabled.";
};

_samplesRequired = _samplesRequired max 1;

// ========================================
// FIND MARKERS (if prefix set)
// ========================================

private _markerAreas = [];

if (_markerPrefix != "") then {
    private _prefixLength = count _markerPrefix;
    {
        if ((_x select [0, _prefixLength]) == _markerPrefix) then {
            _markerAreas pushBack _x;
        };
    } forEach allMapMarkers;

    if (count _markerAreas == 0) then {
        diag_log format ["[RECONDO_SOIL] WARNING: Marker prefix '%1' set but no markers found. Collection will be disabled.", _markerPrefix];
    } else {
        if (_debugLogging) then {
            diag_log format ["[RECONDO_SOIL] Found %1 area markers with prefix '%2'", count _markerAreas, _markerPrefix];
        };
    };
};

// ========================================
// BUILD OBJECTIVE DATA
// ========================================

private _instanceId = format ["soil_%1_%2", _objectiveName, count RECONDO_SOIL_INSTANCES];

// Per-marker objective tracking (or single global objective)
private _objectives = createHashMap;

if (count _markerAreas > 0) then {
    {
        private _markerName = _x;
        private _markerPos = getMarkerPos _markerName;
        private _grid = [_markerPos] call Recondo_fnc_posToGrid;
        _objectives set [_markerName, createHashMapFromArray [
            ["marker", _markerName],
            ["position", _markerPos],
            ["grid", _grid],
            ["turnedIn", 0],
            ["complete", false]
        ]];

        if (_debugLogging) then {
            diag_log format ["[RECONDO_SOIL] Objective registered: %1 at GRID %2 (requires %3 samples)", _markerName, _grid, _samplesRequired];
        };
    } forEach _markerAreas;
} else {
    _objectives set ["__GLOBAL__", createHashMapFromArray [
        ["marker", "__GLOBAL__"],
        ["position", [0,0,0]],
        ["grid", ""],
        ["turnedIn", 0],
        ["complete", false]
    ]];
};

// Initialize turned-in tracking
RECONDO_SOIL_TURNED_IN = _objectives;
publicVariable "RECONDO_SOIL_TURNED_IN";

// ========================================
// STORE AND BROADCAST SETTINGS
// ========================================

private _settings = createHashMapFromArray [
    ["instanceId", _instanceId],
    ["requiredItem", _requiredItem],
    ["rewardItem", _rewardItem],
    ["roadDistance", _roadDistance],
    ["collectDuration", _collectDuration],
    ["cooldownSeconds", _cooldownSeconds],
    ["markerPrefix", _markerPrefix],
    ["markerAreas", _markerAreas],
    ["objectiveName", _objectiveName],
    ["objectiveDescription", _objectiveDescription],
    ["intelBoardCategoryName", _intelBoardCategoryName],
    ["samplesRequired", _samplesRequired],
    ["debugLogging", _debugLogging]
];

RECONDO_SOIL_SETTINGS = _settings;
publicVariable "RECONDO_SOIL_SETTINGS";

RECONDO_SOIL_INSTANCES pushBack _settings;
publicVariable "RECONDO_SOIL_INSTANCES";

// ========================================
// INIT CLIENT ACTIONS
// ========================================

[{!isNil "RECONDO_SOIL_SETTINGS"}, {
    remoteExecCall ["Recondo_fnc_initSoilSampleClient", [0, -2] select isDedicated];
}, []] call CBA_fnc_waitUntilAndExecute;

// ========================================
// SET UP TURN-IN ACTIONS ON INTEL TURN-IN OBJECTS
// ========================================

[_settings] call Recondo_fnc_addSoilTurnIn;

// ========================================
// LOG
// ========================================

if (_debugLogging) then {
    diag_log "[RECONDO_SOIL] Module settings:";
    diag_log format ["[RECONDO_SOIL]   Required item: %1", _requiredItem];
    diag_log format ["[RECONDO_SOIL]   Reward item: %1", _rewardItem];
    diag_log format ["[RECONDO_SOIL]   Road distance: %1m", _roadDistance];
    diag_log format ["[RECONDO_SOIL]   Collect duration: %1s", _collectDuration];
    diag_log format ["[RECONDO_SOIL]   Cooldown: %1s", _cooldownSeconds];
    diag_log format ["[RECONDO_SOIL]   Marker prefix: '%1' (%2 areas)", _markerPrefix, count _markerAreas];
    diag_log format ["[RECONDO_SOIL]   Objective: %1 (%2 samples per location)", _objectiveName, _samplesRequired];
    diag_log format ["[RECONDO_SOIL]   Objectives tracked: %1", count (keys _objectives)];
};

diag_log format ["[RECONDO_SOIL] Module initialized. Required: %1, Reward: %2, Cooldown: %3s, Objectives: %4", _requiredItem, _rewardItem, _cooldownSeconds, count (keys _objectives)];
