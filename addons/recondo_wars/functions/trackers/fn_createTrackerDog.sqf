/*
    Recondo_fnc_createTrackerDog
    Creates a tracker dog for a tracker group
    
    Description:
        Creates a dog unit that accompanies a tracker group.
        The dog can detect players at close range and alerts the group.
    
    Parameters:
        _trackerGroup - The tracker group the dog will accompany
    
    Returns:
        Dog object or objNull if creation failed
*/

if (!isServer) exitWith { objNull };

params ["_trackerGroup"];

private _settings = RECONDO_TRACKERS_SETTINGS;
private _trackerSide = _settings get "trackerSide";
private _dogClassnames = _settings get "dogClassnames";
private _debugLogging = _settings get "debugLogging";

// Validate tracker group
if (isNull _trackerGroup) exitWith {
    if (_debugLogging) then {
        diag_log "[RECONDO_TRACKERS] ERROR: Null tracker group provided to createTrackerDog";
    };
    objNull
};

// Validate dog classnames
if (count _dogClassnames == 0) exitWith {
    if (_debugLogging) then {
        diag_log "[RECONDO_TRACKERS] ERROR: No dog classnames configured";
    };
    objNull
};

private _leader = leader _trackerGroup;
if (!alive _leader) exitWith {
    if (_debugLogging) then {
        diag_log "[RECONDO_TRACKERS] ERROR: Tracker group leader not alive";
    };
    objNull
};

private _spawnPos = getPos _leader;

// Create dog group (same side as trackers)
private _dogGroup = createGroup [_trackerSide, true];
if (isNull _dogGroup) exitWith {
    if (_debugLogging) then {
        diag_log "[RECONDO_TRACKERS] ERROR: Failed to create dog group";
    };
    objNull
};

// Select random dog type
private _dogType = selectRandom _dogClassnames;

// Validate dog classname
if (!isClass (configFile >> "CfgVehicles" >> _dogType)) then {
    if (_debugLogging) then {
        diag_log format ["[RECONDO_TRACKERS] WARNING: Invalid dog classname '%1', using default", _dogType];
    };
    _dogType = "Alsatian_Random_F";
};

// Create dog as unit (not agent) - required for doFollow to work
private _dog = _dogGroup createUnit [_dogType, _spawnPos, [], 0, "CAN_COLLIDE"];
if (isNull _dog) exitWith {
    deleteGroup _dogGroup;
    if (_debugLogging) then {
        diag_log "[RECONDO_TRACKERS] ERROR: Failed to create dog unit";
    };
    objNull
};

// Join dog to its group explicitly
[_dog] join _dogGroup;

// Configure dog
_dog setSpeaker "NoVoice";
_dog setBehaviour "CARELESS";
_dog setVariable ["BIS_fnc_animalBehaviour_disable", true, true];
_dog setVariable ["vn_sam_disable_death_noise", true, true]; // SOG Prairie Fire compatibility

// Set tracker-specific variables
_dog setVariable ["RECONDO_TRACKERS_trackerGroup", _trackerGroup, true];
_dog setVariable ["RECONDO_TRACKERS_dogGroup", _dogGroup, true];
_dog setVariable ["RECONDO_TRACKERS_side", _trackerSide, true];
_dog setVariable ["RECONDO_TRACKERS_lastDetectionTime", 0, true];
_dog setVariable ["RECONDO_TRACKERS_isHarassing", false, true];

// Store reference on tracker group
_trackerGroup setVariable ["RECONDO_TRACKERS_dog", _dog, true];

// Set up bullet magnet so target side will shoot at dog
[_dog] call Recondo_fnc_assignDogBulletMagnet;

// Add death event handler
_dog addEventHandler ["Killed", {
    params ["_dog", "_killer"];
    
    private _settings = RECONDO_TRACKERS_SETTINGS;
    private _deathSounds = _settings get "dogDeathSounds";
    
    // Play death sound
    private _nearbyPlayers = allPlayers select { _x distance _dog < 350 };
    if (count _nearbyPlayers > 0) then {
        [_dog, _deathSounds] remoteExec ["RECONDO_TRACKERS_fnc_playSound", _nearbyPlayers];
    };
    
    // Clean up bullet magnet
    private _bulletMagnet = _dog getVariable ["RECONDO_TRACKERS_bulletMagnet", objNull];
    if (!isNull _bulletMagnet) then {
        detach _bulletMagnet;
        deleteVehicle _bulletMagnet;
    };
    
    if (_settings get "debugLogging") then {
        diag_log format ["[RECONDO_TRACKERS] Dog killed by %1", _killer];
    };
}];

// Start dog behavior loop
[_dog] spawn Recondo_fnc_trackerDogBehavior;

if (_debugLogging) then {
    diag_log format ["[RECONDO_TRACKERS] Dog created for tracker group %1 at %2 (type: %3)", _trackerGroup, _spawnPos, _dogType];
};

_dog
