/*
    Recondo_fnc_addPhotoTurnIn
    Adds photo turn-in ACE action to Intel turn-in objects
    
    Parameters:
        _settings - HASHMAP - Module settings
    
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [["_settings", nil, [createHashMap]]];

if (isNil "_settings") exitWith {};

private _instanceId = _settings get "instanceId";
private _objectiveName = _settings get "objectiveName";
private _rewardItemClassname = _settings get "rewardItemClassname";
private _debugLogging = _settings get "debugLogging";

[{
    !isNil "RECONDO_INTEL_TURNIN_OBJECTS" && {count RECONDO_INTEL_TURNIN_OBJECTS > 0}
}, {
    params ["_instanceId", "_objectiveName", "_rewardItemClassname", "_debugLogging"];
    
    {
        [_x, _instanceId, _objectiveName, _rewardItemClassname] remoteExec ["Recondo_fnc_addPhotoTurnInClient", 0, true];
    } forEach RECONDO_INTEL_TURNIN_OBJECTS;
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_PHOTO] Photo turn-in actions broadcast for '%1'", _objectiveName];
    };
}, [_instanceId, _objectiveName, _rewardItemClassname, _debugLogging], 30, {
    diag_log "[RECONDO_PHOTO] WARNING: Timed out waiting for Intel turn-in objects.";
}] call CBA_fnc_waitUntilAndExecute;
