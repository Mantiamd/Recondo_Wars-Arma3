/*
    Recondo_fnc_startTransmission
    Server-side function to record start of radio transmission
    
    Description:
        Called from client when player starts speaking on a tracked radio.
        Records the start time for duration calculation.
    
    Parameters:
        0: NUMBER - Server time when transmission started
        1: STRING - Radio ID
        2: OBJECT - Player unit
        
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params ["_startTime", "_radioId", "_unit"];

if (isNil "RECONDO_RWR_SETTINGS") exitWith {};

private _debug = RECONDO_RWR_SETTINGS get "enableDebug";

// Validate start time
if (_startTime <= 0) then {
    _startTime = serverTime;
};

// Store transmission start time
RECONDO_RWR_TRANSMISSION_STARTS set [_radioId, _startTime];

// Store unit reference for this transmission
_unit setVariable ["RECONDO_RWR_TransmittingRadio", _radioId, true];

if (_debug) then {
    diag_log format ["[RECONDO_RWR] Started transmission - Radio: %1, Unit: %2, Time: %3", 
        _radioId, name _unit, _startTime];
};
