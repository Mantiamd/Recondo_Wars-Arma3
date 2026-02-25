/*
    Recondo_fnc_addIntelBoardActionClient
    Client-side setup for Intel Board ACE action
    
    Description:
        Adds the ACE interaction to view the Intel Board on the specified object.
        Only runs on machines with interface (players).
    
    Parameters:
        _object - OBJECT - The object to add the action to
        _actionName - STRING - The display name for the ACE action
    
    Returns:
        Nothing
    
    Example:
        [_object, "View Intel Board"] call Recondo_fnc_addIntelBoardActionClient;
*/

if (!hasInterface) exitWith {};

params [
    ["_object", objNull, [objNull]],
    ["_actionName", "View Intel Board", [""]]
];

if (isNull _object) exitWith {};

// Check if action already added (prevent duplicates from JIP)
if (_object getVariable ["Recondo_IntelBoard_ActionAdded_" + str clientOwner, false]) exitWith {};
_object setVariable ["Recondo_IntelBoard_ActionAdded_" + str clientOwner, true];

// Create ACE action
private _action = [
    "Recondo_IntelBoard_View",
    _actionName,
    "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\documents_ca.paa",
    {
        // Action code - open the Intel Board
        [] call Recondo_fnc_openIntelBoard;
    },
    {
        // Condition - available when object is enabled and board not already open
        params ["_target", "_player", "_params"];
        (_target getVariable ["Recondo_IntelBoard_Enabled", false]) && 
        (isNil "RECONDO_INTELBOARD_OPEN" || {!RECONDO_INTELBOARD_OPEN})
    },
    {},
    [],
    [0, 0, 0],
    2,
    [false, false, false, false, false]
] call ace_interact_menu_fnc_createAction;

// Add to object
[_object, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;

private _settings = if (isNil "RECONDO_INTELBOARD_SETTINGS") then { createHashMap } else { RECONDO_INTELBOARD_SETTINGS };
private _debugLogging = _settings getOrDefault ["debugLogging", false];

if (_debugLogging) then {
    diag_log format ["[RECONDO_INTELBOARD] Client: Added Intel Board action to %1", _object];
};
