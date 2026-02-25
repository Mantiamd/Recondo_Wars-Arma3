/*
    Recondo_fnc_civilianDailyRoutine
    Main behavior loop for civilian daily routine
    
    Description:
        State machine that controls civilian daily activities based on
        dynamic sunrise/sunset detection (adapts to map and date):
        - SLEEP: Night time (sunOrMoon < 0.5), at home sleeping
        - WAKEUP: Dawn (sunOrMoon 0.5-0.75, morning), preparing for work
        - WORK: Daylight (sunOrMoon >= 0.75), at job location
        - RETURN_HOME: Dusk (sunOrMoon 0.5-0.75, afternoon), heading home
    
    Parameters:
        _civilian - OBJECT - The civilian unit
    
    Returns:
        Nothing (runs as spawned script)
*/

params [["_civilian", objNull, [objNull]]];

if (isNull _civilian) exitWith {};

private _debugLogging = RECONDO_CIVPOL_SETTINGS getOrDefault ["debugLogging", false];
private _workAnimations = RECONDO_CIVPOL_SETTINGS get "workAnimations";
private _fishAnimations = RECONDO_CIVPOL_SETTINGS get "fishAnimations";
private _fieldsMarkers = RECONDO_CIVPOL_SETTINGS getOrDefault ["fieldsMarkers", []];
private _fishermanMarkers = RECONDO_CIVPOL_SETTINGS getOrDefault ["fishermanMarkers", []];
private _fieldWorkRadius = RECONDO_CIVPOL_SETTINGS getOrDefault ["fieldWorkRadius", 30];
private _fishermanWorkRadius = RECONDO_CIVPOL_SETTINGS getOrDefault ["fishermanWorkRadius", 20];
private _workMoveDistanceMin = RECONDO_CIVPOL_SETTINGS getOrDefault ["workMoveDistanceMin", 5];
private _workMoveDistanceMax = RECONDO_CIVPOL_SETTINGS getOrDefault ["workMoveDistanceMax", 15];
private _workDurationMin = RECONDO_CIVPOL_SETTINGS getOrDefault ["workDurationMin", 15];
private _workDurationMax = RECONDO_CIVPOL_SETTINGS getOrDefault ["workDurationMax", 45];
private _sleepingBagClasses = RECONDO_CIVPOL_SETTINGS getOrDefault ["sleepingBagClasses", ["Land_Sleeping_bag_F"]];

private _markerName = _civilian getVariable ["RECONDO_CIVPOL_VillageMarker", ""];
private _homePos = _civilian getVariable ["RECONDO_CIVPOL_HomePos", [0,0,0]];
private _job = _civilian getVariable ["RECONDO_CIVPOL_Job", "Farmer"];
private _villageCenter = getMarkerPos _markerName;

// ========================================
// HELPER FUNCTIONS
// ========================================

// Get the target state based on dynamic sunrise/sunset
// sunOrMoon: 1.0 = full sun, 0.5 = dawn/dusk, 0.0 = full night
private _fnc_getTargetState = {
    private _sun = sunOrMoon;
    private _isMorning = daytime < 12; // Before noon = morning
    
    switch (true) do {
        // Night time - sleep (dark outside)
        case (_sun < 0.5): { "SLEEP" };
        
        // Dawn/early morning - wake up and head to work
        case (_sun >= 0.5 && _sun < 0.75 && _isMorning): { "WAKEUP" };
        
        // Full daylight - at work
        case (_sun >= 0.75): { "WORK" };
        
        // Dusk/evening - sun setting, return home (~1 hour before dark)
        case (_sun >= 0.5 && _sun < 0.75 && !_isMorning): { "RETURN_HOME" };
        
        // Fallback to sleep
        default { "SLEEP" };
    }
};

// Find nearest job marker for this civilian's profession
// Returns: [markerName, markerPos, workRadius] or ["", homePos, 20] if no marker
private _fnc_getJobMarkerData = {
    params ["_job", "_homePos"];
    
    private _markers = if (_job == "Fisherman") then { _fishermanMarkers } else { _fieldsMarkers };
    private _workRadius = if (_job == "Fisherman") then { _fishermanWorkRadius } else { _fieldWorkRadius };
    
    if (count _markers == 0) exitWith {
        // No job markers, work near home
        ["", _homePos, 20]
    };
    
    // Find nearest job marker
    private _nearest = "";
    private _nearestDist = 999999;
    
    {
        private _dist = _homePos distance2D (getMarkerPos _x);
        if (_dist < _nearestDist) then {
            _nearestDist = _dist;
            _nearest = _x;
        };
    } forEach _markers;
    
    if (_nearest != "") then {
        private _markerPos = getMarkerPos _nearest;
        private _markerSize = getMarkerSize _nearest;
        
        // Use marker size if available, otherwise use configured work radius
        private _effectiveRadius = ((_markerSize select 0) max (_markerSize select 1)) max _workRadius;
        
        [_nearest, _markerPos, _effectiveRadius]
    } else {
        ["", _homePos, 20]
    }
};

