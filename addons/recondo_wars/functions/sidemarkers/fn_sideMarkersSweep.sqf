/*
    Recondo_fnc_sideMarkersSweep
    One sweep pass collecting AI-occupied positions for OPFOR Side Markers

    Description:
        Server-side. Reads the state arrays of every checkbox-enabled
        system, builds [uid, position, label] candidates and appends the
        ones not seen before to the broadcast list (add-only - markers
        persist until mission restart). Broadcasts only when something
        was added.

        Positions already destroyed/completed at the time they are FIRST
        seen (e.g. restored from persistence) are skipped; later
        destruction does not remove an existing marker.

    Parameters:
        None

    Returns:
        Nothing
*/

if (!isServer) exitWith {};
if (isNil "RECONDO_SIDEMARKERS_SETTINGS") exitWith {};

private _settings = RECONDO_SIDEMARKERS_SETTINGS;
private _debugLogging = _settings get "debugLogging";
private _candidates = [];

// Helper: marker-based candidate. Skips markers that don't exist
// (getMarkerPos returns [0,0,0] for unknown markers).
private _addFromMarker = {
    params ["_uid", "_markerId", "_label"];
    private _pos = getMarkerPos _markerId;
    if (_pos distance2D [0, 0, 0] < 1) exitWith {};
    _candidates pushBack [_uid, _pos, _label];
};

// ========================================
// OBJECTIVE - DESTROY
// ========================================
if (_settings get "sysObjDestroy" && {!isNil "RECONDO_OBJDESTROY_ACTIVE"}) then {
    {
        _x params ["_instanceId", "_markerId", "_compData", "_status"];
        if (_status != "destroyed") then {
            ["od_" + _markerId, _markerId, "Objective"] call _addFromMarker;
        };
    } forEach RECONDO_OBJDESTROY_ACTIVE;
};

// ========================================
// OBJECTIVE - HUB & SUBS
// ========================================
if (_settings get "sysHubSubs") then {
    if (!isNil "RECONDO_HUBSUBS_ACTIVE") then {
        {
            _x params ["_instanceId", "_hubMarker", "_compData", "_subSiteMarkers", "_isDestroyed"];
            if (!_isDestroyed) then {
                ["hub_" + _hubMarker, _hubMarker, "Hub Site"] call _addFromMarker;
            };
        } forEach RECONDO_HUBSUBS_ACTIVE;
    };
    if (!isNil "RECONDO_HUBSUBS_SUBSITES") then {
        {
            _x params ["_hubMarker", "_subSiteMarker", "_spawned"];
            ["sub_" + _subSiteMarker, _subSiteMarker, "Sub Site"] call _addFromMarker;
        } forEach RECONDO_HUBSUBS_SUBSITES;
    };
};

// ========================================
// OBJECTIVE - JAMMER
// ========================================
if (_settings get "sysJammer" && {!isNil "RECONDO_JAMMER_ACTIVE_DATA"}) then {
    {
        if (_x getOrDefault ["active", false]) then {
            private _markerId = _x getOrDefault ["markerId", ""];
            private _pos = _x getOrDefault ["position", [0, 0, 0]];
            if (_markerId != "" && {_pos distance2D [0, 0, 0] >= 1}) then {
                _candidates pushBack ["jam_" + _markerId, _pos, "Jammer"];
            };
        };
    } forEach RECONDO_JAMMER_ACTIVE_DATA;
};

// ========================================
// OBJECTIVE - HVT (real + decoy sites, all labeled the same
// so the real HVT location is not leaked to OPFOR players)
// ========================================
if (_settings get "sysHVT" && {!isNil "RECONDO_HVT_LOCATIONS"}) then {
    private _captured = if (isNil "RECONDO_HVT_CAPTURED") then { [] } else { RECONDO_HVT_CAPTURED };
    {
        private _instanceId = _x;
        if !(_instanceId in _captured) then {
            (RECONDO_HVT_LOCATIONS get _instanceId) params [["_hvtMarker", ""], ["_decoyMarkers", []]];
            if (_hvtMarker != "") then {
                ["hvt_" + _hvtMarker, _hvtMarker, "HVT Site"] call _addFromMarker;
            };
            {
                ["hvt_" + _x, _x, "HVT Site"] call _addFromMarker;
            } forEach _decoyMarkers;
        };
    } forEach keys RECONDO_HVT_LOCATIONS;
};

