/*
    Recondo_fnc_convoySpawnLoop
    Main spawn loop for convoy system
    
    Description:
        Continuously checks if new convoys can be spawned and
        spawns them when conditions are met.
        
        - First convoy spawns after the configured spawn delay (not immediately)
        - If synced to objectives, routes to those locations
        - If no objectives available (or none synced), uses direct route (start -> end)
    
    Parameters:
        0: HASHMAP - Settings from module
        
    Returns:
        Nothing
*/

params [["_settings", nil, [createHashMap]]];

if (isNil "_settings") exitWith {
    diag_log "[RECONDO_CONVOY] ERROR: No settings provided to spawn loop";
};

private _maxActive = _settings get "maxActive";
private _spawnDelayMin = _settings get "spawnDelayMin";
private _spawnDelayMax = _settings get "spawnDelayMax";
private _debugLogging = _settings get "debugLogging";
private _hasSyncedObjectives = _settings get "hasSyncedObjectives";
private _stopAtObjective = _settings get "stopAtObjective";

if (_debugLogging) then {
    diag_log "[RECONDO_CONVOY] Spawn loop started";
};

// Initial delay - same as normal spawn delay (first convoy doesn't spawn immediately)
private _initialDelay = _spawnDelayMin + random (_spawnDelayMax - _spawnDelayMin);

if (_debugLogging) then {
    diag_log format ["[RECONDO_CONVOY] Initial spawn delay: %1 seconds (%2 minutes)", _initialDelay, _initialDelay / 60];
};

sleep _initialDelay;

while {true} do {
    // Check if we can spawn a new convoy
    private _activeCount = count RECONDO_CONVOY_ACTIVE;
    
    if (_activeCount < _maxActive) then {
        private _objective = [];
        private _useDirectRoute = false;
        
        // Routing logic:
        // If "Stop at Active Objectives" is enabled AND synced objectives exist:
        //   - Try to route to an active objective
        //   - If no objectives available, fall back to waypoint markers (direct route)
        // If "Stop at Active Objectives" is disabled OR no synced objectives:
        //   - Use waypoint markers (direct route)
        
        if (_stopAtObjective && _hasSyncedObjectives) then {
            // Get active objectives from synced modules
            private _objectives = [_settings] call Recondo_fnc_getActiveObjectives;
            
            if (count _objectives > 0) then {
                // Select random objective
                _objective = selectRandom _objectives;
                
                if (_debugLogging) then {
                    _objective params ["_marker", "_pos", "_type"];
                    diag_log format ["[RECONDO_CONVOY] Selected objective: %1 (%2)", _marker, _type];
                };
            } else {
                // No active objectives available - fall back to waypoint markers
                _useDirectRoute = true;
                
                if (_debugLogging) then {
                    diag_log "[RECONDO_CONVOY] No active objectives available - falling back to waypoint markers";
                };
            };
        } else {
            // Either "Stop at Active Objectives" is disabled or no objectives synced
            // Use waypoint markers (direct route)
            _useDirectRoute = true;
            
            if (_debugLogging) then {
                if (!_stopAtObjective) then {
                    diag_log "[RECONDO_CONVOY] 'Stop at Active Objectives' disabled - using waypoint markers";
                } else {
                    diag_log "[RECONDO_CONVOY] No objectives synced - using waypoint markers";
                };
            };
        };
        
        // Spawn convoy (with objective or direct route)
        private _convoyData = [_settings, _objective] call Recondo_fnc_spawnConvoy;
        
        if (!isNull (_convoyData select 0)) then {
            RECONDO_CONVOY_ACTIVE pushBack _convoyData;
            publicVariable "RECONDO_CONVOY_ACTIVE";
            
            if (_debugLogging) then {
                private _routeType = if (_useDirectRoute || count _objective == 0) then { "direct" } else { "objective" };
                diag_log format ["[RECONDO_CONVOY] Convoy spawned (%1 route). Active: %2/%3", _routeType, count RECONDO_CONVOY_ACTIVE, _maxActive];
            };
            
            // Random delay before next spawn attempt
            private _delay = _spawnDelayMin + random (_spawnDelayMax - _spawnDelayMin);
            
            if (_debugLogging) then {
                diag_log format ["[RECONDO_CONVOY] Next spawn in %1 seconds (%2 minutes)", _delay, _delay / 60];
            };
            
            sleep _delay;
        } else {
            if (_debugLogging) then {
                diag_log "[RECONDO_CONVOY] Failed to spawn convoy, retrying in 60s";
            };
            sleep 60;
        };
    } else {
        // At max capacity, wait before checking again
        sleep 30;
    };
};
