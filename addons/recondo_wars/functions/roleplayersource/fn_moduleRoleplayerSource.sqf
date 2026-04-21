/*
    Recondo_fnc_moduleRoleplayerSource
    Roleplay SOF Source Module

    Two modes controlled by the "Allow All Players" checkbox:
      OFF: Self-actions for synced playable units only.
      ON:  ACE object interaction on a synced object (any player).

    Sync playable units for self-action mode.
    Sync a world object (laptop, flag, table) for object mode.
    Both can be synced simultaneously; the checkbox controls which mode is active.
*/

params ["_logic", "_units", "_activated"];

if (!isServer) exitWith {};

if (!_activated) exitWith {
    diag_log "[RECONDO_RP_SOURCE] Module not activated.";
};

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

private _debugLogging = _logic getVariable ["debuglogging", false];
if (RECONDO_MASTER_DEBUG) then { _debugLogging = true; };

private _instructionsText = _logic getVariable ["instructionstext", ""];
private _allowAllPlayers = _logic getVariable ["allowallplayers", false];

private _rpClassnamesRaw = _logic getVariable ["roleplayerclassnames", ""];
private _rpClassnames = [];
if (_rpClassnamesRaw != "") then {
    _rpClassnames = ((_rpClassnamesRaw splitString (toString [10, 13] + ",")) apply { _x trim [" ", 0] }) select { _x != "" };
};

// Civilian Presence Settings
private _civClassnamesRaw = _logic getVariable ["civclassnames", ""];
private _civClassnames = [];
if (_civClassnamesRaw != "") then {
    _civClassnames = ((_civClassnamesRaw splitString (toString [10, 13] + ",")) apply { _x trim [" ", 0] }) select { _x != "" };
};
private _civsPerSpawn = _logic getVariable ["civsperspawn", 10];
private _civSpawnRadius = _logic getVariable ["civspawnradius", 100];
private _civCooldown = _logic getVariable ["civcooldown", 300];
private _civDespawnDistance = _logic getVariable ["civdespawndistance", 200];
private _civDespawnTimer = _logic getVariable ["civdespawntimer", 300];

// ========================================
// STORE SETTINGS
// ========================================

private _settings = createHashMapFromArray [
    ["debugLogging", _debugLogging],
    ["instructionsText", _instructionsText],
    ["allowAllPlayers", _allowAllPlayers],
    ["rpClassnames", _rpClassnames],
    ["civClassnames", _civClassnames],
    ["civsPerSpawn", _civsPerSpawn],
    ["civSpawnRadius", _civSpawnRadius],
    ["civCooldown", _civCooldown],
    ["civDespawnDistance", _civDespawnDistance],
    ["civDespawnTimer", _civDespawnTimer]
];

RECONDO_RP_SOURCE_SETTINGS = _settings;
publicVariable "RECONDO_RP_SOURCE_SETTINGS";

// ========================================
// PARSE SYNCED OBJECTS
// ========================================

private _syncedObjects = synchronizedObjects _logic;
private _allowedUnits = [];
private _interactObject = objNull;

{
    if (_x isKindOf "Module_F") then {
        continue;
    };

    if (_x isKindOf "CAManBase") then {
        _allowedUnits pushBack _x;
    } else {
        if (isNull _interactObject) then {
            _interactObject = _x;
        };
    };
} forEach _syncedObjects;

// ========================================
// MODE: ALLOW ALL PLAYERS (object interaction)
// ========================================

if (_allowAllPlayers) exitWith {
    if (isNull _interactObject) exitWith {
        diag_log "[RECONDO_RP_SOURCE] ERROR: 'Allow All Players' is enabled but no object is synced to the module. Sync a world object (laptop, flag, table, etc.) in Eden Editor.";
    };

    // Store settings on the object for client-side access
    _interactObject setVariable ["RECONDO_RP_SOURCE_SETTINGS", _settings, true];
    _interactObject setVariable ["RECONDO_RP_SOURCE_OBJECT", true, true];

    // Pass the object to clients via remoteExec args (JIP-safe)
    [true, _interactObject] remoteExec ["Recondo_fnc_initRoleplayerSourceClient", 0, true];

    diag_log format ["[RECONDO_RP_SOURCE] Module initialized (Object Mode). Object: %1 (%2)", _interactObject, typeOf _interactObject];

    if (_debugLogging) then {
        diag_log "[RECONDO_RP_SOURCE] === Roleplayer Source Settings ===";
        diag_log "[RECONDO_RP_SOURCE] Mode: Object Interaction (All Players)";
        diag_log format ["[RECONDO_RP_SOURCE] Object: %1 at %2", typeOf _interactObject, getPosATL _interactObject];
        diag_log format ["[RECONDO_RP_SOURCE] Instructions: %1 chars", count _instructionsText];
    };
};

// ========================================
// MODE: SELF-ACTION (Synced Units + Classnames)
// ========================================

if (count _allowedUnits == 0 && count _rpClassnames == 0) exitWith {
    diag_log "[RECONDO_RP_SOURCE] ERROR: No playable units synced and no roleplayer classnames configured. Sync playable units or add classnames.";
};

{
    _x setVariable ["RECONDO_RP_SOURCE_ALLOWED", true, true];
    _x setVariable ["RECONDO_RP_SOURCE_SETTINGS", _settings, true];

    if (_debugLogging) then {
        diag_log format ["[RECONDO_RP_SOURCE] Registered unit: %1 (type: %2)", _x, typeOf _x];
    };
} forEach _allowedUnits;

[false, objNull] remoteExec ["Recondo_fnc_initRoleplayerSourceClient", 0, true];

diag_log format ["[RECONDO_RP_SOURCE] Module initialized (Self-Action Mode). %1 unit(s) synced, %2 classname(s) configured.", count _allowedUnits, count _rpClassnames];

if (_debugLogging) then {
    diag_log "[RECONDO_RP_SOURCE] === Roleplayer Source Settings ===";
    diag_log "[RECONDO_RP_SOURCE] Mode: Self-Action (Synced Units + Classnames)";
    diag_log format ["[RECONDO_RP_SOURCE] Roleplayer Classnames: %1", _rpClassnames];
    diag_log format ["[RECONDO_RP_SOURCE] Instructions: %1 chars", count _instructionsText];
    diag_log format ["[RECONDO_RP_SOURCE] Units: %1", _allowedUnits];
};
