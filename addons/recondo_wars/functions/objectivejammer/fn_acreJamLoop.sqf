/*
    Recondo_fnc_acreJamLoop
    Main ACRE jamming loop running on each client
    
    Description:
        Continuously checks if the player is within range of any active jammers
        and applies appropriate signal interference based on distance.
        
        Jamming zones:
        - Within fullJamRadius: Maximum interference (constant jamStrength)
        - Between fullJamRadius and partialJamRadius: Linear falloff
        - Beyond partialJamRadius: No jamming
    
    Parameters:
        None (uses global RECONDO_JAMMER_ACTIVE_DATA)
    
    Returns:
        Nothing (runs indefinitely)
*/

if (!hasInterface) exitWith {};

// Store player side at start
private _playerSide = side group player;

// Function to apply interference to ACRE
private _fnc_setInterference = {
    params ["_interference"];
    
    if (_interference == 1) exitWith {
        // No jamming - clear custom signal function
        [{}] call acre_api_fnc_setCustomSignalFunc;
    };
    
    // Apply jamming via custom signal function
    [{
        private _coreSignal = _this call acre_sys_signal_fnc_getSignalCore;
        _coreSignal params ["_Px", "_maxSignal"];
        
        // Get interference from player variable
        private _interference = player getVariable ["RECONDO_ACRE_INTERFERENCE", 1];
        
        // Apply interference: reduce signal power
        [_Px / _interference, _maxSignal]
        
    }] call acre_api_fnc_setCustomSignalFunc;
    
    // Store interference value for the signal function to access
    player setVariable ["RECONDO_ACRE_INTERFERENCE", _interference];
};

// Main loop
while {true} do {
    sleep 5; // Check every 5 seconds
    
    // Wait for jammer data to be available
    if (isNil "RECONDO_JAMMER_ACTIVE_DATA") then {
        continue;
    };
    
    // Get active jammers that affect this player's side
    private _activeJammers = RECONDO_JAMMER_ACTIVE_DATA select {
        (_x get "active") && 
        {(_x get "sideToJam") == _playerSide}
    };
    
    // No active jammers affecting this player
    if (count _activeJammers == 0) then {
        [1] call _fnc_setInterference;
        continue;
    };
    
    // Find the jammer with the strongest effect on this player
    private _strongestInterference = 1;
    private _playerPos = getPosATL player;
    
    {
        private _jammerPos = _x get "position";
        private _partialRadius = _x get "partialJamRadius";
        private _fullRadius = _x get "fullJamRadius";
        private _jamStrength = _x get "jamStrength";
        
        private _dist = _playerPos distance2D _jammerPos;
        
        // Check if player is within partial jam radius
        if (_dist <= _partialRadius) then {
            private _interference = 1;
            
            if (_dist <= _fullRadius) then {
                // Full jamming zone - constant maximum interference
                _interference = 1 + _jamStrength;
            } else {
                // Partial jamming zone - linear falloff from full to edge
                // At fullRadius: interference = 1 + jamStrength
                // At partialRadius: interference = 1
                private _falloffRange = _partialRadius - _fullRadius;
                private _distFromFull = _dist - _fullRadius;
                private _falloffFactor = 1 - (_distFromFull / _falloffRange);
                _interference = 1 + (_jamStrength * _falloffFactor);
            };
            
            // Keep track of strongest interference
            if (_interference > _strongestInterference) then {
                _strongestInterference = _interference;
            };
        };
    } forEach _activeJammers;
    
    // Apply the strongest interference effect
    [_strongestInterference] call _fnc_setInterference;
};
