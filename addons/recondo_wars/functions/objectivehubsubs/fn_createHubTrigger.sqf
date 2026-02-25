/*
    Recondo_fnc_createHubTrigger
    Creates a proximity trigger for a hub objective
    
    Description:
        Creates a trigger that spawns the hub composition and AI
        when players approach.
    
    Parameters:
        _settings - HASHMAP - Module settings
        _hubMarker - STRING - Hub marker name
        _compData - ARRAY - [activeComp, destroyedComp, isModPath]
        _subSiteMarkers - ARRAY - Associated sub-site markers
    
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [
    ["_settings", nil, [createHashMap]],
    ["_hubMarker", "", [""]],
    ["_compData", [], [[]]],
    ["_subSiteMarkers", [], [[]]]
];

if (isNil "_settings" || _hubMarker == "") exitWith {
    diag_log "[RECONDO_HUBSUBS] ERROR: Invalid parameters for createHubTrigger";
};

_compData params ["_activeComp", "_destroyedComp", "_isModPath"];

private _triggerRadius = _settings get "hubTriggerRadius";
private _triggerSide = _settings get "hubTriggerSide";
private _debugLogging = _settings get "debugLogging";

private _markerPos = getMarkerPos _hubMarker;

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
_trigger setVariable ["RECONDO_HUBSUBS_composition", _activeComp];
_trigger setVariable ["RECONDO_HUBSUBS_isModPath", _isModPath];
_trigger setVariable ["RECONDO_HUBSUBS_subSiteMarkers", _subSiteMarkers];
_trigger setVariable ["RECONDO_HUBSUBS_spawned", false];

_trigger setTriggerStatements [
    "this && !(thisTrigger getVariable ['RECONDO_HUBSUBS_spawned', false])",
    "
        thisTrigger setVariable ['RECONDO_HUBSUBS_spawned', true];
        private _settings = thisTrigger getVariable 'RECONDO_HUBSUBS_settings';
        private _hubMarker = thisTrigger getVariable 'RECONDO_HUBSUBS_hubMarker';
        private _composition = thisTrigger getVariable 'RECONDO_HUBSUBS_composition';
        private _isModPath = thisTrigger getVariable 'RECONDO_HUBSUBS_isModPath';
        if (_hubMarker in RECONDO_HUBSUBS_DESTROYED) exitWith {
            diag_log format ['[RECONDO_HUBSUBS] Hub %1 already destroyed, skipping spawn', _hubMarker];
        };
        diag_log format ['[RECONDO_HUBSUBS] Spawning hub at %1 with composition %2', _hubMarker, _composition];
        [_settings, _hubMarker, _composition, false, _isModPath] call Recondo_fnc_spawnHub;
    ",
    ""
];

// Track trigger
RECONDO_HUBSUBS_TRIGGERS pushBack _trigger;

if (_debugLogging) then {
    diag_log format ["[RECONDO_HUBSUBS] Created hub trigger at %1, radius: %2m, side: %3", _markerPos, _triggerRadius, _sideStr];
};
