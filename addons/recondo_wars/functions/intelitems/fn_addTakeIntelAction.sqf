/*
    Recondo_fnc_addTakeIntelAction
    Adds ACE interactions to take intel from a unit
    
    Description:
        Creates ACE interactions on a unit for each intel item they carry.
        Works on both living and dead units (for prisoner searching).
        The action removes one item per interaction.
    
    Parameters:
        _unit - OBJECT - The unit to add actions to
        _intelItems - ARRAY - Array of [displayName, classname] for each item
    
    Returns:
        Nothing
    
    Example:
        [_unit, [["Mobile Phone", "ACE_Cellphone"]]] call Recondo_fnc_addTakeIntelAction;
*/

params [
    ["_unit", objNull, [objNull]],
    ["_intelItems", [], [[]]]
];

if (isNull _unit || count _intelItems == 0) exitWith {};

// Get action text format
private _takeActionText = if (isNil "RECONDO_INTELITEMS_SETTINGS") then {
    "Take %1"
} else {
    RECONDO_INTELITEMS_SETTINGS getOrDefault ["takeActionText", "Take %1"]
};

private _debugLogging = if (isNil "RECONDO_INTELITEMS_SETTINGS") then {
    false
} else {
    RECONDO_INTELITEMS_SETTINGS getOrDefault ["debugLogging", false]
};

// Broadcast to all clients to add ACE actions
[_unit, _intelItems, _takeActionText] remoteExec ["Recondo_fnc_addTakeIntelActionClient", 0, true];

if (_debugLogging) then {
    diag_log format ["[RECONDO_INTELITEMS] Broadcast ACE actions for unit %1 with %2 intel items", _unit, count _intelItems];
};
