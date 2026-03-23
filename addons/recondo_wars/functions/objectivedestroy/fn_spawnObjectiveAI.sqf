/*
    Recondo_fnc_spawnObjectiveAI
    Spawns AI sentries and patrols at an objective
    
    Description:
        Creates sentry units that stay near the objective and
        patrol groups that move around the area.
    
    Parameters:
        _settings - HASHMAP - Module settings
        _position - ARRAY - Position of the objective
        _markerId - STRING - Marker ID (for tracking)
    
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [
    ["_settings", nil, [createHashMap]],
    ["_position", [0,0,0], [[]]],
    ["_markerId", "", [""]]
];

if (isNil "_settings") exitWith {};

private _sentryClassnames = _settings get "sentryClassnames";
private _sentryMinCount = _settings get "sentryMinCount";
private _sentryMaxCount = _settings get "sentryMaxCount";
private _sentrySide = _settings get "sentrySide";

private _patrolClassnames = _settings get "patrolClassnames";
private _patrolCount = _settings get "patrolCount";
private _patrolMinSize = _settings get "patrolMinSize";
private _patrolMaxSize = _settings get "patrolMaxSize";
private _patrolRadius = _settings get "patrolRadius";
private _patrolFormation = _settings get "patrolFormation";

private _simulationDistance = _settings get "simulationDistance";
private _debugLogging = _settings get "debugLogging";

private _spawnedUnits = [];

// ========================================
// SPAWN SENTRIES
// ========================================

if (count _sentryClassnames > 0) then {
    private _sentryCount = _sentryMinCount + floor random ((_sentryMaxCount - _sentryMinCount) + 1);
    private _sentryGroup = createGroup [_sentrySide, true];
    
    for "_i" from 1 to _sentryCount do {
        private _spawnPos = _position findEmptyPosition [5, 20, "Man"];
        if (count _spawnPos == 0) then { _spawnPos = _position getPos [random 15, random 360] };
        
        private _unitClass = selectRandom _sentryClassnames;
        private _unit = _sentryGroup createUnit [_unitClass, _spawnPos, [], 0, "NONE"];
        
        _unit setUnitPos "UP";
        _unit setBehaviour "SAFE";
        _unit allowDamage false;
        
        _spawnedUnits pushBack _unit;
        
        // Sentry random movement behavior
        [_unit, _position] spawn {
            params ["_unit", "_centerPos"];
            
            sleep 30; // Initial wait
            
            while {alive _unit} do {
                sleep (30 + random 45);
                
                if (alive _unit && behaviour _unit == "SAFE") then {
                    private _movePos = _centerPos getPos [random 15, random 360];
                    private _finalPos = _movePos findEmptyPosition [0, 10, typeOf _unit];
                    
                    if (count _finalPos > 0) then {
                        _unit doMove _finalPos;
                        _unit setSpeedMode "LIMITED";
                        
                        private _timeout = time + 30;
                        waitUntil { sleep 1; unitReady _unit || !alive _unit || time > _timeout };
                        doStop _unit;
                    };
                };
            };
        };
    };
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_OBJDESTROY] Spawned %1 sentries at %2", _sentryCount, _markerId];
    };
};

// ========================================
// SPAWN PATROLS
// ========================================

if (count _patrolClassnames > 0 && _patrolCount > 0) then {
    for "_p" from 1 to _patrolCount do {
        private _patrolGroup = createGroup [_sentrySide, true];
        private _groupSize = _patrolMinSize + floor random ((_patrolMaxSize - _patrolMinSize) + 1);
        
        // Spawn patrol units
        for "_i" from 1 to _groupSize do {
            private _spawnPos = _position findEmptyPosition [10, 30, "Man"];
            if (count _spawnPos == 0) then { _spawnPos = _position getPos [20 + random 10, random 360] };
            
            private _unitClass = selectRandom _patrolClassnames;
            private _unit = _patrolGroup createUnit [_unitClass, _spawnPos, [], 0, "NONE"];
            
            _unit allowDamage false;
            _spawnedUnits pushBack _unit;
        };
        
        // Set formation
        _patrolGroup setFormation _patrolFormation;
        
        // Create patrol waypoints
        for "_w" from 1 to 4 do {
            private _wpDir = (_w - 1) * 90 + random 45;
            private _wpDist = (_patrolRadius * 0.5) + random (_patrolRadius * 0.5);
            private _wpPos = _position getPos [_wpDist, _wpDir];
            
            private _wp = _patrolGroup addWaypoint [_wpPos, 10];
            _wp setWaypointType "MOVE";
            _wp setWaypointBehaviour "SAFE";
            _wp setWaypointSpeed "LIMITED";
            _wp setWaypointTimeout [5, 15, 30];
        };
        
        // Cycle waypoint
        private _cycleWp = _patrolGroup addWaypoint [_position, 10];
        _cycleWp setWaypointType "CYCLE";
        
        if (_debugLogging) then {
            diag_log format ["[RECONDO_OBJDESTROY] Spawned patrol %1/%2 with %3 units at %4", _p, _patrolCount, _groupSize, _markerId];
        };
    };
};

// Enable damage after 30 seconds
[{
    params ["_units"];
    {
        if (!isNull _x && alive _x) then {
            _x allowDamage true;
        };
    } forEach _units;
}, [_spawnedUnits], 30] call CBA_fnc_waitAndExecute;

// Register with centralized simulation monitoring system
if (_simulationDistance > 0 && {count _spawnedUnits > 0}) then {
    [{
        params ["_spawnedUnits", "_markerId", "_position", "_simulationDistance", "_debugLogging"];
        
        private _aliveUnits = _spawnedUnits select { alive _x };
        if (count _aliveUnits > 0) then {
            private _identifier = format ["OBJDESTROY_AI_%1", _markerId];
            [_identifier, _aliveUnits, _position, _simulationDistance] call Recondo_fnc_registerSimulation;
            
            if (_debugLogging) then {
                diag_log format ["[RECONDO_OBJDESTROY] Registered %1 AI units with simulation system at distance %2m for %3", 
                    count _aliveUnits, _simulationDistance, _markerId];
            };
        };
    }, [_spawnedUnits, _markerId, _position, _simulationDistance, _debugLogging], 2] call CBA_fnc_waitAndExecute;
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_OBJDESTROY] Total AI spawned at %1: %2 units", _markerId, count _spawnedUnits];
};
