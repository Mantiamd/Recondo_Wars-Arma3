/*
    Recondo_fnc_addPOWTurnIn
    Server-side setup for POW turn-in ACE action
    
    Description:
        Broadcasts the ACE action setup to all clients for the
        specified turn-in object.
    
    Parameters:
        _object - OBJECT - The turn-in object
    
    Returns:
        BOOL - True if broadcast was successful
    
    Example:
        [_intelOfficer] call Recondo_fnc_addPOWTurnIn;
*/

if (!isServer) exitWith { false };

params [["_object", objNull, [objNull]]];

if (isNull _object) exitWith {
    diag_log "[RECONDO_INTELITEMS] ERROR: addPOWTurnIn - Null object provided";
    false
};

// Get POW settings
private _settings = if (isNil "RECONDO_INTELITEMS_SETTINGS") then { 
    createHashMap 
} else { 
    RECONDO_INTELITEMS_SETTINGS 
};

private _actionText = _settings getOrDefault ["powActionText", "Turn In Prisoner"];
private _turnInRadius = _settings getOrDefault ["powTurnInRadius", 10];
private _debugLogging = _settings getOrDefault ["debugLogging", false];

if (_debugLogging) then {
    diag_log format ["[RECONDO_INTELITEMS] Broadcasting POW turn-in action to clients for object: %1", _object];
};

// Broadcast to all clients (including JIP)
[_object, _actionText, _turnInRadius] remoteExec ["Recondo_fnc_addPOWTurnInClient", 0, true];

true
