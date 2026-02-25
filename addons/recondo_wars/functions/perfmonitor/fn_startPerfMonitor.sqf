/*
    Recondo_fnc_startPerfMonitor
    
    Description:
        Starts the performance monitoring loop.
        Uses CBA perFrameHandler for efficient scheduling.
        
    Parameters:
        None
        
    Returns:
        Nothing
        
    Author: GoonSix
*/

// Check if already running
if (RECONDO_PERF_RUNNING) exitWith {
    diag_log "[RECONDO_PERF] Monitor already running - ignoring start request";
};

// Check if settings are available
if (isNil "RECONDO_PERF_SETTINGS") exitWith {
    diag_log "[RECONDO_PERF] ERROR: Cannot start - settings not initialized";
    if (hasInterface) then {
        systemChat "[Perf Monitor] ERROR: Module not initialized";
    };
};

private _settings = RECONDO_PERF_SETTINGS;
private _interval = _settings getOrDefault ["updateInterval", 5];
private _showLocalOnly = _settings getOrDefault ["showLocalOnly", false];
private _debugLogging = _settings getOrDefault ["debugLogging", false];

// Determine if this machine should run the monitor
private _shouldRun = if (_showLocalOnly) then {
    hasInterface  // Each client runs locally
} else {
    isServer  // Only server runs and broadcasts
};

if (!_shouldRun) exitWith {
    if (_debugLogging) then {
        diag_log "[RECONDO_PERF] This machine should not run the monitor (locality check failed)";
    };
};

// Set running flag
RECONDO_PERF_RUNNING = true;

diag_log format ["[RECONDO_PERF] Starting monitor loop - Interval: %1s | Machine: %2", 
    _interval, 
    if (isDedicated) then {"Dedicated Server"} else {if (isServer) then {"Hosted Server"} else {"Client"}}
];

// Main monitoring loop using CBA perFrameHandler
// This is more efficient than spawn/sleep loops
RECONDO_PERF_HANDLE = [{
    params ["_args", "_handle"];
    _args params ["_lastUpdate", "_interval"];
    
    // Check if we should stop
    if (!RECONDO_PERF_RUNNING) exitWith {
        [_handle] call CBA_fnc_removePerFrameHandler;
        RECONDO_PERF_HANDLE = nil;
        hintSilent "";
        diag_log "[RECONDO_PERF] Monitor loop terminated";
    };
    
    // Check if enough time has passed
    private _now = CBA_missionTime;
    if (_now - _lastUpdate < _interval) exitWith {};
    
    // Update last run time
    _args set [0, _now];
    
    // Collect metrics
    private _metrics = [] call Recondo_fnc_collectMetrics;
    RECONDO_PERF_METRICS = _metrics;
    
    // Display/log based on settings (continuous mode = false)
    [_metrics, false] call Recondo_fnc_displayMetrics;
    
}, 0.5, [CBA_missionTime, _interval]] call CBA_fnc_addPerFrameHandler;

if (hasInterface) then {
    systemChat "[Perf Monitor] Monitoring started";
};

diag_log "[RECONDO_PERF] Monitor started successfully";
