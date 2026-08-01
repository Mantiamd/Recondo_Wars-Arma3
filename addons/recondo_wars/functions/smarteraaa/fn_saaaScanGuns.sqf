/*
    Recondo_fnc_saaaScanGuns
    Refreshes the managed gun list

    Description:
        Refreshes RECONDO_SAAA_GUNS with every live static weapon the system
        should manage. Called periodically from the main loop so spawned and
        destroyed guns are picked up (SDR, Custom Site Spawn, editor, anything).

        Only server-LOCAL guns are managed: every steering command this system
        uses (doWatch, disableAI, fire) needs the AI local, and the HC transfer
        helper refuses managed-gun crews - the locality filter here is the
        backstop for guns crewed before this module initialized.

        Also registers a one-time "Fired" EH per gun - the shot timestamp is the
        ground truth "this gun is engaging" signal for the prep tick (knowsAbout
        is unreliable for static gunners).

        RECONDO_SAAA_ignore guns STAY in the list - the prep tick parks them in
        the OFF state so toggling is instant and they remain visible in debug.

    Parameters:
        None

    Returns:
        Nothing (sets RECONDO_SAAA_GUNS)
*/

RECONDO_SAAA_GUNS = (entities [["StaticWeapon"], [], false, true]) select {
    local _x && {[_x] call Recondo_fnc_saaaIsManagedGun}
};

{
    if (isNil {_x getVariable "RECONDO_SAAA_firedEH"}) then {
        private _eh = _x addEventHandler ["Fired", {
            params ["_gun"];
            // Script-forced blind-fire shots must NOT count as "the gun decided
            // to engage" - lastShot drives the ENGAGING transition in prep tick.
            if (_gun getVariable ["RECONDO_SAAA_burstActive", false]) then {
                _gun setVariable ["RECONDO_SAAA_lastScriptShot", time];
                _gun setVariable ["RECONDO_SAAA_scriptShots",
                    (_gun getVariable ["RECONDO_SAAA_scriptShots", 0]) + 1];
            } else {
                _gun setVariable ["RECONDO_SAAA_lastShot", time];
            };
        }];
        _x setVariable ["RECONDO_SAAA_firedEH", _eh];
    };
} forEach RECONDO_SAAA_GUNS;
