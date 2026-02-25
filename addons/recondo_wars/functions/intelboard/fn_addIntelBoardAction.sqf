/*
    Recondo_fnc_addIntelBoardAction
    Server-side setup for Intel Board ACE action
    
    Description:
        Called on server to broadcast ACE action setup to all clients.
        Adds the "View Intel Board" interaction to the specified object.
    
    Parameters:
        _object - OBJECT - The object to add the action to
        _actionName - STRING - The display name for the ACE action
    
    Returns:
        Nothing
    
    Example:
        [_object, "View Intel Board"] call Recondo_fnc_addIntelBoardAction;
*/

if (!isServer) exitWith {};

params [
    ["_object", objNull, [objNull]],
    ["_actionName", "View Intel Board", [""]]
];

if (isNull _object) exitWith {
    diag_log "[RECONDO_INTELBOARD] ERROR: addIntelBoardAction - Null object";
};

// Store action name on object for client reference
_object setVariable ["Recondo_IntelBoard_ActionName", _actionName, true];
_object setVariable ["Recondo_IntelBoard_Enabled", true, true];

// Broadcast to all clients (including JIP)
[_object, _actionName] remoteExec ["Recondo_fnc_addIntelBoardActionClient", 0, _object];

private _settings = if (isNil "RECONDO_INTELBOARD_SETTINGS") then { createHashMap } else { RECONDO_INTELBOARD_SETTINGS };
private _debugLogging = _settings getOrDefault ["debugLogging", false];

if (_debugLogging) then {
    diag_log format ["[RECONDO_INTELBOARD] Broadcasting Intel Board action to clients for: %1", _object];
};
