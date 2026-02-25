/*
    Recondo_fnc_despawnVillageCivilians
    Despawn civilians for a village
    
    Description:
        Removes civilian units when players leave the village area.
        Saves their current state for when they respawn.
    
    Parameters:
        _markerName - STRING - Name of the village marker
    
    Returns:
        BOOL - True if successful
*/

params [["_markerName", "", [""]]];

// Only despawn on server
if (!isServer) exitWith { false };

if (_markerName == "") exitWith {
    diag_log "[RECONDO_CIVPOL] despawnVillageCivilians: Empty marker name";
    false
};

private _villageData = RECONDO_CIVPOL_VILLAGES getOrDefault [_markerName, createHashMap];
if (count keys _villageData == 0) exitWith {
    diag_log format ["[RECONDO_CIVPOL] despawnVillageCivilians: No village data for '%1'", _markerName];
    false
};

// Not spawned?
if !(_villageData getOrDefault ["spawned", false]) exitWith {
    true
};

private _debugLogging = RECONDO_CIVPOL_SETTINGS getOrDefault ["debugLogging", false];
private _spawnedUnits = _villageData getOrDefault ["spawnedUnits", []];

if (_debugLogging) then {
    diag_log format ["[RECONDO_CIVPOL] Despawning %1 civilians from village '%2'", count _spawnedUnits, _markerName];
};

// ========================================
// REMOVE NIGHT LIGHTS
// ========================================

private _activeLights = _villageData getOrDefault ["activeLights", []];
{
    if (!isNull _x) then {
        deleteVehicle _x;
    };
} forEach _activeLights;

// ========================================
// REMOVE WORK AREA PROPS
// ========================================

private _spawnedProps = _villageData getOrDefault ["spawnedProps", []];
{
    if (!isNull _x) then {
        deleteVehicle _x;
    };
} forEach _spawnedProps;

if (_debugLogging && count _spawnedProps > 0) then {
    diag_log format ["[RECONDO_CIVPOL] Deleted %1 work area props from village '%2'", count _spawnedProps, _markerName];
};

// ========================================
// DELETE CIVILIANS
// ========================================

private _homes = _villageData getOrDefault ["homes", []];

{
    private _civilian = _x;
    
    if (!isNull _civilian && alive _civilian) then {
        // Save state if needed (for persistence)
        private _index = _civilian getVariable ["RECONDO_CIVPOL_Index", -1];
        private _gaveDocuments = _civilian getVariable ["RECONDO_CIVPOL_GaveDocuments", false];
        
        // Update home data if civilian gave documents
        if (_index >= 0 && _gaveDocuments) then {
            private _homeData = _homes param [_index, []];
            if (count _homeData > 0) then {
                // Store that this civilian gave documents (persists)
                _homeData pushBack _gaveDocuments;
                _homes set [_index, _homeData];
            };
        };
        
        // Remove event handlers
        private _killedEH = _civilian getVariable ["RECONDO_CIVPOL_KilledEH", -1];
        if (_killedEH >= 0) then {
            _civilian removeEventHandler ["Killed", _killedEH];
        };
        
        private _firedNearEH = _civilian getVariable ["RECONDO_CIVPOL_FiredNearEH", -1];
        if (_firedNearEH >= 0) then {
            _civilian removeEventHandler ["FiredNear", _firedNearEH];
        };
        
        // Delete sleeping mat if exists
        private _sleepingMat = _civilian getVariable ["RECONDO_CIVPOL_SleepingMat", objNull];
        if (!isNull _sleepingMat) then {
            deleteVehicle _sleepingMat;
        };
        
        // Delete the civilian's group then the civilian
        private _group = group _civilian;
        deleteVehicle _civilian;
        
        if (!isNull _group && {count units _group == 0}) then {
            deleteGroup _group;
        };
    };
} forEach _spawnedUnits;

// ========================================
// UPDATE VILLAGE STATE
// ========================================

_villageData set ["spawned", false];
_villageData set ["spawnedUnits", []];
_villageData set ["activeLights", []];
_villageData set ["spawnedProps", []];
_villageData set ["homes", _homes]; // Update with any state changes
RECONDO_CIVPOL_VILLAGES set [_markerName, _villageData];

if (_debugLogging) then {
    diag_log format ["[RECONDO_CIVPOL] Village '%1': Despawned all civilians", _markerName];
};

true
