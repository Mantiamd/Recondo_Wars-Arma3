/*
    Recondo_fnc_initSpectatorCamClient
    Registers the client-side death/respawn hooks for the Spectator Cam

    Description:
        Runs once per client (JIP-safe, guarded against double registration).
        Hooks:
        - EntityKilled on own unit -> enter spectator after the configured delay
        - CBA player "unit" event  -> a new LIVING body (respawn/team switch)
          closes the camera; no re-attach bookkeeping needed since the event
          fires on every body swap
        - ace_unconscious          -> enter on knock-out, exit on wake-up.
          Registered only when ACE Medical is loaded; the module toggle is
          checked at event time so settings sync order never matters

        Everything runs locally on the affected player's machine -
        BIS_fnc_EGSpectator is client UI, so no remoteExec at event time.

    Parameters:
        None

    Returns:
        Nothing
*/

if (!hasInterface) exitWith {};

if (missionNamespace getVariable ["RECONDO_SPECTATORCAM_CLIENT_INIT", false]) exitWith {};
RECONDO_SPECTATORCAM_CLIENT_INIT = true;

RECONDO_SPECTATORCAM_ACTIVE = false;

// Death of own unit (fires on every machine; player still points at the corpse here)
addMissionEventHandler ["EntityKilled", {
    params ["_unit"];
    if !(_unit isEqualTo player) exitWith {};
    [] call Recondo_fnc_enterSpectatorCam;
}];

// Body swap (respawn / team switch): a new living body means we are back in the game
["unit", {
    params ["_newUnit"];
    if (!isNull _newUnit && {alive _newUnit}) then {
        [] call Recondo_fnc_exitSpectatorCam;
    };
}] call CBA_fnc_addPlayerEventHandler;

// ACE unconsciousness
if (isClass (configFile >> "CfgPatches" >> "ace_medical")) then {
    ["ace_unconscious", {
        params ["_unit", "_isUnconscious"];
        if !(_unit isEqualTo player) exitWith {};

        private _settings = missionNamespace getVariable ["RECONDO_SPECTATORCAM_SETTINGS", createHashMap];
        if !(_settings getOrDefault ["unconsciousCam", true]) exitWith {};

        if (_isUnconscious) then {
            [] call Recondo_fnc_enterSpectatorCam;
        } else {
            // Death also flips this false - only a LIVING wake-up closes the cam
            if (alive player) then {
                [] call Recondo_fnc_exitSpectatorCam;
            };
        };
    }] call CBA_fnc_addEventHandler;
};

// Synced spectator objects: living players get an ACE action to watch their
// side's feed (same locked-down camera; Esc closes it). Editor-placed objects
// exist on every machine from mission start, so per-object actions are safe here.
[{
    !isNil "RECONDO_SPECTATORCAM_OBJECTS"
}, {
    if (count RECONDO_SPECTATORCAM_OBJECTS == 0) exitWith {};

    private _settings = missionNamespace getVariable ["RECONDO_SPECTATORCAM_SETTINGS", createHashMap];
    private _actionText = _settings getOrDefault ["objectActionText", "Enter Spectator Cam"];

    private _action = [
        "Recondo_SpectatorCam_Enter",
        _actionText,
        "\a3\ui_f\data\igui\cfg\simpletasks\types\scout_ca.paa",
        {
            [true] call Recondo_fnc_enterSpectatorCam;
        },
        {
            params ["_target", "_player"];
            alive _player && {!RECONDO_SPECTATORCAM_ACTIVE}
        }
    ] call ace_interact_menu_fnc_createAction;

    private _added = 0;
    {
        if (!isNull _x) then {
            [_x, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;
            _added = _added + 1;
        };
    } forEach RECONDO_SPECTATORCAM_OBJECTS;

    diag_log format ["[RECONDO_SPECTATORCAM] Client: enter action added to %1 synced object(s)", _added];
}, []] call CBA_fnc_waitUntilAndExecute;

diag_log "[RECONDO_SPECTATORCAM] Client: spectator cam hooks registered";
