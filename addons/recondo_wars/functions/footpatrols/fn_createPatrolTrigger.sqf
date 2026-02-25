/*
    Recondo_fnc_createPatrolTrigger
    Creates a trigger for patrol spawning at a marker position
    
    Description:
        Creates a detection trigger at the specified marker position.
        When the configured side enters the trigger, a patrol group is spawned.
        The trigger is deleted after activation.
    
    Parameters:
        0: STRING - Marker name
        1: HASHMAP - Settings from module
        
    Returns:
        OBJECT - The created trigger, or objNull on failure
        
    Example:
        private _trigger = ["PATROL_1", _settings] call Recondo_fnc_createPatrolTrigger;
*/

if (!isServer) exitWith { objNull };

params ["_markerName", "_settings"];

private _debug = _settings get "enableDebug";
private _triggerSide = _settings get "triggerSide";
private _triggerRadius = _settings get "triggerRadius";
private _triggerHeight = _settings get "triggerHeight";

// Get marker position
private _pos = getMarkerPos _markerName;

if (_pos isEqualTo [0, 0, 0]) exitWith {
    if (_debug) then {
        diag_log format ["[RECONDO_FP] WARNING: Marker '%1' has invalid position. Skipping.", _markerName];
    };
    objNull
};

if (_debug) then {
    diag_log format ["[RECONDO_FP] Creating trigger at marker '%1' position: %2", _markerName, _pos];
};

// Create trigger
private _trigger = createTrigger ["EmptyDetector", _pos, true];
_trigger setTriggerArea [_triggerRadius, _triggerRadius, 0, false, _triggerHeight];
_trigger setTriggerActivation [_triggerSide, "PRESENT", false];

// Store marker name and settings on trigger for use when activated
_trigger setVariable ["RECONDO_FP_MARKER", _markerName, false];
_trigger setVariable ["RECONDO_FP_SETTINGS", _settings, false];

// Set trigger statements
_trigger setTriggerStatements [
    "this && isServer",
    "[thisTrigger] call Recondo_fnc_spawnFootPatrol; deleteVehicle thisTrigger;",
    ""
];

if (_debug) then {
    diag_log format ["[RECONDO_FP] Trigger created at '%1' - Side: %2, Radius: %3m, Height: %4m", 
        _markerName, _triggerSide, _triggerRadius, _triggerHeight];
};

_trigger
