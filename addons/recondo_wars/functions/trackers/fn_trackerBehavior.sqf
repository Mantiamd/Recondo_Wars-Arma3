/*
    Recondo_fnc_trackerBehavior
    Main behavior loop for tracker groups
    
    Description:
        Controls tracker movement by following footprints and using predictive pursuit
        when footprints run out.
    
    Parameters:
        _group - The tracker group
    
    Returns:
        Nothing (spawned function)
*/

if (!isServer) exitWith {};

params ["_group"];

private _settings = RECONDO_TRACKERS_SETTINGS;
private _movementSpeed = _settings get "movementSpeed";
private _soundInterval = _settings get "soundInterval";
private _predictiveDistanceMin = _settings get "predictiveDistanceMin";
private _predictiveDistanceMax = _settings get "predictiveDistanceMax";
private _debugLogging = _settings get "debugLogging";
private _debugMarkers = _settings get "debugMarkers";

// Get target group ID string for footprint comparison
private _targetGroupId = _group getVariable ["RECONDO_TRACKERS_targetGroupId", ""];
if (_targetGroupId == "") exitWith {
    diag_log format ["[RECONDO_TRACKERS] ERROR: Tracker group %1 has no assigned target group ID", _group];
};

// Get sounds based on whether group has dog
private _hasDog = _group getVariable ["RECONDO_TRACKERS_hasDog", false];
private _sounds = if (_hasDog) then {
    _settings get "soundsWithDog"
} else {
    _settings get "soundsNoDog"
};

private _leader = leader _group;
private _currentFootprintIndex = 0;
private _hasCompletedPredictiveMovement = false;
private _lastKnownDirection = [0, 1, 0]; // Default north

// Function to calculate average direction from footprints
private _fnc_calculateAverageDirection = {
    params ["_footprints", "_currentIndex"];
    
    if (count _footprints < 3) exitWith {
        private _randomDir = random 360;
        [sin _randomDir, cos _randomDir, 0]
    };
    
    private _lastThreeFootprints = [];
    private _startIndex = (count _footprints - 3) max 0;
    
    for "_i" from _startIndex to ((count _footprints - 1) min (_startIndex + 2)) do {
        _lastThreeFootprints pushBack (_footprints select _i select 0);
    };
    
    if (count _lastThreeFootprints < 2) exitWith {
        private _randomDir = random 360;
        [sin _randomDir, cos _randomDir, 0]
    };
    
    private _vectors = [];
    for "_i" from 1 to (count _lastThreeFootprints - 1) do {
        private _vector = (_lastThreeFootprints select _i) vectorDiff (_lastThreeFootprints select (_i - 1));
        _vectors pushBack _vector;
    };
    
    if (count _vectors == 0) exitWith {
        private _randomDir = random 360;
        [sin _randomDir, cos _randomDir, 0]
    };
    
    private _avgVector = [0, 0, 0];
    {
        _avgVector = _avgVector vectorAdd _x;
    } forEach _vectors;
    
    _avgVector = _avgVector vectorMultiply (1 / (count _vectors max 1));
    _avgVector
};

// Function to play tracker sound
private _fnc_playTrackerSound = {
    params ["_unit", "_sounds"];
    
    private _nearbyPlayers = allPlayers select { _x distance _unit < 350 };
    if (count _nearbyPlayers > 0) then {
        [_unit, _sounds] remoteExec ["RECONDO_TRACKERS_fnc_playSound", _nearbyPlayers];
    };
};

// Spawn sound thread if sounds enabled
if (_soundInterval > 0) then {
    [_group, _soundInterval, _sounds, _fnc_playTrackerSound] spawn {
        params ["_group", "_baseInterval", "_sounds", "_soundFunc"];
        private _leader = leader _group;
        
        // Each group gets its own randomized interval (base ±10 seconds)
        private _groupInterval = (_baseInterval + (random 20) - 10) max 5;
        
        // Random initial delay so groups don't sync up
        sleep (random _groupInterval);
        
        while {alive _leader} do {
            [_leader, _sounds] call _soundFunc;
            sleep _groupInterval;
        };
    };
};

// Ensure group maintains configured speed
_group setSpeedMode _movementSpeed;

if (_debugLogging) then {
    diag_log format ["[RECONDO_TRACKERS] Tracker %1 starting behavior, tracking %2", _group, _targetGroupId];
};

