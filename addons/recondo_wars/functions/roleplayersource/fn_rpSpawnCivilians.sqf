/*
    Recondo_fnc_rpSpawnCivilians
    Server-side: Spawns wandering civilians around a position.
    Includes a despawn monitor that removes them when no players
    are nearby for a configured duration.

    Parameters:
        _spawnPos       - ARRAY  - Center position to spawn around
        _settings       - HASHMAP - Module settings

    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [
    ["_spawnPos", [0,0,0], [[]]],
    ["_settings", nil, [createHashMap]]
];

if (isNil "_settings") exitWith {
    diag_log "[RECONDO_RP_SOURCE] rpSpawnCivilians: No settings provided.";
};

private _civClassnames = _settings getOrDefault ["civClassnames", []];
private _civsPerSpawn = _settings getOrDefault ["civsPerSpawn", 10];
private _spawnRadius = _settings getOrDefault ["civSpawnRadius", 100];
private _despawnDistance = _settings getOrDefault ["civDespawnDistance", 200];
private _despawnTimer = _settings getOrDefault ["civDespawnTimer", 300];
private _debugLogging = _settings getOrDefault ["debugLogging", false];

if (count _civClassnames == 0) exitWith {
    diag_log "[RECONDO_RP_SOURCE] rpSpawnCivilians: No civilian classnames configured.";
};

// ========================================
// SPAWN CIVILIANS
// ========================================

private _civilians = [];

for "_i" from 1 to _civsPerSpawn do {
    private _classname = selectRandom _civClassnames;
    private _civPos = _spawnPos getPos [random _spawnRadius, random 360];

    private _civGroup = createGroup [civilian, true];
    private _unit = _civGroup createUnit [_classname, _civPos, [], 0, "NONE"];
    if (isNull _unit) then { continue };

    _unit setPosATL _civPos;
    removeAllWeapons _unit;
    _unit setBehaviour "CARELESS";
    _unit setSpeedMode "LIMITED";
    _unit setVariable ["RECONDO_RP_CIV", true];

    _civilians pushBack _unit;

    // Wandering loop
    [_unit, _spawnPos, _spawnRadius] spawn {
        params ["_unit", "_center", "_radius"];

        sleep (random 3);

        while {alive _unit && {_unit getVariable ["RECONDO_RP_CIV", true]}} do {
            _unit enableAI "MOVE";
            private _newPos = _center getPos [random _radius, random 360];
            _unit doMove _newPos;

            private _timeout = time + 30;
            waitUntil { sleep 1; unitReady _unit || !alive _unit || !(_unit getVariable ["RECONDO_RP_CIV", true]) || time > _timeout };

            sleep (2 + random 5);
        };
    };
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_RP_SOURCE] Spawned %1 civilians at %2", count _civilians, _spawnPos];
};

if (count _civilians == 0) exitWith {};

// ========================================
// DESPAWN MONITOR
// ========================================
// Delete all spawned civilians if no player is within
// _despawnDistance for _despawnTimer continuous seconds.

[_civilians, _spawnPos, _despawnDistance, _despawnTimer, _debugLogging] spawn {
    params ["_civilians", "_center", "_dist", "_timer", "_debug"];

    private _noPlayerNearSince = -1;

    while {true} do {
        sleep 10;

        // Remove dead units from tracking
        _civilians = _civilians select { alive _x };
        if (count _civilians == 0) exitWith {
            if (_debug) then {
                diag_log "[RECONDO_RP_SOURCE] Despawn monitor: All civilians dead, exiting.";
            };
        };

        // Check if any player is within distance
        private _playerNearby = false;
        {
            if (isPlayer _x && {alive _x} && {(_x distance _center) < _dist}) exitWith {
                _playerNearby = true;
            };
        } forEach allPlayers;

        if (_playerNearby) then {
            _noPlayerNearSince = -1;
        } else {
            if (_noPlayerNearSince < 0) then {
                _noPlayerNearSince = time;
            };

            if (time - _noPlayerNearSince >= _timer) exitWith {
                // Despawn all remaining civilians
                {
                    if (alive _x) then {
                        private _grp = group _x;
                        deleteVehicle _x;
                        if (count (units _grp) == 0) then { deleteGroup _grp; };
                    };
                } forEach _civilians;

                if (_debug) then {
                    diag_log format ["[RECONDO_RP_SOURCE] Despawned %1 civilians near %2 (no players within %3m for %4s)", count _civilians, _center, _dist, _timer];
                };
            };
        };
    };
};
