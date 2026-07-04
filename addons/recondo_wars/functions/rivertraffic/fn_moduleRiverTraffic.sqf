/*
    Recondo_fnc_moduleRiverTraffic
    Main initialization for River Traffic module

    Description:
        Spawns dynamic boat patrols along the baked river network of the current
        map (currently vnx_rssz / Rung Sat). Boats spawn near qualifying players
        inside the module zone and are steered along the river by a server-side
        per-frame engine. Dedicated-server safe: ALL logic runs on the server.

        Multi-instance: place several modules to cover different river zones.

    Priority: 5 (AI / spawning)

    Parameters:
        _logic     - Module logic object
        _units     - Synchronized units (unused)
        _activated - Whether module is activated
*/

params ["_logic", "_units", "_activated"];

// --- LOCALITY GUARD --- spawning + AI steering must only run on the server
if (!isServer) exitWith {};

// --- ACTIVATION GUARD ---
if (!_activated) exitWith {
    diag_log "[RECONDO_RIVERTRAFFIC] Module not activated.";
};

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

private _debugLogging = _logic getVariable ["debuglogging", false];
if (!isNil "RECONDO_MASTER_DEBUG" && {RECONDO_MASTER_DEBUG}) then { _debugLogging = true; };

private _markerPrefix        = _logic getVariable ["markerprefix", "river_"];
if (_markerPrefix == "") then { _markerPrefix = "river_"; };

private _moduleRadius        = _logic getVariable ["moduleradius", 1500];
private _activationDistance  = _logic getVariable ["activationdistance", 800];
private _minSpawnAway        = _logic getVariable ["minspawnaway", 300];
private _despawnDistance     = _logic getVariable ["despawndistance", 1200];
private _heightLimit         = _logic getVariable ["heightlimit", 20];
private _scanInterval        = _logic getVariable ["scaninterval", 15];
private _maxBoats            = _logic getVariable ["maxboats", 6];
private _boatSpeed           = _logic getVariable ["boatspeed", 22];

private _civChance           = _logic getVariable ["civchance", 50];
private _opforChance         = _logic getVariable ["opforchance", 25];
private _bluforChance        = _logic getVariable ["bluforchance", 0];

// Eden sliders can be returned as normalized 0..1 values. Convert those to
// percentages so mission maker intent stays readable (e.g., 0.27 -> 27%).
if (_civChance <= 1) then { _civChance = _civChance * 100; };
if (_opforChance <= 1) then { _opforChance = _opforChance * 100; };
if (_bluforChance <= 1) then { _bluforChance = _bluforChance * 100; };
_civChance = (_civChance max 0) min 100;
_opforChance = (_opforChance max 0) min 100;
_bluforChance = (_bluforChance max 0) min 100;

private _civClassStr         = _logic getVariable ["civclassnames", ""];
private _opforClassStr       = _logic getVariable ["opforclassnames", ""];
private _bluforClassStr      = _logic getVariable ["bluforclassnames", ""];
private _civCrewStr          = _logic getVariable ["civcrew", ""];
private _opforCrewStr        = _logic getVariable ["opforcrew", ""];
private _bluforCrewStr       = _logic getVariable ["bluforcrew", ""];

// Extra boat classes used only on "big" rivers (marker riverId starting "big").
private _civBigStr           = _logic getVariable ["civbigclassnames", ""];
private _opforBigStr         = _logic getVariable ["opforbigclassnames", ""];
private _bluforBigStr        = _logic getVariable ["bluforbigclassnames", ""];

// Optional per-side headgear override for spawned boat crew.
private _civHeadgearEnable   = _logic getVariable ["civheadgearenable", true];
private _opforHeadgearEnable = _logic getVariable ["opforheadgearenable", true];
private _civHeadgearStr      = _logic getVariable ["civheadgear", ""];
private _opforHeadgearStr    = _logic getVariable ["opforheadgear", ""];

// Bank-vegetation clearing along river marker paths (map-agnostic).
private _clearObstacles      = _logic getVariable ["clearobstacles", true];
private _clearRadius         = _logic getVariable ["clearradius", 8];

private _civClasses    = [_civClassStr] call Recondo_fnc_parseClassnames;
private _opforClasses  = [_opforClassStr] call Recondo_fnc_parseClassnames;
private _bluforClasses = [_bluforClassStr] call Recondo_fnc_parseClassnames;
private _civCrew    = [_civCrewStr] call Recondo_fnc_parseClassnames;
private _opforCrew  = [_opforCrewStr] call Recondo_fnc_parseClassnames;
private _bluforCrew = [_bluforCrewStr] call Recondo_fnc_parseClassnames;
private _civBig    = [_civBigStr] call Recondo_fnc_parseClassnames;
private _opforBig  = [_opforBigStr] call Recondo_fnc_parseClassnames;
private _bluforBig = [_bluforBigStr] call Recondo_fnc_parseClassnames;
private _civHeadgear   = [_civHeadgearStr] call Recondo_fnc_parseClassnames;
private _opforHeadgear = [_opforHeadgearStr] call Recondo_fnc_parseClassnames;

