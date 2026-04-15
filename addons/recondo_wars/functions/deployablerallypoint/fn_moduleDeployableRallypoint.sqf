/*
    Recondo_fnc_moduleDeployableRallypoint
    Deployable Rally Point System - Server-side initialization
    
    Description:
        Reads module attributes, finds synced base objects, loads persistence,
        and broadcasts configuration to all clients for ACE interactions.
    
    Parameters:
        0: OBJECT - Logic module
        1: ARRAY - Synchronized units/objects (base teleporter objects)
        2: BOOL - Module activated
    
    Returns:
        Nothing
*/

params [["_logic", objNull, [objNull]], ["_units", [], [[]]], ["_activated", true, [true]]];

// Only run on server
if (!isServer) exitWith {};

// Check if module is activated
if (!_activated) exitWith {
    diag_log "[RECONDO_DRP] Module placed but not activated.";
};

// Check if already initialized (prevent multiple modules)
if (!isNil "RECONDO_DRP_INITIALIZED") exitWith {
    diag_log "[RECONDO_DRP] WARNING: Module already initialized. Only one Deployable Rallypoint module should be placed.";
};

RECONDO_DRP_INITIALIZED = true;

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

// General Settings
private _systemName = _logic getVariable ["systemname", "Deploy Rally Point"];
private _sideNum = _logic getVariable ["allowedside", 1];
private _baseMarkerName = _logic getVariable ["basemarkername", "base_marker"];

// Rally Object Settings
private _rallyObjectClass = _logic getVariable ["rallyobjectclass", "Land_TentDome_F"];
private _spawnDistance = _logic getVariable ["spawndistance", 5];

// Marker Settings
private _markerType = _logic getVariable ["markertype", "mil_start"];
private _markerColor = _logic getVariable ["markercolor", "ColorBlue"];
private _markerText = _logic getVariable ["markertext", "Rally Point"];

// Limits & Restrictions
private _maxRallies = _logic getVariable ["maxrallies", 3];
private _minDistanceFromBase = _logic getVariable ["mindistancefrombase", 150];
private _enemyProximity = _logic getVariable ["enemyproximity", 100];
private _destroyRemovesRally = _logic getVariable ["destroyremovesrally", false];

// Requirements
private _requireItemEnabled = _logic getVariable ["requireitemenabled", true];
private _requiredItem = _logic getVariable ["requireditem", "ACRE_PRC77"];
private _requiredItemName = _logic getVariable ["requireditemname", "PRC-77 Radio"];

// Teleport Settings
private _autoRespawnToRally = _logic getVariable ["autorespawntorally", false];

// UI Text
private _deployHint = _logic getVariable ["deployhint", "Rally point deployed!"];
private _undeployHint = _logic getVariable ["undeployhint", "Rally point undeployed!"];
private _packActionText = _logic getVariable ["packactiontext", "Pack Rally Point"];
private _selectActionText = _logic getVariable ["selectactiontext", "Select Rally Point"];
private _replacedHint = _logic getVariable ["replacedhint", "Oldest rally point replaced."];

// Persistence
private _enablePersistence = _logic getVariable ["enablepersistence", true];

// Debug
private _enableDebug = _logic getVariable ["enabledebug", false];
if (RECONDO_MASTER_DEBUG) then { _enableDebug = true; };
private _enableDebugMarkers = _logic getVariable ["enabledebugmarkers", false];

// ========================================
// CONVERT SIDE NUMBER TO SIDE
// ========================================

private _allowedSide = switch (_sideNum) do {
    case 0: { east };
    case 1: { west };
    case 2: { independent };
    case 3: { civilian };
    case 4: { nil };  // Any side
    default { west };
};

// ========================================
// FIND SYNCED BASE TELEPORTER OBJECTS
// ========================================

private _syncedObjects = synchronizedObjects _logic;
private _baseObjects = _syncedObjects select { !(_x isKindOf "Logic") };

if (count _baseObjects == 0) exitWith {
    diag_log "[RECONDO_DRP] ERROR: No objects synced to module! Sync at least one object (flag, table, etc.) to act as base teleporter.";
};

