/*
    Recondo_fnc_moduleSurvivalRadio
    Main initialization for the Survival Radio module - runs on server only

    Description:
        Triangulation system for survival/emergency ACRE radios (no battery).
        Any transmission on a tracked radio longer than the threshold
        triangulates the individual transmitter: a hunter group spawns a
        set distance away in a random direction, moves to the triangulated
        position, then follows the transmitter's footprints. Hunters never
        give up and play whistle sounds only.
        Independent of the RW Radio and Trackers modules; coexists with
        both (use different radio classnames than RW Radio).

    Priority: 5 (Feature module)

    Parameters:
        0: OBJECT - Logic module
        1: ARRAY - Synced units (unused)
        2: BOOL - Is activated

    Returns:
        Nothing
*/

params ["_logic", "_units", "_activated"];

if (!isServer) exitWith {
    diag_log "[RECONDO_SURV] Module attempted to run on non-server. Exiting.";
};

if (!_activated) exitWith {
    diag_log "[RECONDO_SURV] Module not activated.";
};

if (!isNil "RECONDO_SURV_SETTINGS") exitWith {
    diag_log "[RECONDO_SURV] WARNING: Module already initialized. Only one Survival Radio module should be placed.";
};

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

private _settings = createHashMap;

// General
private _radioClassnamesStr = _logic getVariable ["radioclassnames", "ACRE_SEM52SL"];
private _radioClassnames = [_radioClassnamesStr] call Recondo_fnc_parseClassnames;
_settings set ["radioClassnames", _radioClassnames];
_settings set ["transmissionThreshold", (_logic getVariable ["transmissionthreshold", 3]) max 1];
_settings set ["cooldownSeconds", (_logic getVariable ["cooldownseconds", 300]) max 0];

private _sideMap = [east, west, independent];
_settings set ["targetSide", _sideMap select (_logic getVariable ["targetside", 1])];

// Hunters
private _hunterClassnamesStr = _logic getVariable ["hunterclassnames", ""];
private _hunterClassnames = [_hunterClassnamesStr] call Recondo_fnc_parseClassnames;
_settings set ["hunterClassnames", _hunterClassnames];
_settings set ["hunterSide", _sideMap select (_logic getVariable ["hunterside", 0])];

private _hunterMinSize = (_logic getVariable ["hunterminsize", 2]) max 1;
private _hunterMaxSize = (_logic getVariable ["huntermaxsize", 4]) max _hunterMinSize;
_settings set ["hunterMinSize", _hunterMinSize];
_settings set ["hunterMaxSize", _hunterMaxSize];

_settings set ["spawnDistance", (_logic getVariable ["spawndistance", 200]) max 50];
_settings set ["maxHunterGroups", (_logic getVariable ["maxhuntergroups", 4]) max 1];
_settings set ["soundInterval", _logic getVariable ["soundinterval", 30]];

// Whistles only, by design
_settings set ["whistleSounds", ["enemy_whistle_2", "enemy_whistle_3", "enemy_whistle_4", "enemy_whistling_2", "enemy_whistling_3", "enemy_whistling_4"]];

// Exemptions
private _exemptGroupsStr = _logic getVariable ["exemptgroups", ""];
_settings set ["exemptGroups", [_exemptGroupsStr] call Recondo_fnc_parseClassnames];
_settings set ["noCountPrefix", _logic getVariable ["nocountprefix", "NO_RADIO_"]];
_settings set ["noCountRadius", _logic getVariable ["nocountradius", 500]];

// Debug
private _debugLogging = _logic getVariable ["debuglogging", false];
if (RECONDO_MASTER_DEBUG) then { _debugLogging = true; };
_settings set ["debugLogging", _debugLogging];
_settings set ["debugMarkers", _logic getVariable ["debugmarkers", false]];

// ========================================
// VALIDATE
// ========================================

if (count _radioClassnames == 0) exitWith {
    diag_log "[RECONDO_SURV] ERROR: No radio classnames specified. Module disabled.";
};

if (count _hunterClassnames == 0) exitWith {
    diag_log "[RECONDO_SURV] ERROR: No hunter unit classnames specified. Module disabled.";
};

// ========================================
// STORE AND BROADCAST SETTINGS
// ========================================

RECONDO_SURV_SETTINGS = _settings;
publicVariable "RECONDO_SURV_SETTINGS";

// Server-side tracking
RECONDO_SURV_TRANSMISSION_STARTS = createHashMap;  // radioId -> serverTime when started
RECONDO_SURV_COOLDOWNS = createHashMap;            // player UID -> serverTime of last trigger
RECONDO_SURV_TRACKED = createHashMap;              // targetId -> [unit, lastFootprintPos]
RECONDO_SURV_ACTIVE_GROUPS = [];
RECONDO_SURV_FOOTPRINTS = [];                      // [position, time, targetId]

// Sound function (whistles are broadcast only to nearby players)
if (isNil "RECONDO_SURV_fnc_playSound") then {
    RECONDO_SURV_fnc_playSound = compileFinal "
        if (!hasInterface) exitWith {};
        params ['_unit', '_sounds'];
        if (player distance _unit > 300) exitWith {};
        private _sound = selectRandom _sounds;
        private _soundPath = '\recondo_wars\sounds\trackers\' + _sound + '.ogg';
        playSound3D [_soundPath, _unit, false, getPosASL _unit, 5, 1, 300];
    ";
    publicVariable "RECONDO_SURV_fnc_playSound";
};

// JIP handler - re-broadcast settings so joining players receive them
addMissionEventHandler ["PlayerConnected", {
    params ["_id", "_uid", "_name", "_jip", "_owner"];
    if (_jip) then {
        publicVariable "RECONDO_SURV_SETTINGS";
    };
}];

// Start the footprint producer loop (idles cheaply while nothing is tracked)
[] spawn Recondo_fnc_survFootprintLoop;

// Initialize client-side ACRE listeners on all clients (JIP-safe via persistent queue ID)
[] remoteExec ["Recondo_fnc_initSurvivalRadioClient", 0, "RECONDO_SURV_CLIENT_INIT_JIP"];

// ========================================
// LOG
// ========================================

if (_debugLogging) then {
    diag_log "[RECONDO_SURV] === Survival Radio Module Initialized ===";
    diag_log format ["[RECONDO_SURV] Radio Classnames: %1", _radioClassnames];
    diag_log format ["[RECONDO_SURV] Transmission Threshold: %1s", _settings get "transmissionThreshold"];
    diag_log format ["[RECONDO_SURV] Cooldown: %1s per player", _settings get "cooldownSeconds"];
    diag_log format ["[RECONDO_SURV] Target Side: %1, Hunter Side: %2", _settings get "targetSide", _settings get "hunterSide"];
    diag_log format ["[RECONDO_SURV] Hunter Group: %1-%2 of %3", _hunterMinSize, _hunterMaxSize, _hunterClassnames];
    diag_log format ["[RECONDO_SURV] Spawn Distance: %1m, Max Concurrent Groups: %2", _settings get "spawnDistance", _settings get "maxHunterGroups"];
    diag_log format ["[RECONDO_SURV] Exempt Groups: %1", _settings get "exemptGroups"];
    diag_log format ["[RECONDO_SURV] No-Count Marker Prefix: %1 (radius %2m)", _settings get "noCountPrefix", _settings get "noCountRadius"];
};

diag_log format ["[RECONDO_SURV] Module initialized. Tracking %1 radio type(s).", count _radioClassnames];
