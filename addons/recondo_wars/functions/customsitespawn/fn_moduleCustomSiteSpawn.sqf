/*
    Recondo_fnc_moduleCustomSiteSpawn
    Main initialization for Custom Site Spawn module
    
    Description:
        Spawns custom compositions from mission folder at randomly selected
        map markers. Supports garrison AI, patrols, night lights, persistence,
        and both immediate and proximity-based spawning.
    
    Parameters:
        _logic - Module logic object
        _units - Synchronized units (unused)
        _activated - Whether module is activated
*/

params ["_logic", "_units", "_activated"];

if (!isServer) exitWith {};

if (!_activated) exitWith {
    diag_log "[RECONDO_CSS] Module not activated.";
};

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

private _siteName = _logic getVariable ["sitename", "Custom Site"];
private _markerPrefix = _logic getVariable ["markerprefix", "SITE_"];
private _activeCount = _logic getVariable ["activecount", 3];
private _enablePersistence = _logic getVariable ["enablepersistence", true];

private _compositionPath = _logic getVariable ["compositionpath", "compositions"];
private _compositionListRaw = _logic getVariable ["compositionlist", ""];
private _clearRadius = _logic getVariable ["clearradius", 25];
private _disableSimulation = _logic getVariable ["disablesimulation", true];

private _spawnMode = _logic getVariable ["spawnmode", 0];
private _triggerRadius = _logic getVariable ["triggerradius", 800];
private _triggerSideNum = _logic getVariable ["triggerside", 1];

private _garrisonClassnamesRaw = _logic getVariable ["garrisonclassnames", ""];
private _garrisonCount = _logic getVariable ["garrisoncount", 4];
private _garrisonSideNum = _logic getVariable ["garrisonside", 0];

private _enablePatrols = _logic getVariable ["enablepatrols", false];
private _patrolClassnamesRaw = _logic getVariable ["patrolclassnames", ""];
private _patrolCount = _logic getVariable ["patrolcount", 1];
private _patrolSize = _logic getVariable ["patrolsize", 3];
private _patrolRadius = _logic getVariable ["patrolradius", 75];
private _patrolFormation = _logic getVariable ["patrolformation", "WEDGE"];

private _enableNightLights = _logic getVariable ["enablenightlights", true];

private _debugLogging = _logic getVariable ["debuglogging", false];
private _debugMarkers = _logic getVariable ["debugmarkers", false];

// ========================================
// PARSE CONFIGURATIONS
// ========================================

private _compositionList = if (_compositionListRaw != "") then {
    ((_compositionListRaw splitString (toString [10, 13] + ",")) apply { _x trim [" ", 0] }) select { _x != "" && !(_x select [0, 2] == "//") }
} else { [] };

if (count _compositionList == 0) exitWith {
    diag_log format ["[RECONDO_CSS] ERROR: No compositions specified for '%1'. Add at least one composition filename.", _siteName];
};

private _garrisonClassnames = if (_garrisonClassnamesRaw != "") then {
    [_garrisonClassnamesRaw] call Recondo_fnc_parseClassnames
} else { [] };

private _patrolClassnames = if (_patrolClassnamesRaw != "") then {
    [_patrolClassnamesRaw] call Recondo_fnc_parseClassnames
} else {
    +_garrisonClassnames
};

// Convert sides
private _triggerSide = switch (_triggerSideNum) do {
    case 0: { "EAST" };
    case 1: { "WEST" };
    case 2: { "GUER" };
    case 3: { "ANY" };
    default { "WEST" };
};

private _garrisonSide = switch (_garrisonSideNum) do {
    case 0: { east };
    case 1: { west };
    case 2: { independent };
    default { east };
};

// ========================================
// GENERATE INSTANCE ID
// ========================================

private _instanceId = format ["css_%1_%2", _siteName, count RECONDO_CSS_INSTANCES];

// ========================================
// STORE SETTINGS
// ========================================

private _settings = createHashMapFromArray [
    ["instanceId", _instanceId],
    ["siteName", _siteName],
    ["markerPrefix", _markerPrefix],
    ["activeCount", _activeCount],
    ["enablePersistence", _enablePersistence],
    ["compositionPath", _compositionPath],
    ["compositionList", _compositionList],
    ["clearRadius", _clearRadius],
    ["disableSimulation", _disableSimulation],
    ["spawnMode", _spawnMode],
    ["triggerRadius", _triggerRadius],
    ["triggerSide", _triggerSide],
    ["garrisonClassnames", _garrisonClassnames],
    ["garrisonCount", _garrisonCount],
    ["garrisonSide", _garrisonSide],
    ["enablePatrols", _enablePatrols],
    ["patrolClassnames", _patrolClassnames],
    ["patrolCount", _patrolCount],
    ["patrolSize", _patrolSize],
    ["patrolRadius", _patrolRadius],
    ["patrolFormation", _patrolFormation],
    ["enableNightLights", _enableNightLights],
    ["debugLogging", _debugLogging],
    ["debugMarkers", _debugMarkers]
];

RECONDO_CSS_INSTANCES pushBack _settings;
publicVariable "RECONDO_CSS_INSTANCES";

