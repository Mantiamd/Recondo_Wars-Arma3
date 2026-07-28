/*
    Recondo_fnc_survStartTransmission
    Server-side: records the start of a survival radio transmission

    Parameters:
        0: NUMBER - Server time when transmission started
        1: STRING - Radio ID
        2: OBJECT - Transmitting unit

    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params ["_startTime", "_radioId", "_unit"];

if (isNil "RECONDO_SURV_SETTINGS") exitWith {};

if (_startTime <= 0) then {
    _startTime = serverTime;
};

RECONDO_SURV_TRANSMISSION_STARTS set [_radioId, _startTime];

if (RECONDO_SURV_SETTINGS get "debugLogging") then {
    diag_log format ["[RECONDO_SURV] Transmission started - Radio: %1, Unit: %2, Time: %3", _radioId, name _unit, _startTime];
};
