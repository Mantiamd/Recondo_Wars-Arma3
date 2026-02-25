/*
    Recondo_fnc_displayMetrics
    
    Description:
        Displays collected metrics based on current display mode settings.
        Supports Hint (structured text), System Chat (compact), and RPT-only modes.
        
    Parameters:
        _metrics    - HashMap of collected metrics [HASHMAP]
        _forceHint  - If true, always display as hint regardless of mode [BOOL]
        
    Returns:
        Nothing
        
    Author: GoonSix
*/

params [
    ["_metrics", createHashMap, [createHashMap]],
    ["_forceHint", false, [false]]
];

// Validate input
if (_metrics isEqualTo createHashMap) exitWith {
    diag_log "[RECONDO_PERF] displayMetrics called with empty metrics";
};

// Get settings
private _settings = RECONDO_PERF_SETTINGS;
private _displayMode = _settings getOrDefault ["displayMode", 0];
private _logToRPT = _settings getOrDefault ["logToRPT", true];
private _debugLogging = _settings getOrDefault ["debugLogging", false];

// ========================================
// EXTRACT METRICS
// ========================================
private _fps = _metrics getOrDefault ["fps", 0];
private _fpsMin = _metrics getOrDefault ["fpsMin", 0];
private _players = _metrics getOrDefault ["players", 0];
private _localAI = _metrics getOrDefault ["localAI", 0];
private _remoteAI = _metrics getOrDefault ["remoteAI", 0];
private _totalUnits = _metrics getOrDefault ["totalUnitsAlive", 0];
private _groups = _metrics getOrDefault ["groups", 0];
private _vehicles = _metrics getOrDefault ["vehicles", 0];
private _emptyVehicles = _metrics getOrDefault ["emptyVehicles", 0];
private _deadBodies = _metrics getOrDefault ["deadBodies", 0];
private _triggers = _metrics getOrDefault ["triggers", 0];
private _allObjects = _metrics getOrDefault ["allObjects", 0];
private _entities = _metrics getOrDefault ["entities", 0];
private _scriptsTotal = _metrics getOrDefault ["scriptsTotal", 0];
private _scriptsSpawn = _metrics getOrDefault ["scriptsSpawn", 0];
private _scriptsExecVM = _metrics getOrDefault ["scriptsExecVM", 0];
private _scriptsExec = _metrics getOrDefault ["scriptsExec", 0];
private _scriptsFSM = _metrics getOrDefault ["scriptsFSM", 0];
private _markers = _metrics getOrDefault ["markers", 0];
private _waypoints = _metrics getOrDefault ["waypoints", 0];
private _simDisabled = _metrics getOrDefault ["simDisabled", 0];
private _machineType = _metrics getOrDefault ["machineType", "Unknown"];
private _hcCount = _metrics getOrDefault ["headlessClients", 0];

// ========================================
// COLOR CODING FOR FPS
// ========================================
private _fpsColor = switch (true) do {
    case (_fps >= 40): {"#00FF00"};  // Green - Excellent
    case (_fps >= 30): {"#90EE90"};  // Light Green - Good
    case (_fps >= 25): {"#FFFF00"};  // Yellow - Acceptable
    case (_fps >= 15): {"#FFA500"};  // Orange - Poor
    default {"#FF0000"};              // Red - Critical
};

// Color for concerning values
private _deadColor = if (_deadBodies > 50) then {"#FF6347"} else {"#FFFFFF"};
private _scriptsColor = if (_scriptsTotal > 50) then {"#FF6347"} else {"#FFFFFF"};
private _triggersColor = if (_triggers > 100) then {"#FFA500"} else {"#FFFFFF"};

