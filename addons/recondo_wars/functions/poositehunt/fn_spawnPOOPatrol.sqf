/*
    Recondo_fnc_spawnPOOPatrol
    Spawns infantry patrol group(s) guarding a POO site

    Description:
        Runs on the server when a POO site activates. Spawns one or more patrol
        groups (same side as the artillery crew) that roam a ring around the site
        via MOVE waypoints plus a CYCLE, so they loop indefinitely. Patrols live
        independently of the gun: if the artillery is destroyed they remain as
        normal AI.

    Parameters:
        0: _settings  - HASHMAP - Module settings
        1: _centerPos - ARRAY   - World position of the POO site

    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [
    ["_settings", nil, [createHashMap]],
    ["_centerPos", [0,0,0], [[]]]
];

if (isNil "_settings") exitWith {};

private _patrolClassnames = _settings get "patrolClassnames";
private _patrolGroupCount = _settings get "patrolGroupCount";
private _patrolMinSize    = _settings get "patrolMinSize";
private _patrolMaxSize    = _settings get "patrolMaxSize";
private _patrolRadius     = _settings get "patrolRadius";
private _patrolFormation  = _settings get "patrolFormation";
private _side             = _settings get "crewSide";
private _debugLogging     = _settings get "debugLogging";

if (count _patrolClassnames == 0 || _patrolGroupCount < 1) exitWith {
    if (_debugLogging) then {
        diag_log "[RECONDO_POO] Area patrol enabled but no classnames/groups configured; skipping.";
    };
};

// Guard against a min > max misconfiguration.
if (_patrolMaxSize < _patrolMinSize) then { _patrolMaxSize = _patrolMinSize; };

private _spawnedUnits = [];

for "_p" from 1 to _patrolGroupCount do {
    private _group = createGroup [_side, true];
    _group deleteGroupWhenEmpty true;

    private _groupSize = _patrolMinSize + floor random ((_patrolMaxSize - _patrolMinSize) + 1);

    for "_i" from 1 to _groupSize do {
        private _spawnPos = _centerPos findEmptyPosition [10, 30, "Man"];
        if (count _spawnPos == 0) then { _spawnPos = _centerPos getPos [20 + random 10, random 360]; };

        private _unitClass = selectRandom _patrolClassnames;
        private _unit = _group createUnit [_unitClass, _spawnPos, [], 0, "NONE"];
        _unit allowDamage false;
        _spawnedUnits pushBack _unit;
    };

    _group setFormation _patrolFormation;
    _group setBehaviour "SAFE";
    _group setCombatMode "YELLOW";

    // Ring of MOVE waypoints around the site, closed with a CYCLE.
    for "_w" from 1 to 4 do {
        private _wpDir = (_w - 1) * 90 + random 45;
        private _wpDist = (_patrolRadius * 0.5) + random (_patrolRadius * 0.5);
        private _wpPos = _centerPos getPos [_wpDist, _wpDir];

        private _wp = _group addWaypoint [_wpPos, 10];
        _wp setWaypointType "MOVE";
        _wp setWaypointBehaviour "SAFE";
        _wp setWaypointSpeed "LIMITED";
        _wp setWaypointTimeout [5, 15, 30];
    };

    private _cycleWp = _group addWaypoint [_centerPos, 10];
    _cycleWp setWaypointType "CYCLE";

    if (_debugLogging) then {
        diag_log format ["[RECONDO_POO] Spawned patrol %1/%2 with %3 units at %4", _p, _patrolGroupCount, _groupSize, _centerPos];
    };
};

// Brief spawn protection, then normal AI (independent of the gun's lifecycle).
[{
    params ["_units"];
    {
        if (!isNull _x && alive _x) then { _x allowDamage true; };
    } forEach _units;
}, [_spawnedUnits], 30] call CBA_fnc_waitAndExecute;

if (_debugLogging) then {
    diag_log format ["[RECONDO_POO] Total patrol units spawned at %1: %2", _centerPos, count _spawnedUnits];
};
