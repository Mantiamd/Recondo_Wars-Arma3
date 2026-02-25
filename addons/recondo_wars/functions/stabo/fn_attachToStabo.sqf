/*
    Recondo_fnc_attachToStabo
    Attaches a player to the STABO rope using a harness object
    
    Description:
        Creates a harness object (ThingX) attached to the player's pelvis,
        then creates a rope from the helper vehicle to the harness.
        This approach mirrors ACE refuel's nozzle system for reliable
        rope attachment to infantry.
        
    Parameters:
        0: OBJECT - Player/Unit to attach
        1: OBJECT - Helicopter with deployed STABO
        2: OBJECT - Helper vehicle (physics anchor)
        
    Returns:
        Nothing
        
    Example:
        [player, _helicopter, _helper] call Recondo_fnc_attachToStabo;
*/

params ["_unit", "_helicopter", "_helper"];

// Execute on server for rope creation
if (!isServer) exitWith {
    [_unit, _helicopter, _helper] remoteExec ["Recondo_fnc_attachToStabo", 2];
};

// Validate inputs
if (isNull _unit || isNull _helicopter || isNull _helper) exitWith {
    diag_log "[RECONDO_STABO] ERROR: Invalid parameters for attachToStabo";
};

// Check if STABO is deployed
if !(_helicopter getVariable ["RECONDO_STABO_Deployed", false]) exitWith {
    ["STABO rope has been raised"] remoteExec ["hint", _unit];
};

// Get settings
private _settings = _helicopter getVariable ["RECONDO_STABO_Settings", RECONDO_STABO_SETTINGS];
private _maxAttachments = _settings getOrDefault ["maxAttachments", 8];
private _detachDistance = _settings getOrDefault ["detachDistance", 5];
private _debug = _settings getOrDefault ["enableDebug", false];

// Check if already attached
private _attached = _helicopter getVariable ["RECONDO_STABO_AttachedUnits", []];
private _alreadyAttached = _attached findIf { (_x select 0) == _unit } != -1;

if (_alreadyAttached) exitWith {
    ["Already attached to STABO"] remoteExec ["hint", _unit];
};

// Check max attachments
if (count _attached >= _maxAttachments) exitWith {
    ["STABO is at maximum capacity"] remoteExec ["hint", _unit];
};

// Create harness object
private _harness = "Recondo_STABO_Harness" createVehicle (getPosATL _unit);

if (isNull _harness) exitWith {
    diag_log "[RECONDO_STABO] ERROR: Failed to create harness object";
    ["Failed to attach to STABO"] remoteExec ["hint", _unit];
};

// Attach harness to unit's pelvis
_harness attachTo [_unit, [0, 0, 0], "pelvis"];

// Hide the harness visually (it's just for rope attachment)
[_harness, true] remoteExec ["hideObjectGlobal", 2];

if (_debug) then {
    diag_log format ["[RECONDO_STABO] Created harness for %1, attached to pelvis", _unit];
};

// Create rope from helper to harness
// Rope length is detach distance + slack
private _ropeLength = _detachDistance + 3;

private _unitRope = ropeCreate [
    _helper,
    [0, 0, 0],
    _harness,
    [0, 0, 0],
    _ropeLength
];

if (isNull _unitRope) exitWith {
    diag_log "[RECONDO_STABO] ERROR: Failed to create attachment rope";
    deleteVehicle _harness;
    ["Failed to attach to STABO"] remoteExec ["hint", _unit];
};

if (_debug) then {
    diag_log format ["[RECONDO_STABO] Created rope from helper to harness, length: %1m", _ropeLength];
};

// Mark unit as attached
_unit setVariable ["RECONDO_STABO_AttachedTo", _helicopter, true];
_unit setVariable ["RECONDO_STABO_Harness", _harness, true];
_unit setVariable ["RECONDO_STABO_AttachRope", _unitRope, true];

// Add to attached units list [unit, harness, rope, isBodybag]
_attached pushBack [_unit, _harness, _unitRope, false];
_helicopter setVariable ["RECONDO_STABO_AttachedUnits", _attached, true];

if (_debug) then {
    diag_log format ["[RECONDO_STABO] Unit %1 attached to STABO. Total attached: %2/%3", 
        _unit, count _attached, _maxAttachments];
};

// Notify player
["Attached to STABO - stay close to the anchor"] remoteExec ["hint", _unit];