// Main behavior loop
while {alive _leader} do {
    // Filter out aircraft and excluded targets from AI awareness
    [_group, _settings] call Recondo_fnc_filterAirTargets;
    
    // Filter footprints to only those from our target group and sort by time
    private _targetFootprints = RECONDO_TRACKERS_FOOTPRINTS select {_x select 2 == _targetGroupId};
    _targetFootprints sort true; // Sort by time (oldest first)
    
    // Update last known direction from footprints
    if (count _targetFootprints >= 2) then {
        private _lastPos = (_targetFootprints select (count _targetFootprints - 1)) select 0;
        private _prevPos = (_targetFootprints select (count _targetFootprints - 2)) select 0;
        private _dir = _lastPos vectorDiff _prevPos;
        if (vectorMagnitude _dir > 0.1) then {
            _lastKnownDirection = vectorNormalized _dir;
            _group setVariable ["RECONDO_TRACKERS_lastDirection", _lastKnownDirection, true];
        };
    };
    
    if (count _targetFootprints > 0) then {
        // Always try to move to the next unvisited footprint
        if (_currentFootprintIndex >= count _targetFootprints) then {
            // We've reached all current footprints, wait to see if new ones appear
            private _startWaitTime = time;
            private _newFootprintsFound = false;
            
            while {time - _startWaitTime < 5} do {
                private _currentFootprints = RECONDO_TRACKERS_FOOTPRINTS select {_x select 2 == _targetGroupId};
                if (count _currentFootprints > count _targetFootprints) then {
                    _newFootprintsFound = true;
                    _targetFootprints = _currentFootprints;
                    _targetFootprints sort true;
                };
                sleep 1;
            };
            
            if (_newFootprintsFound) then {
                if (_debugLogging) then {
                    diag_log format ["[RECONDO_TRACKERS] Group %1 found new footprints to follow", _group];
                };
            } else {
                // No new footprints, start predictive movement if we haven't already
                if (!_hasCompletedPredictiveMovement) then {
                    if (_debugLogging) then {
                        diag_log format ["[RECONDO_TRACKERS] Group %1 starting predictive movement", _group];
                    };
                    
                    // Calculate average direction from last 3 footprints
                    private _avgDirection = [_targetFootprints, count _targetFootprints - 1] call _fnc_calculateAverageDirection;
                    private _avgDirectionNorm = vectorNormalized _avgDirection;
                    
                    // Update last known direction
                    _lastKnownDirection = _avgDirectionNorm;
                    _group setVariable ["RECONDO_TRACKERS_lastDirection", _lastKnownDirection, true];
                    
                    // Calculate random distance within configured range
                    private _predictiveDistance = _predictiveDistanceMin + random (_predictiveDistanceMax - _predictiveDistanceMin);
                    
                    // Calculate target position
                    private _startPos = getPos _leader;
                    private _targetPos = _startPos vectorAdd (_avgDirectionNorm vectorMultiply _predictiveDistance);
                    
                    // Create debug marker for predictive movement
                    if (_debugMarkers) then {
                        private _markerName = format ["RECONDO_TRACKERS_pred_%1_%2", _group, time];
                        private _marker = createMarker [_markerName, _targetPos];
                        _marker setMarkerType "mil_dot";
                        _marker setMarkerColor "ColorYellow";
                        _marker setMarkerText format ["Pred_%1m", round _predictiveDistance];
                    };
                    
                    // Move to target position
                    _group move _targetPos;
                    _group setVariable ["RECONDO_TRACKERS_currentTargetPos", _targetPos, true];
                    
                    // Wait until we reach the target
                    while {_leader distance _targetPos > 5 && alive _leader} do {
                        _group setSpeedMode _movementSpeed;
                        
                        // Check for new footprints while moving
                        private _newFootprints = RECONDO_TRACKERS_FOOTPRINTS select {_x select 2 == _targetGroupId};
                        if (count _newFootprints > count _targetFootprints) then {
                            // New footprints found, abandon predictive movement
                            _hasCompletedPredictiveMovement = false;
                            _currentFootprintIndex = count _targetFootprints;
                            if (_debugLogging) then {
                                diag_log format ["[RECONDO_TRACKERS] Group %1 abandoning predictive movement for new footprints", _group];
                            };
                        };
                        
                        sleep 1;
                    };
                    
                    _hasCompletedPredictiveMovement = true;
                    
                    // ========================================
                    // PHASE 3: AREA SEARCH PATROL
                    // ========================================
                    // After predictive movement, search the area for fresh trails
                    
                    if (_debugLogging) then {
                        diag_log format ["[RECONDO_TRACKERS] Group %1 starting area search patrol", _group];
                    };
                    
                    private _searchRadius = 40;
                    private _searchDuration = 90;
                    private _waypointRadius = 15;
                    private _searchStartTime = time;
                    private _patrolPointsVisited = 0;
                    private _foundNewTrail = false;
                    
                    // Search pattern: move to random points within radius, biased toward last known direction
                    while {time - _searchStartTime < _searchDuration && alive _leader && !_foundNewTrail} do {
                        // Generate patrol point biased toward last known direction (±90°)
                        private _lastDir = _group getVariable ["RECONDO_TRACKERS_lastDirection", [0,1,0]];
                        private _baseAngle = (_lastDir select 0) atan2 (_lastDir select 1);
                        private _patrolAngle = _baseAngle + (random 180) - 90;
                        private _dist = 10 + random (_searchRadius - 10);
                        private _patrolPos = getPos _leader vectorAdd [sin(_patrolAngle) * _dist, cos(_patrolAngle) * _dist, 0];
                        
                        // Create debug marker for search patrol
                        if (_debugMarkers) then {
                            private _searchMarkerName = format ["RECONDO_TRACKERS_search_%1_%2", _group, _patrolPointsVisited];
                            private _searchMarker = createMarker [_searchMarkerName, _patrolPos];
                            _searchMarker setMarkerType "mil_dot";
                            _searchMarker setMarkerColor "ColorOrange";
                            _searchMarker setMarkerSize [0.4, 0.4];
                        };
                        
                        _group move _patrolPos;
                        _group setSpeedMode "LIMITED";
                        _group setBehaviour "COMBAT";
                        
                        private _patrolStartTime = time;
                        private _patrolTimeout = 20;
                        
                        // Move to patrol point while checking for new footprints
                        while {_leader distance _patrolPos > _waypointRadius && 
                               alive _leader && 
                               time - _patrolStartTime < _patrolTimeout &&
                               !_foundNewTrail} do {
                            
                            // Check for new footprints during search
                            private _currentFootprints = RECONDO_TRACKERS_FOOTPRINTS select {_x select 2 == _targetGroupId};
                            if (count _currentFootprints > count _targetFootprints) then {
                                _foundNewTrail = true;
                                _hasCompletedPredictiveMovement = false;
                                _currentFootprintIndex = count _targetFootprints;
                                
                                if (_debugLogging) then {
                                    diag_log format ["[RECONDO_TRACKERS] Group %1 found fresh trail during area search!", _group];
                                };
                            };
                            
                            sleep 1;
                        };
                        
                        _patrolPointsVisited = _patrolPointsVisited + 1;
                    };
                    
                    // Reset to normal behavior after search
                    _group setSpeedMode _movementSpeed;
                    _group setBehaviour "SAFE";
                    
                    if (_debugLogging) then {
                        private _result = if (_foundNewTrail) then {"FOUND TRAIL"} else {"gave up"};
                        diag_log format ["[RECONDO_TRACKERS] Group %1 area search complete - %2 (%3 points, %4s)", 
                            _group, _result, _patrolPointsVisited, round(time - _searchStartTime)];
                    };
                };
            };
        } else {
            // Move to next footprint in sequence
            private _nextFootprint = _targetFootprints select _currentFootprintIndex;
            private _footprintPos = _nextFootprint select 0;
            
            if (_debugLogging) then {
                diag_log format ["[RECONDO_TRACKERS] Group %1 moving to footprint %2/%3", _group, _currentFootprintIndex + 1, count _targetFootprints];
            };
            
            // Move to the footprint
            _group move _footprintPos;
            _group setVariable ["RECONDO_TRACKERS_currentTargetPos", _footprintPos, true];
            _group setSpeedMode _movementSpeed;
            
            // Wait until we reach the footprint
            while {_leader distance _footprintPos > 2 && alive _leader} do {
                _group setSpeedMode _movementSpeed;
                
                // Check for new footprints while moving
                private _newFootprints = RECONDO_TRACKERS_FOOTPRINTS select {_x select 2 == _targetGroupId};
                if (count _newFootprints > count _targetFootprints) then {
                    // Continue to current footprint but update total count
                    _targetFootprints = _newFootprints;
                    _targetFootprints sort true;
                    if (_debugLogging) then {
                        diag_log format ["[RECONDO_TRACKERS] Group %1 detected new footprints while moving", _group];
                    };
                };
                
                sleep 1;
            };
            
            // Move to next footprint index
            _currentFootprintIndex = _currentFootprintIndex + 1;
        };
    } else {
        sleep 1;
    };
};

// Cleanup when leader dies
RECONDO_TRACKERS_ACTIVE_GROUPS = RECONDO_TRACKERS_ACTIVE_GROUPS - [_group];
RECONDO_TRACKERS_SPEED_BASED = RECONDO_TRACKERS_SPEED_BASED - [_group];

if (_debugLogging) then {
    diag_log format ["[RECONDO_TRACKERS] Tracker %1 behavior ended - leader dead", _group];
};
