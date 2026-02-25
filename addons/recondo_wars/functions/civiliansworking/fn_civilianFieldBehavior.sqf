/*
    Recondo_fnc_civilianFieldBehavior
    Behavior loop for a field worker civilian
    
    Description:
        Controls civilian work cycle: move to spot, kneel, work animation,
        repeat. Handles fleeing when gunfire is detected.
        Keeps civilians within the defined area bounds.
    
    Parameters:
        _civilian - OBJECT - The civilian unit
        _settings - HASHMAP - Module settings
    
    Returns:
        Nothing (runs as spawned script)
*/

params [
    ["_civilian", objNull, [objNull]],
    ["_settings", createHashMap, [createHashMap]]
];

if (isNull _civilian) exitWith {};

private _instanceId = _settings get "instanceId";
private _modulePos = _settings get "modulePos";
private _areaX = _settings get "areaX";
private _areaY = _settings get "areaY";
private _areaDir = _settings get "areaDir";
private _workDurationMin = _settings get "workDurationMin";
private _workDurationMax = _settings get "workDurationMax";
private _moveDistanceMin = _settings get "moveDistanceMin";
private _moveDistanceMax = _settings get "moveDistanceMax";
private _animations = _settings get "animations";
private _fleeOnGunfire = _settings get "fleeOnGunfire";
private _gunfireDetectRadius = _settings get "gunfireDetectRadius";
private _debugLogging = _settings get "debugLogging";

// Function to check if position is within area
private _fnc_isInArea = {
    params ["_pos", "_center", "_sizeX", "_sizeY", "_dir"];
    _pos inArea [_center, _sizeX, _sizeY, _dir, true]
};

// Function to get new position within area
private _fnc_getNewWorkPos = {
    params ["_currentPos", "_minDist", "_maxDist", "_center", "_sizeX", "_sizeY", "_dir"];
    
    private _newPos = [];
    private _attempts = 0;
    
    while {count _newPos == 0 && _attempts < 20} do {
        _attempts = _attempts + 1;
        
        // Random direction and distance
        private _moveDir = random 360;
        private _moveDist = _minDist + random (_maxDist - _minDist);
        
        // Calculate new position
        private _testPos = _currentPos getPos [_moveDist, _moveDir];
        _testPos set [2, 0];
        
        // Check if within area
        if ([_testPos, _center, _sizeX, _sizeY, _dir] call _fnc_isInArea) then {
            _newPos = _testPos;
        };
    };
    
    // Fallback to area center if no valid position found
    if (count _newPos == 0) then {
        _newPos = _center;
    };
    
    _newPos
};

// Add FiredNear event handler for fleeing
if (_fleeOnGunfire) then {
    private _ehId = _civilian addEventHandler ["FiredNear", {
        params ["_unit", "_firer", "_distance", "_weapon", "_muzzle", "_mode", "_ammo", "_gunner"];
        
        private _settings = _unit getVariable ["RECONDO_CIVWORKING_Settings", createHashMap];
        private _detectRadius = _settings getOrDefault ["gunfireDetectRadius", 100];
        
        if (_distance <= _detectRadius && !(_unit getVariable ["RECONDO_CIVWORKING_Fleeing", false])) then {
            _unit setVariable ["RECONDO_CIVWORKING_Fleeing", true];
            
            private _debugLogging = _settings getOrDefault ["debugLogging", false];
            if (_debugLogging) then {
                diag_log format ["[RECONDO_CIVWORKING] Civilian fleeing - gunfire at %1m", round _distance];
            };
        };
    }];
    _civilian setVariable ["RECONDO_CIVWORKING_FiredNearEH", _ehId];
};

// Main behavior loop
while {alive _civilian} do {
    
    // Check if fleeing
    if (_civilian getVariable ["RECONDO_CIVWORKING_Fleeing", false]) then {
        // FLEE BEHAVIOR
        _civilian switchMove "";
        _civilian enableAI "MOVE";
        _civilian setBehaviour "AWARE";
        _civilian setSpeedMode "FULL";
        
        // Run away from current position
        private _fleeDir = random 360;
        private _fleePos = (getPos _civilian) getPos [100 + random 100, _fleeDir];
        
        // Use doMove for more reliable fleeing
        _civilian doMove _fleePos;
        
        // Wait and then exit (civilian runs out of the area)
        sleep 30;
        
        // Delete civilian after fleeing
        deleteVehicle _civilian;
        break;
    };
    
    // NORMAL WORK BEHAVIOR
    
    // 1. Get new work position within the area
    private _newPos = [
        getPos _civilian,
        _moveDistanceMin,
        _moveDistanceMax,
        _modulePos,
        _areaX,
        _areaY,
        _areaDir
    ] call _fnc_getNewWorkPos;
    
    // 2. Walk to new position
    _civilian enableAI "MOVE";
    _civilian switchMove "";
    _civilian setSpeedMode "LIMITED";
    _civilian doMove _newPos;
    
    // Wait for arrival (with timeout and area boundary check)
    private _timeout = time + 60;
    private _leftArea = false;
    
    waitUntil {
        sleep 1;
        
        // Check if civilian has left the area - redirect them back
        if (!([getPos _civilian, _modulePos, _areaX, _areaY, _areaDir] call _fnc_isInArea)) then {
            _leftArea = true;
            doStop _civilian;
            _civilian doMove _modulePos;  // Send back to center
            
            if (_debugLogging) then {
                diag_log format ["[RECONDO_CIVWORKING] Civilian left area, redirecting to center"];
            };
        };
        
        !alive _civilian || 
        (_civilian getVariable ["RECONDO_CIVWORKING_Fleeing", false]) ||
        _leftArea ||
        (_civilian distance2D _newPos < 2) || 
        (time > _timeout)
    };
    
    // If left area, wait to return to center then continue loop
    if (_leftArea) then {
        waitUntil {
            sleep 1;
            !alive _civilian || 
            (_civilian getVariable ["RECONDO_CIVWORKING_Fleeing", false]) ||
            ([getPos _civilian, _modulePos, _areaX, _areaY, _areaDir] call _fnc_isInArea)
        };
        continue;
    };
    
    // Check if we should continue
    if (!alive _civilian || (_civilian getVariable ["RECONDO_CIVWORKING_Fleeing", false])) then {
        continue;
    };
    
    // 3. Stop and prepare for work animation
    _civilian disableAI "MOVE";
    doStop _civilian;
    sleep 0.5;
    
    // 4. Play work animation - use playMoveNow for immediate playback
    private _animation = selectRandom _animations;
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_CIVWORKING] Civilian working with animation: %1", _animation];
    };
    
    // 5. Work for random duration - keep re-applying animation to maintain pose
    private _workDuration = _workDurationMin + random (_workDurationMax - _workDurationMin);
    private _workEndTime = time + _workDuration;
    
    // Work loop - re-apply animation periodically to keep them in the pose
    while {time < _workEndTime && alive _civilian && !(_civilian getVariable ["RECONDO_CIVWORKING_Fleeing", false])} do {
        _civilian playMoveNow _animation;
        sleep 3;  // Re-apply every 3 seconds to maintain animation
    };
    
    // Reset animation before moving
    _civilian switchMove "";
    
    // Small pause before next cycle
    sleep (1 + random 2);
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_CIVWORKING] Behavior loop ended for civilian"];
};
