/*
    Recondo_fnc_commanderSetupSquadClient
    Registers a spawned squad on the officer's client

    Description:
        Runs on the officer's client (called via remoteExec after the server spawns
        the squad). Records the squad in a client-side list keyed only to this
        officer, so it appears as an icon in the command map dialog. The squad stays
        local to the server; the command map reads positions from the synced units.
        Squads are not shown on the vanilla map - only inside the command dialog.

    Parameters:
        0: _officer - OBJECT - The commanding officer (local player on this machine)
        1: _group   - GROUP  - The squad

    Returns:
        Nothing
*/

if (!hasInterface) exitWith {};

params [
    ["_officer", objNull, [objNull]],
    ["_group", grpNull, [grpNull]]
];

if (isNull _officer) exitWith {};
if (isNull _group) exitWith {};

// Skip if this squad is already registered on this client.
if (RECONDO_CMD_CLIENT_SQUADS findIf { (_x select 0) isEqualTo _group } != -1) exitWith {};

// Simple per-officer squad label.
if (isNil "RECONDO_CMD_MARKER_COUNT") then { RECONDO_CMD_MARKER_COUNT = 0; };
RECONDO_CMD_MARKER_COUNT = RECONDO_CMD_MARKER_COUNT + 1;
private _label = format ["Squad %1", RECONDO_CMD_MARKER_COUNT];

// Register for the command map: [group, label].
RECONDO_CMD_CLIENT_SQUADS pushBack [_group, _label];
