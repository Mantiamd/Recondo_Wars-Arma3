/*
    Recondo_fnc_handleCivilianPOLKilled
    Handle civilian death event
    
    Parameters:
        _unit - OBJECT - The killed civilian
    
    Returns:
        Nothing
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit) exitWith {};

private _debugLogging = RECONDO_CIVPOL_SETTINGS getOrDefault ["debugLogging", false];
private _markerName = _unit getVariable ["RECONDO_CIVPOL_VillageMarker", ""];

if (_debugLogging) then {
    private _job = _unit getVariable ["RECONDO_CIVPOL_Job", "Unknown"];
    diag_log format ["[RECONDO_CIVPOL] Civilian (%1) killed in village '%2'", _job, _markerName];
};

// Delete sleeping mat if exists
private _sleepingMat = _unit getVariable ["RECONDO_CIVPOL_SleepingMat", objNull];
if (!isNull _sleepingMat) then {
    deleteVehicle _sleepingMat;
};

// Remove from spawned units list
if (_markerName != "") then {
    private _villageData = RECONDO_CIVPOL_VILLAGES getOrDefault [_markerName, createHashMap];
    private _spawnedUnits = _villageData getOrDefault ["spawnedUnits", []];
    
    _spawnedUnits = _spawnedUnits - [_unit];
    _villageData set ["spawnedUnits", _spawnedUnits];
    
    RECONDO_CIVPOL_VILLAGES set [_markerName, _villageData];
};

// Delete body after delay
[{
    params ["_unit"];
    if (!isNull _unit) then {
        deleteVehicle _unit;
    };
}, [_unit], 300] call CBA_fnc_waitAndExecute; // 5 minute delay
