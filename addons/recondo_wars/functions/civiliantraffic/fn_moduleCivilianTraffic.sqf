/*
    Recondo_fnc_moduleCivilianTraffic
    Main initialization for Civilian Traffic module
    
    Description:
        Creates ambient civilian vehicle traffic within defined marker zones.
        Vehicles spawn on roads when players approach, drive to random destinations,
        park briefly, then continue driving. Despawns when no players are nearby.
    
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
    diag_log "[RECONDO_CIVTRAFFIC] Module not activated.";
};

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

// General Settings
private _markerPrefix = _logic getVariable ["markerprefix", "CIVTRAFFIC_"];

// Spawn Settings
private _maxVehicles = _logic getVariable ["maxvehicles", 5];
private _triggerRadius = _logic getVariable ["triggerradius", 800];
private _spawnRadius = _logic getVariable ["spawnradius", 600];

// Unit Settings
private _civilianClassnamesRaw = _logic getVariable ["civilianclassnames", ""];
private _vehicleClassnamesRaw = _logic getVariable ["vehicleclassnames", ""];

// Behavior Settings
private _speedMode = _logic getVariable ["speedmode", "LIMITED"];
private _parkDurationMin = _logic getVariable ["parkdurationmin", 30];
private _parkDurationMax = _logic getVariable ["parkdurationmax", 120];
private _arrivalDistance = _logic getVariable ["arrivaldistance", 30];
private _earlyStopDistance = _logic getVariable ["earlystopdistance", 100];
private _fleeOnPlayerEnter = _logic getVariable ["fleeonplayerenter", true];
private _cowerUnderFire = _logic getVariable ["cowerunderfire", true];

// Performance Settings
private _spawnDelay = _logic getVariable ["spawndelay", 5];
private _despawnDelay = _logic getVariable ["despawndelay", 10];

// Debug Settings
private _debugLogging = _logic getVariable ["debuglogging", false];
if (RECONDO_MASTER_DEBUG) then { _debugLogging = true; };
private _debugMarkers = _logic getVariable ["debugmarkers", false];

// ========================================
// PARSE CLASSNAME LISTS
// ========================================

private _civilianClassnames = [_civilianClassnamesRaw] call Recondo_fnc_parseClassnames;
private _vehicleClassnames = [_vehicleClassnamesRaw] call Recondo_fnc_parseClassnames;

// Validate required settings
if (count _civilianClassnames == 0) exitWith {
    diag_log "[RECONDO_CIVTRAFFIC] ERROR: No civilian classnames specified. Module disabled.";
};

if (count _vehicleClassnames == 0) exitWith {
    diag_log "[RECONDO_CIVTRAFFIC] ERROR: No vehicle classnames specified. Module disabled.";
};

// ========================================
// STORE SETTINGS
// ========================================

RECONDO_CIVTRAFFIC_SETTINGS = createHashMapFromArray [
    ["markerPrefix", toUpper _markerPrefix],
    ["maxVehicles", _maxVehicles],
    ["triggerRadius", _triggerRadius],
    ["spawnRadius", _spawnRadius],
    ["civilianClassnames", _civilianClassnames],
    ["vehicleClassnames", _vehicleClassnames],
    ["speedMode", _speedMode],
    ["parkDurationMin", _parkDurationMin],
    ["parkDurationMax", _parkDurationMax],
    ["arrivalDistance", _arrivalDistance],
    ["earlyStopDistance", _earlyStopDistance],
    ["fleeOnPlayerEnter", _fleeOnPlayerEnter],
    ["cowerUnderFire", _cowerUnderFire],
    ["spawnDelay", _spawnDelay],
    ["despawnDelay", _despawnDelay],
    ["debugLogging", _debugLogging],
    ["debugMarkers", _debugMarkers]
];
publicVariable "RECONDO_CIVTRAFFIC_SETTINGS";

// ========================================
// FIND AND PROCESS MARKERS
// ========================================

private _markerPrefixUpper = toUpper _markerPrefix;
private _zonesCreated = 0;

{
    private _markerName = _x;
    private _markerNameUpper = toUpper _markerName;
    
    if (_markerNameUpper find _markerPrefixUpper == 0) then {
        // Create traffic zone for this marker
        [_markerName] call Recondo_fnc_createTrafficZone;
        _zonesCreated = _zonesCreated + 1;
        
        if (_debugLogging) then {
            diag_log format ["[RECONDO_CIVTRAFFIC] Created zone for marker: %1", _markerName];
        };
    };
} forEach allMapMarkers;

// ========================================
// LOG INITIALIZATION
// ========================================

if (_zonesCreated == 0) then {
    diag_log format ["[RECONDO_CIVTRAFFIC] WARNING: No markers found with prefix '%1'. No traffic zones created.", _markerPrefix];
} else {
    diag_log format ["[RECONDO_CIVTRAFFIC] Module initialized. Created %1 traffic zones.", _zonesCreated];
};

if (_debugLogging) then {
    diag_log "[RECONDO_CIVTRAFFIC] === Settings ===";
    diag_log format ["[RECONDO_CIVTRAFFIC] Marker Prefix: %1", _markerPrefix];
    diag_log format ["[RECONDO_CIVTRAFFIC] Max Vehicles per Zone: %1", _maxVehicles];
    diag_log format ["[RECONDO_CIVTRAFFIC] Trigger Radius: %1m, Spawn Radius: %2m", _triggerRadius, _spawnRadius];
    diag_log format ["[RECONDO_CIVTRAFFIC] Civilian Classes: %1", _civilianClassnames];
    diag_log format ["[RECONDO_CIVTRAFFIC] Vehicle Classes: %1", _vehicleClassnames];
    diag_log format ["[RECONDO_CIVTRAFFIC] Speed Mode: %1", _speedMode];
    diag_log format ["[RECONDO_CIVTRAFFIC] Park Duration: %1-%2s", _parkDurationMin, _parkDurationMax];
};
