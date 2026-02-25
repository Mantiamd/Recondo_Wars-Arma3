/*
    Recondo_fnc_createObjectiveTrigger
    Creates a proximity trigger for objective spawning
    
    Description:
        Creates a trigger that spawns the objective composition
        when players of the specified side approach.
    
    Parameters:
        _settings - HASHMAP - Module settings
        _markerId - STRING - Marker ID for the objective
        _compData - ARRAY - [activeComp, destroyedComp, isModPath]
        _isDestroyed - BOOL - Whether objective is already destroyed
    
    Returns:
        OBJECT - The created trigger
*/

params [
    ["_settings", nil, [createHashMap]],
    ["_markerId", "", [""]],
    ["_compData", [], [[]]],
    ["_isDestroyed", false, [false]]
];

if (isNil "_settings" || _markerId == "") exitWith { objNull };

_compData params ["_activeComp", "_destroyedComp", "_isModPath"];

private _triggerRadius = _settings get "triggerRadius";
private _triggerSide = _settings get "triggerSide";
private _debugLogging = _settings get "debugLogging";
private _debugMarkers = _settings get "debugMarkers";
private _instanceId = _settings get "instanceId";

private _markerPos = getMarkerPos _markerId;

// Determine which composition to use
private _composition = if (_isDestroyed && _destroyedComp != "") then { _destroyedComp } else { _activeComp };

// Create the trigger
private _trigger = createTrigger ["EmptyDetector", _markerPos, true];
_trigger setTriggerArea [_triggerRadius, _triggerRadius, 0, false, 100];
_trigger setTriggerActivation [_triggerSide, "PRESENT", false];

// Store data on trigger
_trigger setVariable ["RECONDO_OBJ_instanceId", _instanceId, false];
_trigger setVariable ["RECONDO_OBJ_markerId", _markerId, false];
_trigger setVariable ["RECONDO_OBJ_composition", _composition, false];
_trigger setVariable ["RECONDO_OBJ_isDestroyed", _isDestroyed, false];
_trigger setVariable ["RECONDO_OBJ_isModPath", _isModPath, false];
_trigger setVariable ["RECONDO_OBJ_settings", _settings, false];

// Set trigger statements
_trigger setTriggerStatements [
    "this",
    "
        private _thisTrigger = thisTrigger;
        private _settings = _thisTrigger getVariable 'RECONDO_OBJ_settings';
        private _markerId = _thisTrigger getVariable 'RECONDO_OBJ_markerId';
        private _composition = _thisTrigger getVariable 'RECONDO_OBJ_composition';
        private _isDestroyed = _thisTrigger getVariable 'RECONDO_OBJ_isDestroyed';
        private _isModPath = _thisTrigger getVariable 'RECONDO_OBJ_isModPath';
        
        [_settings, _markerId, _composition, _isDestroyed, _isModPath] call Recondo_fnc_spawnObjective;
        
        deleteVehicle _thisTrigger;
    ",
    ""
];

// Track trigger
RECONDO_OBJDESTROY_TRIGGERS pushBack _trigger;

// Create debug marker for trigger radius
if (_debugMarkers) then {
    private _radiusMarker = createMarker [format ["RECONDO_OBJ_RADIUS_%1", _markerId], _markerPos];
    _radiusMarker setMarkerShape "ELLIPSE";
    _radiusMarker setMarkerBrush "Border";
    _radiusMarker setMarkerColor "ColorOrange";
    _radiusMarker setMarkerSize [_triggerRadius, _triggerRadius];
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_OBJDESTROY] Created trigger for %1 at %2, radius: %3m", _markerId, _markerPos, _triggerRadius];
};

_trigger