// Get a random work position within radius of a center point
private _fnc_getWorkPosInRadius = {
    params ["_center", "_radius", "_currentPos"];
    
    private _newPos = [];
    private _attempts = 0;
    
    while {count _newPos == 0 && _attempts < 20} do {
        _attempts = _attempts + 1;
        
        // Random direction and distance from current position
        private _moveDir = random 360;
        private _moveDist = _workMoveDistanceMin + random (_workMoveDistanceMax - _workMoveDistanceMin);
        
        // Calculate new position
        private _testPos = _currentPos getPos [_moveDist, _moveDir];
        _testPos set [2, 0];
        
        // Check if within work radius of center
        if (_testPos distance2D _center <= _radius) then {
            _newPos = _testPos;
        };
    };
    
    // Fallback to random position in radius if no valid move found
    if (count _newPos == 0) then {
        _newPos = _center getPos [random _radius, random 360];
    };
    
    _newPos
};

// Wait for civilian to reach destination (with timeout)
private _fnc_waitForArrival = {
    params ["_civilian", "_destination", "_timeout"];
    
    private _endTime = time + _timeout;
    
    waitUntil {
        sleep 1;
        
        !alive _civilian ||
        (_civilian getVariable ["RECONDO_CIVPOL_Fleeing", false]) ||
        (_civilian distance2D _destination < 3) ||
        (time > _endTime) ||
        (unitReady _civilian)
    };
    
    alive _civilian && !(_civilian getVariable ["RECONDO_CIVPOL_Fleeing", false])
};

// ========================================
// MAIN BEHAVIOR LOOP
// ========================================

private _currentState = "IDLE";
private _lastState = "";

