/*
    Recondo_fnc_isSurvGroupExempt
    Check if a unit's group is exempt from Survival Radio tracking

    Description:
        Checks if the unit's group name contains any of the module's
        exempt prefixes. Exempt groups never trigger triangulation.

    Parameters:
        0: OBJECT - Unit to check

    Returns:
        BOOL - True if group is exempt
*/

params ["_unit"];

if (isNil "RECONDO_SURV_SETTINGS") exitWith { false };

private _exemptGroups = RECONDO_SURV_SETTINGS get "exemptGroups";

if (count _exemptGroups == 0) exitWith { false };

private _groupId = groupId group _unit;
private _isExempt = false;

{
    if ([_x, _groupId] call BIS_fnc_inString) exitWith {
        _isExempt = true;
    };
} forEach _exemptGroups;

_isExempt
