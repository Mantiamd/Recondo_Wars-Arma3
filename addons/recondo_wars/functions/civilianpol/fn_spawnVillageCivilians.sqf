/*
    Recondo_fnc_spawnVillageCivilians
    Spawn civilians for a village
    
    Description:
        Creates civilian units at their home positions and starts their daily routine.
        Called when players enter the village spawn radius.
    
    Parameters:
        _markerName - STRING - Name of the village marker
    
    Returns:
        ARRAY - Array of spawned civilian units
*/

params [["_markerName", "", [""]]];

// Debug: Check if critical variables exist FIRST
diag_log format ["[RECONDO_CIVPOL] spawnVillageCivilians CALLED - marker: '%1', isServer: %2, SETTINGS exist: %3, VILLAGES exist: %4", 
    _markerName, 
    isServer, 
    !isNil "RECONDO_CIVPOL_SETTINGS",
    !isNil "RECONDO_CIVPOL_VILLAGES"
];

if (isNil "RECONDO_CIVPOL_SETTINGS" || isNil "RECONDO_CIVPOL_VILLAGES") exitWith {
    diag_log "[RECONDO_CIVPOL] spawnVillageCivilians: CRITICAL - Missing global variables!";
    []
};

// Only spawn on server
if (!isServer) exitWith { 
    diag_log "[RECONDO_CIVPOL] spawnVillageCivilians: Exiting - not server";
    [] 
};

if (_markerName == "") exitWith {
    diag_log "[RECONDO_CIVPOL] spawnVillageCivilians: Empty marker name";
    []
};

private _villageData = RECONDO_CIVPOL_VILLAGES getOrDefault [_markerName, createHashMap];
if (count keys _villageData == 0) exitWith {
    diag_log format ["[RECONDO_CIVPOL] spawnVillageCivilians: No village data for '%1'", _markerName];
    []
};

// Already spawned?
if (_villageData getOrDefault ["spawned", false]) exitWith {
    diag_log format ["[RECONDO_CIVPOL] spawnVillageCivilians: Village '%1' already spawned, skipping", _markerName];
    _villageData getOrDefault ["spawnedUnits", []]
};

private _debugLogging = RECONDO_CIVPOL_SETTINGS getOrDefault ["debugLogging", false];
private _unitClassnames = RECONDO_CIVPOL_SETTINGS getOrDefault ["unitClassnames", ["C_man_1"]];
private _enableNightLights = RECONDO_CIVPOL_SETTINGS getOrDefault ["enableNightLights", true];

// Props settings
private _fieldPropsCount = RECONDO_CIVPOL_SETTINGS getOrDefault ["fieldPropsCount", 4];
private _fishermanPropsCount = RECONDO_CIVPOL_SETTINGS getOrDefault ["fishermanPropsCount", 4];
private _fieldPropsClasses = RECONDO_CIVPOL_SETTINGS getOrDefault ["fieldPropsClasses", ["Land_WoodenCart_F"]];
private _fishermanPropsClasses = RECONDO_CIVPOL_SETTINGS getOrDefault ["fishermanPropsClasses", ["Land_FishingGear_01_F"]];
private _fieldsMarkers = RECONDO_CIVPOL_SETTINGS getOrDefault ["fieldsMarkers", []];
private _fishermanMarkers = RECONDO_CIVPOL_SETTINGS getOrDefault ["fishermanMarkers", []];
private _fieldWorkRadius = RECONDO_CIVPOL_SETTINGS getOrDefault ["fieldWorkRadius", 30];
private _fishermanWorkRadius = RECONDO_CIVPOL_SETTINGS getOrDefault ["fishermanWorkRadius", 20];

private _homes = _villageData getOrDefault ["homes", []];
private _spawnedUnits = [];
private _spawnedProps = [];

if (_debugLogging) then {
    diag_log format ["[RECONDO_CIVPOL] Spawning %1 civilians for village '%2'", count _homes, _markerName];
};

// ========================================
// SPAWN CIVILIANS
// ========================================

