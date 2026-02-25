/*
    Recondo_fnc_stopTransmission
    Server-side function to handle end of radio transmission
    
    Description:
        Called from client when player stops speaking on a tracked radio.
        Calculates transmission duration, drains battery, updates triangulation,
        and checks enemy spawn thresholds.
    
    Parameters:
        0: STRING - Radio ID
        1: OBJECT - Player unit
        
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params ["_radioId", "_unit"];

if (isNil "RECONDO_RWR_SETTINGS") exitWith {};

private _settings = RECONDO_RWR_SETTINGS;
private _debug = _settings get "enableDebug";

// Get transmission start time
private _startTime = RECONDO_RWR_TRANSMISSION_STARTS getOrDefault [_radioId, -1];

if (_startTime < 0) exitWith {
    if (_debug) then {
        diag_log format ["[RECONDO_RWR] No valid start time for radio %1", _radioId];
    };
};

// Calculate transmission duration
private _endTime = serverTime;
private _duration = _endTime - _startTime;

// Apply drain rate multiplier
private _drainRate = _settings get "drainRate";
private _drainAmount = _duration * _drainRate;

// Clear the start time
RECONDO_RWR_TRANSMISSION_STARTS deleteAt _radioId;
_unit setVariable ["RECONDO_RWR_TransmittingRadio", nil, true];

if (_debug) then {
    diag_log format ["[RECONDO_RWR] Transmission ended - Radio: %1, Duration: %2s, Drain: %3s", 
        _radioId, _duration toFixed 1, _drainAmount toFixed 1];
};

// =========================================
// BATTERY DEPLETION
// =========================================

if (_settings get "enableBattery") then {
    private _batteryCapacity = _settings get "batteryCapacity";
    private _currentLevel = [_radioId] call Recondo_fnc_getBatteryLevel;
    private _newLevel = (_currentLevel - _drainAmount) max 0;
    
    // Update battery level
    [_radioId, _newLevel] call Recondo_fnc_setBatteryLevel;
    
    if (_debug) then {
        diag_log format ["[RECONDO_RWR] Battery: %1 -> %2 (-%3)", 
            _currentLevel toFixed 1, _newLevel toFixed 1, _drainAmount toFixed 1];
    };
    
    // Check if depleted
    if (_newLevel <= 0) then {
        // Turn off radio on client
        [[_radioId], {
            params ["_radioId"];
            [_radioId, "setOnOffState", 0] call acre_sys_data_fnc_dataEvent;
            hint "Radio battery depleted!";
        }] remoteExec ["call", _unit];
        
        if (_debug) then {
            diag_log format ["[RECONDO_RWR] Radio %1 battery depleted - turned off", _radioId];
        };
    } else {
        // Low battery warning
        private _lowWarning = _settings get "lowBatteryWarning";
        private _percentRemaining = (_newLevel / _batteryCapacity) * 100;
        
        if (_percentRemaining <= _lowWarning && _percentRemaining > 0) then {
            [[_percentRemaining], {
                params ["_percent"];
                playSound "Beep";
                hintSilent format ["Critical Battery: %1%2", round _percent, "%"];
            }] remoteExec ["call", _unit];
        };
    };
};

// =========================================
// CHECK SAFE ZONE
// =========================================

// Don't count transmission if in safe zone
if ([_unit] call Recondo_fnc_isInSafeZone) exitWith {
    if (_debug) then {
        diag_log format ["[RECONDO_RWR] Transmission not counted - unit in safe zone"];
    };
};

// =========================================
// TRIANGULATION
// =========================================

if (_settings get "enableTriangulation") then {
    [_unit, _duration] call Recondo_fnc_updateTriangulation;
};

// =========================================
// ENEMY SPAWN CHECK
// =========================================

if (_settings get "enableEnemySpawn") then {
    // Increment global call counter
    RECONDO_RWR_CALL_COUNT = RECONDO_RWR_CALL_COUNT + 1;
    publicVariable "RECONDO_RWR_CALL_COUNT";
    
    private _spawnThreshold = _settings get "spawnThreshold";
    private _timesThresholdReached = floor (RECONDO_RWR_CALL_COUNT / _spawnThreshold);
    
    if (_timesThresholdReached > RECONDO_RWR_LAST_ENEMY_COUNT) then {
        RECONDO_RWR_LAST_ENEMY_COUNT = _timesThresholdReached;
        
        // Spawn enemy group
        [_unit] call Recondo_fnc_spawnRadioEnemy;
        
        if (_debug) then {
            diag_log format ["[RECONDO_RWR] Enemy spawn triggered - Call count: %1/%2", 
                RECONDO_RWR_CALL_COUNT, _spawnThreshold];
        };
    };
};
