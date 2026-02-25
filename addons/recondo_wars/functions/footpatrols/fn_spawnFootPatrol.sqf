/*
    Recondo_fnc_spawnFootPatrol
    Spawns and configures a patrol group with waypoints
    
    Description:
        Called when a patrol trigger is activated. Spawns a group of AI units
        with randomized composition, configures their behavior, and creates
        patrol waypoints in a circular pattern around the spawn position.
    
    Parameters:
        0: OBJECT - The trigger that was activated
        
    Returns:
        OBJECT - The spawned group, or grpNull on failure
        
    Example:
        [_trigger] call Recondo_fnc_spawnFootPatrol;
*/

if (!isServer) exitWith {
    diag_log "[RECONDO_FP] ERROR: Attempted to spawn group on non-server machine";
    grpNull
};

params ["_trigger"];

// Get settings from trigger
private _settings = _trigger getVariable ["RECONDO_FP_SETTINGS", RECONDO_FP_SETTINGS];
private _markerName = _trigger getVariable ["RECONDO_FP_MARKER", "unknown"];

private _debug = _settings get "enableDebug";
private _targetSide = _settings get "targetSide";
private _unitClassnames = _settings get "unitClassnames";
private _minGroupSize = _settings get "minGroupSize";
private _maxGroupSize = _settings get "maxGroupSize";
private _patrolRadius = _settings get "patrolRadius";
private _waypointCount = _settings get "waypointCount";
private _waypointPauseMin = _settings get "waypointPauseMin";
private _waypointPauseMax = _settings get "waypointPauseMax";
private _behaviour = _settings get "behaviour";
private _speedMode = _settings get "speedMode";
private _combatMode = _settings get "combatMode";
private _formation = _settings get "formation";
private _simulationDistance = _settings get "simulationDistance";
private _lambsReinforce = _settings get "lambsReinforce";

if (_debug) then {
    diag_log format ["[RECONDO_FP] Trigger activated for marker '%1'", _markerName];
};

// Calculate random group size
private _groupSize = _minGroupSize + floor random ((_maxGroupSize - _minGroupSize) + 1);
_groupSize = _groupSize max 1;

// Build group composition array
private _groupArray = [];

// First unit is always the first in the classname list (leader)
_groupArray pushBack (_unitClassnames select 0);

// Fill remaining slots with random units
for "_i" from 1 to (_groupSize - 1) do {
    _groupArray pushBack (selectRandom _unitClassnames);
};

// Get spawn position from trigger
private _spawnPos = getPos _trigger;

if (_debug) then {
    diag_log format ["[RECONDO_FP] Spawning group of %1 units at %2", _groupSize, _spawnPos];
};

// Create group
private _group = [_spawnPos, _targetSide, _groupArray] call BIS_fnc_spawnGroup;

if (isNull _group) exitWith {
    diag_log format ["[RECONDO_FP] ERROR: Failed to create group at marker '%1'", _markerName];
    grpNull
};

if (_debug) then {
    diag_log format ["[RECONDO_FP] Successfully created group with %1 units", count units _group];
};

// Set group behavior BEFORE creating waypoints
_group setBehaviour _behaviour;
_group setSpeedMode _speedMode;
_group setCombatMode _combatMode;
_group setFormation _formation;

// Enable LAMBS group reinforcement if requested
if (_lambsReinforce) then {
    _group setVariable ["lambs_danger_enableGroupReinforce", true, true];
};

// Mark group as spawned by this module
_group setVariable ["RECONDO_FP_SPAWNED", true, true];
_group setVariable ["RECONDO_FP_MARKER", _markerName, true];

// Create patrol waypoints in a circular pattern with randomization
private _angleStep = 360 / _waypointCount;
private _startAngle = random 360;  // Randomize starting direction

for "_i" from 0 to (_waypointCount - 1) do {
    private _angle = _startAngle + (_i * _angleStep);
    
    // Add some randomization to radius (80-100% of patrol radius)
    private _wpRadius = _patrolRadius * (0.8 + (random 0.2));
    private _wpPos = _spawnPos getPos [_wpRadius, _angle];
    
    // Find safe position on land
    private _safePos = [_wpPos, 0, 50, 3, 0, 0.5, 0] call BIS_fnc_findSafePos;
    if (_safePos isEqualTo []) then {
        _safePos = _wpPos;  // Fallback to original position
    };
    
    private _wp = _group addWaypoint [_safePos, 0];
    _wp setWaypointType "MOVE";
    _wp setWaypointBehaviour _behaviour;
    _wp setWaypointSpeed _speedMode;
    _wp setWaypointFormation _formation;
    _wp setWaypointTimeout [_waypointPauseMin, (_waypointPauseMin + _waypointPauseMax) / 2, _waypointPauseMax];
    _wp setWaypointCompletionRadius 20;
};

// Add cycle waypoint to loop the patrol
private _cycleWp = _group addWaypoint [_spawnPos, 0];
_cycleWp setWaypointType "CYCLE";
_cycleWp setWaypointBehaviour _behaviour;
_cycleWp setWaypointSpeed _speedMode;

if (_debug) then {
    diag_log format ["[RECONDO_FP] Created %1 waypoints for group with radius %2m", _waypointCount, _patrolRadius];
};

// Register with centralized simulation monitoring system
if (_simulationDistance > 0) then {
    [{
        params ["_group", "_markerName", "_simulationDistance", "_debug"];
        if (!isNull _group && {count units _group > 0}) then {
            private _units = units _group;
            private _position = getPos (leader _group);
            
            // Register units with the simulation system
            [_markerName, _units, _position, _simulationDistance] call Recondo_fnc_registerSimulation;
            
            if (_debug) then {
                diag_log format ["[RECONDO_FP] Registered %1 units with simulation system at distance %2m for '%3'", 
                    count _units, _simulationDistance, _markerName];
            };
        };
    }, [_group, _markerName, _simulationDistance, _debug], 2] call CBA_fnc_waitAndExecute;
};

// Track spawned group
if (!isNil "RECONDO_FP_SPAWNED_GROUPS") then {
    RECONDO_FP_SPAWNED_GROUPS pushBack _group;
};

if (_debug) then {
    diag_log format ["[RECONDO_FP] Patrol group spawned and configured at marker '%1'", _markerName];
};

_group
