/*
    Recondo_fnc_moduleConvoySystem
    Main module initialization for Convoy System
    
    Description:
        Initializes the convoy system which spawns enemy convoys
        that travel from a start marker to active objectives and
        then to an end marker where they are deleted.
        
        SYNC-BASED ROUTING:
        - Sync this module to objective modules (HVT, Hostages, Destroy, Hubs)
          to route convoys to those objective locations.
        - If not synced to any objective module, convoys travel directly
          from start marker to end marker.
        - For HVT and Hostages, convoys also route to decoy locations.
    
    Parameters:
        0: OBJECT - Logic module
        1: ARRAY - Synced units (unused)
        2: BOOL - Is activated
        
    Returns:
        Nothing
*/

params ["_logic", "_units", "_activated"];

// Only run on server
if (!isServer) exitWith {};

// Build settings hashmap from module attributes
private _settings = createHashMap;

// General Settings
_settings set ["convoySide", _logic getVariable ["convoyside", "EAST"]];
_settings set ["maxActive", _logic getVariable ["maxactive", 2]];
_settings set ["spawnDelayMin", _logic getVariable ["spawndelaymin", 1500]];
_settings set ["spawnDelayMax", _logic getVariable ["spawndelaymax", 2100]];
_settings set ["timeout", _logic getVariable ["timeout", 45]];

// Marker Settings
_settings set ["startMarker", _logic getVariable ["startmarker", "CONVOY_START"]];
_settings set ["endMarker", _logic getVariable ["endmarker", "CONVOY_END"]];
_settings set ["dirMarkerSuffix", _logic getVariable ["dirmarkersuffix", "_DIR"]];
_settings set ["waypointPrefix", _logic getVariable ["waypointprefix", "CONVOY"]];

// Vehicle Settings
private _vehicleClassnamesStr = _logic getVariable ["vehicleclassnames", ""];
private _vehicleClassnames = [_vehicleClassnamesStr] call Recondo_fnc_parseClassnames;
_settings set ["vehicleClassnames", _vehicleClassnames];
_settings set ["minVehicles", _logic getVariable ["minvehicles", 2]];
_settings set ["maxVehicles", _logic getVariable ["maxvehicles", 4]];

// Crew Settings
private _driverClassnamesStr = _logic getVariable ["driverclassnames", ""];
private _driverClassnames = [_driverClassnamesStr] call Recondo_fnc_parseClassnames;
_settings set ["driverClassnames", _driverClassnames];

private _gunnerClassnamesStr = _logic getVariable ["gunnerclassnames", ""];
private _gunnerClassnames = [_gunnerClassnamesStr] call Recondo_fnc_parseClassnames;
_settings set ["gunnerClassnames", _gunnerClassnames];

private _cargoClassnamesStr = _logic getVariable ["cargoclassnames", ""];
private _cargoClassnames = [_cargoClassnamesStr] call Recondo_fnc_parseClassnames;
_settings set ["cargoClassnames", _cargoClassnames];
_settings set ["fillCargo", _logic getVariable ["fillcargo", true]];

// Vehicle Cargo Settings
_settings set ["clearVehicleInventory", _logic getVariable ["clearvehicleinventory", true]];
private _vehicleCargoStr = _logic getVariable ["vehiclecargoclassnames", ""];
private _vehicleCargoItems = [_vehicleCargoStr] call Recondo_fnc_parseClassnames;
_settings set ["vehicleCargoItems", _vehicleCargoItems];

// Convoy Behavior Settings
_settings set ["maxSpeed", _logic getVariable ["maxspeed", 40]];
_settings set ["separation", _logic getVariable ["separation", 25]];
_settings set ["stopAtObjective", _logic getVariable ["stopatobjective", true]];
_settings set ["stopDuration", _logic getVariable ["stopduration", 30]];

// Speed Control Settings
_settings set ["stiffness", _logic getVariable ["stiffness", 0.2]];
_settings set ["damping", _logic getVariable ["damping", 0.6]];
_settings set ["curvature", _logic getVariable ["curvature", 0.3]];
_settings set ["linkStiffness", _logic getVariable ["linkstiffness", 0.1]];
_settings set ["pathFreq", _logic getVariable ["pathfreq", 0.05]];
_settings set ["speedFreq", _logic getVariable ["speedfreq", 0.2]];

// Debug Settings
_settings set ["debugLogging", _logic getVariable ["debuglogging", false]];
if (RECONDO_MASTER_DEBUG) then { _settings set ["debugLogging", true]; };
_settings set ["debugMarkers", _logic getVariable ["debugmarkers", false]];

private _debugLogging = _settings get "debugLogging";

// ========================================
// SYNC-BASED OBJECTIVE ROUTING
// ========================================
// Detect synced objective modules and store their instance IDs

private _syncedObjects = synchronizedObjects _logic;

private _syncedHVTInstances = [];
private _syncedHostageInstances = [];
private _syncedDestroyInstances = [];
private _syncedHubInstances = [];

{
    private _syncedClass = typeOf _x;
    
    switch (_syncedClass) do {
        case "Recondo_Module_ObjectiveHVT": {
            // Get the instance ID from the synced module
            private _instanceId = _x getVariable ["instanceId", ""];
            if (_instanceId != "") then {
                _syncedHVTInstances pushBack _instanceId;
            };
        };
        case "Recondo_Module_ObjectiveHostages": {
            private _instanceId = _x getVariable ["instanceId", ""];
            if (_instanceId != "") then {
                _syncedHostageInstances pushBack _instanceId;
            };
        };
        case "Recondo_Module_ObjectiveDestroy": {
            private _instanceId = _x getVariable ["instanceId", ""];
            if (_instanceId != "") then {
                _syncedDestroyInstances pushBack _instanceId;
            };
        };
        case "Recondo_Module_ObjectiveHubSubs": {
            private _instanceId = _x getVariable ["instanceId", ""];
            if (_instanceId != "") then {
                _syncedHubInstances pushBack _instanceId;
            };
        };
    };
} forEach _syncedObjects;

