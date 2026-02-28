/*
    Recondo_fnc_getAITweaksUnitType
    Determines a unit's category for AI tweaks based on classname matching
    
    Parameters:
        0: OBJECT - Unit to classify
        1: HASHMAP - Settings hashmap containing classname arrays
        
    Returns:
        STRING - "elite", "aa", or "base"
*/

params [["_unit", objNull, [objNull]], ["_settings", createHashMap, [createHashMap]]];

if (isNull _unit) exitWith { "base" };

private _className = typeOf _unit;
private _eliteClassnames = _settings getOrDefault ["eliteClassnamesArray", []];
private _aaClassnames = _settings getOrDefault ["aaClassnamesArray", []];

if (_className in _eliteClassnames) exitWith { "elite" };
if (_className in _aaClassnames) exitWith { "aa" };

"base"
