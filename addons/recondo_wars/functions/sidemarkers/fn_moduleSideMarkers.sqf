/*
    Recondo_fnc_moduleSideMarkers
    Main initialization for OPFOR Side Markers module

    Description:
        Marks active AI-occupied positions (objectives, static defenses,
        camps, etc.) on the map - visible ONLY to players of the configured
        viewing side (default OPFOR). Intended for small OPFOR player
        elements in a BLUFOR-focused coop, so they know where their AI
        allies hold ground.

        The server periodically sweeps the state arrays of the checkbox-
        enabled systems and broadcasts an add-only marker list. Clients of
        the viewing side create LOCAL markers from that list - other sides
        never receive a marker, so there is nothing to hide or intercept.

        Markers are add-only: once a position is marked it stays marked
        until mission restart, even if the objective is later destroyed.
        Positions that are already destroyed/completed when first seen
        (e.g. restored from persistence) are never marked.

    Priority: 10 (UI/presentation - reads other modules' data via a
        periodic sweep, so exact init order does not matter)

    Parameters:
        _logic     - Module logic object
        _units     - Synchronized units (unused)
        _activated - Whether module is activated
*/

params ["_logic", "_units", "_activated"];

if (!isServer) exitWith {};

if (!_activated) exitWith {
    diag_log "[RECONDO_SIDEMARKERS] Module not activated.";
};

if (!isNil "RECONDO_SIDEMARKERS_INITIALIZED") exitWith {
    diag_log "[RECONDO_SIDEMARKERS] WARNING: Module already initialized. Skipping duplicate.";
};
RECONDO_SIDEMARKERS_INITIALIZED = true;

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

private _viewSide      = _logic getVariable ["viewside", "EAST"];
private _markerColor   = _logic getVariable ["markercolor", "ColorGreen"];
private _markerType    = _logic getVariable ["markertype", "o_unknown"];
private _showLabels    = _logic getVariable ["showlabels", true];

private _sysObjDestroy = _logic getVariable ["sysobjdestroy", true];
private _sysHubSubs    = _logic getVariable ["syshubsubs", true];
private _sysJammer     = _logic getVariable ["sysjammer", true];
private _sysHVT        = _logic getVariable ["syshvt", true];
private _sysHostages   = _logic getVariable ["syshostages", true];
private _sysPhotos     = _logic getVariable ["sysphotos", true];
private _sysStatics    = _logic getVariable ["sysstatics", true];
private _sysOutposts   = _logic getVariable ["sysoutposts", true];
private _sysCamps      = _logic getVariable ["syscamps", true];
private _sysPOO        = _logic getVariable ["syspoo", true];
private _sysCustom     = _logic getVariable ["syscustom", true];

private _debugLogging = _logic getVariable ["debuglogging", false];
if (RECONDO_MASTER_DEBUG) then { _debugLogging = true; };

// ========================================
// STORE SETTINGS
// ========================================

private _settings = createHashMapFromArray [
    ["sysObjDestroy", _sysObjDestroy],
    ["sysHubSubs", _sysHubSubs],
    ["sysJammer", _sysJammer],
    ["sysHVT", _sysHVT],
    ["sysHostages", _sysHostages],
    ["sysPhotos", _sysPhotos],
    ["sysStatics", _sysStatics],
    ["sysOutposts", _sysOutposts],
    ["sysCamps", _sysCamps],
    ["sysPOO", _sysPOO],
    ["sysCustom", _sysCustom],
    ["debugLogging", _debugLogging]
];
RECONDO_SIDEMARKERS_SETTINGS = _settings;

// Server-authoritative marker list and known-uid index (add-only)
RECONDO_SIDEMARKERS_DATA = [];
RECONDO_SIDEMARKERS_KNOWN = [];

// Client display config - broadcast once, publicVariable also reaches JIP
RECONDO_SIDEMARKERS_CONFIG = createHashMapFromArray [
    ["viewSide", _viewSide],
    ["markerColor", _markerColor],
    ["markerType", _markerType],
    ["showLabels", _showLabels]
];
publicVariable "RECONDO_SIDEMARKERS_CONFIG";

// ========================================
// MAIN LOGIC
// ========================================

// First sweep is delayed so feature modules (priority 5) have registered
// their sites; the periodic sweep catches anything that spawns later
// (proximity sub-sites, SDR statics after HC connect, etc.)
[{
    [] call Recondo_fnc_sideMarkersSweep;

    [{
        [] call Recondo_fnc_sideMarkersSweep;
    }, 30, []] call CBA_fnc_addPerFrameHandler;
}, [], 10] call CBA_fnc_waitAndExecute;

// Start the marker builder on every client (JIP-safe via static id)
[] remoteExec ["Recondo_fnc_initSideMarkersClient", 0, "RECONDO_SIDEMARKERS_CLIENTINIT"];

// ========================================
// FINAL LOG
// ========================================

private _enabledSystems = [];
{
    _x params ["_label", "_enabled"];
    if (_enabled) then { _enabledSystems pushBack _label; };
} forEach [
    ["ObjDestroy", _sysObjDestroy], ["HubSubs", _sysHubSubs], ["Jammer", _sysJammer],
    ["HVT", _sysHVT], ["Hostages", _sysHostages], ["Photos", _sysPhotos],
    ["Statics", _sysStatics], ["Outposts", _sysOutposts], ["Camps", _sysCamps],
    ["POO", _sysPOO], ["CustomSites", _sysCustom]
];

diag_log format ["[RECONDO_SIDEMARKERS] Module initialized. Viewing side: %1, Systems: %2", _viewSide, _enabledSystems];
