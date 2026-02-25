/*
    Recondo_fnc_createPathTrigger
    Creates a trigger for path patrol spawning at the path center
    
    Description:
        Creates a detection trigger at the center of the path markers.
        When the configured side enters the trigger, patrol groups are spawned.
        The trigger is deleted after activation.
    
    Parameters:
        0: ARRAY - Center position [x, y, z]
        1: HASHMAP - Settings from module
        
    Returns:
        OBJECT - The created trigger, or objNull on failure
        
    Example:
        private _trigger = [_centerPos, _settings] call Recondo_fnc_createPathTrigger;
*/

if (!isServer) exitWith { objNull };

params ["_centerPos", "_settings"];

private _debug = _settings get "enableDebug";
private _triggerSide = _settings get "triggerSide";
private _triggerRadius = _settings get "triggerRadius";
private _triggerHeight = _settings get "triggerHeight";

if (_debug) then {
    diag_log format ["[RECONDO_PP] Creating trigger at position: %1", _centerPos];
};

// Create trigger
private _trigger = createTrigger ["EmptyDetector", _centerPos, true];
_trigger setTriggerArea [_triggerRadius, _triggerRadius, 0, false, _triggerHeight];
_trigger setTriggerActivation [_triggerSide, "PRESENT", false];

// Store settings on trigger for use when activated
_trigger setVariable ["RECONDO_PP_SETTINGS", _settings, false];

// Set trigger statements
_trigger setTriggerStatements [
    "this && isServer",
    "[thisTrigger] call Recondo_fnc_spawnPathPatrol; deleteVehicle thisTrigger;",
    ""
];

if (_debug) then {
    diag_log format ["[RECONDO_PP] Trigger created - Side: %1, Radius: %2m, Height: %3m", 
        _triggerSide, _triggerRadius, _triggerHeight];
};

_trigger