// ========================================
// FIND ALL MATCHING MARKERS
// ========================================

private _allMarkers = allMapMarkers select {
    _x select [0, count _markerPrefix] == _markerPrefix
};

if (count _allMarkers == 0) exitWith {
    diag_log format ["[RECONDO_CSS] ERROR: No markers found with prefix '%1' for '%2'.", _markerPrefix, _siteName];
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_CSS] Found %1 markers with prefix '%2'", count _allMarkers, _markerPrefix];
};

// ========================================
// SELECT OR LOAD MARKERS
// ========================================

private _selectedMarkers = [];
private _compositionMap = createHashMap;

private _persistenceKey = format ["CSS_%1", _siteName];

if (_enablePersistence) then {
    private _savedMarkers = [_persistenceKey + "_MARKERS"] call Recondo_fnc_getSaveData;
    private _savedCompMap = [_persistenceKey + "_COMPMAP"] call Recondo_fnc_getSaveData;
    
    if (!isNil "_savedMarkers" && {_savedMarkers isEqualType [] && {count _savedMarkers > 0}}) then {
        _selectedMarkers = _savedMarkers;
        _compositionMap = if (!isNil "_savedCompMap" && {_savedCompMap isEqualType createHashMap}) then { _savedCompMap } else { createHashMap };
        
        if (_debugLogging) then {
            diag_log format ["[RECONDO_CSS] Loaded %1 saved markers for '%2'", count _selectedMarkers, _siteName];
        };
    };
};

if (count _selectedMarkers == 0) then {
    private _shuffled = +_allMarkers;
    _shuffled = _shuffled call BIS_fnc_arrayShuffle;
    
    private _count = _activeCount min (count _shuffled);
    _selectedMarkers = _shuffled select [0, _count];
    
    {
        _compositionMap set [_x, selectRandom _compositionList];
    } forEach _selectedMarkers;
    
    if (_enablePersistence) then {
        [_persistenceKey + "_MARKERS", _selectedMarkers] call Recondo_fnc_setSaveData;
        [_persistenceKey + "_COMPMAP", _compositionMap] call Recondo_fnc_setSaveData;
        saveMissionProfileNamespace;
    };
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_CSS] Selected %1 of %2 markers for '%3'", count _selectedMarkers, count _allMarkers, _siteName];
    };
};

// ========================================
// SPAWN OR CREATE TRIGGERS
// ========================================

{
    private _markerId = _x;
    private _composition = _compositionMap getOrDefault [_markerId, selectRandom _compositionList];
    
    if (_spawnMode == 0) then {
        [_settings, _markerId, _composition] call Recondo_fnc_spawnCustomSite;
    } else {
        [_settings, _markerId, _composition] call Recondo_fnc_createCustomSiteTrigger;
    };
    
    if (_debugMarkers) then {
        private _markerPos = getMarkerPos _markerId;
        private _debugMkr = createMarker [format ["RECONDO_CSS_DEBUG_%1", _markerId], _markerPos];
        _debugMkr setMarkerShape "ICON";
        _debugMkr setMarkerType "mil_dot";
        _debugMkr setMarkerColor "ColorGreen";
        _debugMkr setMarkerText format ["%1 - %2", _siteName, _composition];
    };
} forEach _selectedMarkers;

// ========================================
// START NIGHT LIGHT LOOP
// ========================================

if (_enableNightLights && !RECONDO_CSS_NIGHT_LIGHT_LOOP_STARTED) then {
    RECONDO_CSS_NIGHT_LIGHTS_ENABLED = true;
    publicVariable "RECONDO_CSS_NIGHT_LIGHTS_ENABLED";
    
    RECONDO_CSS_NIGHT_LIGHT_LOOP_STARTED = true;
    [] call Recondo_fnc_updateCustomSiteNightLights;
    
    if (_debugLogging) then {
        diag_log "[RECONDO_CSS] Night light update loop started";
    };
};

// ========================================
// LOG INITIALIZATION
// ========================================

diag_log format ["[RECONDO_CSS] '%1' initialized: %2 sites, Spawn: %3, Persistence: %4",
    _siteName, count _selectedMarkers,
    if (_spawnMode == 0) then { "Immediate" } else { "Proximity" },
    _enablePersistence];

if (_debugLogging) then {
    diag_log "[RECONDO_CSS] === Custom Site Spawn Settings ===";
    diag_log format ["[RECONDO_CSS] Instance ID: %1", _instanceId];
    diag_log format ["[RECONDO_CSS] Marker Prefix: %1", _markerPrefix];
    diag_log format ["[RECONDO_CSS] Compositions: %1", _compositionList];
    diag_log format ["[RECONDO_CSS] Composition Path: %1", _compositionPath];
    diag_log format ["[RECONDO_CSS] Garrison: %1 units (%2 classnames)", _garrisonCount, count _garrisonClassnames];
    diag_log format ["[RECONDO_CSS] Patrols: %1 (count: %2, size: %3, radius: %4m)", _enablePatrols, _patrolCount, _patrolSize, _patrolRadius];
    diag_log format ["[RECONDO_CSS] Selected Markers: %1", _selectedMarkers];
};
