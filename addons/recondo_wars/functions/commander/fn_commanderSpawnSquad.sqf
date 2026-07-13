/*
    Recondo_fnc_commanderSpawnSquad
    Server-side spawn of a commanded squad for an officer

    Description:
        Runs on the server (called via remoteExec from the officer's ACE action).
        Validates the requester is a configured officer and under their squad cap,
        spawns the squad at the configured marker, and tracks it. The squad stays
        LOCAL TO THE SERVER (authoritative AI); the officer commands it via the
        click-to-command map menu, which routes orders back to the server. The
        officer's client is told to set up its private map marker.

    Parameters:
        _officer - OBJECT - The requesting officer (player)

    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [["_officer", objNull, [objNull]]];

if (isNull _officer) exitWith {};
if (isNil "RECONDO_CMD_SETTINGS") exitWith {};
if !(alive _officer) exitWith {};

private _settings = RECONDO_CMD_SETTINGS;
private _officerClassnames = _settings get "officerClassnames";
private _soldierClassnames = _settings get "soldierClassnames";
private _squadSideNum = _settings get "squadSideNum";
private _spawnMarker = _settings get "spawnMarker";
private _maxSquads = _settings get "maxSquads";
private _spawnRadius = _settings get "spawnRadius";
private _debugLogging = _settings get "debugLogging";

// Authoritative officer check (never trust the client).
if !((typeOf _officer) in _officerClassnames) exitWith {
    if (_debugLogging) then {
        diag_log format ["[RECONDO_CMD] Rejected spawn request: %1 (%2) is not an officer type.", name _officer, typeOf _officer];
    };
};

// Marker must still exist.
if !(_spawnMarker in allMapMarkers) exitWith {
    diag_log format ["[RECONDO_CMD] ERROR: Spawn marker '%1' missing at spawn time.", _spawnMarker];
    ["Squad spawn failed: spawn point not found."] remoteExec ["hint", owner _officer];
};

// Per-officer cap (authoritative). Prune dead/empty groups first.
private _uid = getPlayerUID _officer;
if (_uid == "") then { _uid = str (owner _officer); };

private _existing = (RECONDO_CMD_OFFICER_SQUADS getOrDefault [_uid, []]) select {
    private _g = _x;
    !isNull _g && {({alive _x} count units _g) > 0}
};

if (count _existing >= _maxSquads) exitWith {
    RECONDO_CMD_OFFICER_SQUADS set [_uid, _existing];
    _officer setVariable ["RECONDO_CMD_SquadCount", count _existing, true];
    [format ["Maximum squads reached (%1).", _maxSquads]] remoteExec ["hint", owner _officer];
};

// Resolve side (0 = officer's own side).
private _side = switch (_squadSideNum) do {
    case 1: { east };
    case 2: { west };
    case 3: { independent };
    case 4: { civilian };
    default { side _officer };
};

// Spawn the squad at the marker.
private _markerPos = getMarkerPos _spawnMarker;
private _group = createGroup [_side, true];

{
    private _pos = _markerPos getPos [random _spawnRadius, random 360];
    _group createUnit [_x, _pos, [], 0, "FORM"];
} forEach _soldierClassnames;

if (({alive _x} count units _group) == 0) exitWith {
    deleteGroup _group;
    diag_log "[RECONDO_CMD] ERROR: No units spawned — check squad soldier classnames.";
    ["Squad spawn failed: invalid soldier classnames."] remoteExec ["hint", owner _officer];
};

// Tag the squad with its commanding officer (used to authorise map-menu orders).
_group setVariable ["RECONDO_CMD_Officer", _officer, true];

// Track and update the officer's live count (drives client action availability).
_existing pushBack _group;
RECONDO_CMD_OFFICER_SQUADS set [_uid, _existing];
_officer setVariable ["RECONDO_CMD_SquadCount", count _existing, true];

// Squad stays local to the server. Tell the officer's client to set up its
// private map marker and register the squad for the click-to-command menu.
[_officer, _group] remoteExec ["Recondo_fnc_commanderSetupSquadClient", (owner _officer)];

["Squad spawned. Use the 'Command Squads' interaction to give orders."] remoteExec ["hint", owner _officer];

if (_debugLogging) then {
    diag_log format [
        "[RECONDO_CMD] %1 spawned squad of %2 (side %3) at '%4'. Officer now has %5/%6 squads.",
        name _officer, count units _group, _side, _spawnMarker, count _existing, _maxSquads
    ];
};
