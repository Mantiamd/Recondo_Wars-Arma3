/*
    Recondo_fnc_survHunterBehavior
    Behavior loop for Survival Radio hunter groups

    Description:
        Phase 1: move to the triangulated position.
        Phase 2: follow the transmitter's footprints in order. When the
        trail runs out, push a short distance in the last known direction,
        then hold and re-check - hunters never give up and keep watching
        for fresh footprints until the whole group is dead.
        Plays whistle sounds only. Server-only, must be spawned.

    Parameters:
        0: GROUP - Hunter group
        1: STRING - Target ID (footprint key)
        2: ARRAY - Triangulated position

    Returns:
        Nothing (endless loop until group dead)
*/

if (!isServer) exitWith {};

params ["_group", "_targetId", "_triangulatedPos"];

private _settings = RECONDO_SURV_SETTINGS;
private _soundInterval = _settings get "soundInterval";
private _whistleSounds = _settings get "whistleSounds";
private _debug = _settings get "debugLogging";

// ========================================
// WHISTLE SOUND THREAD
// ========================================

if (_soundInterval > 0) then {
    [_group, _soundInterval, _whistleSounds] spawn {
        params ["_group", "_baseInterval", "_sounds"];

        // Per-group randomized interval and initial offset so groups don't sync
        private _groupInterval = (_baseInterval + (random 20) - 10) max 10;
        sleep (random _groupInterval);

        while {({alive _x} count units _group) > 0} do {
            private _leader = leader _group;
            private _nearbyPlayers = allPlayers select { _x distance _leader < 300 };
            if (count _nearbyPlayers > 0) then {
                [_leader, _sounds] remoteExec ["RECONDO_SURV_fnc_playSound", _nearbyPlayers];
            };
            sleep _groupInterval;
        };
    };
};

// ========================================
// PHASE 1: MOVE TO TRIANGULATED POSITION
// ========================================

if (_debug) then {
    diag_log format ["[RECONDO_SURV] Hunter group %1 moving to triangulated position %2", _group, _triangulatedPos];
};

_group move _triangulatedPos;

private _arrived = false;
while {!_arrived && {({alive _x} count units _group) > 0}} do {
    private _leader = leader _group;
    if (_leader distance _triangulatedPos < 20) then {
        _arrived = true;
    } else {
        // Re-issue movement unless the group is actively fighting
        if (behaviour _leader != "COMBAT") then {
            _group move _triangulatedPos;
            _group setSpeedMode "NORMAL";
        };
        sleep 5;
    };
};

if (({alive _x} count units _group) == 0) exitWith {
    RECONDO_SURV_ACTIVE_GROUPS = RECONDO_SURV_ACTIVE_GROUPS - [_group];
};

if (_debug) then {
    diag_log format ["[RECONDO_SURV] Hunter group %1 reached triangulated position, starting footprint pursuit", _group];
};

// ========================================
// PHASE 2: FOLLOW FOOTPRINTS (NO GIVE-UP)
// ========================================

private _visitedCount = 0;              // footprints already walked
private _lastKnownDirection = [0, 1, 0];
private _lastTrailEnd = _triangulatedPos;

while {({alive _x} count units _group) > 0} do {
    private _leader = leader _group;

    // Let the AI fight without movement orders stacking up
    if (behaviour _leader == "COMBAT") then {
        sleep 5;
        continue;
    };

    // This target's trail - already chronological (footprints are pushed in order)
    private _trail = RECONDO_SURV_FOOTPRINTS select { _x select 2 == _targetId };

    // Expired footprints shrink the trail; clamp so we don't skip fresh ones
    _visitedCount = _visitedCount min count _trail;

    // Update last known direction from the two newest footprints
    if (count _trail >= 2) then {
        private _dir = ((_trail select (count _trail - 1)) select 0) vectorDiff ((_trail select (count _trail - 2)) select 0);
        if (vectorMagnitude _dir > 0.1) then {
            _lastKnownDirection = vectorNormalized _dir;
        };
    };

    if (_visitedCount < count _trail) then {
        // Walk the trail: move to the next unvisited footprint
        private _footprintPos = (_trail select _visitedCount) select 0;
        _lastTrailEnd = _footprintPos;

        _group move _footprintPos;
        _group setSpeedMode "NORMAL";
        _group setBehaviour "AWARE";

        private _moveStart = time;
        while {(leader _group) distance _footprintPos > 5 &&
               {({alive _x} count units _group) > 0} &&
               {time - _moveStart < 60}} do {
            sleep 2;
        };

        _visitedCount = _visitedCount + 1;
    } else {
        // Trail exhausted: push a short distance along the last known
        // direction, then hold there scanning for fresh footprints.
        private _searchPos = _lastTrailEnd vectorAdd (_lastKnownDirection vectorMultiply (30 + random 40));
        _searchPos set [2, 0];

        _group move _searchPos;
        _group setSpeedMode "LIMITED";
        _group setBehaviour "COMBAT";

        private _searchStart = time;
        private _foundNewTrail = false;
        while {time - _searchStart < 45 &&
               {({alive _x} count units _group) > 0} &&
               {!_foundNewTrail}} do {
            private _currentTrail = RECONDO_SURV_FOOTPRINTS select { _x select 2 == _targetId };
            if (count _currentTrail > _visitedCount) then {
                _foundNewTrail = true;
            };
            sleep 3;
        };

        _group setBehaviour "AWARE";
        _lastTrailEnd = getPos leader _group;

        if (_debug && !_foundNewTrail) then {
            diag_log format ["[RECONDO_SURV] Hunter group %1 holding near %2, waiting for fresh trail", _group, _lastTrailEnd];
        };
    };
};

// ========================================
// CLEANUP - GROUP WIPED
// ========================================

RECONDO_SURV_ACTIVE_GROUPS = RECONDO_SURV_ACTIVE_GROUPS - [_group];

if (_debug) then {
    diag_log format ["[RECONDO_SURV] Hunter group %1 eliminated - hunt for %2 over", _group, _targetId];
};
