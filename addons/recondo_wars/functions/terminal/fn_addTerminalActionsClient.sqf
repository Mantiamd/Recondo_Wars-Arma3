/*
    Recondo_fnc_addTerminalActionsClient
    Client-side: Creates ACE interaction tree on terminal object
    
    Description:
        Adds admin-only ACE interactions for viewing mission status
        and managing persistence.
    
    Parameters:
        _terminalObject - OBJECT - The terminal object
        _terminalName - STRING - Display name for the terminal
        _linkedToPersistence - BOOL - Whether linked to Persistence module
*/

if (!hasInterface) exitWith {};

params [
    ["_terminalObject", objNull, [objNull]],
    ["_terminalName", "Command Terminal", [""]],
    ["_linkedToPersistence", false, [false]]
];

if (isNull _terminalObject) exitWith {};

// Check if already added
if (_terminalObject getVariable ["RECONDO_TERMINAL_actionsAdded", false]) exitWith {};

// ========================================
// MAIN TERMINAL ACTION (Parent)
// ========================================

private _mainAction = [
    "Recondo_Terminal_Main",
    format ["Access %1", _terminalName],
    "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\intel_ca.paa",
    {},
    {
        // Condition: Only visible to admins
        [] call Recondo_fnc_isPlayerAdmin
    },
    {},
    [],
    [0, 0, 0],
    3,
    [false, false, false, false, false],
    {}
] call ace_interact_menu_fnc_createAction;

[_terminalObject, 0, ["ACE_MainActions"], _mainAction] call ace_interact_menu_fnc_addActionToObject;

// ========================================
// VIEW OBJECTIVE STATUS
// ========================================

private _objectiveAction = [
    "Recondo_Terminal_Objectives",
    "View Objective Status",
    "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\target_ca.paa",
    {
        [] call Recondo_fnc_showObjectiveStatus;
    },
    { true },
    {},
    [],
    [0, 0, 0],
    3,
    [false, false, false, false, false],
    {}
] call ace_interact_menu_fnc_createAction;

[_terminalObject, 0, ["ACE_MainActions", "Recondo_Terminal_Main"], _objectiveAction] call ace_interact_menu_fnc_addActionToObject;

// ========================================
// VIEW PLAYER STATS
// ========================================

private _statsAction = [
    "Recondo_Terminal_Stats",
    "View Player Statistics",
    "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\meet_ca.paa",
    {
        [] call Recondo_fnc_showPlayerStats;
    },
    { true },
    {},
    [],
    [0, 0, 0],
    3,
    [false, false, false, false, false],
    {}
] call ace_interact_menu_fnc_createAction;

[_terminalObject, 0, ["ACE_MainActions", "Recondo_Terminal_Main"], _statsAction] call ace_interact_menu_fnc_addActionToObject;

// ========================================
// RESET MISSION DATA (Only if linked to Persistence)
// ========================================

if (_linkedToPersistence) then {
    // Reset submenu
    private _resetAction = [
        "Recondo_Terminal_Reset",
        "Reset Mission Data",
        "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\danger_ca.paa",
        {},
        { true },
        {},
        [],
        [0, 0, 0],
        3,
        [false, false, false, false, false],
        {}
    ] call ace_interact_menu_fnc_createAction;
    
    [_terminalObject, 0, ["ACE_MainActions", "Recondo_Terminal_Main"], _resetAction] call ace_interact_menu_fnc_addActionToObject;
    
    // Confirm Reset
    private _confirmAction = [
        "Recondo_Terminal_ConfirmReset",
        "CONFIRM: Reset All Data",
        "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\destroy_ca.paa",
        {
            [] remoteExec ["Recondo_fnc_resetAllPersistence", 2];
        },
        { true },
        {},
        [],
        [0, 0, 0],
        3,
        [false, false, false, false, false],
        {}
    ] call ace_interact_menu_fnc_createAction;
    
    [_terminalObject, 0, ["ACE_MainActions", "Recondo_Terminal_Main", "Recondo_Terminal_Reset"], _confirmAction] call ace_interact_menu_fnc_addActionToObject;
    
    // Cancel
    private _cancelAction = [
        "Recondo_Terminal_CancelReset",
        "Cancel",
        "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\exit_ca.paa",
        {
            hint "Reset cancelled.";
        },
        { true },
        {},
        [],
        [0, 0, 0],
        3,
        [false, false, false, false, false],
        {}
    ] call ace_interact_menu_fnc_createAction;
    
    [_terminalObject, 0, ["ACE_MainActions", "Recondo_Terminal_Main", "Recondo_Terminal_Reset"], _cancelAction] call ace_interact_menu_fnc_addActionToObject;
};

// Mark as added
_terminalObject setVariable ["RECONDO_TERMINAL_actionsAdded", true, false];

private _debugLogging = if (isNil "RECONDO_TERMINAL_SETTINGS") then { false } else { RECONDO_TERMINAL_SETTINGS getOrDefault ["debugLogging", false] };
if (_debugLogging) then {
    diag_log format ["[RECONDO_TERMINAL] Client: Added terminal actions to %1", _terminalObject];
};
