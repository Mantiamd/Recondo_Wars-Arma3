/*
    Recondo_fnc_addPhotoTurnInClient
    Client-side setup for photo turn-in ACE action
    
    Parameters:
        _object - OBJECT - The turn-in object
        _instanceId - STRING - Photo instance ID
        _objectiveName - STRING - Objective display name
        _rewardItemClassname - STRING - The photo item classname to check for
    
    Returns:
        Nothing
*/

if (!hasInterface) exitWith {};

params [
    ["_object", objNull, [objNull]],
    ["_instanceId", "", [""]],
    ["_objectiveName", "Recon Photo", [""]],
    ["_rewardItemClassname", "", [""]]
];

if (isNull _object || _instanceId == "") exitWith {};

private _existingActions = _object getVariable ["Recondo_Photo_TurnInActions", []];
if (_instanceId in _existingActions) exitWith {};

private _actionName = format ["Recondo_Photo_TurnIn_%1", _instanceId];
private _actionText = format ["Turn In %1", _objectiveName];

private _action = [
    _actionName,
    _actionText,
    "\a3\ui_f\data\igui\cfg\simpletasks\types\scout_ca.paa",
    {
        params ["_target", "_player", "_params"];
        _params params ["_instanceId", "_rewardItemClassname"];
        [_instanceId, _rewardItemClassname, _player] remoteExec ["Recondo_fnc_handlePhotoTurnIn", 2];
    },
    {
        params ["_target", "_player", "_params"];
        _params params ["_instanceId", "_rewardItemClassname"];
        
        if (isNil "RECONDO_PHOTO_PHOTOGRAPHED") exitWith { false };
        if (count RECONDO_PHOTO_PHOTOGRAPHED == 0) exitWith { false };
        
        // Check player has a photo item
        if (_rewardItemClassname == "") exitWith { false };
        _rewardItemClassname in (items _player)
    },
    {},
    [_instanceId, _rewardItemClassname],
    [0, 0, 0],
    2,
    [false, false, false, false, false],
    {}
] call ace_interact_menu_fnc_createAction;

[_object, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;

_existingActions pushBack _instanceId;
_object setVariable ["Recondo_Photo_TurnInActions", _existingActions, false];
