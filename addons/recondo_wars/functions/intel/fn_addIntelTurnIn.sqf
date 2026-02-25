/*
    Recondo_fnc_addIntelTurnIn
    Adds ACE interaction to an object for turning in intel
    
    Description:
        Server-side function that broadcasts the ACE action setup
        to all clients. The actual action is added client-side via
        fn_addIntelTurnInClient to avoid duplicate actions on hosted servers.
    
    Parameters:
        _object - OBJECT - The object to add the turn-in action to
    
    Returns:
        BOOL - True if broadcast was successful
    
    Example:
        [_intelOfficer] call Recondo_fnc_addIntelTurnIn;
*/

params [["_object", objNull, [objNull]]];

if (isNull _object) exitWith {
    diag_log "[RECONDO_INTEL] ERROR: addIntelTurnIn - Null object provided";
    false
};

// Get settings
private _actionText = if (isNil "RECONDO_INTEL_SETTINGS") then { 
    "Turn In Intel" 
} else { 
    RECONDO_INTEL_SETTINGS getOrDefault ["turnInActionText", "Turn In Intel"] 
};

private _debugLogging = if (isNil "RECONDO_INTEL_SETTINGS") then { false } else { RECONDO_INTEL_SETTINGS getOrDefault ["debugLogging", false] };
if (_debugLogging) then {
    diag_log format ["[RECONDO_INTEL] Broadcasting turn-in action to clients for object: %1", _object];
};

// Broadcast to all clients (including JIP) - action is added client-side only
[_object, _actionText] remoteExec ["Recondo_fnc_addIntelTurnInClient", 0, true];

true
