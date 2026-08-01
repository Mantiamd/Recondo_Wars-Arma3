/*
    Recondo_fnc_moduleSpectatorCam
    Main initialization for Spectator Cam module

    Description:
        Puts dead (and optionally ACE-unconscious) players into the End Game
        Spectator camera; it closes automatically on respawn or revive.
        Camera options (spectatable sides, AI viewing, free camera, 3rd
        person) are configurable separately for the death cam and the synced-
        object cam - defaults are the locked-down anti-scouting view (own
        side only, players only, follow cam, first person). All widgets stay
        hidden except the player list.

        The server only reads attributes and broadcasts settings -
        BIS_fnc_EGSpectator is pure client UI, so all camera work runs on
        each player's own machine (dedicated-server safe by design).

        OPTIONAL: objects synced to the module get an ACE action letting
        LIVING players open the same own-side camera (Esc closes it).

    Priority: 10 (UI/Presentation - no dependencies)

    Parameters:
        _logic     - Module logic object
        _units     - Synchronized objects (optional - spectator entry points)
        _activated - Whether module is activated
*/

params ["_logic", "_units", "_activated"];

if (!isServer) exitWith {};

if (!_activated) exitWith {
    diag_log "[RECONDO_SPECTATORCAM] Module not activated.";
};

if (!isNil "RECONDO_SPECTATORCAM_INITIALIZED") exitWith {
    diag_log "[RECONDO_SPECTATORCAM] WARNING: Module already initialized. Skipping duplicate.";
};
RECONDO_SPECTATORCAM_INITIALIZED = true;

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

private _spectatorDelay = _logic getVariable ["spectatordelay", 3];
private _unconsciousCam = _logic getVariable ["unconsciouscam", true];
private _objectActionText = _logic getVariable ["objectactiontext", "Enter Spectator Cam"];
private _debugLogging = _logic getVariable ["debuglogging", false];
if (RECONDO_MASTER_DEBUG) then { _debugLogging = true; };

// Camera options, separate for the two entry paths: dead players usually get
// the locked-down view (anti-scouting), a base spectator station can be freer
private _deathFreeCam = _logic getVariable ["deathfreecam", false];
private _deathThirdPerson = _logic getVariable ["deaththirdperson", false];
private _deathAllSides = (_logic getVariable ["deathsides", 0]) == 1;
private _deathAllowAI = _logic getVariable ["deathallowai", false];

private _objectFreeCam = _logic getVariable ["objectfreecam", false];
private _objectThirdPerson = _logic getVariable ["objectthirdperson", false];
private _objectAllSides = (_logic getVariable ["objectsides", 0]) == 1;
private _objectAllowAI = _logic getVariable ["objectallowai", false];

// ========================================
// VALIDATE
// ========================================

_spectatorDelay = _spectatorDelay max 0;

// ========================================
// STORE SETTINGS
// ========================================

RECONDO_SPECTATORCAM_SETTINGS = createHashMapFromArray [
    ["spectatorDelay", _spectatorDelay],
    ["unconsciousCam", _unconsciousCam],
    ["objectActionText", _objectActionText],
    ["debugLogging", _debugLogging],
    ["deathFreeCam", _deathFreeCam],
    ["deathThirdPerson", _deathThirdPerson],
    ["deathAllSides", _deathAllSides],
    ["deathAllowAI", _deathAllowAI],
    ["objectFreeCam", _objectFreeCam],
    ["objectThirdPerson", _objectThirdPerson],
    ["objectAllSides", _objectAllSides],
    ["objectAllowAI", _objectAllowAI]
];
publicVariable "RECONDO_SPECTATORCAM_SETTINGS";

// Synced objects (optional): living players can enter the same own-side camera
// through an ACE action on these. Always broadcast (possibly empty) so the
// client-side waitUntil resolves.
RECONDO_SPECTATORCAM_OBJECTS = (synchronizedObjects _logic) select {!(_x isKindOf "Logic")};
publicVariable "RECONDO_SPECTATORCAM_OBJECTS";

// ========================================
// MAIN LOGIC
// ========================================

// Register the death/respawn hooks on every client (JIP-safe via static id)
[] remoteExec ["Recondo_fnc_initSpectatorCamClient", 0, "RECONDO_SPECTATORCAM_CLIENTINIT"];

// ========================================
// FINAL LOG
// ========================================

diag_log format ["[RECONDO_SPECTATORCAM] Module initialized. Delay: %1s, Unconscious cam: %2, Spectator objects: %3",
    _spectatorDelay, _unconsciousCam, count RECONDO_SPECTATORCAM_OBJECTS];
