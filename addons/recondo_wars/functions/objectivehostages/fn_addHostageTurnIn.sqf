/*
    Recondo_fnc_addHostageTurnIn
    Adds "Turn Over Hostage" ACE actions to Intel turn-in objects
    
    Description:
        Called on server to broadcast hostage turn-in ACE actions
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
    diag_log "[RECONDO_HOSTAGE] ERROR: No settings provided for addHostageTurnIn";
};

private _instanceId = _settings get "instanceId";
private _objectiveName = _settings get "objectiveName";
private _hostageCount = _settings get "hostageCount";
private _hostageNames = _settings get "hostageNames";
private _hostageTurnInRadius = _settings get "hostageTurnInRadius";
private _debugLogging = _settings get "debugLogging";

// Wait for Intel turn-in objects to be available
[{
    !isNil "RECONDO_INTEL_TURNIN_OBJECTS" && {count RECONDO_INTEL_TURNIN_OBJECTS > 0}
}, {
    params ["_instanceId", "_objectiveName", "_hostageCount", "_hostageNames", "_hostageTurnInRadius", "_debugLogging"];
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_HOSTAGE] Adding hostage turn-in actions for '%1' (%2 hostages) to %3 objects", 
            _objectiveName, _hostageCount, count RECONDO_INTEL_TURNIN_OBJECTS];
    };
    
    // Broadcast to all clients - one action per hostage
    {
        private _turnInObject = _x;
        
        for "_i" from 0 to (_hostageCount - 1) do {
            private _hostageId = format ["%1_hostage_%2", _instanceId, _i];
            private _hostageName = _hostageNames select (_i min (count _hostageNames - 1));
            
            [_turnInObject, _instanceId, _hostageId, _hostageName, _hostageTurnInRadius] remoteExec ["Recondo_fnc_addHostageTurnInClient", 0, true];
        };
    } forEach RECONDO_INTEL_TURNIN_OBJECTS;
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_HOSTAGE] Hostage turn-in actions broadcast for '%1'", _objectiveName];
    };
}, [_instanceId, _objectiveName, _hostageCount, _hostageNames, _hostageTurnInRadius, _debugLogging], 30, {
    diag_log "[RECONDO_HOSTAGE] WARNING: Timed out waiting for Intel turn-in objects. Hostage turn-in will not work.";
}] call CBA_fnc_waitUntilAndExecute;
