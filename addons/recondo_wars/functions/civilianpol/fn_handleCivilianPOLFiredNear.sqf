/*
    Recondo_fnc_handleCivilianPOLFiredNear
    Handle gunfire near civilian - triggers flee behavior
    
    Parameters:
        _unit - OBJECT - The civilian
        _firer - OBJECT - Who fired
        _distance - NUMBER - Distance to the shot
    
    Returns:
        Nothing
*/

params [
    ["_unit", objNull, [objNull]],
    ["_firer", objNull, [objNull]],
    ["_distance", 0, [0]]
];

if (isNull _unit) exitWith {};

// Check if flee on combat is enabled
private _fleeOnCombat = RECONDO_CIVPOL_SETTINGS getOrDefault ["fleeOnCombat", true];
if (!_fleeOnCombat) exitWith {};

// Check distance threshold
private _combatDetectRadius = RECONDO_CIVPOL_SETTINGS getOrDefault ["combatDetectRadius", 150];
if (_distance > _combatDetectRadius) exitWith {};

// Already fleeing?
if (_unit getVariable ["RECONDO_CIVPOL_Fleeing", false]) exitWith {};

// Set fleeing flag
_unit setVariable ["RECONDO_CIVPOL_Fleeing", true, true];

private _debugLogging = RECONDO_CIVPOL_SETTINGS getOrDefault ["debugLogging", false];
if (_debugLogging) then {
    private _markerName = _unit getVariable ["RECONDO_CIVPOL_VillageMarker", ""];
    diag_log format ["[RECONDO_CIVPOL] Civilian fleeing - gunfire at %1m in %2", round _distance, _markerName];
};
