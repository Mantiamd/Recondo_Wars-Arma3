/*
    Recondo_fnc_rwFootprintLoop
    Server-side footprint producer for Reinforcement Waves.

    Description:
        Creates tracker-style footprints for currently tracked target groups so
        RW strict footprint pursuit works even when the Trackers module is not
        running. Uses the same footprint payload format:
        [position, time, groupIdString, trackerGroups[]].

        Fallback only: stands down (idles) while the Trackers module is
        active, since its own loop already produces and prunes footprints
        for the same shared array - both running would lay double trails.
*/

if (!isServer) exitWith {};

private _lastPosByGroup = createHashMap;      // groupId -> position
private _lastTimeByGroup = createHashMap;     // groupId -> time
private _debugMarkerIndex = 0;

private _footprintSpacing = 10;
private _speedThreshold = 6; // km/h
private _fallbackLifetime = 20 * 60; // seconds

while {true} do {
    if (isNil "RECONDO_RW_INSTANCES" || {count RECONDO_RW_INSTANCES == 0}) exitWith {};

    // Trackers module active: its loop already lays and prunes footprints
    // for the shared array - idle so the same group isn't tracked twice.
    // Checked per-iteration because module init order isn't guaranteed.
    if (!isNil "RECONDO_TRACKERS_SETTINGS") then {
        sleep 5;
        continue;
    };

    if (isNil "RECONDO_TRACKERS_FOOTPRINTS") then { RECONDO_TRACKERS_FOOTPRINTS = []; };
    if (isNil "RECONDO_TRACKERS_TRACKED_GROUPS") then { RECONDO_TRACKERS_TRACKED_GROUPS = []; };
    if (isNil "RECONDO_TRACKERS_ALWAYS_TRACK_GROUPS") then { RECONDO_TRACKERS_ALWAYS_TRACK_GROUPS = []; };

    // Derive target side(s) from active RW instances.
    private _targetSides = [];
    private _debugLogging = false;
    private _debugMarkers = false;
    {
        _targetSides pushBackUnique (_x get "targetSide");
        if (_x getOrDefault ["debugLogging", false]) then { _debugLogging = true; };
        if (_x getOrDefault ["debugMarkers", false]) then { _debugMarkers = true; };
    } forEach RECONDO_RW_INSTANCES;

    // Lifetime follows Trackers settings when available.
    private _footprintLifetime = _fallbackLifetime;
    if (!isNil "RECONDO_TRACKERS_SETTINGS") then {
        _footprintLifetime = RECONDO_TRACKERS_SETTINGS getOrDefault ["footprintLifetime", _fallbackLifetime];
    };

    // Clean expired footprints (safe without Trackers module).
    private _now = time;
    RECONDO_TRACKERS_FOOTPRINTS = RECONDO_TRACKERS_FOOTPRINTS select {
        (_now - (_x select 1)) <= _footprintLifetime
    };

    // Create footprints for tracked target-side groups.
    {
        private _group = _x;
        if !(side _group in _targetSides) then { continue };

        private _groupIdStr = groupId _group;
        if (_groupIdStr == "") then { continue };
        if !(_groupIdStr in RECONDO_TRACKERS_TRACKED_GROUPS) then { continue };

        private _livingUnits = units _group select {alive _x};
        if (_livingUnits isEqualTo []) then { continue };

        private _firstLiving = _livingUnits select 0;
        if (vehicle _firstLiving != _firstLiving) then { continue };

        private _currentPos = getPos _firstLiving;
        private _currentTime = time;

        if !(_groupIdStr in keys _lastPosByGroup) then {
            _lastPosByGroup set [_groupIdStr, _currentPos];
            _lastTimeByGroup set [_groupIdStr, _currentTime];
            continue;
        };

        private _lastPos = _lastPosByGroup get _groupIdStr;
        private _lastPosTime = _lastTimeByGroup getOrDefault [_groupIdStr, _currentTime];
        private _distance = _lastPos distance _currentPos;
        if (_distance < _footprintSpacing) then { continue };

        private _elapsedTime = _currentTime - _lastPosTime;
        private _avgSpeed = if (_elapsedTime > 0) then { (_distance / _elapsedTime) * 3.6 } else { 0 };
        private _isAlwaysTracked = _groupIdStr in RECONDO_TRACKERS_ALWAYS_TRACK_GROUPS;

        if (_isAlwaysTracked || {_avgSpeed > _speedThreshold}) then {
            RECONDO_TRACKERS_FOOTPRINTS pushBack [_currentPos, _currentTime, _groupIdStr, []];

            if (_debugMarkers) then {
                _debugMarkerIndex = _debugMarkerIndex + 1;
                private _markerName = format ["RECONDO_RW_fp_%1_%2", _groupIdStr, _debugMarkerIndex];
                private _marker = createMarker [_markerName, _currentPos];
                _marker setMarkerType "mil_dot";
                _marker setMarkerColor "ColorBlue";
                _marker setMarkerText format ["RW_FP_%1", _debugMarkerIndex];
                _marker setMarkerSize [0.5, 0.5];
            };

            if (_debugLogging && !_isAlwaysTracked) then {
                diag_log format [
                    "[RECONDO_RW] Footprint created for %1 - avg speed %2 km/h over %3m in %4s",
                    _groupIdStr,
                    round (_avgSpeed * 10) / 10,
                    round _distance,
                    round (_elapsedTime * 10) / 10
                ];
            };
        };

        _lastPosByGroup set [_groupIdStr, _currentPos];
        _lastTimeByGroup set [_groupIdStr, _currentTime];
    } forEach allGroups;

    sleep 5;
};
