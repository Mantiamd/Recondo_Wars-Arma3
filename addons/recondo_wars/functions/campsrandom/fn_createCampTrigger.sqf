/*
    Recondo_fnc_createCampTrigger
    Creates a proximity spawn trigger for a camp
    
    Description:
        Creates a trigger that spawns the camp composition and AI
        when players of the specified side enter the radius.
    
    Parameters:
        _settings - HASHMAP - Module settings
        _markerId - STRING - Marker ID for the camp
        _composition - STRING - Composition name to spawn
        _isModPath - BOOL - Whether composition is from mod folder
    
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [
    ["_settings", nil, [createHashMap]],
    ["_markerId", "", [""]],
    ["_composition", "", [""]],
    ["_isModPath", false, [false]]
];

if (isNil "_settings" || _markerId == "" || _composition == "") exitWith {
    diag_log format ["[RECONDO_CAMPS] ERROR: Invalid parameters for createCampTrigger - marker: %1, comp: %2", _markerId, _composition];
};

private _triggerRadius = _settings get "triggerRadius";
private _triggerSide = _settings get "triggerSide";
private _debugLogging = _settings get "debugLogging";

private _markerPos = getMarkerPos _markerId;

// Create spawn trigger
private _trigger = createTrigger ["EmptyDetector", _markerPos, true];
_trigger setTriggerArea [_triggerRadius, _triggerRadius, 0, false];

// Set activation based on side
if (_triggerSide == "ANY") then {
    _trigger setTriggerActivation ["ANY", "PRESENT", false];
} else {
    _trigger setTriggerActivation [_triggerSide, "PRESENT", false];
};

// Store data on trigger
_trigger setVariable ["RECONDO_CAMPS_settings", _settings];
_trigger setVariable ["RECONDO_CAMPS_marker", _markerId];
_trigger setVariable ["RECONDO_CAMPS_composition", _composition];
_trigger setVariable ["RECONDO_CAMPS_isModPath", _isModPath];
_trigger setVariable ["RECONDO_CAMPS_spawned", false];

// Trigger condition and activation
_trigger setTriggerStatements [
    "this && !(thisTrigger getVariable ['RECONDO_CAMPS_spawned', false])",
    "
        thisTrigger setVariable ['RECONDO_CAMPS_spawned', true];
        private _settings = thisTrigger getVariable 'RECONDO_CAMPS_settings';
        private _marker = thisTrigger getVariable 'RECONDO_CAMPS_marker';
        private _comp = thisTrigger getVariable 'RECONDO_CAMPS_composition';
        private _isModPath = thisTrigger getVariable 'RECONDO_CAMPS_isModPath';
        
        diag_log format ['[RECONDO_CAMPS] Proximity trigger activated at %1', _marker];
        
        [_settings, _marker, _comp, _isModPath] call Recondo_fnc_spawnCamp;
    ",
    ""
];

// Track trigger
RECONDO_CAMPSRANDOM_TRIGGERS pushBack _trigger;

if (_debugLogging) then {
    diag_log format ["[RECONDO_CAMPS] Created spawn trigger at %1, radius: %2m, side: %3", 
        _markerId, _triggerRadius, _triggerSide];
};
