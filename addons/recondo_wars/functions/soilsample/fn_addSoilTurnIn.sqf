/*
    Recondo_fnc_addSoilTurnIn
    Server-side: Adds "Turn In Soil Sample" ACE actions to Intel turn-in objects

    Description:
        Waits for Intel turn-in objects to be available, then broadcasts
        the turn-in ACE action to all clients.

    Parameters:
        _settings - HASHMAP - Module settings
*/

if (!isServer) exitWith {};

params [["_settings", nil, [createHashMap]]];

if (isNil "_settings") exitWith {
    diag_log "[RECONDO_SOIL] ERROR: No settings provided for addSoilTurnIn";
};

private _instanceId = _settings get "instanceId";
private _debugLogging = _settings get "debugLogging";

[{
    !isNil "RECONDO_INTEL_TURNIN_OBJECTS" && {count RECONDO_INTEL_TURNIN_OBJECTS > 0}
}, {
    params ["_instanceId", "_debugLogging"];

    if (_debugLogging) then {
        diag_log format ["[RECONDO_SOIL] Adding turn-in actions to %1 Intel turn-in objects", count RECONDO_INTEL_TURNIN_OBJECTS];
    };

    {
        private _turnInObject = _x;
        [_turnInObject, _instanceId] remoteExec ["Recondo_fnc_addSoilTurnInClient", 0, true];
    } forEach RECONDO_INTEL_TURNIN_OBJECTS;

    if (_debugLogging) then {
        diag_log format ["[RECONDO_SOIL] Turn-in actions broadcast for instance '%1'", _instanceId];
    };
}, [_instanceId, _debugLogging], 60, {
    diag_log "[RECONDO_SOIL] WARNING: Timed out waiting for Intel turn-in objects. Soil sample turn-in will not work.";
}] call CBA_fnc_waitUntilAndExecute;
