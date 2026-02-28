/*
    Recondo_fnc_setupBehavior
    Sets up behavior restrictions for AI units
    
    Description:
        Implements force walk and force stand behaviors per category.
        Force walk is released when combat starts.
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

[_unit, _animSpeedCoef] remoteExec ["setAnimSpeedCoef", 0, _unit];

if (_forceStand) then {
    _unit setUnitPos "UP";
};

if (_forceWalk) then {
    _unit forceWalk true;
    
    _unit addEventHandler ["FiredNear", {
        params ["_unit"];
        if (_unit getVariable ["RECONDO_WALK_RELEASED", false]) exitWith {};
        _unit forceWalk false;
        _unit setVariable ["RECONDO_WALK_RELEASED", true];
    }];
    
    _unit addEventHandler ["Hit", {
        params ["_unit"];
        if (_unit getVariable ["RECONDO_WALK_RELEASED", false]) exitWith {};
        _unit forceWalk false;
        _unit setVariable ["RECONDO_WALK_RELEASED", true];
    }];
    
    _unit addEventHandler ["Fired", {
        params ["_unit"];
        if (_unit getVariable ["RECONDO_WALK_RELEASED", false]) exitWith {};
        _unit forceWalk false;
        _unit setVariable ["RECONDO_WALK_RELEASED", true];
    }];
};
