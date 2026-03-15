/*
    Recondo_fnc_modulePOOSiteHunt
    Main initialization for POO Site Hunt module

    Description:
        Selects a configurable number of random artillery spawn sites from
        a pool of map markers. Each site is assigned a random target marker
        that it will fire towards. When a trigger side approaches, the
        artillery is spawned and begins firing. Destroyed sites are optionally
        persisted across restarts.

    Parameters:
        _logic     - Module logic object
        _units     - Synchronized units (unused)
        _activated - Whether module is activated
*/

params ["_logic", "_units", "_activated"];

if (!isServer) exitWith {};

if (!_activated) exitWith {
    diag_log "[RECONDO_POO] Module not activated.";
};

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

private _objectiveName     = _logic getVariable ["objectivename", "POO Site"];
private _pooMarkerPrefix   = _logic getVariable ["poomarkerprefix", "POO_"];
private _targetMarkerPrefix = _logic getVariable ["targetmarkerprefix", "ARTY_TGT_"];
private _numActiveSites    = parseNumber str (_logic getVariable ["numactivesites", 1]);
if (_numActiveSites < 1) then { _numActiveSites = 1 };
private _enablePersistence = _logic getVariable ["enablepersistence", false];

private _triggerSideStr    = _logic getVariable ["triggerside", "WEST"];
private _triggerRadius     = parseNumber str (_logic getVariable ["triggerradius", 800]);
private _terrainClearRadius = parseNumber str (_logic getVariable ["terrainclearradius", 15]);

private _weaponClassname   = _logic getVariable ["weaponclassname", "vn_o_pl_mortar_type63"];
private _crewClassname     = _logic getVariable ["crewclassname", "vn_o_men_nva_65_inf_02"];
private _crewSideStr       = _logic getVariable ["crewside", "EAST"];
private _firingInterval    = parseNumber str (_logic getVariable ["firinginterval", 5]);
private _invulnTime        = parseNumber str (_logic getVariable ["invulntime", 20]);

private _debugLogging      = _logic getVariable ["debuglogging", false];
private _debugMarkers      = _logic getVariable ["debugmarkers", false];

// ========================================
// CONVERT SIDES
// ========================================

private _triggerSide = switch (toUpper _triggerSideStr) do {
    case "EAST": { "EAST" };
    case "WEST": { "WEST" };
    case "GUER": { "GUER" };
    case "ANY":  { "ANY" };
    default      { "WEST" };
};

private _crewSide = switch (toUpper _crewSideStr) do {
    case "EAST":  { east };
    case "WEST":  { west };
    case "GUER":  { independent };
    default       { east };
};

// ========================================
// GENERATE UNIQUE INSTANCE ID
// ========================================

private _instanceId = format ["poo_%1_%2", _objectiveName, count RECONDO_POO_INSTANCES];

// ========================================
// STORE SETTINGS
// ========================================

private _settings = createHashMapFromArray [
    ["instanceId", _instanceId],
    ["objectiveName", _objectiveName],
    ["pooMarkerPrefix", _pooMarkerPrefix],
    ["targetMarkerPrefix", _targetMarkerPrefix],
    ["numActiveSites", _numActiveSites],
    ["enablePersistence", _enablePersistence],
    ["triggerSide", _triggerSide],
    ["triggerRadius", _triggerRadius],
    ["terrainClearRadius", _terrainClearRadius],
    ["weaponClassname", _weaponClassname],
    ["crewClassname", _crewClassname],
    ["crewSide", _crewSide],
    ["firingInterval", _firingInterval],
    ["invulnTime", _invulnTime],
    ["debugLogging", _debugLogging],
    ["debugMarkers", _debugMarkers]
];

RECONDO_POO_INSTANCES pushBack _settings;
publicVariable "RECONDO_POO_INSTANCES";

// ========================================
// FIND MARKERS BY PREFIX
// ========================================

private _allPOOMarkers = allMapMarkers select {
    (_x select [0, count _pooMarkerPrefix]) == _pooMarkerPrefix
};

private _allTargetMarkers = allMapMarkers select {
    (_x select [0, count _targetMarkerPrefix]) == _targetMarkerPrefix
};

if (count _allPOOMarkers == 0) exitWith {
    diag_log format ["[RECONDO_POO] ERROR: No markers found with prefix '%1'", _pooMarkerPrefix];
};

if (count _allTargetMarkers == 0) exitWith {
    diag_log format ["[RECONDO_POO] ERROR: No target markers found with prefix '%1'", _targetMarkerPrefix];
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_POO] Found %1 POO markers and %2 target markers", count _allPOOMarkers, count _allTargetMarkers];
};

// ========================================
// LOAD PERSISTENCE DATA
// ========================================

private _persistenceKey = format ["POO_%1_%2", _pooMarkerPrefix, _objectiveName];
private _savedActive = [];
private _savedTargets = [];
private _savedDestroyed = [];

if (_enablePersistence) then {
    _savedActive    = [_persistenceKey + "_ACTIVE"] call Recondo_fnc_getSaveData;
    _savedTargets   = [_persistenceKey + "_TARGETS"] call Recondo_fnc_getSaveData;
    _savedDestroyed = [_persistenceKey + "_DESTROYED"] call Recondo_fnc_getSaveData;

    if (isNil "_savedActive")    then { _savedActive = [] };
    if (isNil "_savedTargets")   then { _savedTargets = [] };
    if (isNil "_savedDestroyed") then { _savedDestroyed = [] };
};

