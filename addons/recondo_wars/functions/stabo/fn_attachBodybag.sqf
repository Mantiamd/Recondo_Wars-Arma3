/*
    Recondo_fnc_attachBodybag
    Attaches a bodybag to the STABO rope using a harness
    
    Description:
        Finds the nearest helicopter with deployed STABO and creates
        a harness attached to the bodybag, then creates a rope from
        the helper vehicle to the harness.
        When the pilot raises the STABO, the bodybag is deleted
        (simulating it being secured in the helicopter).
        
    Parameters:
        0: OBJECT - Bodybag to attach
        1: OBJECT - Player performing the action
        
    Returns:
        Nothing
        
    Example:
        [cursorTarget, player] call Recondo_fnc_attachBodybag;
*/

params ["_bodybag", "_player"];

// Execute on server
if (!isServer) exitWith {
    [_bodybag, _player] remoteExec ["Recondo_fnc_attachBodybag", 2];
};

// Get settings
private _settings = RECONDO_STABO_SETTINGS;
if (isNil "_settings") exitWith {
    ["No STABO system configured"] remoteExec ["hint", _player];
};

private _searchRadius = _settings getOrDefault ["searchRadius", 50];
private _maxAttachments = _settings getOrDefault ["maxAttachments", 8];
private _detachDistance = _settings getOrDefault ["detachDistance", 5];
private _debug = _settings getOrDefault ["enableDebug", false];

// Find nearest helicopter with deployed STABO
private _nearbyHelis = (position _bodybag) nearEntities ["Helicopter", _searchRadius];
private _heli = objNull;

{
    if ((_x getVariable ["RECONDO_STABO_Deployed", false]) && 
        (_x getVariable ["RECONDO_STABO_Enabled", false])) exitWith {
        _heli = _x;
    };
} forEach _nearbyHelis;

if (isNull _heli) exitWith {
    ["No helicopter with deployed STABO found nearby"] remoteExec ["hint", _player];
};

// Get helper vehicle
private _helper = _heli getVariable ["RECONDO_STABO_Helper", objNull];
if (isNull _helper) exitWith {
    ["STABO helper not found"] remoteExec ["hint", _player];
};

// Check if already attached
private _attached = _heli getVariable ["RECONDO_STABO_AttachedUnits", []];
private _alreadyAttached = _attached findIf { (_x select 0) == _bodybag } != -1;

if (_alreadyAttached) exitWith {
    ["Bodybag already attached to STABO"] remoteExec ["hint", _player];
};

// Check max attachments
if (count _attached >= _maxAttachments) exitWith {
    ["STABO is at maximum capacity"] remoteExec ["hint", _player];
};

// Create harness object
private _harness = "Recondo_STABO_Harness" createVehicle (getPosATL _bodybag);

if (isNull _harness) exitWith {
    diag_log "[RECONDO_STABO] ERROR: Failed to create harness for bodybag";
    ["Failed to attach bodybag to STABO"] remoteExec ["hint", _player];
};

// Attach harness to bodybag
// Bodybags don't have bones, so attach at center
_harness attachTo [_bodybag, [0, 0, 0.2]];

// Hide the harness visually
[_harness, true] remoteExec ["hideObjectGlobal", 2];

if (_debug) then {
    diag_log "[RECONDO_STABO] Created harness for bodybag";
};

// Create rope from helper to harness
private _ropeLength = _detachDistance + 3;

private _unitRope = ropeCreate [
    _helper,
    [0, 0, 0],
    _harness,
    [0, 0, 0],
    _ropeLength
];

if (isNull _unitRope) exitWith {
    diag_log "[RECONDO_STABO] ERROR: Failed to create attachment rope for bodybag";
    deleteVehicle _harness;
    ["Failed to attach bodybag to STABO"] remoteExec ["hint", _player];
};

// Mark bodybag as attached
_bodybag setVariable ["RECONDO_STABO_AttachedTo", _heli, true];
_bodybag setVariable ["RECONDO_STABO_Harness", _harness, true];
_bodybag setVariable ["RECONDO_STABO_AttachRope", _unitRope, true];

// Add to attached units list [unit, harness, rope, isBodybag = true]
_attached pushBack [_bodybag, _harness, _unitRope, true];
_heli setVariable ["RECONDO_STABO_AttachedUnits", _attached, true];

if (_debug) then {
    diag_log format ["[RECONDO_STABO] Bodybag attached to STABO by %1. Total attached: %2/%3", 
        name _player, count _attached, _maxAttachments];
};

["Bodybag attached to STABO"] remoteExec ["hint", _player];
