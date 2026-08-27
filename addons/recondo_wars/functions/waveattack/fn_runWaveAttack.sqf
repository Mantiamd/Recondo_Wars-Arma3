/*
    Recondo_fnc_runWaveAttack
    Runs the full wave sequence for one triggered marker

    Description:
        After the trigger fires, waits the configured initial delay, then
        spawns waves on a fixed countdown. Each wave spawns one group per
        selected bearing simultaneously. Once triggered, the sequence
        always runs to completion - there is no players-still-in-area
        requirement. Server-only.

        When chargers are enabled, a second schedule with its own wave
        count and countdown runs in parallel after the same initial
        delay, spawning charger groups (fn_spawnWaveChargerGroup).

    Parameters:
        0: HASHMAP - Module settings
        1: STRING  - Triggered marker name

    Returns:
        Nothing (spawned sequence)
*/

if (!isServer) exitWith {};

params ["_settings", "_marker"];

private _instanceId = _settings get "instanceId";
private _initialDelay = _settings getOrDefault ["initialDelay", 10];
private _bearings = _settings get "bearings";
private _maxWaves = _settings get "maxWaves";
private _timeBetweenWaves = _settings get "timeBetweenWaves";
private _debugLogging = _settings get "debugLogging";

private _markerPos = getMarkerPos _marker;

// Both tiers hold for the same initial delay, keeping them synchronized
// from the same trigger moment
if (_initialDelay > 0) then {
    if (_debugLogging) then {
        diag_log format ["[RECONDO_WAVEATK] %1: Marker %2 triggered - first spawn in %3s",
            _instanceId, _marker, _initialDelay];
    };
    sleep _initialDelay;
};

// Charger tier: own wave count and countdown, running in parallel
if (_settings getOrDefault ["enableChargers", false]) then {
    [_settings, _marker, _markerPos] spawn {
        params ["_settings", "_marker", "_markerPos"];

        private _instanceId = _settings get "instanceId";
        private _bearings = _settings get "bearings";
        private _chargerMaxWaves = _settings get "chargerMaxWaves";
        private _chargerTimeBetweenWaves = _settings get "chargerTimeBetweenWaves";
        private _debugLogging = _settings get "debugLogging";

        private _waveNumber = 0;

        while {_waveNumber < _chargerMaxWaves} do {
            _waveNumber = _waveNumber + 1;

            {
                [_settings, _marker, _markerPos, _x, _waveNumber] call Recondo_fnc_spawnWaveChargerGroup;
            } forEach _bearings;

            if (_debugLogging) then {
                diag_log format ["[RECONDO_WAVEATK] %1: Marker %2 charger wave %3/%4 spawned (%5 groups)",
                    _instanceId, _marker, _waveNumber, _chargerMaxWaves, count _bearings];
            };

            if (_waveNumber < _chargerMaxWaves) then {
                sleep _chargerTimeBetweenWaves;
            };
        };
    };
};

private _waveNumber = 0;

while {_waveNumber < _maxWaves} do {
    _waveNumber = _waveNumber + 1;

    {
        [_settings, _marker, _markerPos, _x, _waveNumber] call Recondo_fnc_spawnWaveAttackGroup;
    } forEach _bearings;

    if (_debugLogging) then {
        diag_log format ["[RECONDO_WAVEATK] %1: Marker %2 wave %3/%4 spawned (%5 groups)",
            _instanceId, _marker, _waveNumber, _maxWaves, count _bearings];
    };

    if (_waveNumber < _maxWaves) then {
        sleep _timeBetweenWaves;
    };
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_WAVEATK] %1: Marker %2 sequence complete (%3 waves)", _instanceId, _marker, _maxWaves];
};
