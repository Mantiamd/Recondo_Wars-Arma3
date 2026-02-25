/*
    Recondo_fnc_initVillage
    Initialize a village with homes and spawn trigger
    
    Description:
        For a given village marker, finds buildings, assigns homes to civilians,
        determines jobs based on nearby job markers, and creates spawn trigger.
    
    Parameters:
        _markerName - STRING - Name of the village marker
    
    Returns:
        BOOL - True if successful
*/

params [["_markerName", "", [""]]];

if (_markerName == "") exitWith {
    diag_log "[RECONDO_CIVPOL] initVillage: Empty marker name";
    false
};

private _debugLogging = RECONDO_CIVPOL_SETTINGS getOrDefault ["debugLogging", false];
private _debugMarkers = RECONDO_CIVPOL_SETTINGS getOrDefault ["debugMarkers", false];
private _civiliansPerVillage = RECONDO_CIVPOL_SETTINGS get "civiliansPerVillage";
private _homeSearchRadius = RECONDO_CIVPOL_SETTINGS get "homeSearchRadius";

// Get village center from marker
private _villageCenter = getMarkerPos _markerName;
if (_villageCenter isEqualTo [0,0,0]) exitWith {
    diag_log format ["[RECONDO_CIVPOL] initVillage: Invalid marker position for '%1'", _markerName];
    false
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_CIVPOL] Initializing village: %1 at %2", _markerName, _villageCenter];
};

// ========================================
// CHECK FOR EXISTING PERSISTENCE DATA
// ========================================

private _existingData = RECONDO_CIVPOL_VILLAGES getOrDefault [_markerName, createHashMap];
private _existingHomes = _existingData getOrDefault ["homes", []];

// ========================================
// FIND HOMES IF NOT PERSISTED
// ========================================

private _homes = [];

if (count _existingHomes > 0) then {
    // Restore from persistence - need to re-find building objects
    {
        _x params ["_homePos", "_job"];
        
        // Find the building at this position
        private _nearBuildings = nearestObjects [_homePos, ["House"], 10];
        private _building = if (count _nearBuildings > 0) then { _nearBuildings select 0 } else { objNull };
        
        _homes pushBack [_homePos, _job, _building];
    } forEach _existingHomes;
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_CIVPOL] %1: Restored %2 homes from persistence", _markerName, count _homes];
    };
} else {
    // Find new homes
    _homes = [_villageCenter, _homeSearchRadius, _civiliansPerVillage, _markerName] call Recondo_fnc_findHomePositions;
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_CIVPOL] %1: Found %2 homes", _markerName, count _homes];
    };
};

// Validate we have homes
if (count _homes == 0) then {
    diag_log format ["[RECONDO_CIVPOL] WARNING: No valid homes found for village '%1'", _markerName];
};

// ========================================
// STORE VILLAGE DATA
// ========================================

private _villageData = createHashMapFromArray [
    ["markerName", _markerName],
    ["centerPos", _villageCenter],
    ["homes", _homes],
    ["spawned", false],
    ["spawnedUnits", []],
    ["activeLights", []]
];

RECONDO_CIVPOL_VILLAGES set [_markerName, _villageData];

// ========================================
// CREATE DEBUG MARKERS
// ========================================

if (_debugMarkers) then {
    // Village center marker
    private _centerMarker = createMarker [format ["RECONDO_CIVPOL_CENTER_%1", _markerName], _villageCenter];
    _centerMarker setMarkerShape "ICON";
    _centerMarker setMarkerType "mil_dot";
    _centerMarker setMarkerColor "ColorCIV";
    _centerMarker setMarkerText format ["POL: %1", _markerName];
    
    // Home markers
    {
        _x params ["_homePos", "_job", "_building"];
        
        private _homeMarker = createMarker [format ["RECONDO_CIVPOL_HOME_%1_%2", _markerName, _forEachIndex], _homePos];
        _homeMarker setMarkerShape "ICON";
        _homeMarker setMarkerType "mil_box";
        _homeMarker setMarkerColor (if (_job == "Fisherman") then { "ColorBlue" } else { "ColorGreen" });
        _homeMarker setMarkerText _job;
        _homeMarker setMarkerSize [0.5, 0.5];
    } forEach _homes;
};

// ========================================
// CREATE SPAWN TRIGGER
// ========================================

[_markerName] call Recondo_fnc_createVillageTrigger;

if (_debugLogging) then {
    diag_log format ["[RECONDO_CIVPOL] Village '%1' initialized with %2 civilians", _markerName, count _homes];
};

true
