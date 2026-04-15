/*
    Recondo_fnc_modulePerfMonitor
    
    Description:
        Eden module initialization for Performance Monitoring.
        Provides real-time performance metrics accessible via ACE self-interaction.
        Only available to logged-in server admins.
        
    Parameters:
        _logic      - Module logic object [OBJECT]
        _units      - Synchronized units (unused) [ARRAY]
        _activated  - Module activated state [BOOL]
        
    Returns:
        Nothing
        
    Requirements:
        - CBA_A3
        - ACE3
        
    Author: GoonSix
*/

params [
    ["_logic", objNull, [objNull]],
    ["_units", [], [[]]],
    ["_activated", true, [true]]
];

if (!_activated) exitWith {
    diag_log "[RECONDO_PERF] Module not activated";
};

if (!isServer) exitWith {};

// ========================================
// GET MODULE ATTRIBUTES
// ========================================
private _updateInterval = _logic getVariable ["updateinterval", 5];
private _displayMode = _logic getVariable ["displaymode", 0];
private _autoStart = _logic getVariable ["autostart", false];
private _logToRPT = _logic getVariable ["logtorpt", true];
private _showLocalOnly = _logic getVariable ["showlocalonly", false];
private _debugLogging = _logic getVariable ["debuglogging", false];
if (RECONDO_MASTER_DEBUG) then { _debugLogging = true; };

// ========================================
// VALIDATE SETTINGS
// ========================================
// Enforce minimum interval of 1 second
if (_updateInterval < 1) then {
    _updateInterval = 1;
    diag_log "[RECONDO_PERF] Warning: Update interval too low, set to 1 second minimum";
};

// Enforce maximum interval of 300 seconds (5 minutes)
if (_updateInterval > 300) then {
    _updateInterval = 300;
    diag_log "[RECONDO_PERF] Warning: Update interval too high, capped at 300 seconds";
};

// ========================================
// STORE SETTINGS GLOBALLY
// ========================================
RECONDO_PERF_SETTINGS = createHashMapFromArray [
    ["updateInterval", _updateInterval],
    ["displayMode", _displayMode],
    ["autoStart", _autoStart],
    ["logToRPT", _logToRPT],
    ["showLocalOnly", _showLocalOnly],
    ["debugLogging", _debugLogging]
];

// Broadcast settings to all clients
publicVariable "RECONDO_PERF_SETTINGS";

// ========================================
// LOG INITIALIZATION
// ========================================
private _displayModeText = ["Hint", "SystemChat", "RPT Only"] select _displayMode;

diag_log format [
    "[RECONDO_PERF] Module initialized - Interval: %1s | Display: %2 | AutoStart: %3 | LogRPT: %4 | LocalOnly: %5 | Debug: %6",
    _updateInterval,
    _displayModeText,
    _autoStart,
    _logToRPT,
    _showLocalOnly,
    _debugLogging
];

// ========================================
// INITIALIZE ON ALL CLIENTS
// ========================================
// This adds ACE actions for admin players
[] remoteExecCall ["Recondo_fnc_initPerfMonitor", 0, true];

// ========================================
// AUTO-START IF ENABLED (SERVER-SIDE)
// ========================================
if (_autoStart && !_showLocalOnly) then {
    // Delay slightly to ensure all systems are initialized
    [{
        [] call Recondo_fnc_startPerfMonitor;
        diag_log "[RECONDO_PERF] Auto-started server-side monitoring";
    }, [], 3] call CBA_fnc_waitAndExecute;
};

diag_log "[RECONDO_PERF] Module setup complete";
