/*
    Recondo_fnc_handlePowergridDestroyed
    Handles the destruction of a powergrid's linked object

    Description:
        Called from the Killed EH on the synced object (destroy mode).
        Turns off all lights and optionally persists the destroyed state.

    Parameters:
        _instanceId - STRING - Powergrid instance ID

    Execution:
        Server only (called from Killed EH)
*/

if (!isServer) exitWith {};

params [["_instanceId", "", [""]]];

if (_instanceId == "") exitWith {
    diag_log "[RECONDO_POWERGRID] ERROR: Empty instance ID in handlePowergridDestroyed";
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

private _enablePersistence = _settings get "enablePersistence";
private _debugLogging = _settings get "debugLogging";

diag_log format ["[RECONDO_POWERGRID] Power grid destroyed: %1", _instanceId];

[_instanceId, "OFF"] call Recondo_fnc_togglePowergridLights;

if (_enablePersistence) then {
    private _persistenceKey = format ["POWERGRID_%1_DESTROYED", _instanceId];
    [_persistenceKey, true] call Recondo_fnc_setSaveData;
    saveMissionProfileNamespace;

    if (_debugLogging) then {
        diag_log format ["[RECONDO_POWERGRID] Saved destroyed state for '%1'", _instanceId];
    };
};