if (_enableDebug) then {
    diag_log format ["[RECONDO_DRP] Found %1 synced base teleporter objects", count _baseObjects];
};

// ========================================
// STORE SETTINGS IN HASHMAP
// ========================================

private _settings = createHashMapFromArray [
    ["systemName", _systemName],
    ["allowedSideNum", _sideNum],
    ["baseMarkerName", _baseMarkerName],
    ["rallyObjectClass", _rallyObjectClass],
    ["spawnDistance", _spawnDistance],
    ["markerType", _markerType],
    ["markerColor", _markerColor],
    ["markerText", _markerText],
    ["maxRallies", _maxRallies],
    ["minDistanceFromBase", _minDistanceFromBase],
    ["enemyProximity", _enemyProximity],
    ["destroyRemovesRally", _destroyRemovesRally],
    ["requireItemEnabled", _requireItemEnabled],
    ["requiredItem", _requiredItem],
    ["requiredItemName", _requiredItemName],
    ["autoRespawnToRally", _autoRespawnToRally],
    ["deployHint", _deployHint],
    ["undeployHint", _undeployHint],
    ["packActionText", _packActionText],
    ["selectActionText", _selectActionText],
    ["replacedHint", _replacedHint],
    ["enablePersistence", _enablePersistence],
    ["enableDebug", _enableDebug],
    ["enableDebugMarkers", _enableDebugMarkers]
];

RECONDO_DRP_SETTINGS = _settings;

// ========================================
// STORE BASE OBJECTS (using netIds for JIP)
// ========================================

{
    private _baseData = createHashMapFromArray [
        ["netId", netId _x],
        ["position", getPosATL _x]
    ];
    
    RECONDO_DRP_BASE_OBJECTS pushBack _baseData;
    
    // Store settings on object for client reference
    _x setVariable ["RECONDO_DRP_IS_BASE", true, true];
    
    if (_enableDebug) then {
        diag_log format ["[RECONDO_DRP] Registered base teleporter: %1 at %2 (netId: %3)", typeOf _x, getPosATL _x, netId _x];
    };
} forEach _baseObjects;

// ========================================
// LOAD PERSISTENCE OR START FRESH
// ========================================

if (_enablePersistence) then {
    [] call Recondo_fnc_loadRallypoints;
} else {
    RECONDO_DRP_RALLIES = [];
};

// ========================================
// BROADCAST TO CLIENTS
// ========================================

publicVariable "RECONDO_DRP_SETTINGS";
publicVariable "RECONDO_DRP_RALLIES";
publicVariable "RECONDO_DRP_BASE_OBJECTS";
publicVariable "RECONDO_DRP_INITIALIZED";

// ========================================
// LOG INITIALIZATION
// ========================================

diag_log format ["[RECONDO_DRP] Initialized: %1 base teleporters, max %2 rallies per side", count _baseObjects, _maxRallies];

// Always log key settings to help diagnose issues
diag_log format ["[RECONDO_DRP] Item Requirement: enabled=%1, item='%2', name='%3'", _requireItemEnabled, _requiredItem, _requiredItemName];
diag_log format ["[RECONDO_DRP] Allowed Side: %1 (sideNum: %2)", _allowedSide, _sideNum];
diag_log format ["[RECONDO_DRP] Debug Mode: %1", _enableDebug];

if (_enableDebug) then {
    diag_log "[RECONDO_DRP] === Full Module Settings ===";
    diag_log format ["[RECONDO_DRP] System Name: %1", _systemName];
    diag_log format ["[RECONDO_DRP] Base Marker: %1", _baseMarkerName];
    diag_log format ["[RECONDO_DRP] Rally Object: %1", _rallyObjectClass];
    diag_log format ["[RECONDO_DRP] Max Rallies: %1", _maxRallies];
    diag_log format ["[RECONDO_DRP] Min Distance from Base: %1m", _minDistanceFromBase];
    diag_log format ["[RECONDO_DRP] Enemy Proximity: %1m", _enemyProximity];
    diag_log format ["[RECONDO_DRP] Persistence: %1", _enablePersistence];
};
