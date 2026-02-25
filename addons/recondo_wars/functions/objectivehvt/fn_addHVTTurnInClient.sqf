/*
    Recondo_fnc_addHVTTurnInClient
    Client-side setup for HVT turn-in ACE action
    
    Description:
        Called on clients to add the "Turn Over HVT" ACE interaction
        to the specified turn-in object.
    
    Parameters:
        _object - OBJECT - The turn-in object
        _instanceId - STRING - HVT instance ID
        _hvtName - STRING - HVT display name
        _turnInRadius - NUMBER - Required distance of HVT from turn-in object
    
    Returns:
        Nothing
*/

if (!hasInterface) exitWith {};

params [
    ["_object", objNull, [objNull]],
    ["_instanceId", "", [""]],
    ["_hvtName", "Unknown Target", [""]],
    ["_turnInRadius", 10, [0]]
];

if (isNull _object || _instanceId == "") exitWith {};

// Check if action already exists for this instance on this object
private _existingActions = _object getVariable ["Recondo_HVT_TurnInActions", []];
if (_instanceId in _existingActions) exitWith {};

// Create the ACE action
private _actionName = format ["Recondo_HVT_TurnIn_%1", _instanceId];
private _actionText = format ["Turn Over %1", _hvtName];

private _action = [
    _actionName,
    _actionText,
    "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\meet_ca.paa",
    {
        // Statement - executed when action is used
        params ["_target", "_player", "_params"];
        _params params ["_instanceId", "_hvtName"];
        
        // Find the HVT unit
        private _hvt = RECONDO_HVT_UNITS getOrDefault [_instanceId, objNull];
        
        if (isNull _hvt || !alive _hvt) exitWith {
            hint "HVT is not available.";
        };
        
        // Store who captured for RP award
        _hvt setVariable ["RECONDO_HVT_capturedBy", _player, true];
        
        // Process capture on server
        [_instanceId, _hvt] remoteExec ["Recondo_fnc_handleHVTCapture", 2];
    },
    {
        // Condition - when is action shown
        params ["_target", "_player", "_params"];
        _params params ["_instanceId", "_hvtName", "_turnInRadius"];
        
        // Check if already captured
        if (_instanceId in RECONDO_HVT_CAPTURED) exitWith { false };
        
        // Get the HVT unit
        private _hvt = RECONDO_HVT_UNITS getOrDefault [_instanceId, objNull];
        
        if (isNull _hvt || !alive _hvt) exitWith { false };
        
        // Check if HVT is within turn-in radius of this object
        private _hvtDistance = _hvt distance _target;
        
        _hvtDistance <= _turnInRadius
    },
    {},
    [_instanceId, _hvtName, _turnInRadius],
    [0, 0, 0],
    2,
    [false, false, false, false, false],
    {}
] call ace_interact_menu_fnc_createAction;

// Add the action to the object
[_object, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;

// Mark as added
_existingActions pushBack _instanceId;
_object setVariable ["Recondo_HVT_TurnInActions", _existingActions, false];

private _debugLogging = if (isNil "RECONDO_HVT_INSTANCES") then { false } else {
    private _settings = nil;
    {
        if ((_x get "instanceId") == _instanceId) exitWith { _settings = _x };
    } forEach RECONDO_HVT_INSTANCES;
    if (isNil "_settings") then { false } else { _settings getOrDefault ["debugLogging", false] }
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_HVT] Client: Added turn-in action for '%1' to object: %2", _hvtName, _object];
};
