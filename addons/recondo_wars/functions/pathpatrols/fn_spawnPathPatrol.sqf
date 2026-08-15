/*
    Recondo_fnc_spawnPathPatrol
    Spawns and configures patrol groups that move along path markers
    
    Description:
        Called when the path patrol trigger is activated. Spawns patrol groups
        that move along the predefined marker path, ping-ponging between endpoints.
        Each group starts at a random marker and moves in a random direction.
        When reaching an endpoint, the patrol reverses direction.
    
    Parameters:
        0: OBJECT - The trigger that was activated
        
    Returns:
        ARRAY - Array of spawned groups
        
    Example:
        [_trigger] call Recondo_fnc_spawnPathPatrol;
*/

if (!isServer) exitWith {
    diag_log "[RECONDO_PP] ERROR: Attempted to spawn group on non-server machine";
    []
};

params ["_trigger"];

// Get settings from trigger
private _settings = _trigger getVariable ["RECONDO_PP_SETTINGS", RECONDO_PP_SETTINGS];

private _debug = _settings get "enableDebug";
private _aiSide = _settings get "aiSide";
private _unitClassnames = _settings get "unitClassnames";
private _minGroupSize = _settings get "minGroupSize";
private _maxGroupSize = _settings get "maxGroupSize";
private _numberOfGroups = _settings get "numberOfGroups";
private _spawnPercentage = _settings get "spawnPercentage";
private _simulationDistance = _settings get "simulationDistance";
private _lambsReinforce = _settings get "lambsReinforce";
private _pathMarkers = _settings get "pathMarkers";
private _patrolBehaviour = _settings getOrDefault ["patrolBehaviour", "SAFE"];

if (_debug) then {
    diag_log format ["[RECONDO_PP] Trigger activated. Spawning up to %1 groups.", _numberOfGroups];
};

if (count _pathMarkers < 2) exitWith {
    diag_log "[RECONDO_PP] ERROR: Path must have at least 2 markers to patrol. Aborting.";
    []
};

private _spawnedGroups = [];

// Create pool of available markers for unique spawn positions
private _availableMarkerIndices = [];
for "_idx" from 0 to (count _pathMarkers - 1) do {
    _availableMarkerIndices pushBack _idx;
};

