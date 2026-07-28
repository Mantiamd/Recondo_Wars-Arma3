/*
    Recondo_fnc_initSurvivalRadioClient
    Client-side initialization for the Survival Radio system

    Description:
        Sets up ACRE transmission event handlers for tracked survival
        radios and reports start/stop to the server, which measures the
        duration and handles triangulation. No battery system.
        Runs on each client with interface.

    Parameters:
        None

    Returns:
        Nothing
*/

if (!hasInterface) exitWith {};

// Guard against double-add (broadcast fired both live and via JIP queue)
if (missionNamespace getVariable ["RECONDO_SURV_CLIENT_INIT", false]) exitWith {};

// Wait for player and settings to be available
waitUntil {sleep 0.5; !isNull player && {!isNil "RECONDO_SURV_SETTINGS"}};

private _settings = RECONDO_SURV_SETTINGS;
private _debug = _settings get "debugLogging";

// Check if ACRE is available
if (isNil "acre_api_fnc_getCurrentRadioList") exitWith {
    diag_log "[RECONDO_SURV] ERROR: ACRE not detected. Survival Radio system disabled.";
};

RECONDO_SURV_CLIENT_INIT = true;

// Handle start of transmission
["acre_startedSpeaking", {
    params ["_unit", "_onRadio", "_radioId", "_speakingType"];

    if (_unit != player) exitWith {};
    if (!_onRadio || _radioId == "") exitWith {};
    if ([_unit] call Recondo_fnc_isSurvGroupExempt) exitWith {};

    private _settings = RECONDO_SURV_SETTINGS;
    private _radioClassnames = _settings get "radioClassnames";

    // Only tracked survival radios
    private _baseRadio = [_radioId] call acre_api_fnc_getBaseRadio;
    if !(_baseRadio in _radioClassnames) exitWith {};

    [serverTime, _radioId, _unit] remoteExec ["Recondo_fnc_survStartTransmission", 2];

    // Store radio ID for the stop event
    player setVariable ["RECONDO_SURV_LastRadioId", _radioId, false];

    if (_settings get "debugLogging") then {
        diag_log format ["[RECONDO_SURV] Started transmission on %1 (%2)", _radioId, _baseRadio];
    };
}] call CBA_fnc_addEventHandler;

// Handle end of transmission
["acre_stoppedSpeaking", {
    params ["_unit", "_onRadio"];

    if (_unit != player) exitWith {};
    if ([_unit] call Recondo_fnc_isSurvGroupExempt) exitWith {};

    private _radioId = player getVariable ["RECONDO_SURV_LastRadioId", ""];
    if (_radioId == "") exitWith {};

    private _settings = RECONDO_SURV_SETTINGS;
    private _radioClassnames = _settings get "radioClassnames";

    private _baseRadio = [_radioId] call acre_api_fnc_getBaseRadio;
    if !(_baseRadio in _radioClassnames) exitWith {};

    [_radioId, _unit] remoteExec ["Recondo_fnc_survStopTransmission", 2];

    player setVariable ["RECONDO_SURV_LastRadioId", "", false];

    if (_settings get "debugLogging") then {
        diag_log format ["[RECONDO_SURV] Stopped transmission on %1", _radioId];
    };
}] call CBA_fnc_addEventHandler;

if (_debug) then {
    diag_log format ["[RECONDO_SURV] Client initialization complete for %1", name player];
};
