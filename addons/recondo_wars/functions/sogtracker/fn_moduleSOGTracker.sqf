/*
    Recondo_fnc_moduleSOGTracker
    SOG PF Tracker Group Module

    Defines marker areas where OPFOR tracker units spawn and pursue
    BLUFOR groups using SOG Prairie Fire's tracking system.
    When a BLUFOR group enters a marker area, their tracks become
    visible and a 2-man stalker team spawns at the marker center.

    Requires SOG Prairie Fire (vn_ms_fnc_tracker_tracksLoop,
    vn_ms_fnc_tracker_stalker).
*/

params ["_logic", "_units", "_activated"];

if (!isServer) exitWith {};

if (!_activated) exitWith {
    diag_log "[RECONDO_SOGTRACKER] Module not activated.";
};

// ========================================
// VALIDATE SOG PF DEPENDENCY
// ========================================

if (isNil "vn_ms_fnc_tracker_tracksLoop" || isNil "vn_ms_fnc_tracker_stalker") exitWith {
    diag_log "[RECONDO_SOGTRACKER] ERROR: SOG Prairie Fire functions not found. Ensure S.O.G. Prairie Fire DLC is loaded.";
    "[RECONDO_SOGTRACKER] ERROR: SOG Prairie Fire DLC required but not detected." remoteExec ["systemChat", 0];
};

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

private _debugLogging = _logic getVariable ["debuglogging", false];
if (RECONDO_MASTER_DEBUG) then { _debugLogging = true; };

private _trackerSide = _logic getVariable ["trackerside", "EAST"];
private _markerPrefix = _logic getVariable ["markerprefix", "TRACKER_"];

private _triggerRadius = _logic getVariable ["triggerradius", 100];

private _trackerClassnamesRaw = _logic getVariable ["trackerclassnames", ""];
private _trackerClassnames = [];
if (_trackerClassnamesRaw != "") then {
    _trackerClassnames = ((_trackerClassnamesRaw splitString (toString [10, 13] + ",")) apply { _x trim [" ", 0] }) select { _x != "" };
};

if (count _trackerClassnames == 0) exitWith {
    diag_log "[RECONDO_SOGTRACKER] ERROR: No tracker unit classnames configured. Module disabled.";
};

// ========================================
// STORE SETTINGS
// ========================================

private _settings = createHashMapFromArray [
    ["debugLogging", _debugLogging],
    ["trackerSide", _trackerSide],
    ["markerPrefix", _markerPrefix],
    ["triggerRadius", _triggerRadius],
    ["trackerClassnames", _trackerClassnames]
];

// ========================================
// FIND TRACKER MARKERS
// ========================================

private _markers = [];
private _markerIndex = 1;

while {true} do {
    private _markerName = format ["%1%2", _markerPrefix, _markerIndex];

    if (getMarkerColor _markerName == "") exitWith {};

    _markers pushBack _markerName;
    _markerIndex = _markerIndex + 1;
};

if (count _markers == 0) exitWith {
    diag_log format ["[RECONDO_SOGTRACKER] ERROR: No markers found with prefix '%1' (expected '%11', '%12', etc.). Module disabled.", _markerPrefix];
};

if (_debugLogging) then {
    diag_log "[RECONDO_SOGTRACKER] ========================================";
    diag_log "[RECONDO_SOGTRACKER] SOG PF Tracker Group Initializing";
    diag_log format ["[RECONDO_SOGTRACKER] Tracker Side: %1", _trackerSide];
    diag_log format ["[RECONDO_SOGTRACKER] Marker Prefix: %1", _markerPrefix];
    diag_log format ["[RECONDO_SOGTRACKER] Trigger Radius: %1m", _triggerRadius];
    diag_log format ["[RECONDO_SOGTRACKER] Markers Found: %1", count _markers];
    diag_log format ["[RECONDO_SOGTRACKER] Tracker Classnames: %1", _trackerClassnames];
    {
        diag_log format ["[RECONDO_SOGTRACKER]   %1 at %2", _x, getMarkerPos _x];
    } forEach _markers;
    diag_log "[RECONDO_SOGTRACKER] ========================================";
};

// ========================================
// START DETECTION LOOP
// ========================================

[_settings, _markers] spawn Recondo_fnc_sogTrackerLoop;

diag_log format ["[RECONDO_SOGTRACKER] Module initialized. %1 tracker zone(s) active.", count _markers];
