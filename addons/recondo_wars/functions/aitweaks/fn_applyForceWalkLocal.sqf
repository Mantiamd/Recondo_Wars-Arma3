/*
    Recondo_fnc_applyForceWalkLocal
    Applies managed force walk to a unit on the machine where it is local

    Description:
        Part of the dynamic force walk system: units walk until combat
        starts (shots nearby, hits, own fire, or COMBAT behaviour), then
        run freely. The sweep loop (fn_forceWalkSweep) re-applies the
        walk 30 minutes after the release, deferred until the current
        fight ends if the group is still engaged at that point.

        The release moment is stamped once per release on the group
        (public, so the 30-minute clock survives Headless Client
        transfers); a stamp of -1 means the group is currently walking.

        forceWalk and the release event handlers only work where the unit
        is local, so this runs on the server or a Headless Client and is
        re-invoked via the CBA "Local" class handler whenever the unit
        changes owner (see fn_preInit.sqf). The RECONDO_FORCEWALK marker
        is public so the new owner knows the unit is managed.

        Event handlers persist per machine, so a guard variable prevents
        stacking duplicates when a unit bounces server -> HC -> server.

    Parameters:
        0: OBJECT - Unit to manage

    Returns:
        Nothing
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit || {!alive _unit} || {!local _unit}) exitWith {};

// Release event handlers - added once per machine, they persist across
// locality bounces and simply resume working when the unit is local again
if (!(_unit getVariable ["RECONDO_WALK_EH_ADDED", false])) then {
    _unit setVariable ["RECONDO_WALK_EH_ADDED", true];

    private _release = {
        params ["_unit"];
        private _grp = group _unit;
        // Tracker signal shots are staged gunfire, not combat - the
        // shooter's own Fired and his groupmates' FiredNear must not
        // release the group's walk (see fn_trackerSignalShot)
        if (_grp getVariable ["RECONDO_TRACKERS_signalShotActive", false]) exitWith {};
        // Stamp only the first release - the 30-minute re-apply clock in
        // the sweep loop runs from the moment the group started running
        if ((_grp getVariable ["RECONDO_WALK_RELEASEDAT", -1]) < 0) then {
            _grp setVariable ["RECONDO_WALK_RELEASEDAT", time, true];
        };
        if (_unit getVariable ["RECONDO_WALK_ACTIVE", false]) then {
            _unit forceWalk false;
            // setAnimSpeedCoef has local effect - broadcast so every
            // client sees it (JIP keyed on the unit: latest value wins)
            [_unit, _unit getVariable ["RECONDO_BASE_ANIMCOEF", 1]] remoteExec ["setAnimSpeedCoef", 0, _unit];
            _unit setVariable ["RECONDO_WALK_ACTIVE", false];
        };
    };

    _unit addEventHandler ["FiredNear", _release];
    _unit addEventHandler ["Hit", _release];
    _unit addEventHandler ["Fired", _release];
};

// Group already released: stay running - the sweep re-applies the walk
// once the 30-minute clock expires
if ((group _unit getVariable ["RECONDO_WALK_RELEASEDAT", -1]) >= 0) exitWith {};

// Don't force a walk on a unit that is currently fighting (e.g. handed to
// an HC mid-firefight) - mark the group released so the clock runs
private _inCombat = (behaviour _unit in ["COMBAT", "STEALTH"]) || {!isNull (_unit findNearestEnemy _unit)};

if (_inCombat) then {
    (group _unit) setVariable ["RECONDO_WALK_RELEASEDAT", time, true];
} else {
    _unit forceWalk true;
    // Sped-up walk animation: brisker pace while still pinned to the
    // walking gait; restored to the configured coef on every release.
    // setAnimSpeedCoef has local effect - broadcast so every client
    // sees it (JIP keyed on the unit: latest value wins)
    [_unit, 1.5] remoteExec ["setAnimSpeedCoef", 0, _unit];
    _unit setVariable ["RECONDO_WALK_ACTIVE", true];
};
