/*
    Recondo_fnc_addOPORDActions
    Adds ACE actions to the OPORD object.
    Called via remoteExec on all clients (including JIP).
*/

if (!hasInterface) exitWith {};

params [
    ["_object", objNull, [objNull]]
];

if (isNull _object) exitWith {};

if (_object getVariable ["RECONDO_OPORD_ActionsAdded_" + str clientOwner, false]) exitWith {};
_object setVariable ["RECONDO_OPORD_ActionsAdded_" + str clientOwner, true];

// ========================================
// PARENT ACTION
// ========================================

private _mainAction = [
    "Recondo_OPORD_Main",
    "OPORD",
    "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\documents_ca.paa",
    {},
    { true },
    {},
    [],
    [0, 0, 0],
    3,
    [false, false, false, false, false],
    {}
] call ace_interact_menu_fnc_createAction;

[_object, 0, ["ACE_MainActions"], _mainAction] call ace_interact_menu_fnc_addActionToObject;

// ========================================
// EXPORT PROMPT ACTION
// ========================================

private _exportAction = [
    "Recondo_OPORD_Export",
    "Export OPORD Prompt",
    "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\upload_ca.paa",
    {
        [] call Recondo_fnc_exportOPORDPrompt;
    },
    {
        !isNil "RECONDO_OPORD_SETTINGS"
    },
    {},
    [],
    [0, 0, 0],
    3,
    [false, false, false, false, false],
    {}
] call ace_interact_menu_fnc_createAction;

[_object, 0, ["ACE_MainActions", "Recondo_OPORD_Main"], _exportAction] call ace_interact_menu_fnc_addActionToObject;

// ========================================
// VIEW OPORD ACTION (only if file was loaded)
// ========================================

private _viewAction = [
    "Recondo_OPORD_View",
    "View OPORD",
    "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\intel_ca.paa",
    {
        [] call Recondo_fnc_showOPORD;
    },
    {
        !isNil "RECONDO_OPORD_TEXT"
    },
    {},
    [],
    [0, 0, 0],
    3,
    [false, false, false, false, false],
    {}
] call ace_interact_menu_fnc_createAction;

[_object, 0, ["ACE_MainActions", "Recondo_OPORD_Main"], _viewAction] call ace_interact_menu_fnc_addActionToObject;
