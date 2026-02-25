/*
    Recondo_fnc_addCampIntelAction
    Adds ACE interaction to an intel object at a camp
    
    Description:
        Creates an ACE interaction action on the intel object
        that allows players to pick it up.
        Runs on all clients via remoteExec.
    
    Parameters:
        _object - OBJECT - The intel object
        _actionText - STRING - Text for the action
    
    Returns:
        Nothing
    
    Example:
        [_intelObject, "Take Documents"] call Recondo_fnc_addCampIntelAction;
*/

if (!hasInterface) exitWith {};

params [
    ["_object", objNull, [objNull]],
    ["_actionText", "Take Intel", [""]]
];

if (isNull _object) exitWith {};

// Check if ACE interact is available
if (isNil "ace_interact_menu_fnc_createAction") then {
    // Fallback to vanilla addAction
    _object addAction [
        format ["<t color='#FFD700'>%1</t>", _actionText],
        {
            params ["_target", "_caller", "_actionId", "_arguments"];
            [_target, _caller] call Recondo_fnc_handleIntelPickup;
        },
        nil,
        6,
        true,
        true,
        "",
        "alive _target && isPlayer _this && _this distance _target < 3",
        3,
        false
    ];
} else {
    // ACE interaction
    private _action = [
        format ["RECONDO_CAMPS_pickup_%1", _object],
        _actionText,
        "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_search_ca.paa",
        {
            params ["_target", "_player", "_params"];
            [_target, _player] call Recondo_fnc_handleIntelPickup;
        },
        {
            params ["_target", "_player", "_params"];
            alive _target && isPlayer _player
        },
        {},
        [],
        [0, 0, 0],
        2
    ] call ace_interact_menu_fnc_createAction;
    
    [_object, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;
};