{
    _x params ["_homePos", "_job", "_building"];
    
    // Create civilian group
    private _group = createGroup [civilian, true];
    
    // Select random classname
    private _classname = selectRandom _unitClassnames;
    
    // Spawn at home position
    private _civilian = _group createUnit [_classname, _homePos, [], 0, "CAN_COLLIDE"];
    
    if (isNull _civilian) then {
        diag_log format ["[RECONDO_CIVPOL] WARNING: Failed to spawn civilian at %1", _homePos];
    } else {
        // Configure civilian
        _civilian disableAI "AUTOTARGET";
        _civilian disableAI "AUTOCOMBAT";
        _civilian setSkill 0.1;
        _civilian setBehaviour "CARELESS";
        _civilian setSpeedMode "LIMITED";
        
        // Store civilian data
        _civilian setVariable ["RECONDO_CIVPOL_VillageMarker", _markerName, true];
        _civilian setVariable ["RECONDO_CIVPOL_HomePos", _homePos, true];
        _civilian setVariable ["RECONDO_CIVPOL_HomeBuilding", _building, true];
        _civilian setVariable ["RECONDO_CIVPOL_Job", _job, true];
        _civilian setVariable ["RECONDO_CIVPOL_State", "IDLE", true];
        _civilian setVariable ["RECONDO_CIVPOL_GaveDocuments", false, true];
        _civilian setVariable ["RECONDO_CIVPOL_Index", _forEachIndex, true];
        
        // Add event handlers
        private _killedEH = _civilian addEventHandler ["Killed", {
            params ["_unit", "_killer"];
            [_unit] call Recondo_fnc_handleCivilianPOLKilled;
        }];
        _civilian setVariable ["RECONDO_CIVPOL_KilledEH", _killedEH];
        
        private _firedNearEH = _civilian addEventHandler ["FiredNear", {
            params ["_unit", "_firer", "_distance", "_weapon", "_muzzle", "_mode", "_ammo", "_gunner"];
            [_unit, _firer, _distance] call Recondo_fnc_handleCivilianPOLFiredNear;
        }];
        _civilian setVariable ["RECONDO_CIVPOL_FiredNearEH", _firedNearEH];
        
        _spawnedUnits pushBack _civilian;
        
        // Start daily routine behavior
        [_civilian] spawn Recondo_fnc_civilianDailyRoutine;
        
        if (_debugLogging) then {
            diag_log format ["[RECONDO_CIVPOL] Spawned %1 (%2) at home in %3", _classname, _job, _markerName];
        };
    };
} forEach _homes;

// ========================================
// SPAWN PROPS AT NEARBY JOB MARKERS
// ========================================

private _villageCenter = _villageData getOrDefault ["centerPos", [0,0,0]];

// Find nearby job markers (within 500m of village)
private _nearbyFieldsMarkers = _fieldsMarkers select { (_villageCenter distance2D (getMarkerPos _x)) < 500 };
private _nearbyFishermanMarkers = _fishermanMarkers select { (_villageCenter distance2D (getMarkerPos _x)) < 500 };

// Spawn field props
{
    private _jobMarker = _x;
    private _jobMarkerPos = getMarkerPos _jobMarker;
    private _jobMarkerSize = getMarkerSize _jobMarker;
    private _effectiveRadius = ((_jobMarkerSize select 0) max (_jobMarkerSize select 1)) max _fieldWorkRadius;
    
    for "_i" from 1 to _fieldPropsCount do {
        private _propClass = selectRandom _fieldPropsClasses;
        private _propPos = _jobMarkerPos getPos [random _effectiveRadius, random 360];
        private _propDir = random 360;
        
        // Create as simple object
        private _prop = createSimpleObject [_propClass, [0,0,0], true];
        _prop setDir _propDir;
        _prop setPosATL (_propPos vectorAdd [0, 0, 0]);  // Ground level
        
        _spawnedProps pushBack _prop;
    };
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_CIVPOL] Spawned %1 field props at %2", _fieldPropsCount, _jobMarker];
    };
} forEach _nearbyFieldsMarkers;

// Spawn fisherman props
{
    private _jobMarker = _x;
    private _jobMarkerPos = getMarkerPos _jobMarker;
    private _jobMarkerSize = getMarkerSize _jobMarker;
    private _effectiveRadius = ((_jobMarkerSize select 0) max (_jobMarkerSize select 1)) max _fishermanWorkRadius;
    
    for "_i" from 1 to _fishermanPropsCount do {
        private _propClass = selectRandom _fishermanPropsClasses;
        private _propPos = _jobMarkerPos getPos [random _effectiveRadius, random 360];
        private _propDir = random 360;
        
        // Create as simple object
        private _prop = createSimpleObject [_propClass, [0,0,0], true];
        _prop setDir _propDir;
        _prop setPosATL (_propPos vectorAdd [0, 0, 0]);  // Ground level
        
        _spawnedProps pushBack _prop;
    };
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_CIVPOL] Spawned %1 fisherman props at %2", _fishermanPropsCount, _jobMarker];
    };
} forEach _nearbyFishermanMarkers;

// ========================================
// UPDATE VILLAGE STATE
// ========================================

_villageData set ["spawned", true];
_villageData set ["spawnedUnits", _spawnedUnits];
_villageData set ["spawnedProps", _spawnedProps];
RECONDO_CIVPOL_VILLAGES set [_markerName, _villageData];

// ========================================
// UPDATE NIGHT LIGHTS IF NEEDED
// ========================================

if (_enableNightLights) then {
    [_markerName] call Recondo_fnc_updateVillageNightLights;
};

diag_log format ["[RECONDO_CIVPOL] Village '%1': Spawned %2 civilians, %3 props", _markerName, count _spawnedUnits, count _spawnedProps];

_spawnedUnits