// Merge destroyed list into global
{
    if (!(_x in RECONDO_POO_DESTROYED)) then {
        RECONDO_POO_DESTROYED pushBack _x;
    };
} forEach _savedDestroyed;
publicVariable "RECONDO_POO_DESTROYED";

// ========================================
// SELECT OR LOAD ACTIVE SITES
// ========================================

private _selectedMarkers = [];
private _targetAssignments = []; // parallel array: each entry is the target marker for the same-index POO marker

if (count _savedActive > 0 && _enablePersistence) then {
    _selectedMarkers   = _savedActive;
    _targetAssignments = _savedTargets;

    if (_debugLogging) then {
        diag_log format ["[RECONDO_POO] Loaded %1 saved active sites for '%2'", count _selectedMarkers, _objectiveName];
    };
} else {
    // Shuffle and pick N markers
    private _shuffled = _allPOOMarkers call BIS_fnc_arrayShuffle;
    private _count = (_numActiveSites min count _shuffled);
    _selectedMarkers = _shuffled select [0, _count];

    // Assign each site a random target marker
    {
        _targetAssignments pushBack (selectRandom _allTargetMarkers);
    } forEach _selectedMarkers;

    // Save to persistence
    if (_enablePersistence) then {
        [_persistenceKey + "_ACTIVE", _selectedMarkers] call Recondo_fnc_setSaveData;
        [_persistenceKey + "_TARGETS", _targetAssignments] call Recondo_fnc_setSaveData;
        [_persistenceKey + "_DESTROYED", []] call Recondo_fnc_setSaveData;
        saveMissionProfileNamespace;
    };

    if (_debugLogging) then {
        diag_log format ["[RECONDO_POO] Selected %1 active sites from %2 available", count _selectedMarkers, count _allPOOMarkers];
    };
};

// ========================================
// HIDE ALL POO MARKERS ON MAP
// ========================================

{
    _x setMarkerAlphaLocal 0;
} forEach _allPOOMarkers;

{
    _x setMarkerAlphaLocal 0;
} forEach _allTargetMarkers;

// ========================================
// CREATE TRIGGERS FOR SURVIVING SITES
// ========================================

{
    private _markerId = _x;
    private _targetMarker = _targetAssignments select _forEachIndex;

    if (_markerId in _savedDestroyed) then {
        if (_debugLogging) then {
            diag_log format ["[RECONDO_POO] Skipping destroyed site: %1", _markerId];
        };
        continue;
    };

    // Track as active
    RECONDO_POO_ACTIVE pushBack [_instanceId, _markerId, _targetMarker, "waiting"];

    [_settings, _markerId, _targetMarker] call Recondo_fnc_createPOOTrigger;

    // Create debug markers
    if (_debugMarkers) then {
        private _markerPos = getMarkerPos _markerId;

        private _dbgMarker = createMarker [format ["RECONDO_POO_DEBUG_%1", _markerId], _markerPos];
        _dbgMarker setMarkerShape "ICON";
        _dbgMarker setMarkerType "mil_warning";
        _dbgMarker setMarkerColor "ColorRed";
        _dbgMarker setMarkerText format ["POO: %1 -> %2", _markerId, _targetMarker];

        private _radiusMarker = createMarker [format ["RECONDO_POO_RADIUS_%1", _markerId], _markerPos];
        _radiusMarker setMarkerShape "ELLIPSE";
        _radiusMarker setMarkerBrush "Border";
        _radiusMarker setMarkerColor "ColorOrange";
        _radiusMarker setMarkerSize [_triggerRadius, _triggerRadius];
    };
} forEach _selectedMarkers;

publicVariable "RECONDO_POO_ACTIVE";

// ========================================
// LOG INITIALIZATION
// ========================================

private _activeCount = count _selectedMarkers - count _savedDestroyed;
diag_log format ["[RECONDO_POO] '%1' initialized: %2 active, %3 destroyed, Total selected: %4, Persistence: %5",
    _objectiveName, _activeCount, count _savedDestroyed, count _selectedMarkers, _enablePersistence];

if (_debugLogging) then {
    diag_log "[RECONDO_POO] === POO Site Hunt Settings ===";
    diag_log format ["[RECONDO_POO] Instance ID: %1", _instanceId];
    diag_log format ["[RECONDO_POO] POO Marker Prefix: %1 (%2 found)", _pooMarkerPrefix, count _allPOOMarkers];
    diag_log format ["[RECONDO_POO] Target Marker Prefix: %1 (%2 found)", _targetMarkerPrefix, count _allTargetMarkers];
    diag_log format ["[RECONDO_POO] Weapon: %1 | Crew: %2 | Side: %3", _weaponClassname, _crewClassname, _crewSideStr];
    diag_log format ["[RECONDO_POO] Firing Interval: %1s | Invuln: %2s", _firingInterval, _invulnTime];
    {
        private _markerId = _x;
        private _tgt = _targetAssignments select _forEachIndex;
        private _status = if (_markerId in _savedDestroyed) then { "DESTROYED" } else { "ACTIVE" };
        diag_log format ["[RECONDO_POO]   Site %1: %2 -> %3 [%4]", _forEachIndex + 1, _markerId, _tgt, _status];
    } forEach _selectedMarkers;
};
