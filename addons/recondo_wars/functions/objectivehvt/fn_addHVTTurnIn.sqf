/*
    Recondo_fnc_addHVTTurnIn
    Adds "Turn Over HVT" ACE action to Intel turn-in objects
    
    Description:
        Called on server to broadcast HVT turn-in ACE action
        to all clients for the Intel turn-in objects.
        Waits for Intel module to initialize if needed.
    
    Parameters:
        _settings - HASHMAP - Module settings
    
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [["_settings", nil, [createHashMap]]];

if (isNil "_settings") exitWith {
    diag_log "[RECONDO_HVT] ERROR: No settings provided for addHVTTurnIn";
};

private _instanceId = _settings get "instanceId";
private _hvtName = _settings get "hvtName";
private _hvtTurnInRadius = _settings get "hvtTurnInRadius";
private _debugLogging = _settings get "debugLogging";

// Wait for Intel turn-in objects to be available (Intel module may not have initialized yet)
[{
    !isNil "RECONDO_INTEL_TURNIN_OBJECTS" && {count RECONDO_INTEL_TURNIN_OBJECTS > 0}
}, {
    params ["_instanceId", "_hvtName", "_hvtTurnInRadius", "_debugLogging"];
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_HVT] Adding HVT turn-in action for '%1' to %2 objects", _hvtName, count RECONDO_INTEL_TURNIN_OBJECTS];
    };
    
    // Broadcast to all clients
    {
        [_x, _instanceId, _hvtName, _hvtTurnInRadius] remoteExec ["Recondo_fnc_addHVTTurnInClient", 0, true];
    } forEach RECONDO_INTEL_TURNIN_OBJECTS;
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_HVT] HVT turn-in actions broadcast for '%1'", _hvtName];
    };
}, [_instanceId, _hvtName, _hvtTurnInRadius, _debugLogging], 30, {
    // Timeout after 30 seconds
    diag_log "[RECONDO_HVT] WARNING: Timed out waiting for Intel turn-in objects. HVT turn-in will not work.";
}] call CBA_fnc_waitUntilAndExecute;