// Spawn each patrol group
for "_i" from 1 to _numberOfGroups do {
    
    // Check spawn percentage
    if (random 1 > _spawnPercentage) then {
        if (_debug) then {
            diag_log format ["[RECONDO_PP] Group %1 skipped due to spawn percentage", _i];
        };
        continue;
    };
    
    // Calculate random group size
    private _groupSize = _minGroupSize + floor random ((_maxGroupSize - _minGroupSize) + 1);
    _groupSize = _groupSize max 1;
    
    // Build group composition array
    private _groupArray = [];
    
    // First unit is always the first in the classname list (leader)
    _groupArray pushBack (_unitClassnames select 0);
    
    // Fill remaining slots with random units
    for "_j" from 1 to (_groupSize - 1) do {
        _groupArray pushBack (selectRandom _unitClassnames);
    };
    
    // Choose random starting marker from available pool (ensures unique spawn positions)
    // If pool is empty, refill it (allows reuse if more groups than markers)
    if (count _availableMarkerIndices == 0) then {
        for "_idx" from 0 to (count _pathMarkers - 1) do {
            _availableMarkerIndices pushBack _idx;
        };
        if (_debug) then {
            diag_log "[RECONDO_PP] Marker pool exhausted, refilling for additional groups";
        };
    };
    
    // Pick random index from available pool and remove it
    private _poolIndex = floor random (count _availableMarkerIndices);
    private _startMarkerIndex = _availableMarkerIndices select _poolIndex;
    _availableMarkerIndices deleteAt _poolIndex;
    
    private _startMarker = _pathMarkers select _startMarkerIndex;
    private _spawnPos = getMarkerPos _startMarker;
    
    // Choose random initial direction (true = ascending, false = descending)
    private _movingAscending = (random 1) > 0.5;
    
    if (_debug) then {
        diag_log format ["[RECONDO_PP] Spawning group %1 of %2 units at marker %3, direction: %4", 
            _i, _groupSize, _startMarker, if (_movingAscending) then {"ascending"} else {"descending"}];
    };
    
    // Create group
    private _group = [_spawnPos, _aiSide, _groupArray] call BIS_fnc_spawnGroup;
    
    if (isNull _group) then {
        diag_log format ["[RECONDO_PP] ERROR: Failed to create group %1", _i];
        continue;
    };
    
    // Set group behavior - relaxed patrol by default, normal speed
    _group setBehaviour _patrolBehaviour;
    _group setSpeedMode "NORMAL";
    _group setCombatMode "YELLOW";
    _group setFormation "STAG COLUMN";
    
    // Enable LAMBS group reinforcement if requested
    if (_lambsReinforce) then {
        _group setVariable ["lambs_danger_enableGroupReinforce", true, true];
    };
    
    // Mark group as spawned by this module
    _group setVariable ["RECONDO_PP_SPAWNED", true, true];
    _group setVariable ["RECONDO_PP_PATH_MARKERS", _pathMarkers, true];
    _group setVariable ["RECONDO_PP_CURRENT_INDEX", _startMarkerIndex, true];
    _group setVariable ["RECONDO_PP_ASCENDING", _movingAscending, true];
    
    // Store spawned group
    _spawnedGroups pushBack _group;
    
    // Create initial waypoints for this group
    [_group, _pathMarkers, _startMarkerIndex, _movingAscending, _patrolBehaviour, _debug] spawn {
        params ["_group", "_pathMarkers", "_currentIndex", "_ascending", "_patrolBehaviour", "_debug"];
        
        private _markerCount = count _pathMarkers;

        // Contact tracking: while the group knows about an enemy it fights in
        // COMBAT; the patrol behaviour is only restored after a calm period,
        // so the loop's waypoint resets never drag a fighting group back to
        // relaxed SAFE mode (which suppressed engagement entirely).
        private _inContact = false;
        private _lastContactTime = -1e6;
        private _calmDelay = 60;
        
        // Main patrol loop - continues until group is destroyed
        while {!isNull _group && {count units _group > 0}} do {
            
            // Calculate next marker index
            private _nextIndex = if (_ascending) then {
                _currentIndex + 1
            } else {
                _currentIndex - 1
            };
            
            // Check if we've reached an endpoint and need to reverse
            if (_nextIndex >= _markerCount) then {
                // Reached the end, reverse to descending
                _ascending = false;
                _nextIndex = _currentIndex - 1;
                
                if (_debug) then {
                    diag_log format ["[RECONDO_PP] Group %1 reached end, reversing to descending", _group];
                };
            };
            
            if (_nextIndex < 0) then {
                // Reached the beginning, reverse to ascending
                _ascending = true;
                _nextIndex = _currentIndex + 1;
                
                if (_debug) then {
                    diag_log format ["[RECONDO_PP] Group %1 reached start, reversing to ascending", _group];
                };
            };
            
            // Validate next index
            if (_nextIndex < 0 || _nextIndex >= _markerCount) then {
                // Something went wrong, reset to start
                _nextIndex = 0;
                _ascending = true;
            };
            
            // Get next marker position
            private _nextMarker = _pathMarkers select _nextIndex;
            private _nextPos = getMarkerPos _nextMarker;
            
            // Clear existing waypoints (except current position)
            while {count waypoints _group > 0} do {
                deleteWaypoint [_group, 0];
            };
            
            // Add waypoint to next marker. Waypoint behaviour is the reliable
            // cross-locality channel (waypoints are global commands), so it
            // carries COMBAT during contact even for HC-owned groups.
            private _wp = _group addWaypoint [_nextPos, 0];
            _wp setWaypointType "MOVE";
            _wp setWaypointBehaviour ([_patrolBehaviour, "COMBAT"] select _inContact);
            _wp setWaypointSpeed "NORMAL";
            _wp setWaypointFormation "STAG COLUMN";
            _wp setWaypointCompletionRadius 10;
            
            // Update group variables
            _group setVariable ["RECONDO_PP_CURRENT_INDEX", _nextIndex, true];
            _group setVariable ["RECONDO_PP_ASCENDING", _ascending, true];
            
            if (_debug) then {
                diag_log format ["[RECONDO_PP] Group %1 moving to marker %2 (index %3)", _group, _nextMarker, _nextIndex];
            };
            
            // Wait for group to reach waypoint or be destroyed
            waitUntil {
                sleep 2;
                
                // Check if group is destroyed
                if (isNull _group || {count units _group == 0}) exitWith { true };
                
                // Check if reached waypoint
                private _leader = leader _group;
                if (isNull _leader) exitWith { true };

                // Contact check: known enemy, or the owning machine's danger
                // FSM escalated the group itself. The behaviour test only
                // counts while not in contact - we set COMBAT ourselves, so
                // during contact only actual enemy knowledge refreshes the
                // timer, letting the group settle once knowledge decays.
                if (!isNull (_leader findNearestEnemy _leader) || {!_inContact && {behaviour _leader == "COMBAT"}}) then {
                    _lastContactTime = time;
                    if (!_inContact) then {
                        _inContact = true;
                        _group setBehaviour "COMBAT";
                        if (_debug) then {
                            diag_log format ["[RECONDO_PP] Group %1 in contact - switching to COMBAT", _group];
                        };
                    };
                };

                // Contact over: settle back to patrol behaviour after a calm period
                if (_inContact && {time - _lastContactTime > _calmDelay}) then {
                    _inContact = false;
                    _group setBehaviour _patrolBehaviour;
                    if (_debug) then {
                        diag_log format ["[RECONDO_PP] Group %1 contact over - resuming %2 patrol", _group, _patrolBehaviour];
                    };
                };
                
                (_leader distance _nextPos) < 20
            };
            
            // Update current index after reaching waypoint
            _currentIndex = _nextIndex;
            
            // Small delay before next waypoint
            sleep 1;
        };
        
        if (_debug) then {
            diag_log format ["[RECONDO_PP] Patrol loop ended for group %1", _group];
        };
    };
    
    // Register with centralized simulation monitoring system
    if (_simulationDistance > 0) then {
        [{
            params ["_group", "_simulationDistance", "_debug", "_startMarker"];
            if (!isNull _group && {count units _group > 0}) then {
                private _units = units _group;
                private _position = getPos (leader _group);
                private _identifier = format ["PP_%1_%2", _startMarker, _group];
                
                // Register units with the simulation system
                [_identifier, _units, _position, _simulationDistance] call Recondo_fnc_registerSimulation;
                
                if (_debug) then {
                    diag_log format ["[RECONDO_PP] Registered %1 units with simulation system at distance %2m", 
                        count _units, _simulationDistance];
                };
            };
        }, [_group, _simulationDistance, _debug, _startMarker], 2] call CBA_fnc_waitAndExecute;
    };
    
    if (_debug) then {
        diag_log format ["[RECONDO_PP] Group %1 spawned and patrol loop started", _i];
    };
};

// Track spawned groups globally
if (!isNil "RECONDO_PP_SPAWNED_GROUPS") then {
    { RECONDO_PP_SPAWNED_GROUPS pushBack _x } forEach _spawnedGroups;
};

// Hand the groups to a Headless Client if one is connected. The server-side
// patrol loop keeps working across locality because it only manages
// waypoints, which are global commands.
if (_settings getOrDefault ["enableHC", false]) then {
    { [_x, _debug] call Recondo_fnc_transferGroupToHC } forEach _spawnedGroups;
};

if (_debug) then {
    diag_log format ["[RECONDO_PP] Spawned %1 patrol groups", count _spawnedGroups];
};

// Log summary
diag_log format ["[RECONDO_PP] Path patrol trigger activated. Spawned %1 of %2 requested groups.", 
    count _spawnedGroups, _numberOfGroups];

_spawnedGroups
