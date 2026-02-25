/*
    Recondo_fnc_createVillageTrigger
    Create proximity trigger for spawning/despawning village civilians
    
    Description:
        Creates a trigger that spawns civilians when players enter
        and despawns them when players leave. Runs on server only.
    
    Parameters:
        _markerName - STRING - Name of the village marker
    
    Returns:
        OBJECT - The created trigger
*/

params [["_markerName", "", [""]]];

if (_markerName == "") exitWith {
    diag_log "[RECONDO_CIVPOL] createVillageTrigger: Empty marker name";
    objNull
};

private _villageData = RECONDO_CIVPOL_VILLAGES getOrDefault [_markerName, createHashMap];
if (count keys _villageData == 0) exitWith {
    diag_log format ["[RECONDO_CIVPOL] createVillageTrigger: No village data for '%1'", _markerName];
    objNull
};

private _debugLogging = RECONDO_CIVPOL_SETTINGS getOrDefault ["debugLogging", false];
private _spawnDistance = RECONDO_CIVPOL_SETTINGS get "spawnDistance";
private _despawnDistance = RECONDO_CIVPOL_SETTINGS get "despawnDistance";
private _triggerSide = RECONDO_CIVPOL_SETTINGS get "triggerSide";

private _villageCenter = _villageData get "centerPos";

// ========================================
// CREATE SPAWN TRIGGER
// ========================================

private _spawnTrigger = createTrigger ["EmptyDetector", _villageCenter, false];
_spawnTrigger setTriggerArea [_spawnDistance, _spawnDistance, 0, false];

// Set trigger activation based on configured side
private _activationSide = switch (toUpper _triggerSide) do {
    case "WEST": { "WEST" };
    case "EAST": { "EAST" };
    case "GUER"; 
    case "INDEPENDENT": { "GUER" };
    case "CIV": { "CIV" };
    default { "ANYPLAYER" };
};

_spawnTrigger setTriggerActivation [_activationSide, "PRESENT", true];

// Store marker name on trigger for reference
_spawnTrigger setVariable ["RECONDO_CIVPOL_MarkerName", _markerName];

// Spawn condition and statement
_spawnTrigger setTriggerStatements [
    // Condition - check if not already spawned
    "this && !((thisTrigger getVariable ['RECONDO_CIVPOL_MarkerName', '']) call Recondo_fnc_isVillageSpawned)",
    
    // On activation - spawn civilians (simplified - direct call)
    "private _marker = thisTrigger getVariable ['RECONDO_CIVPOL_MarkerName', '']; diag_log format ['[RECONDO_CIVPOL] TRIGGER FIRED for: %1', _marker]; private _result = [_marker] call Recondo_fnc_spawnVillageCivilians; diag_log format ['[RECONDO_CIVPOL] Spawn returned: %1 units', count _result]",
    
    // On deactivation - do nothing here (handled by despawn trigger)
    ""
];

// ========================================
// CREATE DESPAWN TRIGGER
// ========================================

private _despawnTrigger = createTrigger ["EmptyDetector", _villageCenter, false];
_despawnTrigger setTriggerArea [_despawnDistance, _despawnDistance, 0, false];
_despawnTrigger setTriggerActivation [_activationSide, "NOT PRESENT", true];

_despawnTrigger setVariable ["RECONDO_CIVPOL_MarkerName", _markerName];

_despawnTrigger setTriggerStatements [
    // Condition - check if currently spawned
    "this && ((thisTrigger getVariable ['RECONDO_CIVPOL_MarkerName', '']) call Recondo_fnc_isVillageSpawned)",
    
    // On activation - despawn civilians
    "[thisTrigger getVariable 'RECONDO_CIVPOL_MarkerName'] call Recondo_fnc_despawnVillageCivilians",
    
    // On deactivation - do nothing
    ""
];

// Store triggers in village data
_villageData set ["spawnTrigger", _spawnTrigger];
_villageData set ["despawnTrigger", _despawnTrigger];
RECONDO_CIVPOL_VILLAGES set [_markerName, _villageData];

if (_debugLogging) then {
    diag_log format ["[RECONDO_CIVPOL] Created triggers for '%1' - Spawn: %2m, Despawn: %3m", 
        _markerName, _spawnDistance, _despawnDistance];
};

_spawnTrigger
