/*
    Recondo_fnc_addPowergridActionClient
    Client-side setup for powergrid ACE interactions

    Description:
        Adds "Turn Off Power" and "Turn On Power" ACE actions to the
        synced object. Only one is visible at a time based on the
        current power state tracked in RECONDO_POWERGRID_STATES.

    Parameters:
        _object - OBJECT - The synced powergrid object
        _instanceId - STRING - Powergrid instance ID
        _actionText - STRING - Display text for turn-off action
        _restoreActionText - STRING - Display text for restore action

    Execution:
        Client only (called via remoteExec from server)
*/

if (!hasInterface) exitWith {};

params [
    ["_object", objNull, [objNull]],
    ["_instanceId", "", [""]],
    ["_actionText", "Turn Off Power", [""]],
    ["_restoreActionText", "Turn On Power", [""]]
];

if (isNull _object || _instanceId == "") exitWith {};

private _existing = _object getVariable ["Recondo_Powergrid_ActionsAdded", []];
if (_instanceId in _existing) exitWith {};

// "Turn Off Power" action
private _turnOffAction = [
    format ["Recondo_PG_Off_%1", _instanceId],
    _actionText,
    "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\destroy_ca.paa",
    {
        params ["_target", "_player", "_params"];
        _params params ["_instanceId"];
        [_instanceId, "OFF"] remoteExec ["Recondo_fnc_togglePowergridLights", 2];
    },
    {
        params ["_target", "_player", "_params"];
        _params params ["_instanceId"];
        (RECONDO_POWERGRID_STATES getOrDefault [_instanceId, "ON"]) == "ON"
    },
    {},
    [_instanceId],
    [0, 0, 0],
    3,
    [false, false, false, false, false],
    {}
] call ace_interact_menu_fnc_createAction;

[_object, 0, ["ACE_MainActions"], _turnOffAction] call ace_interact_menu_fnc_addActionToObject;

// "Turn On Power" action
private _turnOnAction = [
    format ["Recondo_PG_On_%1", _instanceId],
    _restoreActionText,
    "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\repair_ca.paa",
    {
        params ["_target", "_player", "_params"];
        _params params ["_instanceId"];
        [_instanceId, "ON"] remoteExec ["Recondo_fnc_togglePowergridLights", 2];
    },
    {
        params ["_target", "_player", "_params"];
        _params params ["_instanceId"];
        (RECONDO_POWERGRID_STATES getOrDefault [_instanceId, "ON"]) == "OFF"
    },
    {},
    [_instanceId],
    [0, 0, 0],
    3,
    [false, false, false, false, false],
    {}
] call ace_interact_menu_fnc_createAction;

[_object, 0, ["ACE_MainActions"], _turnOnAction] call ace_interact_menu_fnc_addActionToObject;

_existing pushBack _instanceId;
_object setVariable ["Recondo_Powergrid_ActionsAdded", _existing, false];
