/*
    Recondo_fnc_createHostageDecoyTrigger
    Creates a proximity trigger for decoy location
    
    Description:
        Creates a trigger that spawns only the composition and
        optionally AI when players approach. No hostages at decoys.
    
    Parameters:
        _settings - HASHMAP - Module settings
        _marker - STRING - Location marker name
        _composition - STRING - Composition name to spawn
        _isModPath - BOOL - True to load composition from mod folder
    
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [
    ["_settings", nil, [createHashMap]],
    ["_marker", "", [""]],
    ["_composition", "", [""]],
    ["_isModPath", true, [false]]
];

if (isNil "_settings" || _marker == "") exitWith {
    diag_log "[RECONDO_HOSTAGE] ERROR: Invalid parameters for createHostageDecoyTrigger";
};

private _compositionTriggerRadius = _settings get "compositionTriggerRadius";
private _triggerSide = _settings get "triggerSide";
private _debugLogging = _settings get "debugLogging";

private _markerPos = getMarkerPos _marker;

// Determine trigger activation side
private _sideStr = switch (toUpper _triggerSide) do {
    case "WEST": { "WEST" };
    case "EAST": { "EAST" };
    case "GUER": { "GUER" };
    default { "ANY" };
};

// Create outer trigger (composition spawn)
private _trigger = createTrigger ["EmptyDetector", _markerPos, true];
_trigger setTriggerArea [_compositionTriggerRadius, _compositionTriggerRadius, 0, false, 50];

if (_sideStr == "ANY") then {
    _trigger setTriggerActivation ["ANY", "PRESENT", false];
} else {
    _trigger setTriggerActivation [_sideStr, "PRESENT", false];
};

// Store data on trigger
_trigger setVariable ["RECONDO_HOSTAGE_settings", _settings];
_trigger setVariable ["RECONDO_HOSTAGE_marker", _marker];
_trigger setVariable ["RECONDO_HOSTAGE_composition", _composition];
_trigger setVariable ["RECONDO_HOSTAGE_isModPath", _isModPath];
_trigger setVariable ["RECONDO_HOSTAGE_spawned", false];

_trigger setTriggerStatements [
    "this && !(thisTrigger getVariable ['RECONDO_HOSTAGE_spawned', false])",
    "
        thisTrigger setVariable ['RECONDO_HOSTAGE_spawned', true];
        private _settings = thisTrigger getVariable 'RECONDO_HOSTAGE_settings';
        private _marker = thisTrigger getVariable 'RECONDO_HOSTAGE_marker';
        private _composition = thisTrigger getVariable 'RECONDO_HOSTAGE_composition';
        private _isModPath = thisTrigger getVariable 'RECONDO_HOSTAGE_isModPath';
        [thisTrigger, _settings, _marker, _composition, _isModPath] call Recondo_fnc_handleHostageDecoyTriggerActivation;
    ",
    ""
];

// Track trigger
RECONDO_HOSTAGE_TRIGGERS pushBack _trigger;

if (_debugLogging) then {
    diag_log format ["[RECONDO_HOSTAGE] Created DECOY trigger at %1, radius: %2m", _marker, _compositionTriggerRadius];
};
