/*
    Recondo_fnc_addPerfActions
    
    Description:
        Adds ACE self-interaction actions for the Performance Monitor.
        Actions are only visible to logged-in server admins.
        
    Parameters:
        None
        
    Returns:
        Nothing
        
    Actions Added:
        - Performance Monitor (parent category)
          - Start Monitoring
          - Stop Monitoring
          - Show Current Stats
          - Cycle Display Mode
          
    Author: GoonSix
*/

// Only run on machines with player interface
if (!hasInterface) exitWith {};

// ========================================
// ADMIN CHECK CONDITION
// ========================================
// This condition is evaluated each time the menu is opened
// Player must be logged in as admin to see the Performance Monitor option
private _isAdmin = {
    // Check multiple admin detection methods
    // serverCommandAvailable "#kick" - true if player can use server commands
    // admin owner player - returns admin level (0=none, 1=logged in, 2=voted in)
    serverCommandAvailable "#kick" || {admin owner player > 0}
};

// ========================================
// MAIN PERFORMANCE MONITOR ACTION (Parent)
// ========================================
private _mainAction = [
    "RECONDO_PerfMonitor",                              // Action name (unique ID)
    "Performance Monitor",                               // Display name
    "\a3\ui_f\data\igui\cfg\actions\gear_ca.paa",        // Icon
    {},                                                  // Statement (none - just a container)
    _isAdmin                                             // Condition - admin only
] call ace_interact_menu_fnc_createAction;

// Add to player's self-interaction menu
[player, 1, ["ACE_SelfActions"], _mainAction] call ace_interact_menu_fnc_addActionToObject;

// ========================================
// START MONITORING ACTION
// ========================================
private _startAction = [
    "RECONDO_PerfStart",
    "Start Monitoring",
    "\a3\ui_f\data\igui\cfg\actions\settimer_ca.paa",
    {
        [] call Recondo_fnc_startPerfMonitor;
    },
    {!RECONDO_PERF_RUNNING}  // Only show when NOT running
] call ace_interact_menu_fnc_createAction;

[player, 1, ["ACE_SelfActions", "RECONDO_PerfMonitor"], _startAction] call ace_interact_menu_fnc_addActionToObject;

// ========================================
// STOP MONITORING ACTION
// ========================================
private _stopAction = [
    "RECONDO_PerfStop",
    "Stop Monitoring",
    "\a3\ui_f\data\igui\cfg\actions\canceltimer_ca.paa",
    {
        [] call Recondo_fnc_stopPerfMonitor;
    },
    {RECONDO_PERF_RUNNING}  // Only show when running
] call ace_interact_menu_fnc_createAction;

[player, 1, ["ACE_SelfActions", "RECONDO_PerfMonitor"], _stopAction] call ace_interact_menu_fnc_addActionToObject;

// ========================================
// SHOW CURRENT STATS ACTION (One-time)
// ========================================
private _showAction = [
    "RECONDO_PerfShow",
    "Show Current Stats",
    "\a3\ui_f\data\igui\cfg\actions\ico_cpt_land_ca.paa",
    {
        // Collect and display metrics immediately with force-hint
        private _metrics = [] call Recondo_fnc_collectMetrics;
        [_metrics, true] call Recondo_fnc_displayMetrics;
    },
    {true}  // Always available
] call ace_interact_menu_fnc_createAction;

[player, 1, ["ACE_SelfActions", "RECONDO_PerfMonitor"], _showAction] call ace_interact_menu_fnc_addActionToObject;

// ========================================
// CYCLE DISPLAY MODE ACTION
// ========================================
private _cycleAction = [
    "RECONDO_PerfCycleMode",
    "Cycle Display Mode",
    "\a3\ui_f\data\igui\cfg\actions\repair_ca.paa",
    {
        private _settings = RECONDO_PERF_SETTINGS;
        private _currentMode = _settings getOrDefault ["displayMode", 0];
        private _newMode = (_currentMode + 1) mod 3;
        
        // Update local settings
        _settings set ["displayMode", _newMode];
        
        // Get mode name for feedback
        private _modeName = ["Hint (Overlay)", "System Chat", "RPT Only"] select _newMode;
        systemChat format ["[Perf Monitor] Display mode: %1", _modeName];
        
        // Log change
        diag_log format ["[RECONDO_PERF] Display mode changed to: %1", _modeName];
    },
    {true}  // Always available
] call ace_interact_menu_fnc_createAction;

[player, 1, ["ACE_SelfActions", "RECONDO_PerfMonitor"], _cycleAction] call ace_interact_menu_fnc_addActionToObject;

// ========================================
// TOGGLE RPT LOGGING ACTION
// ========================================
private _toggleRPTAction = [
    "RECONDO_PerfToggleRPT",
    "Toggle RPT Logging",
    "\a3\ui_f\data\igui\cfg\actions\talk_ca.paa",
    {
        private _settings = RECONDO_PERF_SETTINGS;
        private _currentState = _settings getOrDefault ["logToRPT", true];
        private _newState = !_currentState;
        
        // Update local settings
        _settings set ["logToRPT", _newState];
        
        // Feedback
        private _stateText = if (_newState) then {"ENABLED"} else {"DISABLED"};
        systemChat format ["[Perf Monitor] RPT logging: %1", _stateText];
        
        diag_log format ["[RECONDO_PERF] RPT logging %1", _stateText];
    },
    {true}
] call ace_interact_menu_fnc_createAction;

[player, 1, ["ACE_SelfActions", "RECONDO_PerfMonitor"], _toggleRPTAction] call ace_interact_menu_fnc_addActionToObject;

diag_log "[RECONDO_PERF] ACE self-interaction actions registered";
