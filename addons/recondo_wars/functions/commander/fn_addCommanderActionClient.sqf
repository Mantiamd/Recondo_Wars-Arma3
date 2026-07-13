/*
    Recondo_fnc_addCommanderActionClient
    Registers the "Spawn Squad" ACE self-interaction for officer classnames

    Description:
        Runs on every client (including JIP). Adds a self-action to each configured
        officer classname. The action asks the server to spawn a squad; the condition
        greys it out while the officer is at their squad cap. The player action only
        requests the spawn — all authority stays on the server.

    Parameters:
        _settings - HashMap - Commander settings (passed so JIP clients have it too)

    Returns:
        Nothing
*/

if (!hasInterface) exitWith {};

params [["_settings", createHashMap, [createHashMap]]];

// Ensure the global exists on this client (publicVariable is not JIP-persistent).
RECONDO_CMD_SETTINGS = _settings;

// Guard against duplicate adds (JIP re-broadcast, multiple modules should not exist).
if (RECONDO_CMD_ACTIONS_ADDED) exitWith {};
RECONDO_CMD_ACTIONS_ADDED = true;

private _officerClassnames = _settings getOrDefault ["officerClassnames", []];
private _actionName = _settings getOrDefault ["actionName", "Spawn Squad"];

if (count _officerClassnames == 0) exitWith {};

// Action 1: request the server to spawn a new squad (greyed out at the squad cap).
private _spawnAction = [
    "RECONDO_CMD_SpawnSquad",
    _actionName,
    "\a3\ui_f\data\igui\cfg\simpletasks\types\move_ca.paa",
    {
        params ["_target", "_player"];
        [_player] remoteExecCall ["Recondo_fnc_commanderSpawnSquad", 2];
    },
    {
        params ["_target", "_player"];
        alive _player
        && {!isNil "RECONDO_CMD_SETTINGS"}
        && {(_player getVariable ["RECONDO_CMD_SquadCount", 0]) < (RECONDO_CMD_SETTINGS getOrDefault ["maxSquads", 3])}
    },
    {},
    [],
    [0, 0, 0],
    4
] call ace_interact_menu_fnc_createAction;

// Action 2: open the command map (shown only when the officer has a live squad).
private _commandAction = [
    "RECONDO_CMD_CommandSquads",
    "Command Squads",
    "\a3\ui_f\data\igui\cfg\simpletasks\types\meet_ca.paa",
    {
        [] call Recondo_fnc_commanderOpenCommandMap;
    },
    {
        params ["_target", "_player"];
        alive _player
        && {!isNil "RECONDO_CMD_CLIENT_SQUADS"}
        && {(RECONDO_CMD_CLIENT_SQUADS findIf { private _g = _x select 0; !isNull _g && {({alive _x} count units _g) > 0} }) != -1}
    },
    {},
    [],
    [0, 0, 0],
    4
] call ace_interact_menu_fnc_createAction;

// Add both to each officer classname (no inheritance — exact classnames only).
{
    [_x, 1, ["ACE_SelfActions"], _spawnAction, false] call ace_interact_menu_fnc_addActionToClass;
    [_x, 1, ["ACE_SelfActions"], _commandAction, false] call ace_interact_menu_fnc_addActionToClass;
} forEach _officerClassnames;

if (_settings getOrDefault ["debugLogging", false]) then {
    diag_log format ["[RECONDO_CMD] Client: registered '%1' + 'Command Squads' self-actions on %2 officer class(es).", _actionName, count _officerClassnames];
};
