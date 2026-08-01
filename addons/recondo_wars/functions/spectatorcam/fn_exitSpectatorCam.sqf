/*
    Recondo_fnc_exitSpectatorCam
    Closes the End Game Spectator camera on the local client

    Description:
        Terminates the spectator display if it is open (guarded - respawn and
        revive both call this, whichever fires first wins). Called from the
        hooks registered in fn_initSpectatorCamClient.

    Parameters:
        None

    Returns:
        Nothing
*/

if (!hasInterface) exitWith {};
if (!RECONDO_SPECTATORCAM_ACTIVE) exitWith {};

RECONDO_SPECTATORCAM_ACTIVE = false;
["Terminate"] call BIS_fnc_EGSpectator;

private _settings = missionNamespace getVariable ["RECONDO_SPECTATORCAM_SETTINGS", createHashMap];
if (_settings getOrDefault ["debugLogging", false]) then {
    diag_log "[RECONDO_SPECTATORCAM] Spectator closed";
};
