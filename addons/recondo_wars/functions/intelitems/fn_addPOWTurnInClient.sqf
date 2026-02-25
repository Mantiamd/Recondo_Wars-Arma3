/*
    Recondo_fnc_addPOWTurnInClient
    Client-side setup for POW turn-in ACE action
    
    Description:
        Adds the "Turn In Prisoner" ACE interaction to the
        specified turn-in object. Shows action when a valid
        POW is within range.
    
    Parameters:
        _object - OBJECT - The turn-in object
        _actionText - STRING - Text for the ACE action
        _turnInRadius - NUMBER - Required distance of POW from turn-in object
    
    Returns:
        Nothing
*/

if (!hasInterface) exitWith {};

params [
    ["_object", objNull, [objNull]],
    ["_actionText", "Turn In Prisoner", [""]],
    ["_turnInRadius", 10, [0]]
];

if (isNull _object) exitWith {};

// Check if action already exists on this object
if (_object getVariable ["Recondo_POW_TurnInActionAdded", false]) exitWith {};

// Create the ACE action
private _action = [
    "Recondo_POW_TurnIn",
    _actionText,
    "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\meet_ca.paa",
    {
        // Statement - executed when action is used
        params ["_target", "_player", "_params"];
        _params params ["_turnInRadius"];
        
        // Find nearest valid POW
        private _pow = [_target, _turnInRadius] call Recondo_fnc_findNearestValidPOW;
        
        if (isNull _pow) exitWith {
            hint "No valid prisoner nearby.";
        };
        
        // Process turn-in on server
        [_pow, _player] remoteExec ["Recondo_fnc_handlePOWTurnIn", 2];
    },
    {
        // Condition - when is action shown
        params ["_target", "_player", "_params"];
        _params params ["_turnInRadius"];
        
        // Check if there's a valid POW nearby
        private _pow = [_target, _turnInRadius] call Recondo_fnc_findNearestValidPOW;
        
        !isNull _pow
    },
    {},
    [_turnInRadius],
    [0, 0, 0],
    2,
    [false, false, false, false, false],
    {}
] call ace_interact_menu_fnc_createAction;

// Add the action to the object
[_object, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;

// Mark as added
_object setVariable ["Recondo_POW_TurnInActionAdded", true, false];

private _debugLogging = if (isNil "RECONDO_INTELITEMS_SETTINGS") then { false } else {
    RECONDO_INTELITEMS_SETTINGS getOrDefault ["debugLogging", false]
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_INTELITEMS] Client: Added POW turn-in action to object: %1", _object];
};
