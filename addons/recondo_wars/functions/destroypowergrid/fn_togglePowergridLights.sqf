/*
    Recondo_fnc_togglePowergridLights
    Toggles lights within a powergrid instance's radius

    Description:
        Server-side entry point. Broadcasts the light toggle to all
        clients via JIP-compatible remoteExec. The client-side function
        handles both switchLight and setDamage on lamp objects.

    Parameters:
        _instanceId - STRING - Powergrid instance ID
        _state - STRING - "OFF" or "ON"

    Execution:
        Server only (called from ACE action via remoteExec or directly)
*/

if (!isServer) exitWith {};

params [
    ["_instanceId", "", [""]],
    ["_state", "OFF", [""]]
];

if (_instanceId == "") exitWith {
    diag_log "[RECONDO_POWERGRID] ERROR: Empty instance ID in togglePowergridLights";
};

private _settings = nil;
{
    if ((_x get "instanceId") == _instanceId) exitWith {
        _settings = _x;
    };
} forEach RECONDO_POWERGRID_INSTANCES;

if (isNil "_settings") exitWith {
    diag_log format ["[RECONDO_POWERGRID] ERROR: No settings found for instance '%1'", _instanceId];
};

private _effectRadius = _settings get "effectRadius";
private _additionalClassnames = _settings get "additionalClassnames";
private _objectPos = _settings get "objectPos";
private _debugLogging = _settings get "debugLogging";

if (_debugLogging) then {
    diag_log format ["[RECONDO_POWERGRID] Toggling lights %1 for '%2' (radius: %3m, pos: %4)",
        _state, _instanceId, _effectRadius, _objectPos];
};

// Broadcast to all clients (and server) with JIP ticket
private _jipTicket = format ["RECONDO_PG_%1", _instanceId];
[_objectPos, _effectRadius, _state, _additionalClassnames] remoteExec ["Recondo_fnc_applyLightsLocal", 0, _jipTicket];

// Update global state
RECONDO_POWERGRID_STATES set [_instanceId, _state];
publicVariable "RECONDO_POWERGRID_STATES";

if (_debugLogging) then {
    diag_log format ["[RECONDO_POWERGRID] State updated to %1 for '%2'", _state, _instanceId];
};
