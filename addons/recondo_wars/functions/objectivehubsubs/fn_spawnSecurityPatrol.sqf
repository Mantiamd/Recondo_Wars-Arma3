/*
    Recondo_fnc_spawnSecurityPatrol
    Spawns security patrol groups that patrol between hub and sub-sites
    
    Description:
        Creates patrol groups that travel between the hub and its sub-sites
        in a random order, pausing briefly at each location. Loops indefinitely.
    
    Parameters:
        _settings - HASHMAP - Module settings
        _hubPos - ARRAY - Hub position
        _hubMarker - STRING - Hub marker name
    
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [
    ["_settings", nil, [createHashMap]],
    ["_hubPos", [0,0,0], [[]]],
    ["_hubMarker", "", [""]]
];

if (isNil "_settings" || _hubMarker == "") exitWith {
    diag_log "[RECONDO_HUBSUBS] ERROR: Invalid parameters for spawnSecurityPatrol";
};

// Get settings
private _hubAISide = _settings get "hubAISide";
private _hubSentryClassnames = _settings get "hubSentryClassnames";
private _patrolCount = _settings get "securityPatrolCount";
private _patrolMin = _settings get "securityPatrolMin";
private _patrolMax = _settings get "securityPatrolMax";
private _pauseMin = _settings get "securityPatrolPauseMin";
private _pauseMax = _settings get "securityPatrolPauseMax";
private _behaviour = _settings get "securityPatrolBehaviour";
private _speed = _settings get "securityPatrolSpeed";
private _formation = _settings get "securityPatrolFormation";
private _simulationDistance = _settings get "simulationDistance";
private _debugLogging = _settings get "debugLogging";
private _instanceId = _settings get "instanceId";

// Validate classnames
if (count _hubSentryClassnames == 0) exitWith {
    if (_debugLogging) then {
        diag_log format ["[RECONDO_HUBSUBS] No sentry classnames defined, skipping security patrol for %1", _hubMarker];
    };
};

// Get sub-site markers for this hub from the active hubs list
private _subSiteMarkers = [];
{
    _x params ["_instId", "_marker", "_comp", "_subMarkers", "_destroyed"];
    if (_instId == _instanceId && _marker == _hubMarker) exitWith {
        _subSiteMarkers = _subMarkers;
    };
} forEach RECONDO_HUBSUBS_ACTIVE;

// Build list of patrol positions (hub + sub-sites)
private _patrolPositions = [_hubPos];
{
    private _subPos = getMarkerPos _x;
    if !(_subPos isEqualTo [0,0,0]) then {
        _patrolPositions pushBack _subPos;
    };
} forEach _subSiteMarkers;

if (_debugLogging) then {
    diag_log format ["[RECONDO_HUBSUBS] Security patrol positions for %1: %2 locations (hub + %3 sub-sites)", 
        _hubMarker, count _patrolPositions, count _subSiteMarkers];
};

// Spawn patrol groups
for "_i" from 1 to _patrolCount do {
    // Calculate group size
    private _groupSize = _patrolMin + floor random ((_patrolMax - _patrolMin) + 1);
    _groupSize = _groupSize max 1;
    
    // Create group
    private _group = createGroup [_hubAISide, true];
    if (isNull _group) then {
        diag_log format ["[RECONDO_HUBSUBS] ERROR: Failed to create security patrol group %1 for %2", _i, _hubMarker];
        continue;
    };
    
    // Create units at hub position
    private _unitsCreated = 0;
    for "_u" from 1 to _groupSize do {
        private _class = selectRandom _hubSentryClassnames;
        if (isClass (configFile >> "CfgVehicles" >> _class)) then {
            private _unit = _group createUnit [_class, _hubPos, [], 5, "NONE"];
            if (!isNull _unit) then {
                _unitsCreated = _unitsCreated + 1;
            };
        };
    };
    
    if (_unitsCreated == 0) then {
        deleteGroup _group;
        diag_log format ["[RECONDO_HUBSUBS] ERROR: Failed to create any units for security patrol %1 at %2", _i, _hubMarker];
        continue;
    };
    
    // Set group behavior
    _group setFormation _formation;
    _group setBehaviour _behaviour;
    _group setSpeedMode _speed;
    _group setCombatMode "YELLOW";
    
    // Shuffle patrol positions for random order
    private _shuffledPositions = +_patrolPositions;
    _shuffledPositions = _shuffledPositions call BIS_fnc_arrayShuffle;
    
    // Create waypoints
    private _waypointIndex = 0;
    {
        private _wp = _group addWaypoint [_x, 10];
        _wp setWaypointType "MOVE";
        _wp setWaypointBehaviour _behaviour;
        _wp setWaypointSpeed _speed;
        _wp setWaypointFormation _formation;
        _wp setWaypointCompletionRadius 15;
        
        // Set pause timeout at each location
        _wp setWaypointTimeout [_pauseMin, (_pauseMin + _pauseMax) / 2, _pauseMax];
        
        _waypointIndex = _waypointIndex + 1;
    } forEach _shuffledPositions;
    
    // Add cycle waypoint to loop back to the first waypoint
    private _cycleWp = _group addWaypoint [_shuffledPositions select 0, 10];
    _cycleWp setWaypointType "CYCLE";
    
    // Register with centralized simulation monitoring system
    if (_simulationDistance > 0) then {
        [{
            params ["_group", "_hubMarker", "_i", "_hubPos", "_simulationDistance", "_debugLogging"];
            if (!isNull _group && {count units _group > 0}) then {
                private _aliveUnits = units _group select { alive _x };
                if (count _aliveUnits > 0) then {
                    private _identifier = format ["HUBSUBS_PATROL_%1_%2", _hubMarker, _i];
                    [_identifier, _aliveUnits, _hubPos, _simulationDistance] call Recondo_fnc_registerSimulation;
                    
                    if (_debugLogging) then {
                        diag_log format ["[RECONDO_HUBSUBS] Registered %1 patrol units with simulation system at distance %2m for %3", 
                            count _aliveUnits, _simulationDistance, _hubMarker];
                    };
                };
            };
        }, [_group, _hubMarker, _i, _hubPos, _simulationDistance, _debugLogging], 2] call CBA_fnc_waitAndExecute;
    };
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_HUBSUBS] Created security patrol %1 for %2: %3 units, %4 waypoints, pause: %5-%6s", 
            _i, _hubMarker, _unitsCreated, count _shuffledPositions, _pauseMin, _pauseMax];
    };
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_HUBSUBS] Spawned %1 security patrol(s) for hub %2", _patrolCount, _hubMarker];
};
