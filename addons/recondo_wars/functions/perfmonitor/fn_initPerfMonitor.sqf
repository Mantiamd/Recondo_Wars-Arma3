/*
    Recondo_fnc_initPerfMonitor
    
    Description:
        Initializes the Performance Monitor system on each client.
        Adds ACE self-interaction actions for admin players.
        Called via BIS_fnc_MP from the module initialization.
        
    Parameters:
        None
        
    Returns:
        Nothing
        
    Author: GoonSix
*/

// Only run on machines with a player interface
if (!hasInterface) exitWith {};

// Wait for settings to be available from server
[{
    !isNil "RECONDO_PERF_SETTINGS"
}, {
    // Add ACE actions for this player
    [] call Recondo_fnc_addPerfActions;
    
    // Get settings
    private _settings = RECONDO_PERF_SETTINGS;
    private _autoStart = _settings getOrDefault ["autoStart", false];
    private _showLocalOnly = _settings getOrDefault ["showLocalOnly", false];
    private _debugLogging = _settings getOrDefault ["debugLogging", false];
    
    // If local-only mode and auto-start is enabled, start local monitoring
    if (_autoStart && _showLocalOnly) then {
        [] call Recondo_fnc_startPerfMonitor;
        if (_debugLogging) then {
            diag_log "[RECONDO_PERF] Auto-started local monitoring for this client";
        };
    };
    
    diag_log "[RECONDO_PERF] Client initialized - ACE actions added for admin access";
    
}, [], 30, {
    // Timeout handler - settings never arrived
    diag_log "[RECONDO_PERF] ERROR: Timeout waiting for RECONDO_PERF_SETTINGS from server";
}] call CBA_fnc_waitUntilAndExecute;