while {alive _civilian} do {
    
    // Check if fleeing
    if (_civilian getVariable ["RECONDO_CIVPOL_Fleeing", false]) then {
        // ========================================
        // FLEE STATE
        // ========================================
        
        _civilian setVariable ["RECONDO_CIVPOL_State", "FLEEING", true];
        _civilian switchMove "";
        _civilian enableAI "MOVE";
        _civilian setBehaviour "AWARE";
        _civilian setSpeedMode "FULL";
        
        // Run away from danger
        private _fleeDir = random 360;
        private _fleePos = (getPos _civilian) getPos [100 + random 100, _fleeDir];
        _civilian doMove _fleePos;
        
        if (_debugLogging) then {
            diag_log format ["[RECONDO_CIVPOL] Civilian fleeing from %1", _markerName];
        };
        
        // Wait and then stop fleeing after some time
        sleep 30;
        
        // If still alive, go back to normal behavior after fleeing
        if (alive _civilian) then {
            _civilian setVariable ["RECONDO_CIVPOL_Fleeing", false, true];
            _civilian setBehaviour "CARELESS";
            _civilian setSpeedMode "LIMITED";
            _currentState = "RETURN_HOME"; // Go home after fleeing
        };
    } else {
        // ========================================
        // NORMAL DAILY ROUTINE
        // ========================================
        
        private _targetState = call _fnc_getTargetState;
        
        // Only change behavior if state changed
        if (_targetState != _currentState) then {
            _lastState = _currentState;
            _currentState = _targetState;
            _civilian setVariable ["RECONDO_CIVPOL_State", _currentState, true];
            
            if (_debugLogging) then {
                diag_log format ["[RECONDO_CIVPOL] %1 civilian state: %2 -> %3", _job, _lastState, _currentState];
            };
            
            switch (_currentState) do {
                // ========================================
                // WAKEUP STATE (dawn, sunOrMoon 0.5-0.75 morning)
                // ========================================
                case "WAKEUP": {
                    // Delete sleeping mat if exists
                    private _sleepingMat = _civilian getVariable ["RECONDO_CIVPOL_SleepingMat", objNull];
                    if (!isNull _sleepingMat) then {
                        deleteVehicle _sleepingMat;
                        _civilian setVariable ["RECONDO_CIVPOL_SleepingMat", objNull, true];
                        
                        if (_debugLogging) then {
                            diag_log format ["[RECONDO_CIVPOL] Deleted sleeping mat for %1", _job];
                        };
                    };
                    
                    _civilian switchMove "";
                    _civilian enableAI "MOVE";
                    
                    // Small wait before starting the day
                    sleep (5 + random 10);
                };
                
                // ========================================
                // WORK STATE (daylight, sunOrMoon >= 0.75)
                // ========================================
                case "WORK": {
                    // Get job marker data
                    private _jobData = [_job, _homePos] call _fnc_getJobMarkerData;
                    _jobData params ["_jobMarker", "_jobCenter", "_workRadius"];
                    
                    // Get initial position within work area
                    private _jobPos = _jobCenter getPos [random _workRadius, random 360];
                    
                    // Walk to job location
                    _civilian enableAI "MOVE";
                    _civilian switchMove "";
                    _civilian setSpeedMode "LIMITED";
                    _civilian doMove _jobPos;
                    
                    if (_debugLogging) then {
                        diag_log format ["[RECONDO_CIVPOL] %1 heading to work at %2 (radius: %3m)", _job, _jobMarker, _workRadius];
                    };
                    
                    // Wait for arrival
                    private _arrived = [_civilian, _jobPos, 180] call _fnc_waitForArrival;
                    
                    if (_arrived) then {
                        // Select appropriate animations
                        private _anims = if (_job == "Fisherman") then { _fishAnimations } else { _workAnimations };
                        
                        // Work loop until state changes (like civiliansworking behavior)
                        while {alive _civilian && !(_civilian getVariable ["RECONDO_CIVPOL_Fleeing", false]) && (call _fnc_getTargetState) == "WORK"} do {
                            
                            // 1. Stop and prepare for work animation
                            _civilian disableAI "MOVE";
                            doStop _civilian;
                            sleep 0.5;
                            
                            // 2. Select and play work animation
                            private _anim = selectRandom _anims;
                            
                            // 3. Work for random duration - keep re-applying animation
                            private _workDuration = _workDurationMin + random (_workDurationMax - _workDurationMin);
                            private _workEndTime = time + _workDuration;
                            
                            while {time < _workEndTime && alive _civilian && !(_civilian getVariable ["RECONDO_CIVPOL_Fleeing", false]) && (call _fnc_getTargetState) == "WORK"} do {
                                _civilian playMoveNow _anim;
                                sleep 3;  // Re-apply every 3 seconds to maintain animation
                            };
                            
                            // 4. Move to new work spot within the radius
                            if (alive _civilian && !(_civilian getVariable ["RECONDO_CIVPOL_Fleeing", false]) && (call _fnc_getTargetState) == "WORK") then {
                                _civilian switchMove "";
                                _civilian enableAI "MOVE";
                                
                                // Get new position within work area
                                private _newSpot = [_jobCenter, _workRadius, getPos _civilian] call _fnc_getWorkPosInRadius;
                                _civilian doMove _newSpot;
                                
                                // Wait for arrival with timeout
                                [_civilian, _newSpot, 60] call _fnc_waitForArrival;
                            };
                            
                            // Small pause before next work cycle
                            sleep (1 + random 2);
                        };
                    };
                };
                
                // ========================================
                // RETURN_HOME STATE (dusk, ~1 hour before dark)
                // ========================================
                case "RETURN_HOME": {
                    _civilian switchMove "";
                    _civilian enableAI "MOVE";
                    _civilian setSpeedMode "LIMITED";
                    _civilian doMove _homePos;
                    
                    // Wait for arrival home
                    [_civilian, _homePos, 300] call _fnc_waitForArrival;
                    
                    // Once home, they'll transition to SLEEP when sunOrMoon drops below 0.5
                };
                
                // ========================================
                // SLEEP STATE (night time, sunOrMoon < 0.5)
                // ========================================
                case "SLEEP": {
                    // Go to home if not there
                    if (_civilian distance2D _homePos > 5) then {
                        _civilian enableAI "MOVE";
                        _civilian switchMove "";
                        _civilian doMove _homePos;
                        [_civilian, _homePos, 120] call _fnc_waitForArrival;
                    };
                    
                    // Stop and prepare for sleep
                    _civilian disableAI "MOVE";
                    doStop _civilian;
                    
                    // Spawn sleeping mat under civilian (if not already exists)
                    private _existingMat = _civilian getVariable ["RECONDO_CIVPOL_SleepingMat", objNull];
                    if (isNull _existingMat) then {
                        private _matClass = selectRandom _sleepingBagClasses;
                        private _matPos = getPosATL _civilian;  // Get position including height (for raised buildings)
                        private _matDir = getDir _civilian;
                        
                        // Create as simple object for performance
                        private _sleepingMat = createSimpleObject [_matClass, [0,0,0], true];
                        _sleepingMat setDir _matDir;
                        _sleepingMat setPosATL _matPos;  // Place at civilian's actual height
                        
                        // Store reference for deletion later
                        _civilian setVariable ["RECONDO_CIVPOL_SleepingMat", _sleepingMat, true];
                        
                        if (_debugLogging) then {
                            diag_log format ["[RECONDO_CIVPOL] Spawned sleeping mat %1 for %2", _matClass, _job];
                        };
                    };
                    
                    // Sleep animation (lying down)
                    _civilian playMoveNow "AinjPpneMstpSnonWnonDnon_injuredHealed";
                    
                    // Stay asleep until state changes
                    while {alive _civilian && !(_civilian getVariable ["RECONDO_CIVPOL_Fleeing", false]) && (call _fnc_getTargetState) == "SLEEP"} do {
                        _civilian playMoveNow "AinjPpneMstpSnonWnonDnon_injuredHealed";
                        sleep 10;
                    };
                    
                    // Wake up - delete sleeping mat
                    private _sleepingMat = _civilian getVariable ["RECONDO_CIVPOL_SleepingMat", objNull];
                    if (!isNull _sleepingMat) then {
                        deleteVehicle _sleepingMat;
                        _civilian setVariable ["RECONDO_CIVPOL_SleepingMat", objNull, true];
                    };
                    
                    // Wake up animation
                    _civilian switchMove "";
                };
            };
        };
    };
    
    // Small delay before next check
    sleep 5;
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_CIVPOL] Daily routine ended for civilian from %1", _markerName];
};
