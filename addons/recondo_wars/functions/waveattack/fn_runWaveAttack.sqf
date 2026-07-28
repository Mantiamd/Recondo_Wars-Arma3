/*
    Recondo_fnc_runWaveAttack
    Runs the full wave sequence for one triggered marker

    Description:
        Spawns waves on a fixed countdown. Each wave spawns one group per
        selected bearing simultaneously. Before every wave after the
        first, trigger-side players must still be inside the trigger
        radius or the sequence stops and surviving groups that are away
        from players are despawned. Server-only.

    Parameters:
        0: HASHMAP - Module settings
        1: STRING  - Triggered marker name

    Returns:
        Nothing (spawned sequence)
*/

if (!isServer) exitWith {};

params ["_settings", "_marker"];

private _instanceId = _settings get "instanceId";
private _triggerRadius = _settings get "triggerRadius";
private _triggerSideStr = _settings get "triggerSideStr";
private _heightLimit = _settings get "heightLimit";
private _bearings = _settings get "bearings";
private _maxWaves = _settings get "maxWaves";
private _timeBetweenWaves = _settings get "timeBetweenWaves";
private _debugLogging = _settings get "debugLogging";

private _markerPos = getMarkerPos _marker;

private _triggerSide = switch (_triggerSideStr) do {
    case "EAST": { east };
    case "WEST": { west };
    case "GUER": { independent };
    default { sideUnknown }; // ANY
};

// Players still in the area keep the sequence alive
private _fnc_playersInArea = {
    private _players = allPlayers select {
        alive _x
        && {_triggerSideStr == "ANY" || side _x == _triggerSide}
        && {((getPosATL _x) select 2) <= _heightLimit}
    };
    (_players findIf { _x distance2D _markerPos <= _triggerRadius }) != -1
};

private _spawnedGroups = [];
private _waveNumber = 0;
private _aborted = false;

while {_waveNumber < _maxWaves && !_aborted} do {
    _waveNumber = _waveNumber + 1;

    // Wave 1 spawns on trigger; later waves require players still in the area
    if (_waveNumber > 1 && {!(call _fnc_playersInArea)}) exitWith {
        _aborted = true;
    };

    {
        private _group = [_settings, _marker, _markerPos, _x, _waveNumber] call Recondo_fnc_spawnWaveAttackGroup;
        if (!isNull _group) then {
            _spawnedGroups pushBack _group;
        };
    } forEach _bearings;

    if (_debugLogging) then {
        diag_log format ["[RECONDO_WAVEATK] %1: Marker %2 wave %3/%4 spawned (%5 groups)",
            _instanceId, _marker, _waveNumber, _maxWaves, count _bearings];
    };

    if (_waveNumber < _maxWaves) then {
        sleep _timeBetweenWaves;
    };
};

if (_aborted) then {
    if (_debugLogging) then {
        diag_log format ["[RECONDO_WAVEATK] %1: Marker %2 sequence stopped after wave %3 - no players in area",
            _instanceId, _marker, _waveNumber - 1];
    };

    // Despawn surviving groups, but never in front of players
    {
        private _group = _x;
        if (!isNull _group) then {
            private _units = units _group select { alive _x };
            private _nearPlayers = (_units findIf {
                private _unit = _x;
                (allPlayers findIf { _x distance _unit < 300 }) != -1
            }) != -1;

            if (!_nearPlayers) then {
                { deleteVehicle _x } forEach _units;
                if (_debugLogging) then {
                    diag_log format ["[RECONDO_WAVEATK] %1: Despawned group at marker %2", _instanceId, _marker];
                };
            };
        };
    } forEach _spawnedGroups;
} else {
    if (_debugLogging) then {
        diag_log format ["[RECONDO_WAVEATK] %1: Marker %2 sequence complete (%3 waves)", _instanceId, _marker, _maxWaves];
    };
};
