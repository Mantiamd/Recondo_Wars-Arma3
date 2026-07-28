/*
    Recondo_fnc_rwTrackerBehavior
    Controls tracker group movement following footprints
    
    Description:
        Main group and pursuit groups use this behavior to follow
        player footprints. Similar to Trackers module behavior but
        with Wave 1 sounds and integrated settings.
        
        Movement priority (strict footprint mode):
        1. If footprints exist from target group, follow them
        2. Move toward initial detection position (one-time convergence)
        3. Otherwise, search from last known footprint position
    
    Parameters:
        _group - The tracker group
        _moduleSettings - HashMap of module settings
    
    Returns:
        Nothing (spawned behavior loop)
*/

if (!isServer) exitWith {};

params ["_group", "_moduleSettings"];

if (isNull _group) exitWith {};

private _moduleId = _moduleSettings get "moduleId";
private _soundInterval = _moduleSettings get "soundInterval";
private _debugLogging = _moduleSettings get "debugLogging";
private _soundPoolsNoDog = _moduleSettings get "soundPoolsNoDog";
private _soundPoolsWithDog = _moduleSettings get "soundPoolsWithDog";

private _waveNumber = _group getVariable ["RECONDO_RW_waveNumber", 1];
private _hasDog = _group getVariable ["RECONDO_RW_hasDog", false];
private _targetGroupId = _group getVariable ["RECONDO_RW_targetGroupId", ""];
private _targetGroup = _group getVariable ["RECONDO_RW_targetGroup", grpNull];
private _isMainGroup = _group getVariable ["RECONDO_RW_isMainGroup", false];
private _useSounds = _group getVariable ["RECONDO_RW_useSounds", true];
private _initialTargetPos = _group getVariable ["RECONDO_RW_initialTargetPos", []];

// Wave 1 main groups use sounds, pursuit groups do not
if (_waveNumber > 1) then {
    _useSounds = false;
};

// Select sound category pools based on dog presence.
// Each tick draws a category with equal chance; an empty category means silence.
private _soundPools = if (_hasDog) then { _soundPoolsWithDog } else { _soundPoolsNoDog };

if (_debugLogging) then {
    diag_log format ["[RECONDO_RW] Module %1: Tracker behavior started for group %2 (Wave %3, sounds: %4, dog: %5, initialTarget: %6)",
        _moduleId, _group, _waveNumber, _useSounds, _hasDog, _initialTargetPos];
};

private _leader = leader _group;
// Each group gets its own randomized interval (base ±10 seconds)
// If soundInterval is 0 or less, disable sounds entirely
private _groupSoundInterval = if (_soundInterval <= 0) then { 
    0 
} else { 
    (_soundInterval + (random 20) - 10) max 5 
};
private _lastSoundTime = if (_groupSoundInterval > 0) then { time - (random _groupSoundInterval) } else { 0 };  // Random initial offset so groups don't sync up
private _lastMoveTime = 0;
private _lastKnownPos = if (count _initialTargetPos > 0) then { _initialTargetPos } else { getPos _leader };
private _searching = false;
private _predictiveDir = random 360;
private _reachedInitialTarget = false;

