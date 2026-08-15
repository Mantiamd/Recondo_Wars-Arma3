/*
    Recondo_fnc_forceWalkSweep
    Periodic loop managing dynamic force walk release and re-application

    Description:
        Every 5 seconds, checks each group led by a locally-owned unit that
        contains force-walk managed units (RECONDO_FORCEWALK tag):

        - Group in combat (leader in COMBAT/STEALTH behaviour or with a
          known enemy) and still walking: releases force walk on the whole
          group so it can run, and stamps the release time. This catches
          AI that detected players without any shots fired yet - the unit
          event handlers (fn_applyForceWalkLocal) already release
          instantly on gunfire and hits.

        - Group released for 30+ minutes: re-applies force walk. If the
          clock expires mid-firefight the re-apply is deferred - checked
          again each tick - until the group is out of combat, so units
          are never forced to walk while actively engaged. Each later
          contact releases them again with a fresh 30-minute clock.

        The release stamp (RECONDO_WALK_RELEASEDAT, group variable, -1
        when walking) is public so the clock survives Headless Client
        transfers.

        Checks are group-level (leader only), so cost stays trivial even
        with hundreds of managed units.

        forceWalk is an argument-local command, so this loop runs on every
        machine that owns AI: the server and each Headless Client, each
        handling only its own local groups. Started from fn_postInit.sqf.

    Parameters:
        None

    Returns:
        Nothing
*/

// AI owners only: server (dedicated or hosted) and Headless Clients
if (!isServer && hasInterface) exitWith {};

if (!isNil "RECONDO_FORCEWALK_SWEEP_RUNNING") exitWith {};
RECONDO_FORCEWALK_SWEEP_RUNNING = true;

// Seconds after a release before force walk is re-applied
private _walkAgainDelay = 1800;

[_walkAgainDelay] spawn {
    params ["_walkAgainDelay"];

    while {true} do {
        sleep 5;

        {
            private _group = _x;
            private _leader = leader _group;
            if (isNull _leader || {!alive _leader} || {!local _leader}) then { continue };

            private _managed = (units _group) select { alive _x && {_x getVariable ["RECONDO_FORCEWALK", false]} };
            if (_managed isEqualTo []) then { continue };

            private _inCombat = (behaviour _leader in ["COMBAT", "STEALTH"]) || {!isNull (_leader findNearestEnemy _leader)};
            private _releasedAt = _group getVariable ["RECONDO_WALK_RELEASEDAT", -1];

            if (_inCombat) then {
                // Detection-based release; stamp only the first release so
                // the clock runs from the moment the group started running
                if (_releasedAt < 0) then {
                    _group setVariable ["RECONDO_WALK_RELEASEDAT", time, true];
                };
                {
                    if (_x getVariable ["RECONDO_WALK_ACTIVE", false]) then {
                        _x forceWalk false;
                        // Local-effect command - broadcast to all clients
                        [_x, _x getVariable ["RECONDO_BASE_ANIMCOEF", 1]] remoteExec ["setAnimSpeedCoef", 0, _x];
                        _x setVariable ["RECONDO_WALK_ACTIVE", false];
                    };
                } forEach _managed;
            } else {
                // Out of combat: re-apply once the 30-minute clock expires.
                // Expiries that landed mid-firefight arrive here on the
                // first calm tick after the fight ends.
                if (_releasedAt >= 0 && {time - _releasedAt > _walkAgainDelay}) then {
                    {
                        if (!(_x getVariable ["RECONDO_WALK_ACTIVE", false]) && {local _x}) then {
                            _x forceWalk true;
                            // Local-effect command - broadcast to all clients
                            [_x, 1.5] remoteExec ["setAnimSpeedCoef", 0, _x];
                            _x setVariable ["RECONDO_WALK_ACTIVE", true];
                        };
                    } forEach _managed;
                    _group setVariable ["RECONDO_WALK_RELEASEDAT", -1, true];
                };
            };
        } forEach allGroups;
    };
};