// Store synced instances in settings
_settings set ["syncedHVTInstances", _syncedHVTInstances];
_settings set ["syncedHostageInstances", _syncedHostageInstances];
_settings set ["syncedDestroyInstances", _syncedDestroyInstances];
_settings set ["syncedHubInstances", _syncedHubInstances];

// Determine if we have any synced objectives
private _hasSyncedObjectives = (count _syncedHVTInstances > 0) || 
                               (count _syncedHostageInstances > 0) || 
                               (count _syncedDestroyInstances > 0) || 
                               (count _syncedHubInstances > 0);

_settings set ["hasSyncedObjectives", _hasSyncedObjectives];

// Validate required settings
if (count _vehicleClassnames == 0) exitWith {
    diag_log "[RECONDO_CONVOY] ERROR: No vehicle classnames specified. Module disabled.";
};

if (count _cargoClassnames == 0 && count _driverClassnames == 0) exitWith {
    diag_log "[RECONDO_CONVOY] ERROR: No crew classnames specified. Module disabled.";
};

// Validate markers
private _startMarker = _settings get "startMarker";
private _endMarker = _settings get "endMarker";

if (getMarkerColor _startMarker == "") exitWith {
    diag_log format ["[RECONDO_CONVOY] ERROR: Start marker '%1' not found. Module disabled.", _startMarker];
};

if (getMarkerColor _endMarker == "") exitWith {
    diag_log format ["[RECONDO_CONVOY] ERROR: End marker '%1' not found. Module disabled.", _endMarker];
};

// ========================================
// CLEAR TERRAIN AT CONVOY MARKERS
// ========================================
// Remove trees, bushes, and rocks in a 50m radius (100m diameter) around start and end markers
// This gives convoys room to maneuver and turn around

private _clearRadius = 50;
private _markersToClear = [_startMarker, _endMarker];

{
    private _markerName = _x;
    private _markerPos = getMarkerPos _markerName;
    
    // Get all terrain objects in the area (trees, bushes, rocks)
    private _terrainObjects = nearestTerrainObjects [_markerPos, ["TREE", "SMALL TREE", "BUSH", "ROCK", "ROCKS"], _clearRadius, false, true];
    
    // Hide all terrain objects
    {
        _x hideObjectGlobal true;
    } forEach _terrainObjects;
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_CONVOY] Cleared %1 terrain objects within %2m of marker '%3'", count _terrainObjects, _clearRadius, _markerName];
    };
} forEach _markersToClear;

// Store settings globally
RECONDO_CONVOY_SETTINGS = _settings;
publicVariable "RECONDO_CONVOY_SETTINGS";

// Initialize active convoys array
RECONDO_CONVOY_ACTIVE = [];
publicVariable "RECONDO_CONVOY_ACTIVE";

if (_debugLogging) then {
    diag_log "[RECONDO_CONVOY] ========================================";
    diag_log "[RECONDO_CONVOY] Convoy System Initializing";
    diag_log format ["[RECONDO_CONVOY] Side: %1", _settings get "convoySide"];
    diag_log format ["[RECONDO_CONVOY] Max Active: %1", _settings get "maxActive"];
    diag_log format ["[RECONDO_CONVOY] Spawn Delay: %1-%2s", _settings get "spawnDelayMin", _settings get "spawnDelayMax"];
    diag_log format ["[RECONDO_CONVOY] Vehicles: %1 (%2-%3 per convoy)", count _vehicleClassnames, _settings get "minVehicles", _settings get "maxVehicles"];
    diag_log format ["[RECONDO_CONVOY] Start Marker: %1", _startMarker];
    diag_log format ["[RECONDO_CONVOY] End Marker: %1", _endMarker];
    diag_log format ["[RECONDO_CONVOY] Direction Marker Suffix: %1 (looks for '%2')", _settings get "dirMarkerSuffix", _startMarker + (_settings get "dirMarkerSuffix")];
    diag_log "[RECONDO_CONVOY] --- Synced Objectives ---";
    diag_log format ["[RECONDO_CONVOY] HVT Instances: %1", _syncedHVTInstances];
    diag_log format ["[RECONDO_CONVOY] Hostage Instances: %1", _syncedHostageInstances];
    diag_log format ["[RECONDO_CONVOY] Destroy Instances: %1", _syncedDestroyInstances];
    diag_log format ["[RECONDO_CONVOY] Hub Instances: %1", _syncedHubInstances];
    if (!_hasSyncedObjectives) then {
        diag_log "[RECONDO_CONVOY] No objectives synced - convoys will travel direct route (Start -> End)";
    };
    diag_log "[RECONDO_CONVOY] ========================================";
};

// Start the convoy spawn loop
RECONDO_CONVOY_SPAWN_LOOP_HANDLE = [_settings] spawn Recondo_fnc_convoySpawnLoop;

// Start the cleanup loop
RECONDO_CONVOY_CLEANUP_HANDLE = [_settings] spawn Recondo_fnc_convoyCleanup;

diag_log "[RECONDO_CONVOY] Module initialized successfully";
