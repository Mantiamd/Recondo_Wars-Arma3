/*
    Recondo_fnc_trackerDogBehavior
    Main behavior loop for tracker dogs
    
    Description:
        Controls dog movement and detection behavior.
        Dogs lead the tracker group and detect players at close range.
    
    Parameters:
        _dog - The dog unit
    
    Returns:
        Nothing (spawned function)
*/

if (!isServer) exitWith {};

params ["_dog"];

private _settings = RECONDO_TRACKERS_SETTINGS;
private _targetSide = _settings get "targetSide";
private _dogDetectionDay = _settings get "dogDetectionDay";
private _dogDetectionNight = _settings get "dogDetectionNight";
private _dogLeadDistance = _settings get "dogLeadDistance";
private _dogHarassmentRange = _settings get "dogHarassmentRange";
private _heightLimit = _settings get "heightLimit";
private _detectionSounds = _settings get "dogDetectionSounds";
private _debugLogging = _settings get "debugLogging";

// Validate dog
if (isNull _dog) exitWith {
    if (_debugLogging) then {
        diag_log "[RECONDO_TRACKERS] ERROR: Null dog provided to behavior function";
    };
};

private _trackerGroup = _dog getVariable ["RECONDO_TRACKERS_trackerGroup", grpNull];
if (isNull _trackerGroup) exitWith {
    if (_debugLogging) then {
        diag_log "[RECONDO_TRACKERS] ERROR: Dog has no assigned tracker group";
    };
};

// Animation tracking
private _last_anim = "";

// Function to get current detection range based on time of day
private _fnc_getDetectionRange = {
    private _sunMoon = sunOrMoon;
    if (_sunMoon > 0.5) then {
        _dogDetectionDay
    } else {
        _dogDetectionNight
    };
};

// Function to play detection sound
private _fnc_playDetectionSound = {
    params ["_dog"];
    
    private _nearbyPlayers = allPlayers select { _x distance _dog < 350 };
    if (count _nearbyPlayers > 0) then {
        [_dog, _detectionSounds] remoteExec ["RECONDO_TRACKERS_fnc_playSound", _nearbyPlayers];
    };
};

// Function to detect target side units
private _fnc_detectTarget = {
    params ["_dog", "_detectionRange"];
    
    private _dogPos = getPos _dog;
    private _detected = objNull;
    
    {
        if (side _x == _targetSide && alive _x && _x distance _dogPos <= _detectionRange) then {
            private _heightAboveGround = (getPosATL _x) select 2;
            if (_heightAboveGround <= _heightLimit) then {
                _detected = _x;
            };
        };
    } forEach allUnits;
    
    _detected
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_TRACKERS] Starting dog behavior loop for dog %1", _dog];
};

// Main behavior loop - runs every 1 second
while {alive _dog} do {
    private _trackerGroup = _dog getVariable ["RECONDO_TRACKERS_trackerGroup", grpNull];
    
    // Exit if tracker group is gone
    if (isNull _trackerGroup) exitWith {
        if (_debugLogging) then {
            diag_log "[RECONDO_TRACKERS] Tracker group no longer exists, ending dog behavior";
        };
    };
    
    // Get first living unit in tracker group (handler)
    private _livingUnits = (units _trackerGroup) select { alive _x };
    if (count _livingUnits == 0) exitWith {
        if (_debugLogging) then {
            diag_log "[RECONDO_TRACKERS] No living units in tracker group, ending dog behavior";
        };
    };
    
    private _handler = _livingUnits select 0;
    
    // Get current detection range
    private _detectionRange = call _fnc_getDetectionRange;
    
    // Check for target
    private _detectedEnemy = [_dog, _detectionRange] call _fnc_detectTarget;
    
    if (!isNull _detectedEnemy) then {
        // Enemy detected - alert and harass behavior
        private _lastDetection = _dog getVariable ["RECONDO_TRACKERS_lastDetectionTime", 0];
        private _timeSinceDetection = time - _lastDetection;
        
        if (_timeSinceDetection > 10) then {
            [_dog] call _fnc_playDetectionSound;
            _dog setVariable ["RECONDO_TRACKERS_lastDetectionTime", time];
            _trackerGroup setBehaviour "COMBAT";
            
            if (_debugLogging) then {
                diag_log format ["[RECONDO_TRACKERS] Dog detected target %1 at %2m", _detectedEnemy, round(_dog distance _detectedEnemy)];
            };
        };
        
        _dog doWatch _detectedEnemy;
        
        // Harassment if very close
        private _enemyDistance = _dog distance _detectedEnemy;
        if (_enemyDistance <= _dogHarassmentRange) then {
            private _harassPos = [_detectedEnemy, 1.5, [_detectedEnemy, _dog] call BIS_fnc_dirTo] call BIS_fnc_relPos;
            _dog doMove _harassPos;
            
            if (_timeSinceDetection > 5) then {
                // Play aggressive sounds
                private _aggressiveSounds = ["dog_growl_vicious", "barkmean1", "barkmean2", "barkmean3"];
                private _nearbyPlayers = allPlayers select { _x distance _dog < 350 };
                if (count _nearbyPlayers > 0) then {
                    [_dog, _aggressiveSounds] remoteExec ["RECONDO_TRACKERS_fnc_playSound", _nearbyPlayers];
                };
                _dog setVariable ["RECONDO_TRACKERS_lastDetectionTime", time];
            };
            
            if (_last_anim != "Dog_Sprint") then { 
                _dog playMove "Dog_Sprint"; 
                _last_anim = "Dog_Sprint"; 
            };
        };
    } else {
        // No enemy - heel/follow behavior
        _dog enableAI "PATH";
        _dog doFollow _handler;
        
        // Calculate heel position - in front of handler
        private _heelPos = _handler modelToWorld [0, _dogLeadDistance, 0];
        
        // Watch forward from heel position
        _dog doWatch (_handler modelToWorld [0, _dogLeadDistance + 10, 0]);
        
        // Animation based on distance to heel position
        private _distToHeel = _dog distance _heelPos;
        private _handlerSpeed = speed _handler;
        
        switch (true) do {
            // STOP when close to heel position and handler slow/stopped
            case (_distToHeel < 5 && _handlerSpeed < 5): {
                if (_last_anim != "Dog_Stop") then { 
                    _dog playMove "Dog_Stop"; 
                    _last_anim = "Dog_Stop"; 
                };
            };
            // WALK when moderately close
            case (_distToHeel >= 5 && _distToHeel < 10 && _handlerSpeed < 8): {
                if (_last_anim != "Dog_Walk") then { 
                    _dog playMove "Dog_Walk"; 
                    _last_anim = "Dog_Walk"; 
                };
            };
            // RUN when further away
            case (_distToHeel >= 10 && _distToHeel < 20): {
                if (_last_anim != "Dog_Run") then { 
                    _dog playMove "Dog_Run"; 
                    _last_anim = "Dog_Run"; 
                };
            };
            // SPRINT when far or handler moving fast
            default {
                if (_last_anim != "Dog_Sprint") then { 
                    _dog playMove "Dog_Sprint"; 
                    _last_anim = "Dog_Sprint"; 
                };
            };
        };
    };
    
    // Align dog to terrain
    private _surfaceNormal = surfaceNormal getPosATL _dog;
    _dog setVectorUp _surfaceNormal;
    
    sleep 1;
};

// Cleanup
if (_debugLogging) then {
    diag_log format ["[RECONDO_TRACKERS] Dog behavior loop ended for dog %1", _dog];
};
