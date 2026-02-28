/*
    Recondo_fnc_createCustomSiteTrigger
    Creates a proximity trigger for custom site spawning
    
    Description:
        Creates a trigger that spawns the custom site composition
        when players of the specified side approach.
    
    Parameters:
        _settings - HASHMAP - Module settings
        _markerId - STRING - Marker ID for the site
        _composition - STRING - Composition filename to spawn
    
    Returns:
        OBJECT - The created trigger
*/

if (!isServer) exitWith { objNull };

params [
    ["_settings", nil, [createHashMap]],
    ["_markerId", "", [""]],
    ["_composition", "", [""]]
];

if (isNil "_settings" || _markerId == "") exitWith { objNull };

private _triggerRadius = _settings get "triggerRadius";
private _triggerSide = _settings get "triggerSide";
private _debugLogging = _settings get "debugLogging";

private _markerPos = getMarkerPos _markerId;

private _trigger = createTrigger ["EmptyDetector", _markerPos, true];
_trigger setTriggerArea [_triggerRadius, _triggerRadius, 0, false, 100];
_trigger setTriggerActivation [_triggerSide, "PRESENT", false];

_trigger setVariable ["RECONDO_CSS_settings", _settings, false];
_trigger setVariable ["RECONDO_CSS_markerId", _markerId, false];
_trigger setVariable ["RECONDO_CSS_composition", _composition, false];

_trigger setTriggerStatements [
    "this",
    "
        private _thisTrigger = thisTrigger;
        private _settings = _thisTrigger getVariable 'RECONDO_CSS_settings';
        private _markerId = _thisTrigger getVariable 'RECONDO_CSS_markerId';
        private _composition = _thisTrigger getVariable 'RECONDO_CSS_composition';
        
        [_settings, _markerId, _composition] call Recondo_fnc_spawnCustomSite;
        
        deleteVehicle _thisTrigger;
    ",
    ""
];

RECONDO_CSS_TRIGGERS pushBack _trigger;

if (_debugLogging) then {
    diag_log format ["[RECONDO_CSS] Created trigger for %1 at %2, radius: %3m, side: %4", _markerId, _markerPos, _triggerRadius, _triggerSide];
};

_trigger
