/*
    Recondo_fnc_createSubSiteTrigger
    Creates a proximity trigger for a sub-site
    
    Description:
        Creates a trigger that spawns the sub-site object and
        garrison AI when players approach.
    
    Parameters:
        _settings - HASHMAP - Module settings
        _hubMarker - STRING - Parent hub marker name
        _subSiteMarker - STRING - Sub-site marker name
        _classname - STRING - Object classname to spawn
    
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [
    ["_settings", nil, [createHashMap]],
    ["_hubMarker", "", [""]],
    ["_subSiteMarker", "", [""]],
    ["_classname", "", [""]]
];

if (isNil "_settings" || _subSiteMarker == "") exitWith {
    diag_log "[RECONDO_HUBSUBS] ERROR: Invalid parameters for createSubSiteTrigger";
};

private _triggerRadius = _settings get "subSiteTriggerRadius";
private _triggerSide = _settings get "hubTriggerSide";
private _debugLogging = _settings get "debugLogging";

private _markerPos = getMarkerPos _subSiteMarker;

// Determine trigger activation side
private _sideStr = switch (toUpper _triggerSide) do {
    case "WEST": { "WEST" };
    case "EAST": { "EAST" };
    case "GUER": { "GUER" };
    case "CIV": { "CIV" };
    default { "ANY" };
};

// Create trigger
private _trigger = createTrigger ["EmptyDetector", _markerPos, true];
_trigger setTriggerArea [_triggerRadius, _triggerRadius, 0, false, 50];

if (_sideStr == "ANY") then {
    _trigger setTriggerActivation ["ANY", "PRESENT", false];
} else {
    _trigger setTriggerActivation [_sideStr, "PRESENT", false];
};

// Store data on trigger
_trigger setVariable ["RECONDO_HUBSUBS_settings", _settings];
_trigger setVariable ["RECONDO_HUBSUBS_hubMarker", _hubMarker];
_trigger setVariable ["RECONDO_HUBSUBS_subSiteMarker", _subSiteMarker];
_trigger setVariable ["RECONDO_HUBSUBS_classname", _classname];
_trigger setVariable ["RECONDO_HUBSUBS_spawned", false];

_trigger setTriggerStatements [
    "this && !(thisTrigger getVariable ['RECONDO_HUBSUBS_spawned', false])",
    "
        thisTrigger setVariable ['RECONDO_HUBSUBS_spawned', true];
        private _settings = thisTrigger getVariable 'RECONDO_HUBSUBS_settings';
        private _hubMarker = thisTrigger getVariable 'RECONDO_HUBSUBS_hubMarker';
        private _subSiteMarker = thisTrigger getVariable 'RECONDO_HUBSUBS_subSiteMarker';
        private _classname = thisTrigger getVariable 'RECONDO_HUBSUBS_classname';
        if (_hubMarker in RECONDO_HUBSUBS_DESTROYED) exitWith {
            diag_log format ['[RECONDO_HUBSUBS] Parent hub %1 destroyed, skipping sub-site %2', _hubMarker, _subSiteMarker];
        };
        diag_log format ['[RECONDO_HUBSUBS] Spawning sub-site at %1 with classname %2', _subSiteMarker, _classname];
        [_settings, _hubMarker, _subSiteMarker, _classname] call Recondo_fnc_spawnSubSite;
    ",
    ""
];

// Track trigger
RECONDO_HUBSUBS_TRIGGERS pushBack _trigger;

// Track sub-site
RECONDO_HUBSUBS_SUBSITES pushBack [_hubMarker, _subSiteMarker, false];
publicVariable "RECONDO_HUBSUBS_SUBSITES";

if (_debugLogging) then {
    diag_log format ["[RECONDO_HUBSUBS] Created sub-site trigger at %1, radius: %2m", _markerPos, _triggerRadius];
};
