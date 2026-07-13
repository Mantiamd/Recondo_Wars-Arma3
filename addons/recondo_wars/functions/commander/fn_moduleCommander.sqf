/*
    Recondo_fnc_moduleCommander
    Main initialization for the Commander System module

    Description:
        Lets designated officer units spawn an AI squad (via ACE self-interaction)
        at an invisible Eden marker, then command it with vanilla High Command.
        The squad is spawned server-side (authoritative AI), then its locality is
        handed to the officer's client so High Command orders are responsive on a
        dedicated server. Per-officer squad cap is enforced server-side.

    Priority: 5 (Feature module — spawns entities, no dependency on other modules)

    Parameters:
        _logic     - Module logic object
        _units     - Synchronized units (unused)
        _activated - Whether module is activated
*/

params ["_logic", "_units", "_activated"];

// --- LOCALITY GUARD ---
// Server owns the squad-spawn and tracking logic. The client ACE action is
// registered separately via remoteExec below.
if (!isServer) exitWith {};

// --- ACTIVATION GUARD ---
if (!_activated) exitWith {
    diag_log "[RECONDO_CMD] Module not activated.";
};

// --- SINGLETON GUARD ---
if (!isNil "RECONDO_CMD_INITIALIZED") exitWith {
    diag_log "[RECONDO_CMD] WARNING: Module already initialized. Skipping duplicate.";
};
RECONDO_CMD_INITIALIZED = true;

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

private _officerRaw = _logic getVariable ["officerclassnames", ""];
private _soldierRaw = _logic getVariable ["soldierclassnames", ""];
private _actionName = _logic getVariable ["actionname", "Spawn Squad"];
private _spawnMarker = _logic getVariable ["spawnmarker", ""];
private _squadSideNum = _logic getVariable ["squadside", 0];
private _maxSquads = _logic getVariable ["maxsquads", 3];
private _spawnRadius = _logic getVariable ["spawnradius", 5];

private _debugLogging = _logic getVariable ["debuglogging", false];
if (RECONDO_MASTER_DEBUG) then { _debugLogging = true; };

// ========================================
// PARSE & VALIDATE
// ========================================

private _officerClassnames = [_officerRaw] call Recondo_fnc_parseClassnames;
private _soldierClassnames = [_soldierRaw] call Recondo_fnc_parseClassnames;

if (count _officerClassnames == 0) exitWith {
    diag_log "[RECONDO_CMD] ERROR: No officer classnames configured. Module disabled.";
};

if (count _soldierClassnames == 0) exitWith {
    diag_log "[RECONDO_CMD] ERROR: No squad soldier classnames configured. Module disabled.";
};

if (_spawnMarker == "") exitWith {
    diag_log "[RECONDO_CMD] ERROR: No spawn marker configured. Module disabled.";
};

if !(_spawnMarker in allMapMarkers) exitWith {
    diag_log format ["[RECONDO_CMD] ERROR: Spawn marker '%1' not found on the map. Module disabled.", _spawnMarker];
};

if (_maxSquads < 1) then { _maxSquads = 1; };
if (_spawnRadius < 0) then { _spawnRadius = 0; };

// ========================================
// STORE SETTINGS (broadcast for client action condition)
// ========================================

private _settings = createHashMapFromArray [
    ["officerClassnames", _officerClassnames],
    ["soldierClassnames", _soldierClassnames],
    ["actionName", _actionName],
    ["spawnMarker", _spawnMarker],
    ["squadSideNum", _squadSideNum],
    ["maxSquads", _maxSquads],
    ["spawnRadius", _spawnRadius],
    ["debugLogging", _debugLogging]
];

RECONDO_CMD_SETTINGS = _settings;
publicVariable "RECONDO_CMD_SETTINGS";

// ========================================
// REGISTER CLIENT ACE ACTION (JIP-safe)
// ========================================
// Settings are passed as an argument so joining clients receive them even though
// publicVariable is not JIP-persistent.

[_settings] remoteExec ["Recondo_fnc_addCommanderActionClient", 0, true];

// ========================================
// RELEASE SQUADS WHEN AN OFFICER DISCONNECTS
// ========================================
// Ownership of a disconnecting client's local groups migrates back to the server
// automatically, so the squad keeps living as normal AI. We only clear tracking so
// the cap frees up for any future reconnecting officer.

addMissionEventHandler ["HandleDisconnect", {
    params ["_unit", "_id", "_uid", "_name"];
    if (!isNil "RECONDO_CMD_OFFICER_SQUADS" && {_uid in (keys RECONDO_CMD_OFFICER_SQUADS)}) then {
        RECONDO_CMD_OFFICER_SQUADS deleteAt _uid;
        if (!isNil "RECONDO_CMD_SETTINGS" && {RECONDO_CMD_SETTINGS getOrDefault ["debugLogging", false]}) then {
            diag_log format ["[RECONDO_CMD] Officer '%1' (%2) disconnected. Released commanded squads to server AI.", _name, _uid];
        };
    };
    false
}];

// ========================================
// MONITOR: prune dead/empty squads and refresh per-officer counts
// ========================================
// The count variable drives the client-side availability of the spawn action.

[{
    {
        private _uid = _x;
        private _groups = (RECONDO_CMD_OFFICER_SQUADS get _uid) select {
            private _g = _x;
            !isNull _g && {({alive _x} count units _g) > 0}
        };
        RECONDO_CMD_OFFICER_SQUADS set [_uid, _groups];

        private _officer = objNull;
        {
            if (getPlayerUID _x == _uid) exitWith { _officer = _x; };
        } forEach allPlayers;

        if (!isNull _officer) then {
            _officer setVariable ["RECONDO_CMD_SquadCount", count _groups, true];
        };
    } forEach (keys RECONDO_CMD_OFFICER_SQUADS);
}, 20, []] call CBA_fnc_addPerFrameHandler;

// ========================================
// FINAL LOG
// ========================================

diag_log format [
    "[RECONDO_CMD] Module initialized. Officers: %1, Squad size: %2, Marker: '%3', Max/officer: %4",
    count _officerClassnames, count _soldierClassnames, _spawnMarker, _maxSquads
];
