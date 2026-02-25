/*
    Recondo_fnc_convoyLinkSpeedControl
    Controls follower vehicle speeds
    
    Description:
        Each follower vehicle adjusts its speed to maintain
        proper separation with the vehicle in front.
    
    Parameters:
        0: OBJECT - Leader vehicle
        1: ARRAY - All vehicles in convoy
        2: HASHMAP - Settings from module
        
    Returns:
        Nothing
*/

params [
    ["_leaderVeh", objNull, [objNull]],
    ["_vehicles", [], [[]]],
    ["_settings", nil, [createHashMap]]
];

if (isNull _leaderVeh || count _vehicles < 2 || isNil "_settings") exitWith {
    diag_log "[RECONDO_CONVOY] LinkSpeedControl: Invalid parameters or single-vehicle convoy";
};

private _convSeparation = _settings get "separation";
private _speedFreq = _settings get "speedFreq";
private _stiffnessLinkCoeff = _settings get "linkStiffness";
private _debugLogging = _settings get "debugLogging";

private _convoyLength = count _vehicles;

if (_debugLogging) then {
    diag_log format ["[RECONDO_CONVOY] LinkSpeedControl started for %1 vehicles", _convoyLength - 1];
};

while {!(_leaderVeh getVariable ["RECONDO_CONVOY_Terminate", false])} do {
    // Check if leader is valid
    if (isNull _leaderVeh || !alive _leaderVeh) exitWith {
        if (_debugLogging) then {
            diag_log "[RECONDO_CONVOY] LinkSpeedControl: Leader destroyed, exiting";
        };
    };
    
    private _isStopped = _leaderVeh getVariable ["RECONDO_CONVOY_Stopped", false];
    
    // Adjust speed for each follower
    for "_i" from 1 to (_convoyLength - 1) do {
        private _vehicle = _vehicles select _i;
        private _vehicleInFront = _vehicles select (_i - 1);
        
        if (isNull _vehicle || isNull _vehicleInFront) then { continue };
        if (!alive _vehicle || !alive _vehicleInFront) then { continue };
        
        // Calculate link metrics
        private _distLink = (getPosATL _vehicle) distance (getPosATL _vehicleInFront);
        private _linkRelaxation = _distLink - _convSeparation;
        
        // Calculate target speed based on vehicle in front and relaxation
        private _frontSpeed = speed _vehicleInFront;
        private _linkSpeed = _frontSpeed;
        
        // Adjust speed based on distance (accelerate if too far, slow if too close)
        if (_linkRelaxation != 0) then {
            private _sign = _linkRelaxation / abs(_linkRelaxation);
            _linkSpeed = _frontSpeed + (_stiffnessLinkCoeff * _sign * (abs(_linkRelaxation) ^ 1.5));
            _linkSpeed = [_linkSpeed, 0, 100] call BIS_fnc_clamp;
        };
        
        // Apply speed
        if (!_isStopped) then {
            _vehicle forceSpeed -1;
            _vehicle limitSpeed _linkSpeed;
        } else {
            _vehicle forceSpeed 0;
        };
        
        // Force vehicles to not use road following (they follow the path instead)
        _vehicle forceFollowRoad false;
    };
    
    sleep _speedFreq;
};

// Reset speed limits on exit
{
    if (!isNull _x && alive _x) then {
        _x forceSpeed -1;
    };
} forEach _vehicles;

if (_debugLogging) then {
    diag_log "[RECONDO_CONVOY] LinkSpeedControl stopped";
};
