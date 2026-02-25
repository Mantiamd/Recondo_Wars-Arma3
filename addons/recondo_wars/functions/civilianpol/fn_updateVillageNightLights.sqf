/*
    Recondo_fnc_updateVillageNightLights
    Update night lights for all occupied homes in a village
    
    Description:
        Checks sunOrMoon and enables/disables lights in occupied buildings.
        Lights are on when it's dark outside (sunOrMoon < 0.5) and civilian is home.
        Automatically adapts to map latitude and mission date.
    
    Parameters:
        _markerName - STRING - Name of the village marker
    
    Returns:
        Nothing
*/

params [["_markerName", "", [""]]];

if (_markerName == "") exitWith {};

private _enableNightLights = RECONDO_CIVPOL_SETTINGS getOrDefault ["enableNightLights", true];
if (!_enableNightLights) exitWith {};

private _villageData = RECONDO_CIVPOL_VILLAGES getOrDefault [_markerName, createHashMap];
if (count keys _villageData == 0) exitWith {};

// Only update if village is spawned
if !(_villageData getOrDefault ["spawned", false]) exitWith {};

private _debugLogging = RECONDO_CIVPOL_SETTINGS getOrDefault ["debugLogging", false];
private _spawnedUnits = _villageData getOrDefault ["spawnedUnits", []];
private _activeLights = _villageData getOrDefault ["activeLights", []];

// ========================================
// DETERMINE IF LIGHTS SHOULD BE ON
// ========================================

// Use sunOrMoon for dynamic sunrise/sunset detection
// sunOrMoon < 0.5 means it's dark outside (night time)
private _shouldLightsBeOn = (sunOrMoon < 0.5);

// ========================================
// UPDATE LIGHTS FOR EACH CIVILIAN
// ========================================

{
    private _civilian = _x;
    
    if (!isNull _civilian && alive _civilian) then {
        private _building = _civilian getVariable ["RECONDO_CIVPOL_HomeBuilding", objNull];
        private _state = _civilian getVariable ["RECONDO_CIVPOL_State", "IDLE"];
        
        // Civilian should have light on if at home during dark hours
        private _isAtHome = (_state == "SLEEP") || (_civilian distance2D (_civilian getVariable ["RECONDO_CIVPOL_HomePos", [0,0,0]]) < 15);
        private _wantsLight = _shouldLightsBeOn && _isAtHome;
        
        if (!isNull _building) then {
            [_building, _wantsLight] call Recondo_fnc_setBuildingLight;
        };
    };
} forEach _spawnedUnits;
