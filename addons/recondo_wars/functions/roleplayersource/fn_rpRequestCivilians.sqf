/*
    Recondo_fnc_rpRequestCivilians
    Server-side: Receives a civilian spawn request from a client.
    Called via remoteExec from the player's self-action.

    Parameters:
        _spawnPos - ARRAY - Position to spawn civilians around

    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [
    ["_spawnPos", [0,0,0], [[]]]
];

if (isNil "RECONDO_RP_SOURCE_SETTINGS") exitWith {
    diag_log "[RECONDO_RP_SOURCE] rpRequestCivilians: Settings not available.";
};

private _settings = RECONDO_RP_SOURCE_SETTINGS;
private _debugLogging = _settings getOrDefault ["debugLogging", false];

if (_debugLogging) then {
    diag_log format ["[RECONDO_RP_SOURCE] Civilian spawn requested at %1", _spawnPos];
};

[_spawnPos, _settings] call Recondo_fnc_rpSpawnCivilians;
