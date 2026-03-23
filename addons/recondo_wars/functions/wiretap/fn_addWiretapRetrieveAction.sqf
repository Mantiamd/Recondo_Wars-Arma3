/*
    Recondo_fnc_addWiretapRetrieveAction
    Client-side: Adds ACE actions to retrieve wiretap from a pole
    
    Description:
        Creates ACE interactions for retrieving a wiretap and
        checking time remaining until retrieval is available.
    
    Parameters:
        _pole - OBJECT - The pole with the wiretap
*/

if (!hasInterface) exitWith {};

params [["_pole", objNull, [objNull]]];

if (isNull _pole) exitWith {};

// Wait for settings to be available
waitUntil { sleep 0.5; !isNil "RECONDO_WIRETAP_SETTINGS" };

private _actionRetrieve = RECONDO_WIRETAP_SETTINGS get "actionRetrieve";
private _actionCheckTime = RECONDO_WIRETAP_SETTINGS get "actionCheckTime";
private _textWaitTime = RECONDO_WIRETAP_SETTINGS get "textWaitTime";
private _retrievalDelay = RECONDO_WIRETAP_SETTINGS get "retrievalDelay";
private _enableClassRestriction = RECONDO_WIRETAP_SETTINGS get "enableClassRestriction";
private _allowedClassnames = RECONDO_WIRETAP_SETTINGS get "allowedClassnames";
private _restrictedText = RECONDO_WIRETAP_SETTINGS get "restrictedText";

// Retrieve action - only available after delay
private _retrieveCondition = {
    params ["_target", "_player", "_params"];
    _params params ["_retrievalDelay", "_enableClassRestriction", "_allowedClassnames"];
    
    private _placementTime = _target getVariable ["RECONDO_WIRETAP_placementTime", 0];
    private _hasWiretap = _target getVariable ["RECONDO_WIRETAP_hasWiretap", false];
    
    private _baseCondition = _hasWiretap && (time - _placementTime) >= _retrievalDelay;
    
    // Check class restriction if enabled
    if (_baseCondition && _enableClassRestriction) then {
        (typeOf _player) in _allowedClassnames
    } else {
        _baseCondition
    }
};

private _retrieveStatement = {
    params ["_target", "_player", "_params"];
    _params params ["_retrievalDelay", "_enableClassRestriction", "_allowedClassnames", "_restrictedText"];
    
    // Double-check class restriction (in case condition was bypassed)
    if (_enableClassRestriction && !((typeOf _player) in _allowedClassnames)) exitWith {
        hint _restrictedText;
    };
    
    [_target, _player] call Recondo_fnc_startWiretapRetrieve;
};

private _retrieveAction = [
    "Recondo_RetrieveWiretap",
    _actionRetrieve,
    "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\radio_ca.paa",
    _retrieveStatement,
    _retrieveCondition,
    {},
    [_retrievalDelay, _enableClassRestriction, _allowedClassnames, _restrictedText],
    [0, 0, 0],
    3,
    [false, false, false, false, false],
    {}
] call ace_interact_menu_fnc_createAction;

[_pole, 0, ["ACE_MainActions"], _retrieveAction] call ace_interact_menu_fnc_addActionToObject;

// Check time action - only available during wait period (also respects class restriction)
private _checkTimeCondition = {
    params ["_target", "_player", "_params"];
    _params params ["_retrievalDelay", "_enableClassRestriction", "_allowedClassnames"];
    
    private _placementTime = _target getVariable ["RECONDO_WIRETAP_placementTime", 0];
    private _hasWiretap = _target getVariable ["RECONDO_WIRETAP_hasWiretap", false];
    
    private _baseCondition = _hasWiretap && (time - _placementTime) < _retrievalDelay;
    
    // Check class restriction if enabled
    if (_baseCondition && _enableClassRestriction) then {
        (typeOf _player) in _allowedClassnames
    } else {
        _baseCondition
    }
};

private _checkTimeStatement = {
    params ["_target", "_player", "_params"];
    _params params ["_retrievalDelay", "_enableClassRestriction", "_allowedClassnames", "_textWaitTime"];
    
    private _placementTime = _target getVariable ["RECONDO_WIRETAP_placementTime", 0];
    private _timeRemaining = _retrievalDelay - (time - _placementTime);
    
    if (_timeRemaining > 0) then {
        hint format [_textWaitTime, round _timeRemaining];
    };
};

private _checkTimeAction = [
    "Recondo_CheckWiretapTime",
    _actionCheckTime,
    "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\wait_ca.paa",
    _checkTimeStatement,
    _checkTimeCondition,
    {},
    [_retrievalDelay, _enableClassRestriction, _allowedClassnames, _textWaitTime],
    [0, 0, 0],
    3,
    [false, false, false, false, false],
    {}
] call ace_interact_menu_fnc_createAction;

[_pole, 0, ["ACE_MainActions"], _checkTimeAction] call ace_interact_menu_fnc_addActionToObject;
