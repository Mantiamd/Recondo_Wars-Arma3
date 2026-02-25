/*
    Recondo_fnc_collectMetrics
    
    Description:
        Collects all performance metrics and returns them as a hashmap.
        Gathers data on FPS, units, objects, scripts, and more.
        
    Parameters:
        None
        
    Returns:
        HashMap containing all collected metrics
        
    Metrics Collected:
        Frame Rate:     fps, fpsMin
        Units:          players, localAI, remoteAI, totalUnitsAlive, totalUnits
        Groups:         groups
        Vehicles:       vehicles, emptyVehicles
        Objects:        triggers, allObjects, entities, deadBodies
        Scripts:        scriptsSpawn, scriptsExecVM, scriptsExec, scriptsFSM, scriptsTotal
        Markers:        markers
        Waypoints:      waypoints
        Simulation:     simDisabled
        Machine:        machineType, headlessClients
        
    Author: GoonSix
*/

private _metrics = createHashMap;

// ========================================
// TIMESTAMP
// ========================================
_metrics set ["timestamp", CBA_missionTime];
_metrics set ["realTime", systemTime];

// ========================================
// FRAME RATE METRICS
// ========================================
_metrics set ["fps", round diag_fps];
_metrics set ["fpsMin", round diag_fpsmin];

// ========================================
// UNIT METRICS
// ========================================
private _allUnits = allUnits;
private _aliveUnits = _allUnits select {alive _x};

private _players = {isPlayer _x} count _aliveUnits;
private _localAI = {local _x && !isPlayer _x} count _aliveUnits;
private _remoteAI = (count _aliveUnits) - _players - _localAI;

_metrics set ["players", _players];
_metrics set ["localAI", _localAI];
_metrics set ["remoteAI", _remoteAI];
_metrics set ["totalUnitsAlive", count _aliveUnits];
_metrics set ["totalUnits", count _allUnits];

// ========================================
// GROUP METRICS
// ========================================
private _allGroups = allGroups;
_metrics set ["groups", count _allGroups];

// Count groups by side
private _groupsByide = createHashMap;
{
    private _side = side _x;
    private _sideStr = str _side;
    private _count = _groupsByide getOrDefault [_sideStr, 0];
    _groupsByide set [_sideStr, _count + 1];
} forEach _allGroups;
_metrics set ["groupsBySide", _groupsByide];

// ========================================
// VEHICLE METRICS
// ========================================
private _allVehicles = vehicles;
private _emptyVehicles = {crew _x isEqualTo []} count _allVehicles;

_metrics set ["vehicles", count _allVehicles];
_metrics set ["emptyVehicles", _emptyVehicles];

// ========================================
// OBJECT METRICS
// ========================================
_metrics set ["triggers", count allMissionObjects "EmptyDetector"];
_metrics set ["allObjects", count allMissionObjects "All"];
_metrics set ["entities", count entities "All"];

// ========================================
// DEAD BODIES (Performance Impact)
// ========================================
_metrics set ["deadBodies", count allDeadMen];

// ========================================
// ACTIVE SCRIPTS
// ========================================
private _activeScripts = diag_activeScripts;

_metrics set ["scriptsSpawn", _activeScripts select 0];
_metrics set ["scriptsExecVM", _activeScripts select 1];
_metrics set ["scriptsExec", _activeScripts select 2];
_metrics set ["scriptsFSM", _activeScripts select 3];
_metrics set ["scriptsTotal", 
    (_activeScripts select 0) + 
    (_activeScripts select 1) + 
    (_activeScripts select 2) + 
    (_activeScripts select 3)
];

// ========================================
// MARKERS
// ========================================
_metrics set ["markers", count allMapMarkers];

// ========================================
// WAYPOINTS
// ========================================
private _waypointCount = 0;
{
    _waypointCount = _waypointCount + count waypoints _x;
} forEach _allGroups;
_metrics set ["waypoints", _waypointCount];

// ========================================
// SIMULATION STATE
// ========================================
_metrics set ["simDisabled", {!simulationEnabled _x} count _aliveUnits];

// ========================================
// MACHINE INFORMATION
// ========================================
private _machineType = if (isDedicated) then {
    "Dedicated Server"
} else {
    if (isServer) then {
        "Hosted Server"
    } else {
        "Client"
    }
};
_metrics set ["machineType", _machineType];

// Headless clients
_metrics set ["headlessClients", count entities "HeadlessClient_F"];

// ========================================
// NETWORK INFO (Server Only)
// ========================================
if (isServer) then {
    _metrics set ["connectedPlayers", count (allPlayers - entities "HeadlessClient_F")];
};

// Return metrics
_metrics
