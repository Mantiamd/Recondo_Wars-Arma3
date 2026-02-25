/*
    Recondo_fnc_stopPerfMonitor
    
    Description:
        Stops the performance monitoring loop.
        Cleans up the perFrameHandler and clears any displayed hints.
        
    Parameters:
        None
        
    Returns:
        Nothing
        
    Author: GoonSix
*/

// Check if running
if (!RECONDO_PERF_RUNNING) exitWith {
    diag_log "[RECONDO_PERF] Monitor not running - ignoring stop request";
    if (hasInterface) then {
        systemChat "[Perf Monitor] Not currently running";
    };
};

// Set flag to stop (the perFrameHandler will clean itself up on next tick)
RECONDO_PERF_RUNNING = false;

// Also force-remove the handler if it exists
if (!isNil "RECONDO_PERF_HANDLE") then {
    [RECONDO_PERF_HANDLE] call CBA_fnc_removePerFrameHandler;
    RECONDO_PERF_HANDLE = nil;
};

// Clear any displayed hint
if (hasInterface) then {
    hintSilent "";
    systemChat "[Perf Monitor] Monitoring stopped";
};

diag_log "[RECONDO_PERF] Monitor stopped";
