/*
    Recondo_fnc_simulationMonitorLoop
    Per-frame handler that monitors player distances and toggles simulation
    
    Description:
        Runs every 5 seconds, checking all registered entity groups against
        player positions. Enables simulation when players are within the
        configured distance, disables when outside (with +100m hysteresis).
    
    Parameters:
        None
    
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

if (RECONDO_SIM_LOOP_RUNNING) exitWith {
    if (RECONDO_SIM_DEBUG) then {
        diag_log "[RECONDO_SIM] Monitor loop already running";
    };
};

RECONDO_SIM_LOOP_RUNNING = true;
diag_log "[RECONDO_SIM] Starting simulation monitor loop (5 second interval)";

// Use CBA per-frame handler with 5 second delay
[{
    // Get all players
    private _allPlayers = allPlayers select { alive _x };
    
    if (count _allPlayers == 0) exitWith {};
    
    // Process each registered entry
    {
        _x params ["_identifier", "_entities", "_position", "_simulationDistance", "_currentlyEnabled"];
        
        // Filter to still-valid entities
        private _validEntities = _entities select { !isNull _x && { alive _x || !(_x isKindOf "CAManBase") } };
        
        // Update the registry with cleaned entity list
        if (count _validEntities != count _entities) then {
            _x set [1, _validEntities];
        };
        
        // Skip if no valid entities remain
        if (count _validEntities == 0) then {
            continue;
        };
        
        // Find closest player distance to this group's position
        private _closestDist = 999999;
        {
            private _dist = _x distance2D _position;
            if (_dist < _closestDist) then {
                _closestDist = _dist;
            };
        } forEach _allPlayers;
        
        // Calculate enable/disable thresholds with hysteresis
        private _enableDist = _simulationDistance;
        private _disableDist = _simulationDistance + 100; // +100m hysteresis
        
        // Determine if simulation should be enabled
        private _shouldBeEnabled = if (_currentlyEnabled) then {
            // Currently enabled - use disable threshold (farther)
            _closestDist <= _disableDist
        } else {
            // Currently disabled - use enable threshold (closer)
            _closestDist <= _enableDist
        };
        
        // Toggle simulation if state changed
        if (_shouldBeEnabled != _currentlyEnabled) then {
            {
                if (!isNull _x) then {
                    _x enableSimulationGlobal _shouldBeEnabled;
                };
            } forEach _validEntities;
            
            // Update state in registry
            _x set [4, _shouldBeEnabled];
            
            if (RECONDO_SIM_DEBUG) then {
                diag_log format ["[RECONDO_SIM] %1: Simulation %2 (%3 entities, closest player: %4m, threshold: %5m)", 
                    _identifier, 
                    if (_shouldBeEnabled) then { "ENABLED" } else { "DISABLED" },
                    count _validEntities,
                    round _closestDist,
                    if (_shouldBeEnabled) then { _enableDist } else { _disableDist }
                ];
            };
        };
    } forEach RECONDO_SIM_REGISTRY;
    
    // Cleanup empty entries
    RECONDO_SIM_REGISTRY = RECONDO_SIM_REGISTRY select { count (_x select 1) > 0 };
    
}, 5] call CBA_fnc_addPerFrameHandler;
