/*
    Recondo_fnc_addHostageTurnInClient
    Client-side setup for hostage turn-in ACE action
    
    Description:
        Called on clients to add the "Turn Over [Hostage Name]" ACE interaction
        to the specified turn-in object for a specific hostage.
    
    Parameters:
        _object - OBJECT - The turn-in object
        _instanceId - STRING - Hostage instance ID
        _hostageId - STRING - Unique hostage ID
        _hostageName - STRING - Hostage display name
        _turnInRadius - NUMBER - Required distance of hostage from turn-in object
    
    Returns:
        Nothing
*/

if (!hasInterface) exitWith {};

params [
    ["_object", objNull, [objNull]],
    ["_instanceId", "", [""]],
    ["_hostageId", "", [""]],
    ["_hostageName", "Unknown Hostage", [""]],
    ["_turnInRadius", 10, [0]]
];

if (isNull _object || _instanceId == "" || _hostageId == "") exitWith {};

// Check if action already exists for this hostage on this object
private _existingActions = _object getVariable ["Recondo_HOSTAGE_TurnInActions", []];
if (_hostageId in _existingActions) exitWith {};

// Create the ACE action
private _actionName = format ["Recondo_HOSTAGE_TurnIn_%1", _hostageId];
private _actionText = format ["Turn Over %1", _hostageName];

private _action = [
    _actionName,
    _actionText,
    "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\meet_ca.paa",
    {
        // Statement - executed when action is used
        params ["_target", "_player", "_params"];
        _params params ["_instanceId", "_hostageId", "_hostageName"];
        
        // Find the hostage unit
        private _hostage = objNull;
        private _hostageUnits = RECONDO_HOSTAGE_UNITS getOrDefault [_instanceId, []];
        
        {
            if (_x getVariable ["RECONDO_HOSTAGE_hostageId", ""] == _hostageId) exitWith {
                _hostage = _x;
            };
        } forEach _hostageUnits;
        
        if (isNull _hostage || !alive _hostage) exitWith {
            hint format ["%1 is not available.", _hostageName];
        };
        
        // Store who rescued for RP award
        _hostage setVariable ["RECONDO_HOSTAGE_rescuedBy", _player, true];
        
        // Process rescue on server
        [_instanceId, _hostageId, _hostage] remoteExec ["Recondo_fnc_handleHostageRescue", 2];
    },
    {
        // Condition - when is action shown
        params ["_target", "_player", "_params"];
        _params params ["_instanceId", "_hostageId", "_hostageName", "_turnInRadius"];
        
        // Check if already rescued
        if (_hostageId in RECONDO_HOSTAGE_RESCUED) exitWith { false };
        
        // Find the hostage unit
        private _hostage = objNull;
        private _hostageUnits = RECONDO_HOSTAGE_UNITS getOrDefault [_instanceId, []];
        
        {
            if (_x getVariable ["RECONDO_HOSTAGE_hostageId", ""] == _hostageId) exitWith {
                _hostage = _x;
            };
        } forEach _hostageUnits;
        
        if (isNull _hostage || !alive _hostage) exitWith { false };
        
        // Check if hostage is within turn-in radius of this object
        private _hostageDistance = _hostage distance _target;
        
        _hostageDistance <= _turnInRadius
    },
    {},
    [_instanceId, _hostageId, _hostageName, _turnInRadius],
    [0, 0, 0],
    2,
    [false, false, false, false, false],
    {}
] call ace_interact_menu_fnc_createAction;

// Add the action to the object
[_object, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;

// Mark as added
_existingActions pushBack _hostageId;
_object setVariable ["Recondo_HOSTAGE_TurnInActions", _existingActions, false];
