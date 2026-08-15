/*
    Recondo_fnc_setupBehavior
    Sets up behavior restrictions for AI units
    
    Description:
        Implements force walk and force stand behaviors per category.
        Force walk is dynamic: released when combat starts (shots, hits,
        or COMBAT behaviour) and re-applied by the sweep loop 30 minutes
        after the release (see fn_forceWalkSweep). Survives Headless
        Client transfers via the CBA "Local" handler in fn_preInit.sqf.
        Also applies animation speed coefficient.
    
    Parameters:
        0: OBJECT - Unit to configure
        1: STRING - Unit type: "base", "elite", or "aa"
        2: HASHMAP - Settings hashmap for the instance
        
    Returns:
        Nothing
*/

params [["_unit", objNull, [objNull]], ["_unitType", "base", [""]], ["_settings", createHashMap, [createHashMap]]];

if (isNull _unit) exitWith {};

private _forceWalk = switch (_unitType) do {
    case "elite": { _settings get "eliteForceWalk" };
    case "aa": { _settings get "aaForceWalk" };
    default { _settings get "baseForceWalk" };
};

private _forceStand = switch (_unitType) do {
    case "elite": { _settings get "eliteForceStand" };
    case "aa": { _settings get "aaForceStand" };
    default { _settings get "baseForceStand" };
};

private _animSpeedCoef = switch (_unitType) do {
    case "elite": { _settings get "eliteAnimSpeedCoef" };
    case "aa": { _settings get "aaAnimSpeedCoef" };
    default { _settings get "baseAnimSpeedCoef" };
};

// Remembered (public) so force walk releases can restore the configured
// coef instead of a hardcoded 1, on whichever machine owns the unit
_unit setVariable ["RECONDO_BASE_ANIMCOEF", _animSpeedCoef, true];
[_unit, _animSpeedCoef] remoteExec ["setAnimSpeedCoef", 0, _unit];

if (_forceStand) then {
    _unit setUnitPos "UP";
};

if (_forceWalk) then {
    // Public marker so whichever machine owns the unit (server or HC)
    // knows to manage its walk state after a locality transfer
    _unit setVariable ["RECONDO_FORCEWALK", true, true];

    // The unit may already sit on an HC by the time the delayed
    // EntityCreated processing runs - apply on the owning machine
    if (local _unit) then {
        [_unit] call Recondo_fnc_applyForceWalkLocal;
    } else {
        [_unit] remoteExec ["Recondo_fnc_applyForceWalkLocal", _unit];
    };
};
