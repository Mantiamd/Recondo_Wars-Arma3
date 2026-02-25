/*
    Recondo_fnc_addWiretapPlaceAction
    Client-side: Adds ACE action to place wiretap on a pole
    
    Description:
        Creates an ACE interaction for placing a wiretap.
        Requires player to have the wiretap item in inventory
        and the pole to not already have a wiretap.
    
    Parameters:
        _pole - OBJECT - The pole to add the action to
*/

if (!hasInterface) exitWith {};

params [["_pole", objNull, [objNull]]];

if (isNull _pole) exitWith {};

// Wait for settings to be available
waitUntil { !isNil "RECONDO_WIRETAP_SETTINGS" };

private _actionText = RECONDO_WIRETAP_SETTINGS get "actionPlace";
private _wiretapItem = RECONDO_WIRETAP_SETTINGS get "wiretapItem";
private _enableClassRestriction = RECONDO_WIRETAP_SETTINGS get "enableClassRestriction";
private _allowedClassnames = RECONDO_WIRETAP_SETTINGS get "allowedClassnames";
private _restrictedText = RECONDO_WIRETAP_SETTINGS get "restrictedText";

private _condition = {
    params ["_target", "_player", "_params"];
    _params params ["_wiretapItem", "_enableClassRestriction", "_allowedClassnames"];
    
    // Player has wiretap item AND pole doesn't have active wiretap AND pole not already used
    private _baseCondition = (_wiretapItem in (items _player)) && 
        !(_target getVariable ["RECONDO_WIRETAP_hasWiretap", false]) &&
        !(_target in RECONDO_WIRETAP_USED_POLES);
    
    // Check class restriction if enabled
    if (_baseCondition && _enableClassRestriction) then {
        (typeOf _player) in _allowedClassnames
    } else {
        _baseCondition
    }
};

private _statement = {
    params ["_target", "_player", "_params"];
    _params params ["_wiretapItem", "_enableClassRestriction", "_allowedClassnames", "_restrictedText"];
    
    // Double-check class restriction (in case condition was bypassed)
    if (_enableClassRestriction && !((typeOf _player) in _allowedClassnames)) exitWith {
        hint _restrictedText;
    };
    
    [_target, _player] call Recondo_fnc_startWiretapPlace;
};

private _action = [
    "Recondo_PlaceWiretap",
    _actionText,
    "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\radio_ca.paa",
    _statement,
    _condition,
    {},
    [_wiretapItem, _enableClassRestriction, _allowedClassnames, _restrictedText],
    [0, 0, 0],
    3,
    [false, false, false, false, false],
    {}
] call ace_interact_menu_fnc_createAction;

[_pole, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;
