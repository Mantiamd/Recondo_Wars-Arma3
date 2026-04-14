/*
    Recondo_fnc_spawnUprisingCivilians
    Spawns civilians around a village marker with wandering behavior

    Parameters:
        _settings     - HASHMAP - Module settings
        _villageMarker - STRING - Village marker name
        _villagePos   - ARRAY  - Village center position

    Returns:
        ARRAY - Spawned civilian units
*/

if (!isServer) exitWith { [] };

params [
    ["_settings", nil, [createHashMap]],
    ["_villageMarker", "", [""]],
    ["_villagePos", [0,0,0], [[]]]
];

if (isNil "_settings") exitWith { [] };

private _civClassnames = _settings get "civClassnames";
private _civsPerSite = _settings get "civsPerSite";
private _spawnRadius = _settings get "spawnRadius";
private _debugLogging = _settings get "debugLogging";

private _civilians = [];

for "_i" from 1 to _civsPerSite do {
    private _classname = selectRandom _civClassnames;
    private _spawnPos = _villagePos getPos [random _spawnRadius, random 360];

    private _civGroup = createGroup [civilian, true];
    private _unit = _civGroup createUnit [_classname, _spawnPos, [], 0, "NONE"];
    if (isNull _unit) then { continue };

    _unit setPosATL _spawnPos;
    removeAllWeapons _unit;
    _unit setBehaviour "CARELESS";
    _unit setSpeedMode "LIMITED";
    _unit setVariable ["RECONDO_UPRISING_village", _villageMarker];
    _unit setVariable ["RECONDO_UPRISING_active", true];

    _civilians pushBack _unit;

    // Wandering loop
    [_unit, _villagePos, _spawnRadius, _debugLogging, _villageMarker] spawn {
        params ["_unit", "_center", "_radius", "_debug", "_marker"];

        sleep (random 3);

        while {alive _unit && {_unit getVariable ["RECONDO_UPRISING_active", true]}} do {
            _unit enableAI "MOVE";
            private _newPos = _center getPos [random _radius, random 360];
            _unit doMove _newPos;

            private _timeout = time + 30;
            waitUntil { sleep 1; unitReady _unit || !alive _unit || !(_unit getVariable ["RECONDO_UPRISING_active", true]) || time > _timeout };

            sleep (2 + random 5);
        };
    };
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_UPRISING] Spawned %1 civilians at %2", count _civilians, _villageMarker];
};

_civilians