// ========================================
// VALIDATE
// ========================================

// Build this instance's river data from its prefixed markers (map-agnostic,
// JIP/save-load safe). Each instance is scoped to its own Marker Prefix, so
// multiple River Traffic modules can cover different marker sets on one map.
if (isNil "RECONDO_RIVERTRAFFIC_SUPPORTED") then { RECONDO_RIVERTRAFFIC_SUPPORTED = false; };
private _rivers = [_markerPrefix] call Recondo_fnc_riverTrafficBuildRiversFromMarkers;

if (count _rivers == 0) exitWith {
    diag_log format ["[RECONDO_RIVERTRAFFIC] No '%1<id>_<NNN>' markers found on world '%2'. Module instance disabled.", _markerPrefix, worldName];
};

// At least one boat type must be usable.
if ((_civChance <= 0 || count _civClasses == 0) &&
    (_opforChance <= 0 || count _opforClasses == 0) &&
    (_bluforChance <= 0 || count _bluforClasses == 0)) exitWith {
    diag_log "[RECONDO_RIVERTRAFFIC] No boat type has both a spawn chance > 0 and classnames set. Module disabled.";
};

// ========================================
// STORE SETTINGS (multi-instance)
// ========================================

private _centerPos = getPosATL _logic;

private _settings = createHashMap;
_settings set ["markerPrefix", _markerPrefix];
_settings set ["rivers", _rivers];
_settings set ["center", _centerPos];
_settings set ["moduleRadius", _moduleRadius];
_settings set ["activationDistance", _activationDistance];
_settings set ["minSpawnAway", _minSpawnAway];
_settings set ["despawnDistance", _despawnDistance];
_settings set ["heightLimit", _heightLimit];
_settings set ["scanInterval", _scanInterval];
_settings set ["maxBoats", _maxBoats];
_settings set ["boatSpeed", _boatSpeed];
_settings set ["civChance", _civChance];
_settings set ["opforChance", _opforChance];
_settings set ["bluforChance", _bluforChance];
_settings set ["civClasses", _civClasses];
_settings set ["opforClasses", _opforClasses];
_settings set ["bluforClasses", _bluforClasses];
_settings set ["civCrew", _civCrew];
_settings set ["opforCrew", _opforCrew];
_settings set ["bluforCrew", _bluforCrew];
_settings set ["civBig", _civBig];
_settings set ["opforBig", _opforBig];
_settings set ["bluforBig", _bluforBig];
_settings set ["civHeadgearEnable", _civHeadgearEnable];
_settings set ["opforHeadgearEnable", _opforHeadgearEnable];
_settings set ["civHeadgear", _civHeadgear];
_settings set ["opforHeadgear", _opforHeadgear];
_settings set ["clearObstacles", _clearObstacles];
_settings set ["clearRadius", _clearRadius];
_settings set ["debugLogging", _debugLogging];
_settings set ["lastScan", -1];

if (isNil "RECONDO_RIVERTRAFFIC_INSTANCES") then { RECONDO_RIVERTRAFFIC_INSTANCES = []; };
RECONDO_RIVERTRAFFIC_INSTANCES pushBack _settings;

if (isNil "RECONDO_RIVERTRAFFIC_BOATS") then { RECONDO_RIVERTRAFFIC_BOATS = []; };

// ========================================
// START SHARED LOOPS (once)
// ========================================

if (isNil "RECONDO_RIVERTRAFFIC_CLEANED") then { RECONDO_RIVERTRAFFIC_CLEANED = []; };

if (isNil "RECONDO_RIVERTRAFFIC_STARTED") then {
    RECONDO_RIVERTRAFFIC_STARTED = true;

    // Bank vegetation is cleared lazily per river the first time a boat spawns
    // on it (see scan loop), so nothing map-specific runs up front here.

    // Scan loop: lowest scanInterval among instances drives the tick rate;
    // each instance is throttled by its own lastScan timestamp.
    [Recondo_fnc_riverTrafficScanLoop, 1, []] call CBA_fnc_addPerFrameHandler;

    // Per-frame steering engine for all active boats.
    [Recondo_fnc_riverBoatMove, 0, []] call CBA_fnc_addPerFrameHandler;

    diag_log "[RECONDO_RIVERTRAFFIC] Scan and movement loops started.";
};

diag_log format [
    "[RECONDO_RIVERTRAFFIC] Instance initialized. Prefix=%1 Center=%2 Radius=%3 Rivers=%4 MaxBoats=%5 (Civ %6%% / OPFOR %7%% / BLUFOR %8%%)",
    _markerPrefix, mapGridPosition _centerPos, _moduleRadius, count _rivers, _maxBoats, _civChance, _opforChance, _bluforChance
];
