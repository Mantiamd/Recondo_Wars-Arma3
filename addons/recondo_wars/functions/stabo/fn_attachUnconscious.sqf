/*
    Recondo_fnc_attachUnconscious
    Attaches an unconscious unit to the STABO rope using a harness
    
    Description:
        Finds the nearest helicopter with deployed STABO and creates
        a harness attached to the unconscious unit, then creates a
        rope from the helper vehicle to the harness.
        When the pilot raises the STABO, the unit is moved to cargo.
        
    Parameters:
        0: OBJECT - Unconscious unit to attach
        1: OBJECT - Player performing the action
        
    Returns:
        Nothing
        
    Example:
        [cursorTarget, player] call Recondo_fnc_attachUnconscious;
*/

params ["_unconscious", "_player"];

// Execute on server for rope creation
if (!isServer) exitWith {
    [_unconscious, _player] remoteExec ["Recondo_fnc_attachUnconscious", 2];
};

// Get settings for search radius
private _settings = RECONDO_STABO_SETTINGS;
if (isNil "_settings") exitWith {
    ["No STABO system configured"] remoteExec ["hint", _player];
};

private _searchRadius = _settings getOrDefault ["searchRadius", 50];
private _maxAttachments = _settings getOrDefault ["maxAttachments", 8];
private _detachDistance = _settings getOrDefault ["detachDistance", 5];
private _debug = _settings getOrDefault ["enableDebug", false];

// Find nearest helicopter with deployed STABO
private _nearbyHelis = (position _unconscious) nearEntities ["Helicopter", _searchRadius];
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
private _alreadyAttached = _attached findIf { (_x select 0) == _unconscious } != -1;

if (_alreadyAttached) exitWith {
    ["Casualty already attached to STABO"] remoteExec ["hint", _player];
};

// Check max attachments
if (count _attached >= _maxAttachments) exitWith {
    ["STABO is at maximum capacity"] remoteExec ["hint", _player];
};

// Create harness object
private _harness = "Recondo_STABO_Harness" createVehicle (getPosATL _unconscious);

if (isNull _harness) exitWith {
    diag_log "[RECONDO_STABO] ERROR: Failed to create harness for unconscious";
    ["Failed to attach casualty to STABO"] remoteExec ["hint", _player];
};

// Attach harness to unconscious unit's pelvis
_harness attachTo [_unconscious, [0, 0, 0], "pelvis"];

// Hide the harness visually
[_harness, true] remoteExec ["hideObjectGlobal", 2];

if (_debug) then {
    diag_log format ["[RECONDO_STABO] Created harness for unconscious %1", name _unconscious];
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
    diag_log "[RECONDO_STABO] ERROR: Failed to create attachment rope for unconscious";
    deleteVehicle _harness;
    ["Failed to attach casualty to STABO"] remoteExec ["hint", _player];
};

// Mark unit as attached
_unconscious setVariable ["RECONDO_STABO_AttachedTo", _heli, true];
_unconscious setVariable ["RECONDO_STABO_Harness", _harness, true];
_unconscious setVariable ["RECONDO_STABO_AttachRope", _unitRope, true];

// Add to attached units list [unit, harness, rope, isBodybag]
_attached pushBack [_unconscious, _harness, _unitRope, false];
_heli setVariable ["RECONDO_STABO_AttachedUnits", _attached, true];

if (_debug) then {
    diag_log format ["[RECONDO_STABO] Unconscious %1 attached to STABO by %2. Total attached: %3/%4", 
        name _unconscious, name _player, count _attached, _maxAttachments];
};

["Casualty attached to STABO"] remoteExec ["hint", _player];
