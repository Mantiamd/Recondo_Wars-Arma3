/*
    Recondo_fnc_releaseForceWalk
    Permanently removes a unit from the dynamic force walk system

    Description:
        Clears the public RECONDO_FORCEWALK marker so neither the sweep
        loop (fn_forceWalkSweep) nor a locality transfer re-applies the
        walk, then releases the current forceWalk state.

        forceWalk is an argument-local command, so the function forwards
        itself to the unit's owner when called from another machine.

        Used by spawner modules that want their units exempt from AI
        Tweaks force walk (e.g. Reinforcement Waves' release-after-spawn
        option).

    Parameters:
        0: OBJECT - Unit to release

    Returns:
        Nothing
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit) exitWith {};

if (!local _unit) exitWith {
    [_unit] remoteExec ["Recondo_fnc_releaseForceWalk", _unit];
};

_unit setVariable ["RECONDO_FORCEWALK", false, true];

if (_unit getVariable ["RECONDO_WALK_ACTIVE", false]) then {
    _unit forceWalk false;
    // Local-effect command - broadcast to all clients
    [_unit, _unit getVariable ["RECONDO_BASE_ANIMCOEF", 1]] remoteExec ["setAnimSpeedCoef", 0, _unit];
    _unit setVariable ["RECONDO_WALK_ACTIVE", false];
};
