/*
    Recondo_fnc_convoyLeadSpeedControl
    Controls lead vehicle speed based on convoy state
    
    Description:
        Dynamically adjusts the lead vehicle's speed based on:
        - Average distance between vehicles (convoy spreading)
        - Heading differences (road curvature)
        - Speed differences (convoy entropy)
        
        Uses a spring-damper model for smooth speed adjustments.
    
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

if (isNull _leaderVeh || count _vehicles == 0 || isNil "_settings") exitWith {
    diag_log "[RECONDO_CONVOY] LeadSpeedControl: Invalid parameters";
};

private _maxDefSpeed = _settings get "maxSpeed";
private _convSeparation = _settings get "separation";
private _speedFreq = _settings get "speedFreq";
private _stiffnessCoeff = _settings get "stiffness";
private _dampingCoeff = _settings get "damping";
private _curvatureCoeff = _settings get "curvature";
private _debugLogging = _settings get "debugLogging";

private _convoyLength = count _vehicles;

if (_debugLogging) then {
    diag_log format ["[RECONDO_CONVOY] LeadSpeedControl started, max speed: %1 km/h, separation: %2m", _maxDefSpeed, _convSeparation];
};

while {!(_leaderVeh getVariable ["RECONDO_CONVOY_Terminate", false])} do {
    // Check if leader is valid
    if (isNull _leaderVeh || !alive _leaderVeh) exitWith {
        if (_debugLogging) then {
            diag_log "[RECONDO_CONVOY] LeadSpeedControl: Leader destroyed, exiting";
        };
    };
    
    // Collect convoy metrics
    private _arrayDistances = [];
    private _arrayRotations = [];
    private _arraySpeeds = [];
    
    for "_i" from 1 to (_convoyLength - 1) do {
        private _vehicle = _vehicles select _i;
        private _vehicleInFront = _vehicles select (_i - 1);
        
        if (!isNull _vehicle && !isNull _vehicleInFront && alive _vehicle && alive _vehicleInFront) then {
            _arrayDistances pushBack (_vehicle distance _vehicleInFront);
            _arrayRotations pushBack (abs((getDir _vehicle) - (getDir _vehicleInFront)));
            _arraySpeeds pushBack (abs((speed _vehicle) - (speed _vehicleInFront)));
        };
    };
    
    // Calculate convoy metrics
    private _avrDistance = 0;
    private _convoyRelaxation = 0;
    private _convoyCurvature = 0;
    private _convoyEntropy = 0;
    
    if (count _arrayDistances > 0) then {
        _avrDistance = _arrayDistances call BIS_fnc_arithmeticMean;
        _convoyRelaxation = [_avrDistance - _convSeparation, 0, 100000] call BIS_fnc_clamp;
        _convoyCurvature = _arrayRotations call BIS_fnc_arithmeticMean;
        _convoyEntropy = _arraySpeeds call BIS_fnc_arithmeticMean;
    };
    
    // Calculate target speed using spring-damper model
    private _maxSpeed = 0;
    
    if (_maxDefSpeed > 0) then {
        private _speedReduction = _stiffnessCoeff * (_convoyRelaxation ^ 1.5);
        _speedReduction = _speedReduction + (_curvatureCoeff * ([_convoyCurvature, 0, 45] call BIS_fnc_clamp));
        _speedReduction = _speedReduction + (_dampingCoeff * _convoyEntropy);
        _speedReduction = [_speedReduction, 0, _maxDefSpeed - 5] call BIS_fnc_clamp;
        
        _maxSpeed = _maxDefSpeed - _speedReduction;
    };
    
    // Apply speed to leader
    private _isStopped = _leaderVeh getVariable ["RECONDO_CONVOY_Stopped", false];
    
    if (_maxDefSpeed > 0 && !_isStopped) then {
        _leaderVeh forceSpeed -1;
        _leaderVeh limitSpeed _maxSpeed;
    } else {
        _leaderVeh forceSpeed 0;
    };
    
    sleep _speedFreq;
};

// Reset speed limit on exit
_leaderVeh forceSpeed -1;

if (_debugLogging) then {
    diag_log "[RECONDO_CONVOY] LeadSpeedControl stopped";
};