// ========================================
// OBJECTIVE - HOSTAGES (real + decoy sites, same label)
// ========================================
if (_settings get "sysHostages" && {!isNil "RECONDO_HOSTAGE_LOCATIONS"}) then {
    {
        (RECONDO_HOSTAGE_LOCATIONS get _x) params [["_hostageMarkers", []], ["_decoyMarkers", []]];
        {
            ["hos_" + _x, _x, "Hostage Site"] call _addFromMarker;
        } forEach (_hostageMarkers + _decoyMarkers);
    } forEach keys RECONDO_HOSTAGE_LOCATIONS;
};

// ========================================
// OBJECTIVE - PHOTOGRAPHS
// ========================================
if (_settings get "sysPhotos" && {!isNil "RECONDO_PHOTO_ACTIVE"}) then {
    {
        _x params ["_instanceId", "_markerId", "_compData", "_status"];
        if (_status != "completed") then {
            ["pho_" + _markerId, _markerId, "Photo Objective"] call _addFromMarker;
        };
    } forEach RECONDO_PHOTO_ACTIVE;
};

// ========================================
// STATIC DEFENSE RANDOMIZED (one marker per gun; array is
// append-only so the index is a stable uid)
// ========================================
if (_settings get "sysStatics" && {!isNil "RECONDO_SDR_SPAWNED_STATICS"}) then {
    {
        if (!isNull _x && {alive _x}) then {
            _candidates pushBack [format ["sdr_%1", _forEachIndex], getPos _x, "Static Defense"];
        };
    } forEach RECONDO_SDR_SPAWNED_STATICS;
};

// ========================================
// OUTPOST TELE
// ========================================
if (_settings get "sysOutposts" && {!isNil "RECONDO_OUTPOSTTELE_OUTPOSTS"}) then {
    {
        if !(_x getOrDefault ["destroyed", false]) then {
            private _markerId = _x getOrDefault ["markerId", ""];
            private _pos = _x getOrDefault ["position", [0, 0, 0]];
            private _label = _x getOrDefault ["displayName", "Outpost"];
            if (_label == "") then { _label = "Outpost"; };
            if (_markerId != "" && {_pos distance2D [0, 0, 0] >= 1}) then {
                _candidates pushBack ["opt_" + _markerId, _pos, _label];
            };
        };
    } forEach RECONDO_OUTPOSTTELE_OUTPOSTS;
};

// ========================================
// CAMPS RANDOM
// ========================================
if (_settings get "sysCamps" && {!isNil "RECONDO_CAMPSRANDOM_ACTIVE"}) then {
    {
        _x params ["_instanceId", "_markerId", "_composition", "_isModPath", "_status"];
        ["camp_" + _markerId, _markerId, "Camp"] call _addFromMarker;
    } forEach RECONDO_CAMPSRANDOM_ACTIVE;
};

// ========================================
// POO SITE HUNT
// ========================================
if (_settings get "sysPOO" && {!isNil "RECONDO_POO_ACTIVE"}) then {
    private _destroyed = if (isNil "RECONDO_POO_DESTROYED") then { [] } else { RECONDO_POO_DESTROYED };
    {
        _x params ["_instanceId", "_markerId", "_targetMarker", "_status"];
        if !(_markerId in _destroyed) then {
            ["poo_" + _markerId, _markerId, "Artillery Site"] call _addFromMarker;
        };
    } forEach RECONDO_POO_ACTIVE;
};

// ========================================
// CUSTOM SITE SPAWN
// ========================================
if (_settings get "sysCustom" && {!isNil "RECONDO_CSS_INSTANCES"}) then {
    {
        private _siteName = _x getOrDefault ["siteName", "Custom Site"];
        {
            ["css_" + _x, _x, _siteName] call _addFromMarker;
        } forEach (_x getOrDefault ["selectedMarkers", []]);
    } forEach RECONDO_CSS_INSTANCES;
};

// ========================================
// APPEND NEW ENTRIES AND BROADCAST
// ========================================

private _added = 0;
{
    _x params ["_uid", "_pos", "_label"];
    if !(_uid in RECONDO_SIDEMARKERS_KNOWN) then {
        RECONDO_SIDEMARKERS_KNOWN pushBack _uid;
        RECONDO_SIDEMARKERS_DATA pushBack [_uid, _pos, _label];
        _added = _added + 1;
    };
} forEach _candidates;

if (_added > 0) then {
    publicVariable "RECONDO_SIDEMARKERS_DATA";
    if (_debugLogging) then {
        diag_log format ["[RECONDO_SIDEMARKERS] Sweep added %1 position(s), total marked: %2", _added, count RECONDO_SIDEMARKERS_DATA];
    };
};
