/*
    Recondo_fnc_createPOOTrigger
    Creates a proximity trigger for a POO site

    Description:
        When the configured side enters the trigger radius the trigger
        fires once, spawning the POO site artillery, then deletes itself.

    Parameters:
        _settings     - HASHMAP - Module settings
        _markerId     - STRING  - POO site marker
        _targetMarker - STRING  - Target marker the artillery fires at

    Returns:
        OBJECT - The created trigger
*/

params [
    ["_settings", nil, [createHashMap]],
    ["_markerId", "", [""]],
    ["_targetMarker", "", [""]]
];

if (isNil "_settings" || _markerId == "") exitWith { objNull };

private _triggerRadius = _settings get "triggerRadius";
private _triggerSide   = _settings get "triggerSide";
private _debugLogging  = _settings get "debugLogging";

private _markerPos = getMarkerPos _markerId;

private _trigger = createTrigger ["EmptyDetector", _markerPos, true];
_trigger setTriggerArea [_triggerRadius, _triggerRadius, 0, false, 100];
_trigger setTriggerActivation [_triggerSide, "PRESENT", false];

_trigger setVariable ["RECONDO_POO_settings", _settings, false];
_trigger setVariable ["RECONDO_POO_markerId", _markerId, false];
_trigger setVariable ["RECONDO_POO_targetMarker", _targetMarker, false];

_trigger setTriggerStatements [
    "this",
    "
        private _thisTrigger = thisTrigger;
        private _s  = _thisTrigger getVariable 'RECONDO_POO_settings';
        private _m  = _thisTrigger getVariable 'RECONDO_POO_markerId';
        private _tm = _thisTrigger getVariable 'RECONDO_POO_targetMarker';

        [_s, _m, _tm] spawn Recondo_fnc_spawnPOOSite;

        deleteVehicle _thisTrigger;
    ",
    ""
];

RECONDO_POO_TRIGGERS pushBack _trigger;

if (_debugLogging) then {
    diag_log format ["[RECONDO_POO] Created trigger for %1 at %2, radius: %3m, target: %4",
        _markerId, _markerPos, _triggerRadius, _targetMarker];
};

_trigger