while {!isNull _group && {count (units _group select {alive _x}) > 0}} do {
    _leader = leader _group;
    
    if (isNull _leader || !alive _leader) then {
        // Find new leader
        private _aliveUnits = units _group select {alive _x};
        if (count _aliveUnits > 0) then {
            _group selectLeader (_aliveUnits select 0);
            _leader = leader _group;
        } else {
            break;
        };
    };
    
    // Give up and delete in place once the trail has gone cold
    if ([_group, _moduleSettings] call Recondo_fnc_rwCheckGiveUp) then {
        if (_debugLogging) then {
            diag_log format ["[RECONDO_RW] Module %1: Group %2 gave up cold trail - deleting in place", _moduleId, _group];
        };
        [_group, _moduleSettings] call Recondo_fnc_despawnRWGroup;
        break;
    };
    
    // Filter out aircraft and excluded targets from AI awareness
    [_group, _moduleSettings] call Recondo_fnc_filterAirTargets;
    
    private _leaderPos = getPos _leader;
    private _inCombat = behaviour _leader == "COMBAT";
    
    // Skip movement if in combat
    if (!_inCombat) then {
        private _moveTarget = [];
        private _moveReason = "";
        
        // Priority 1: Follow footprints from the target group
        if (count _moveTarget == 0) then {
            private _nearestDist = 150; // Search radius for footprints
            private _footprintPos = [];
            
            {
                _x params ["_fPos", "_fTime", "_fGroupId", "_fTrackerGroups"];
                
                // Only follow footprints from our target group
                if (_fGroupId == _targetGroupId) then {
                    private _dist = _leaderPos distance _fPos;
                    if (_dist < _nearestDist) then {
                        _nearestDist = _dist;
                        _footprintPos = _fPos;
                    };
                };
            } forEach RECONDO_TRACKERS_FOOTPRINTS;
            
            if (count _footprintPos > 0) then {
                _moveTarget = _footprintPos;
                _lastKnownPos = _footprintPos;
                _moveReason = "following footprint";
                _searching = false;
                _reachedInitialTarget = true;
            };
        };
        
        // Priority 2: Move toward initial target position if not yet reached
        if (count _moveTarget == 0 && !_reachedInitialTarget && count _initialTargetPos > 0) then {
            private _distToInitial = _leaderPos distance _initialTargetPos;
            if (_distToInitial > 50) then {
                _moveTarget = _initialTargetPos;
                _moveReason = "moving to initial target position";
            } else {
                _reachedInitialTarget = true;
            };
        };
        
        // Priority 3: Search from last known position
        if (count _moveTarget == 0) then {
            if (!_searching) then {
                _searching = true;
                // Calculate direction from spawn to last known pos for predictive search
                private _originPos = _group getVariable ["RECONDO_RW_originPos", _leaderPos];
                _predictiveDir = _originPos getDir _lastKnownPos;
                
                if (_debugLogging) then {
                    diag_log format ["[RECONDO_RW] Group %1: No target/footprints, searching from %2 in direction %3", 
                        _group, _lastKnownPos, round _predictiveDir];
                };
            };
            
            // Move in predictive direction from last known position
            private _searchDist = 50 + random 100;
            _moveTarget = _lastKnownPos getPos [_searchDist, _predictiveDir];
            _moveReason = "searching";
            
            // Update last known pos to keep moving forward
            if (_leaderPos distance _lastKnownPos < 30) then {
                _lastKnownPos = _moveTarget;
                // Occasionally vary search direction
                if (random 1 < 0.15) then {
                    _predictiveDir = (_predictiveDir + (random 60 - 30)) mod 360;
                };
            };
        };
        
        // Update waypoint if we have a target and enough time has passed
        if (count _moveTarget > 0 && time - _lastMoveTime > 5) then {
            // Clear waypoints and set new one
            while {count waypoints _group > 0} do {
                deleteWaypoint [_group, 0];
            };
            
            private _wp = _group addWaypoint [_moveTarget, 0];
            _wp setWaypointType "MOVE";
            _wp setWaypointBehaviour "AWARE";
            _wp setWaypointSpeed "LIMITED";
            _wp setWaypointFormation (if (_searching) then { "WEDGE" } else { "FILE" });
            _wp setWaypointCompletionRadius (if (_searching) then { 30 } else { 10 });
            
            _group setCurrentWaypoint _wp;
            _lastMoveTime = time;
            
            if (_debugLogging) then {
                diag_log format ["[RECONDO_RW] Group %1: Moving to %2 (%3)", _group, _moveTarget, _moveReason];
            };
        };
    };
    
    // Play sounds at interval (Wave 1 only)
    if (_useSounds && _groupSoundInterval > 0 && time - _lastSoundTime >= _groupSoundInterval) then {
        if (count _soundPools > 0 && !isNull _leader && alive _leader) then {
            // Equal-weight category draw; empty pool = silent this interval
            private _pool = selectRandom _soundPools;
            if (!(_pool isEqualTo [])) then {
                [_leader, _pool] remoteExec ["RECONDO_RW_fnc_playSound", 0];
            };
        };
        _lastSoundTime = time;
    };
    
    sleep 3;
};

// Cleanup - remove from active groups
private _activeGroups = _moduleSettings get "activeGroups";
_activeGroups = _activeGroups - [_group];
_moduleSettings set ["activeGroups", _activeGroups];
RECONDO_RW_ACTIVE_GROUPS = RECONDO_RW_ACTIVE_GROUPS - [_group];

if (_debugLogging) then {
    diag_log format ["[RECONDO_RW] Module %1: Tracker behavior ended for group %2", _moduleId, _group];
};
