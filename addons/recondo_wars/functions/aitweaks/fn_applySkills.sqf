/*
    Recondo_fnc_applySkills
    Applies skill values to a unit based on unit type
    
    Description:
        Sets all AI skill values based on module configuration.
        Applies different skill sets for Base, Elite, and AA units.
    
    Parameters:
        0: OBJECT - Unit to apply skills to
        1: STRING - Unit type: "base", "elite", or "aa"
        
    Returns:
        Nothing
        
    Example:
        [_unit, "base"] call Recondo_fnc_applySkills;
        [_unit, "elite"] call Recondo_fnc_applySkills;
        [_unit, "aa"] call Recondo_fnc_applySkills;
*/

params [["_unit", objNull, [objNull]], ["_unitType", "base", [""]]];

if (isNull _unit) exitWith {};

private _settings = RECONDO_AITWEAKS_SETTINGS;

switch (_unitType) do {
    case "elite": {
        _unit setSkill ["aimingAccuracy", _settings get "eliteAimingAccuracy"];
        _unit setSkill ["aimingShake", _settings get "eliteAimingShake"];
        _unit setSkill ["aimingSpeed", _settings get "eliteAimingSpeed"];
        _unit setSkill ["spotDistance", _settings get "eliteSpotDistance"];
        _unit setSkill ["spotTime", _settings get "eliteSpotTime"];
        _unit setSkill ["courage", _settings get "eliteCourage"];
        _unit setSkill ["commanding", _settings get "eliteCommanding"];
        _unit setSkill ["general", _settings get "eliteGeneral"];
        _unit setSkill ["reloadSpeed", _settings get "eliteReloadSpeed"];
    };
    case "aa": {
        _unit setSkill ["aimingAccuracy", _settings get "aaAimingAccuracy"];
        _unit setSkill ["aimingShake", _settings get "aaAimingShake"];
        _unit setSkill ["aimingSpeed", _settings get "aaAimingSpeed"];
        _unit setSkill ["spotDistance", _settings get "aaSpotDistance"];
        _unit setSkill ["spotTime", _settings get "aaSpotTime"];
        _unit setSkill ["courage", _settings get "aaCourage"];
        _unit setSkill ["commanding", _settings get "aaCommanding"];
        _unit setSkill ["general", _settings get "aaGeneral"];
        _unit setSkill ["reloadSpeed", _settings get "aaReloadSpeed"];
    };
    default {
        // Base soldiers
        _unit setSkill ["aimingAccuracy", _settings get "baseAimingAccuracy"];
        _unit setSkill ["aimingShake", _settings get "baseAimingShake"];
        _unit setSkill ["aimingSpeed", _settings get "baseAimingSpeed"];
        _unit setSkill ["spotDistance", _settings get "baseSpotDistance"];
        _unit setSkill ["spotTime", _settings get "baseSpotTime"];
        _unit setSkill ["courage", _settings get "baseCourage"];
        _unit setSkill ["commanding", _settings get "baseCommanding"];
        _unit setSkill ["general", _settings get "baseGeneral"];
        _unit setSkill ["reloadSpeed", _settings get "baseReloadSpeed"];
    };
};