// ========================================
// HINT DISPLAY FORMAT (Structured Text)
// ========================================
private _hintText = parseText format [
    "<t size='1.2' color='#FFD700'>═══ PERFORMANCE MONITOR ═══</t><br/>" +
    "<t size='0.9' color='#888888'>%1 | HCs: %2</t><br/><br/>" +
    
    "<t size='1.0' color='#87CEEB'>▸ FRAME RATE</t><br/>" +
    "  <t color='%3'>FPS: %4</t>  |  <t color='#AAAAAA'>Min: %5</t><br/><br/>" +
    
    "<t size='1.0' color='#87CEEB'>▸ UNITS (%6 alive)</t><br/>" +
    "  Players: <t color='#90EE90'>%7</t>  |  Local AI: <t color='#FFB6C1'>%8</t>  |  Remote AI: <t color='#DDA0DD'>%9</t><br/>" +
    "  Groups: %10  |  Sim Off: <t color='#888888'>%11</t><br/><br/>" +
    
    "<t size='1.0' color='#87CEEB'>▸ VEHICLES</t><br/>" +
    "  Total: %12  |  Empty: <t color='#888888'>%13</t><br/><br/>" +
    
    "<t size='1.0' color='#87CEEB'>▸ WORLD</t><br/>" +
    "  Dead: <t color='%14'>%15</t>  |  Triggers: <t color='%24'>%16</t><br/>" +
    "  Objects: %17  |  Entities: %18<br/>" +
    "  Markers: %19  |  Waypoints: %20<br/><br/>" +
    
    "<t size='1.0' color='#87CEEB'>▸ SCRIPTS</t><br/>" +
    "  Total: <t color='%21'>%22</t><br/>" +
    "  <t size='0.85' color='#AAAAAA'>spawn:%23 | execVM:%25 | exec:%26 | fsm:%27</t>",
    
    _machineType, _hcCount,
    _fpsColor, _fps, _fpsMin,
    _totalUnits, _players, _localAI, _remoteAI,
    _groups, _simDisabled,
    _vehicles, _emptyVehicles,
    _deadColor, _deadBodies, _triggers,
    _allObjects, _entities,
    _markers, _waypoints,
    _scriptsColor, _scriptsTotal, _scriptsSpawn,
    _triggersColor, _scriptsExecVM, _scriptsExec, _scriptsFSM
];

// ========================================
// SYSTEM CHAT FORMAT (Compact)
// ========================================
private _chatText = format [
    "[PERF] FPS:%1/%2 | Units:%3 (P:%4 L:%5 R:%6) | Grp:%7 | Veh:%8 | Dead:%9 | Scripts:%10",
    _fps, _fpsMin,
    _totalUnits, _players, _localAI, _remoteAI,
    _groups, _vehicles, _deadBodies, _scriptsTotal
];

// ========================================
// RPT FORMAT (Detailed Log)
// ========================================
private _rptText = format [
    "[RECONDO_PERF] FPS:%1 MIN:%2 | PLAYERS:%3 LOCAI:%4 REMAI:%5 UNITS:%6 GROUPS:%7 | VEH:%8 EMPTY:%9 | DEAD:%10 TRIG:%11 OBJ:%12 ENT:%13 | SCRIPTS:%14 (spawn:%15 vm:%16 exec:%17 fsm:%18) | MARK:%19 WP:%20 | SIMDIS:%21",
    _fps, _fpsMin,
    _players, _localAI, _remoteAI, _totalUnits, _groups,
    _vehicles, _emptyVehicles,
    _deadBodies, _triggers, _allObjects, _entities,
    _scriptsTotal, _scriptsSpawn, _scriptsExecVM, _scriptsExec, _scriptsFSM,
    _markers, _waypoints, _simDisabled
];

// ========================================
// DISPLAY BASED ON MODE
// ========================================
if (_forceHint) then {
    // Force hint mode (one-time show)
    if (hasInterface) then {
        hint _hintText;
    };
} else {
    // Use configured display mode
    switch (_displayMode) do {
        // Hint (Screen Overlay)
        case 0: {
            if (hasInterface) then {
                hint _hintText;
            };
        };
        
        // System Chat (Compact)
        case 1: {
            if (hasInterface) then {
                systemChat _chatText;
            };
        };
        
        // RPT Only (No Visual Display)
        case 2: {
            // No visual output - just log to RPT below
        };
    };
};

// ========================================
// LOG TO RPT IF ENABLED
// ========================================
if (_logToRPT) then {
    diag_log _rptText;
};

// Debug logging
if (_debugLogging) then {
    diag_log format ["[RECONDO_PERF] DEBUG: Display mode %1, force hint: %2", _displayMode, _forceHint];
};
