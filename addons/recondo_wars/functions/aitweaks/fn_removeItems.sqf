/*
    Recondo_fnc_removeItems
    Removes specified items from AI inventory
    
    Description:
        Removes grenades and other throwables specified in the module
        settings for the given unit category.
    
    Parameters:
        0: OBJECT - Unit to remove items from
        1: STRING - Unit type: "base", "elite", or "aa"
        2: HASHMAP - Settings hashmap for the instance
        
    Returns:
        Nothing
*/

params [["_unit", objNull, [objNull]], ["_unitType", "base", [""]], ["_settings", createHashMap, [createHashMap]]];

if (isNull _unit) exitWith {};

private _grenadesToRemove = switch (_unitType) do {
    case "elite": { _settings get "eliteGrenadesArray" };
    case "aa": { _settings get "aaGrenadesArray" };
    default { _settings get "baseGrenadesArray" };
};

{
    _unit removeMagazines _x;
} forEach _grenadesToRemove;
