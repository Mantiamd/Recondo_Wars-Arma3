/*
    Recondo_fnc_qraaWatcher
    Arms a Quick Reaction AA layout on knowsAbout detection

    Description:
        One watcher per module instance. Loops until any Detector Side AI
        unit within Detection Radius of any pending site (and under the
        height limit) reaches the configured knowsAbout threshold on a
        Target Side unit that is also under the height limit. When that
        happens, the entire layout spawns at once and the watcher exits.

        Modeled on Reinforcement Waves' detection loop
        (fn_createRWDetectionTrigger.sqf) - the point of QRAA is that AI
        on the ground has to actually see or hear the enemy, not just
        that the enemy walks past a point. knowsAbout accounts for line
        of sight, stance, noise and cover for free (engine-computed) and
        1.5 = 'identified as enemy'.

        Bypasses HC transfer intentionally - the layout is a one-shot
        ambush and static gunners are cheap to run on the server.
        Server-only.

    Parameters:
        0: HASHMAP - Module settings (must contain qraaPendingMarkers,
                     qraaDetectorSideNum, qraaTargetSideNum, qraaRadius,
                     qraaDetectionThreshold, qraaHeightLimit)

    Returns:
        Nothing (spawned loop)
*/

if (!isServer) exitWith {};

params ["_settings"];

private _debug = _settings get "enableDebug";
private _markerPrefix = _settings get "markerPrefix";
private _radius = _settings get "qraaRadius";
private _heightLimit = _settings get "qraaHeightLimit";
private _detectionThreshold = _settings get "qraaDetectionThreshold";
private _safetyRadius = _settings getOrDefault ["qraaSafetyRadius", 200];
private _sideMap = [east, west, independent];
private _detectorSide = _sideMap select ((_settings get "qraaDetectorSideNum") max 0 min 2);
private _targetSide = _sideMap select ((_settings get "qraaTargetSideNum") max 0 min 2);

private _pendingMarkers = _settings get "qraaPendingMarkers";

if (isNil "_pendingMarkers" || {count _pendingMarkers == 0}) exitWith {
    diag_log format ["[RECONDO_SDR] QRAA watcher for '%1' exited immediately - no pending markers.", _markerPrefix];
};

// Cache marker positions once - they don't move
private _markerPositions = _pendingMarkers apply { getMarkerPos _x };

// Startup delay lets AI finish initializing before the first sweep, and a
// jitter staggers multiple instances so their sweeps don't share ticks
sleep (5 + random 4);

private _armed = true;
private _tripDetector = objNull;
private _tripTarget = objNull;

while {_armed} do {
    private _cachedUnits = allUnits;

    // Detectors: alive, right side, below height ceiling, and within
    // radius of ANY pending marker (2D distance)
    private _detectors = _cachedUnits select {
        alive _x
        && {side _x == _detectorSide}
        && {((getPosATL _x) select 2) <= _heightLimit}
        && {
            private _unit = _x;
            _markerPositions findIf { _unit distance2D _x <= _radius } != -1
        }
    };

    // Targets: alive, right side, below height ceiling (map-wide, RW pattern)
    private _targets = _cachedUnits select {
        alive _x
        && {side _x == _targetSide}
        && {((getPosATL _x) select 2) <= _heightLimit}
    };

    if (count _detectors > 0 && {count _targets > 0}) then {
        {
            private _detector = _x;
            {
                if (_detector knowsAbout _x >= _detectionThreshold) exitWith {
                    _tripDetector = _detector;
                    _tripTarget = _x;
                    _armed = false;
                };
            } forEach _targets;
            if (!_armed) exitWith {};
        } forEach _detectors;
    };

    if (_armed) then {
        // ~5s polling with jitter, same cadence as RW
        sleep (4 + random 2);
    };
};

if (_debug) then {
    diag_log format ["[RECONDO_SDR] QRAA tripped for '%1' - %2 spotted %3 (knowsAbout %4).",
        _markerPrefix, _tripDetector, _tripTarget, _tripDetector knowsAbout _tripTarget];
};

// Snapshot target-side units once for the safety pass - they can be checked
// against every pending marker without re-scanning allUnits per site
private _safetyTargets = allUnits select {
    alive _x && {side _x == _targetSide}
};

private _skipped = 0;
{
    private _markerName = _x;
    private _markerPos = getMarkerPos _markerName;

    // Safety: never pop a site in front of an enemy standing on top of it.
    // Skipped sites are lost (not queued for retry) - the layout is a one-shot
    // ambush, so a site the enemy already owned this cycle is simply gone.
    private _blocked = (_safetyTargets findIf { _x distance2D _markerPos <= _safetyRadius }) != -1;
    if (_blocked) then {
        _skipped = _skipped + 1;
        if (_debug) then {
            diag_log format ["[RECONDO_SDR] QRAA safety skip: '%1' has a %2 unit within %3m - site abandoned.",
                _markerName, _targetSide, _safetyRadius];
        };
    } else {
        private _result = [_markerName, _settings] call Recondo_fnc_spawnStaticDefense;
        if (_result isEqualType []) then {
            _result params ["_static", "_unit"];
            RECONDO_SDR_SPAWNED_STATICS pushBack _static;
            RECONDO_SDR_SPAWNED_UNITS pushBack _unit;
        };
    };
} forEach _pendingMarkers;

_settings set ["qraaPendingMarkers", []];

diag_log format ["[RECONDO_SDR] QRAA spent for '%1' - %2 statics live, %3 sites skipped for safety.",
    _markerPrefix, count RECONDO_SDR_SPAWNED_STATICS, _skipped];
