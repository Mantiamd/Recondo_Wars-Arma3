/*
    Recondo_fnc_convoyDriverMonitor
    Monitors driver status and handles replacement
    
    Description:
        Monitors a vehicle's driver and handles incapacitation
        by moving another crew member to the driver seat.
        Prioritizes non-gunners for driver replacement.
    
    Parameters:
        0: OBJECT - Vehicle to monitor
        1: OBJECT - Leader vehicle (for terminate flag)
        2: HASHMAP - Settings from module
        
    Returns:
        Nothing
*/

params [
    ["_vehicle", objNull, [objNull]],
    ["_leaderVeh", objNull, [objNull]],
    ["_settings", nil, [createHashMap]]
];

if (isNull _vehicle || isNull _leaderVeh || isNil "_settings") exitWith {
    diag_log "[RECONDO_CONVOY] DriverMonitor: Invalid parameters";
};

private _debugLogging = _settings get "debugLogging";

// Initialize vehicle state
_vehicle setVariable ["RECONDO_CONVOY_DriverIncapacitated", false];
_vehicle setVariable ["RECONDO_CONVOY_VehicleIncapacitated", false];

if (_debugLogging) then {
    diag_log format ["[RECONDO_CONVOY] DriverMonitor started for %1", typeOf _vehicle];
};

while {!(_leaderVeh getVariable ["RECONDO_CONVOY_Terminate", false])} do {
    // Check if vehicle is still valid
    if (isNull _vehicle || !alive _vehicle || !canMove _vehicle) exitWith {
        _vehicle setVariable ["RECONDO_CONVOY_VehicleIncapacitated", true];
        
        if (_debugLogging) then {
            diag_log format ["[RECONDO_CONVOY] DriverMonitor: Vehicle %1 destroyed/immobile", typeOf _vehicle];
        };
    };
    
    // Check driver status
    private _driver = driver _vehicle;
    private _driverIncapacitated = isNull _driver || !alive _driver || 
        (lifeState _driver) in ["INCAPACITATED", "DEAD"];
    
    if (_driverIncapacitated) then {
        _vehicle setVariable ["RECONDO_CONVOY_DriverIncapacitated", true];
        
        if (_debugLogging) then {
            diag_log format ["[RECONDO_CONVOY] DriverMonitor: Driver incapacitated in %1", typeOf _vehicle];
        };
        
        // Get alive crew
        private _aliveCrew = (crew _vehicle) select { alive _x && (lifeState _x) != "INCAPACITATED" };
        
        if (count _aliveCrew == 0) then {
            // No crew left, mark vehicle as incapacitated
            _vehicle setVariable ["RECONDO_CONVOY_VehicleIncapacitated", true];
            
            if (_debugLogging) then {
                diag_log format ["[RECONDO_CONVOY] DriverMonitor: No crew left in %1, marking incapacitated", typeOf _vehicle];
            };
        } else {
            // Try to find a replacement driver (prefer non-gunners)
            private _replacement = objNull;
            
            // First pass: look for non-gunners
            {
                if (_x != gunner _vehicle) exitWith {
                    _replacement = _x;
                };
            } forEach _aliveCrew;
            
            // Second pass: use gunner if no other choice
            if (isNull _replacement && count _aliveCrew > 0) then {
                _replacement = _aliveCrew select 0;
            };
            
            if (!isNull _replacement) then {
                // Store original behavior
                private _prevBehavior = behaviour _replacement;
                
                // Create new group for driver and move them
                private _newGroup = createGroup [(side _replacement), true];
                [_replacement] joinSilent _newGroup;
                _newGroup copyWaypoints (group _driver);
                _newGroup addVehicle _vehicle;
                
                // Assign as driver
                _replacement assignAsDriver _vehicle;
                _replacement moveInDriver _vehicle;
                
                // Set behavior to CARELESS (keep moving)
                _newGroup setBehaviour "CARELESS";
                _vehicle setEffectiveCommander _replacement;
                
                // Clear incapacitated flag
                _vehicle setVariable ["RECONDO_CONVOY_DriverIncapacitated", false];
                
                if (_debugLogging) then {
                    diag_log format ["[RECONDO_CONVOY] DriverMonitor: %1 assigned as new driver in %2", typeOf _replacement, typeOf _vehicle];
                };
            };
        };
    };
    
    sleep 1;
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_CONVOY] DriverMonitor stopped for %1", typeOf _vehicle];
};
