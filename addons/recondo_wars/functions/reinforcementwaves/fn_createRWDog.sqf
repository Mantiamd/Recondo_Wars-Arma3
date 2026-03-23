/*
    Recondo_fnc_createRWDog
    Creates a tracker dog for a reinforcement group
    
    Description:
        Creates a dog unit that leads the tracker group and can detect
        nearby targets. Uses same behavior as Trackers module dogs.
    
    Parameters:
        _group - The tracker group to attach dog to
        _moduleSettings - HashMap of module settings
    
    Returns:
        Dog object (or objNull on failure)
*/

if (!isServer) exitWith { objNull };

params ["_group", "_moduleSettings"];

if (isNull _group) exitWith { objNull };

private _moduleId = _moduleSettings get "moduleId";
private _reinforcementSide = _moduleSettings get "reinforcementSide";
private _targetSide = _moduleSettings get "targetSide";
private _dogClassnames = _moduleSettings get "dogClassnames";
private _dogDetectionDay = _moduleSettings get "dogDetectionDay";
private _dogDetectionNight = _moduleSettings get "dogDetectionNight";
private _dogLeadDistance = _moduleSettings get "dogLeadDistance";
private _dogHarassmentRange = _moduleSettings get "dogHarassmentRange";
private _dogDetectionSounds = _moduleSettings get "dogDetectionSounds";
private _dogDeathSounds = _moduleSettings get "dogDeathSounds";
private _debugLogging = _moduleSettings get "debugLogging";

// Validate dog classnames
if (count _dogClassnames == 0) exitWith {
    if (_debugLogging) then {
        diag_log format ["[RECONDO_RW] Module %1: No dog classnames configured", _moduleId];
    };
    objNull
};

// Get spawn position (slightly ahead of group leader)
private _leader = leader _group;
if (isNull _leader) exitWith { objNull };

private _leaderPos = getPos _leader;
private _leaderDir = getDir _leader;
private _dogPos = _leaderPos getPos [_dogLeadDistance, _leaderDir];

// Select random dog class
private _dogClass = selectRandom _dogClassnames;

// Validate class exists
if (!isClass (configFile >> "CfgVehicles" >> _dogClass)) exitWith {
    if (_debugLogging) then {
        diag_log format ["[RECONDO_RW] Module %1: Invalid dog classname: %2", _moduleId, _dogClass];
    };
    objNull
};

// Create dog unit
private _dog = _group createUnit [_dogClass, _dogPos, [], 0, "NONE"];

if (isNull _dog) exitWith {
    if (_debugLogging) then {
        diag_log format ["[RECONDO_RW] Module %1: Failed to create dog", _moduleId];
    };
    objNull
};

// Store dog variables
_dog setVariable ["RECONDO_RW_isDog", true];
_dog setVariable ["RECONDO_RW_moduleId", _moduleId];
_dog setVariable ["RECONDO_RW_detectionDay", _dogDetectionDay];
_dog setVariable ["RECONDO_RW_detectionNight", _dogDetectionNight];
_dog setVariable ["RECONDO_RW_leadDistance", _dogLeadDistance];
_dog setVariable ["RECONDO_RW_harassmentRange", _dogHarassmentRange];
_dog setVariable ["RECONDO_RW_detectionSounds", _dogDetectionSounds];
_dog setVariable ["RECONDO_RW_deathSounds", _dogDeathSounds];
_dog setVariable ["RECONDO_RW_targetSide", _targetSide];

// Link dog to group
_group setVariable ["RECONDO_RW_dog", _dog];

// Create bullet magnet for the dog
private _bulletMagnet = [_dog, _reinforcementSide] call Recondo_fnc_assignDogBulletMagnet;
_dog setVariable ["RECONDO_RW_bulletMagnet", _bulletMagnet];

// Add death event handler
_dog addEventHandler ["Killed", {
    params ["_unit", "_killer"];
    
    // Play death sound
    private _deathSounds = _unit getVariable ["RECONDO_RW_deathSounds", []];
    if (count _deathSounds > 0) then {
        [_unit, _deathSounds] remoteExec ["RECONDO_RW_fnc_playSound", 0];
    };
    
    // Cleanup bullet magnet
    private _bulletMagnet = _unit getVariable ["RECONDO_RW_bulletMagnet", objNull];
    if (!isNull _bulletMagnet) then {
        deleteVehicle _bulletMagnet;
    };
    
    // Update group variable
    private _group = group _unit;
    if (!isNull _group) then {
        _group setVariable ["RECONDO_RW_dog", objNull];
        _group setVariable ["RECONDO_RW_hasDog", false];
    };
}];

// Start dog behavior
[_dog, _group, _moduleSettings] spawn {
    params ["_dog", "_group", "_moduleSettings"];
    
    private _moduleId = _moduleSettings get "moduleId";
    private _targetSide = _moduleSettings get "targetSide";
    private _debugLogging = _moduleSettings get "debugLogging";
    
    private _detectionDay = _dog getVariable ["RECONDO_RW_detectionDay", 15];
    private _detectionNight = _dog getVariable ["RECONDO_RW_detectionNight", 10];
    private _leadDistance = _dog getVariable ["RECONDO_RW_leadDistance", 12];
    private _harassmentRange = _dog getVariable ["RECONDO_RW_harassmentRange", 5];
    private _detectionSounds = _dog getVariable ["RECONDO_RW_detectionSounds", []];
    
    private _lastDetectionSoundTime = 0;
    
    while {alive _dog && !isNull _group && {count (units _group select {alive _x}) > 0}} do {
        private _leader = leader _group;
        if (isNull _leader || !alive _leader) then {
            sleep 2;
            continue;
        };
        
        // Determine detection range based on time of day
        private _sunAngle = sunOrMoon;
        private _detectionRange = if (_sunAngle > 0.5) then { _detectionDay } else { _detectionNight };
        
        // Check for nearby targets
        private _dogPos = getPos _dog;
        private _nearestTarget = objNull;
        private _nearestDist = _detectionRange;
        
        {
            if (alive _x && side _x == _targetSide) then {
                private _dist = _x distance _dog;
                if (_dist < _nearestDist) then {
                    // Height check (ignore aircraft)
                    if ((getPosATL _x select 2) < 20) then {
                        _nearestDist = _dist;
                        _nearestTarget = _x;
                    };
                };
            };
        } forEach allUnits;
        
        if (!isNull _nearestTarget) then {
            // Target detected - alert and chase
            if (time - _lastDetectionSoundTime > 10) then {
                if (count _detectionSounds > 0) then {
                    [_dog, _detectionSounds] remoteExec ["RECONDO_RW_fnc_playSound", 0];
                };
                _lastDetectionSoundTime = time;
            };
            
            // Chase behavior
            if (_nearestDist < _harassmentRange) then {
                // Close enough to harass
                _dog doMove (getPos _nearestTarget);
                _dog doWatch _nearestTarget;
            } else {
                // Move toward target
                _dog doMove (getPos _nearestTarget);
            };
            
            // Alert the group
            _group reveal [_nearestTarget, 4];
            
        } else {
            // No target - lead the group
            private _leaderPos = getPos _leader;
            private _leaderDir = getDir _leader;
            private _leadPos = _leaderPos getPos [_leadDistance, _leaderDir];
            
            _dog doMove _leadPos;
            _dog doFollow _leader;
        };
        
        sleep 2;
    };
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_RW] Module %1: Dog behavior ended (alive: %2)", _moduleId, alive _dog];
    };
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_RW] Module %1: Dog created (%2) for group %3", _moduleId, _dogClass, _group];
};

_dog
