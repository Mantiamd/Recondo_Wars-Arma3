/*
    Recondo_fnc_isGroupExempt
    Check if a unit's group is exempt from radio tracking
    
    Description:
        Checks if the unit's group name contains any of the exempt prefixes.
        Exempt groups don't have battery drain or triangulation.
    
    Parameters:
        0: OBJECT - Unit to check
        
    Returns:
        BOOL - True if group is exempt
*/

params ["_unit"];

if (isNil "RECONDO_RWR_SETTINGS") exitWith { false };

private _exemptGroups = RECONDO_RWR_SETTINGS get "exemptGroups";

if (count _exemptGroups == 0) exitWith { false };

private _groupId = groupId group _unit;
private _isExempt = false;

{
    if ([_x, _groupId] call BIS_fnc_inString) exitWith {
        _isExempt = true;
    };
} forEach _exemptGroups;

_isExempt
