/*
    Recondo_fnc_createPhotoTrigger
    Creates a proximity trigger for photo objective spawning
    
    Parameters:
        _settings - HASHMAP - Module settings
        _markerId - STRING - Marker ID
        _compData - ARRAY - [activeComp, targetClassname, isModPath]
    
    Returns:
        OBJECT - The created trigger
*/

if (!isServer) exitWith { objNull };

params [
    ["_settings", nil, [createHashMap]],
    ["_markerId", "", [""]],
    ["_compData", [], [[]]]
];

if (isNil "_settings" || _markerId == "") exitWith { objNull };

_compData params ["_activeComp", "_targetClassname", "_isModPath"];

private _triggerRadius = _settings get "triggerRadius";
private _triggerSide = _settings get "triggerSide";
private _debugLogging = _settings get "debugLogging";
private _instanceId = _settings get "instanceId";

private _markerPos = getMarkerPos _markerId;

private _trigger = createTrigger ["EmptyDetector", _markerPos, true];
_trigger setTriggerArea [_triggerRadius, _triggerRadius, 0, false, 100];
_trigger setTriggerActivation [_triggerSide, "PRESENT", false];

_trigger setVariable ["RECONDO_PHOTO_settings", _settings, false];
_trigger setVariable ["RECONDO_PHOTO_markerId", _markerId, false];
_trigger setVariable ["RECONDO_PHOTO_composition", _activeComp, false];
_trigger setVariable ["RECONDO_PHOTO_isModPath", _isModPath, false];

_trigger setTriggerStatements [
    "this",
    "
        private _thisTrigger = thisTrigger;
        private _settings = _thisTrigger getVariable 'RECONDO_PHOTO_settings';
        private _markerId = _thisTrigger getVariable 'RECONDO_PHOTO_markerId';
        private _composition = _thisTrigger getVariable 'RECONDO_PHOTO_composition';
        private _isModPath = _thisTrigger getVariable 'RECONDO_PHOTO_isModPath';
        
        [_settings, _markerId, _composition, _isModPath] call Recondo_fnc_spawnPhotoObjective;
        
        deleteVehicle _thisTrigger;
    ",
    ""
];

RECONDO_PHOTO_TRIGGERS pushBack _trigger;

if (_debugLogging) then {
    diag_log format ["[RECONDO_PHOTO] Created proximity trigger for %1, radius: %2m", _markerId, _triggerRadius];
};

_trigger
