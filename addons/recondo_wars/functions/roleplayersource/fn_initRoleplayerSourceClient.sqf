/*
    Recondo_fnc_initRoleplayerSourceClient
    Client-side: Adds ACE actions for roleplayer source data.

    Two modes:
      _allowAllPlayers = false: Self-actions on synced players only.
      _allowAllPlayers = true:  Object interactions on the synced object (any player).

    Civilian Presence self-action is added directly to the player
    object in both modes (uses addActionToObject on player).
*/

params [
    ["_allowAllPlayers", false, [false]],
    ["_interactObject", objNull, [objNull]]
];

if (!hasInterface) exitWith {};

// ========================================
// CIVILIAN PRESENCE SELF-ACTION (Both Modes)
// Added directly to the player object.
// ========================================

if (isNil "RECONDO_RP_SOURCE_CIVACTION_ADDED" || {!RECONDO_RP_SOURCE_CIVACTION_ADDED}) then {
    RECONDO_RP_SOURCE_CIVACTION_ADDED = true;

    private _civAction = [
        "Recondo_RPSource_SpawnCivs",
        "Populate Nearby with Civilian Presence",
        "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\meet_ca.paa",
        {
            private _pos = getPosATL player;
            [_pos] remoteExec ["Recondo_fnc_rpRequestCivilians", 2];
            player setVariable ["RECONDO_RP_CIVSPAWN_LASTUSE", time];
            systemChat "Populating area with civilian presence...";
        },
        {
            private _settings = missionNamespace getVariable ["RECONDO_RP_SOURCE_SETTINGS", nil];
            if (isNil "_settings") exitWith { false };
            private _civClassnames = _settings getOrDefault ["civClassnames", []];
            if (count _civClassnames == 0) exitWith { false };
            private _cooldown = _settings getOrDefault ["civCooldown", 300];
            private _lastUse = player getVariable ["RECONDO_RP_CIVSPAWN_LASTUSE", -99999];
            time - _lastUse >= _cooldown
        },
        {},
        [],
        [0, 0, 0],
        3,
        [false, false, false, false, false],
        {}
    ] call ace_interact_menu_fnc_createAction;

    [player, 1, ["ACE_SelfActions"], _civAction] call ace_interact_menu_fnc_addActionToObject;
};

// ========================================
// MODE: OBJECT INTERACTION (All Players)
// ========================================

if (_allowAllPlayers) exitWith {
    if (isNull _interactObject) exitWith {};

    if (_interactObject getVariable ["RECONDO_RP_SOURCE_actionsAdded", false]) exitWith {};

    private _mainAction = [
        "Recondo_RPSource_Main",
        "ROLEPLAYER Source Data",
        "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\intel_ca.paa",
        {},
        { true },
        {},
        [],
        [0, 0, 0],
        3,
        [false, false, false, false, false],
        {}
    ] call ace_interact_menu_fnc_createAction;

    [_interactObject, 0, ["ACE_MainActions"], _mainAction] call ace_interact_menu_fnc_addActionToObject;

    private _instructionsAction = [
        "Recondo_RPSource_Instructions",
        "Roleplayer Instructions",
        "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\documents_ca.paa",
        {
            [] call Recondo_fnc_rpShowInstructions;
        },
        { true },
        {},
        [],
        [0, 0, 0],
        3,
        [false, false, false, false, false],
        {}
    ] call ace_interact_menu_fnc_createAction;

    [_interactObject, 0, ["ACE_MainActions", "Recondo_RPSource_Main"], _instructionsAction] call ace_interact_menu_fnc_addActionToObject;

    private _objectiveAction = [
        "Recondo_RPSource_Objectives",
        "View Objective Status",
        "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\target_ca.paa",
        {
            [] call Recondo_fnc_rpShowObjectiveStatus;
        },
        { true },
        {},
        [],
        [0, 0, 0],
        3,
        [false, false, false, false, false],
        {}
    ] call ace_interact_menu_fnc_createAction;

    [_interactObject, 0, ["ACE_MainActions", "Recondo_RPSource_Main"], _objectiveAction] call ace_interact_menu_fnc_addActionToObject;

    private _statsAction = [
        "Recondo_RPSource_Stats",
        "View Player Statistics",
        "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\meet_ca.paa",
        {
            [] call Recondo_fnc_rpShowPlayerStats;
        },
        { true },
        {},
        [],
        [0, 0, 0],
        3,
        [false, false, false, false, false],
        {}
    ] call ace_interact_menu_fnc_createAction;

    [_interactObject, 0, ["ACE_MainActions", "Recondo_RPSource_Main"], _statsAction] call ace_interact_menu_fnc_addActionToObject;

    _interactObject setVariable ["RECONDO_RP_SOURCE_actionsAdded", true, false];
};

// ========================================
// MODE: SELF-ACTION (Synced Units Only)
// ========================================

if (!isNil "RECONDO_RP_SOURCE_SELFACTIONS_ADDED" && {RECONDO_RP_SOURCE_SELFACTIONS_ADDED}) exitWith {};
RECONDO_RP_SOURCE_SELFACTIONS_ADDED = true;

private _fnc_isRoleplayer = {
    if (player getVariable ["RECONDO_RP_SOURCE_ALLOWED", false]) exitWith { true };
    private _settings = missionNamespace getVariable ["RECONDO_RP_SOURCE_SETTINGS", nil];
    if (isNil "_settings") exitWith { false };
    private _rpClassnames = _settings getOrDefault ["rpClassnames", []];
    (typeOf player) in _rpClassnames
};

private _mainAction = [
    "Recondo_RPSource_Main",
    "ROLEPLAYER Source Data",
    "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\intel_ca.paa",
    {},
    _fnc_isRoleplayer,
    {},
    [],
    [0, 0, 0],
    3,
    [false, false, false, false, false],
    {}
] call ace_interact_menu_fnc_createAction;

["CAManBase", 1, ["ACE_SelfActions"], _mainAction, true] call ace_interact_menu_fnc_addActionToClass;

private _instructionsAction = [
    "Recondo_RPSource_Instructions",
    "Roleplayer Instructions",
    "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\documents_ca.paa",
    {
        [] call Recondo_fnc_rpShowInstructions;
    },
    { true },
    {},
    [],
    [0, 0, 0],
    3,
    [false, false, false, false, false],
    {}
] call ace_interact_menu_fnc_createAction;

["CAManBase", 1, ["ACE_SelfActions", "Recondo_RPSource_Main"], _instructionsAction, true] call ace_interact_menu_fnc_addActionToClass;

private _objectiveAction = [
    "Recondo_RPSource_Objectives",
    "View Objective Status",
    "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\target_ca.paa",
    {
        [] call Recondo_fnc_rpShowObjectiveStatus;
    },
    { true },
    {},
    [],
    [0, 0, 0],
    3,
    [false, false, false, false, false],
    {}
] call ace_interact_menu_fnc_createAction;

["CAManBase", 1, ["ACE_SelfActions", "Recondo_RPSource_Main"], _objectiveAction, true] call ace_interact_menu_fnc_addActionToClass;

private _statsAction = [
    "Recondo_RPSource_Stats",
    "View Player Statistics",
    "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\meet_ca.paa",
    {
        [] call Recondo_fnc_rpShowPlayerStats;
    },
    { true },
    {},
    [],
    [0, 0, 0],
    3,
    [false, false, false, false, false],
    {}
] call ace_interact_menu_fnc_createAction;

["CAManBase", 1, ["ACE_SelfActions", "Recondo_RPSource_Main"], _statsAction, true] call ace_interact_menu_fnc_addActionToClass;
