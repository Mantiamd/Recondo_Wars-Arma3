/*
    Recondo_fnc_moduleObjectiveDestroy
    Main initialization for Objective - Destroy module
    
    Description:
        Spawns destroyable objectives using compositions at invisible map markers.
        Integrates with Intel system for location reveals.
        Supports persistence across mission restarts.
    
    Parameters:
        _logic - Module logic object
        _units - Synchronized units (unused)
        _activated - Whether module is activated
*/

params ["_logic", "_units", "_activated"];

// Server-only initialization
if (!isServer) exitWith {};

// Validate activation
if (!_activated) exitWith {
    diag_log "[RECONDO_OBJDESTROY] Module not activated.";
};

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

private _objectiveName = _logic getVariable ["objectivename", "Weapons Cache"];
private _objectiveDesc = _logic getVariable ["objectivedesc", "A hidden cache containing enemy weapons and supplies."];
private _intelBoardCategoryName = _logic getVariable ["intelboardcategoryname", ""];
private _markerPrefix = _logic getVariable ["markerprefix", "CACHE_"];
private _spawnPercentage = _logic getVariable ["spawnpercentage", 0.5];

// Composition Pool (individual checkboxes)
private _compCache1 = _logic getVariable ["comp_cache1", false];
private _compCache2 = _logic getVariable ["comp_cache2", false];
private _compCache3 = _logic getVariable ["comp_cache3", false];
private _compCache4 = _logic getVariable ["comp_cache4", false];
private _compCache5 = _logic getVariable ["comp_cache5", false];
private _compAACache1 = _logic getVariable ["comp_aacache1", false];
private _compNVABivouac1 = _logic getVariable ["comp_nva_bivouac_1", false];
private _compNVAVCBivouac2 = _logic getVariable ["comp_nva_vc_bivouac_2", false];
private _compBivouac3 = _logic getVariable ["comp_bivouac_3", false];
private _compNVABivouac4 = _logic getVariable ["comp_nva_bivouac_4", false];
private _compNVABivouac5 = _logic getVariable ["comp_nva_bivouac_5", false];
private _compBivouac6 = _logic getVariable ["comp_bivouac_6", false];
private _compBivouac7 = _logic getVariable ["comp_bivouac_7", false];
private _compBivouac8 = _logic getVariable ["comp_bivouac_8", false];
private _compNVABivouac9 = _logic getVariable ["comp_nva_bivouac_9", false];
private _compBivouac10 = _logic getVariable ["comp_bivouac_10", false];
private _customCompPath = _logic getVariable ["customcomppath", "compositions"];
private _customActiveCompsRaw = _logic getVariable ["customactivecomps", ""];
private _customDestroyedCompsRaw = _logic getVariable ["customdestroyedcomps", ""];
private _clearRadius = _logic getVariable ["clearradius", 25];

private _targetClassname = _logic getVariable ["targetclassname", ""];
private _disableSimulation = _logic getVariable ["disablesimulation", true];

private _spawnMode = _logic getVariable ["spawnmode", 1];
private _triggerRadius = _logic getVariable ["triggerradius", 500];
private _triggerSideNum = _logic getVariable ["triggerside", 1];
private _simulationDistance = _logic getVariable ["simulationdistance", 1000];

private _sentryClassnamesRaw = _logic getVariable ["sentryclassnames", ""];
private _sentryMinCount = _logic getVariable ["sentrymincount", 2];
private _sentryMaxCount = _logic getVariable ["sentrymaxcount", 4];
private _sentrySideNum = _logic getVariable ["sentryside", 0];

private _patrolClassnamesRaw = _logic getVariable ["patrolclassnames", ""];
private _patrolCount = _logic getVariable ["patrolcount", 1];
private _patrolMinSize = _logic getVariable ["patrolminsize", 2];
private _patrolMaxSize = _logic getVariable ["patrolmaxsize", 4];
private _patrolRadius = _logic getVariable ["patrolradius", 50];
private _patrolFormation = _logic getVariable ["patrolformation", "WEDGE"];

private _intelWeight = _logic getVariable ["intelweight", 5];
private _intelRevealMessagesDocRaw = _logic getVariable ["intelrevealmessagesdoc", ""];
private _intelRevealMessagesPOWRaw = _logic getVariable ["intelrevealmessagespow", ""];

private _debugLogging = _logic getVariable ["debuglogging", false];
if (RECONDO_MASTER_DEBUG) then { _debugLogging = true; };
private _debugMarkers = _logic getVariable ["debugmarkers", false];

// Night Lights
private _enableNightLights = _logic getVariable ["enablenightlights", true];

// Smell Hints
private _enableSmellHints = _logic getVariable ["enablesmellhints", true];
private _smellHintRadius = _logic getVariable ["smellhintradius", 200];
private _smellHintMessagesRaw = _logic getVariable ["smellhintmessages", "The smell of oil and gunpowder hangs in the air...,A faint chemical odor drifts on the breeze...,You catch a whiff of ammunition and weapon lubricant...,Something metallic taints the air nearby."];

// ========================================
// PARSE CONFIGURATIONS
// ========================================

// Parse classnames
private _sentryClassnames = if (_sentryClassnamesRaw != "") then {
    [_sentryClassnamesRaw] call Recondo_fnc_parseClassnames
} else { [] };

private _patrolClassnames = if (_patrolClassnamesRaw != "") then {
    [_patrolClassnamesRaw] call Recondo_fnc_parseClassnames
} else { [] };

// ========================================
// BUILD COMPOSITION POOL
// ========================================
// Pool format: [activeComp, destroyedComp, isModPath]

private _compositionPool = [];

// Add mod compositions based on enabled checkboxes
if (_compCache1) then { _compositionPool pushBack ["Cache_1.sqe", "Cache_1_destroyed.sqe", true]; };
if (_compCache2) then { _compositionPool pushBack ["Cache_2.sqe", "Cache_2_destroyed.sqe", true]; };
if (_compCache3) then { _compositionPool pushBack ["Cache_3.sqe", "Cache_3_destroyed.sqe", true]; };
if (_compCache4) then { _compositionPool pushBack ["Cache_4.sqe", "Cache_4_destroyed.sqe", true]; };
if (_compCache5) then { _compositionPool pushBack ["Cache_5.sqe", "Cache_5_destroyed.sqe", true]; };
if (_compAACache1) then { _compositionPool pushBack ["AAcache1.sqe", "AAcache1_destroyed.sqe", true]; };
if (_compNVABivouac1) then { _compositionPool pushBack ["NVA_Bivouac_1.sqe", "Bivouac_destroyed.sqe", true]; };
if (_compNVAVCBivouac2) then { _compositionPool pushBack ["NVA_VC_Bivouac_2.sqe", "Bivouac_destroyed.sqe", true]; };
if (_compBivouac3) then { _compositionPool pushBack ["Bivouac_3.sqe", "Bivouac_destroyed.sqe", true]; };
if (_compNVABivouac4) then { _compositionPool pushBack ["NVA_Bivouac_4.sqe", "Bivouac_destroyed.sqe", true]; };
if (_compNVABivouac5) then { _compositionPool pushBack ["NVA_Bivouac_5.sqe", "Bivouac_destroyed.sqe", true]; };
if (_compBivouac6) then { _compositionPool pushBack ["Bivouac_6.sqe", "Bivouac_destroyed.sqe", true]; };
if (_compBivouac7) then { _compositionPool pushBack ["Bivouac_7.sqe", "Bivouac_destroyed.sqe", true]; };
if (_compBivouac8) then { _compositionPool pushBack ["Bivouac_8.sqe", "Bivouac_destroyed.sqe", true]; };
if (_compNVABivouac9) then { _compositionPool pushBack ["NVA_Bivouac_9.sqe", "Bivouac_destroyed.sqe", true]; };
if (_compBivouac10) then { _compositionPool pushBack ["Bivouac_10.sqe", "Bivouac_destroyed.sqe", true]; };

// Parse custom compositions from mission folder
private _customActiveComps = ((_customActiveCompsRaw splitString (toString [10, 13] + ",")) apply { _x trim [" ", 0] }) select { _x != "" && !(_x select [0, 2] == "//") };
private _customDestroyedComps = ((_customDestroyedCompsRaw splitString (toString [10, 13] + ",")) apply { _x trim [" ", 0] }) select { _x != "" && !(_x select [0, 2] == "//") };

// Add custom compositions to pool
{
    private _activeComp = _x;
    private _destroyedComp = if (_forEachIndex < count _customDestroyedComps) then {
        _customDestroyedComps select _forEachIndex
    } else {
        ""
    };
    _compositionPool pushBack [_activeComp, _destroyedComp, false]; // false = mission path
} forEach _customActiveComps;

// Validate composition pool
if (count _compositionPool == 0) exitWith {
    diag_log format ["[RECONDO_OBJDESTROY] ERROR: No compositions enabled for '%1'. Check at least one checkbox or add custom compositions.", _objectiveName];
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_OBJDESTROY] Composition pool built: %1 entries", count _compositionPool];
    diag_log format ["[RECONDO_OBJDESTROY] Pool contents: %1", _compositionPool];
};

// Parse smell hint messages
private _smellHintMessages = ((_smellHintMessagesRaw splitString ",") apply { _x trim [" ", 0] }) select { _x != "" };

// Parse intel reveal messages (split by newlines)
private _intelRevealMessagesDoc = ((_intelRevealMessagesDocRaw splitString (toString [10, 13])) apply { _x trim [" ", 0] }) select { _x != "" };
private _intelRevealMessagesPOW = ((_intelRevealMessagesPOWRaw splitString (toString [10, 13])) apply { _x trim [" ", 0] }) select { _x != "" };

// Convert sides
private _triggerSide = switch (_triggerSideNum) do {
    case 0: { "EAST" };
    case 1: { "WEST" };
    case 2: { "GUER" };
    case 3: { "ANY" };
    default { "WEST" };
};

private _sentrySide = switch (_sentrySideNum) do {
    case 0: { east };
    case 1: { west };
    case 2: { independent };
    default { east };
};

// ========================================
// VALIDATE SETTINGS
// ========================================

if (_targetClassname == "") then {
    diag_log format ["[RECONDO_OBJDESTROY] WARNING: No target classname specified for '%1'", _objectiveName];
};

// ========================================
// GENERATE UNIQUE INSTANCE ID
// ========================================

private _instanceId = format ["objdestroy_%1_%2", _objectiveName, count RECONDO_OBJDESTROY_INSTANCES];

// ========================================
// STORE SETTINGS
// ========================================

private _settings = createHashMapFromArray [
    ["instanceId", _instanceId],
    ["objectiveName", _objectiveName],
    ["objectiveDesc", _objectiveDesc],
    ["intelBoardCategoryName", _intelBoardCategoryName],
    ["markerPrefix", _markerPrefix],
    ["spawnPercentage", _spawnPercentage],
    ["compositionPool", _compositionPool],
    ["customCompPath", _customCompPath],
    ["clearRadius", _clearRadius],
    ["targetClassname", _targetClassname],
    ["disableSimulation", _disableSimulation],
    ["spawnMode", _spawnMode],
    ["triggerRadius", _triggerRadius],
    ["triggerSide", _triggerSide],
    ["simulationDistance", _simulationDistance],
    ["sentryClassnames", _sentryClassnames],
    ["sentryMinCount", _sentryMinCount],
    ["sentryMaxCount", _sentryMaxCount],
    ["sentrySide", _sentrySide],
    ["patrolClassnames", _patrolClassnames],
    ["patrolCount", _patrolCount],
    ["patrolMinSize", _patrolMinSize],
    ["patrolMaxSize", _patrolMaxSize],
    ["patrolRadius", _patrolRadius],
    ["patrolFormation", _patrolFormation],
    ["intelWeight", _intelWeight],
    ["intelRevealMessagesDoc", _intelRevealMessagesDoc],
    ["intelRevealMessagesPOW", _intelRevealMessagesPOW],
    ["debugLogging", _debugLogging],
    ["debugMarkers", _debugMarkers],
    ["enableNightLights", _enableNightLights],
    ["enableSmellHints", _enableSmellHints],
    ["smellHintRadius", _smellHintRadius],
    ["smellHintMessages", _smellHintMessages]
];

RECONDO_OBJDESTROY_INSTANCES pushBack _settings;
publicVariable "RECONDO_OBJDESTROY_INSTANCES";

// ========================================
// LOAD PERSISTENCE DATA
// ========================================

private _persistenceKey = format ["OBJDESTROY_%1_%2", _markerPrefix, _objectiveName];
private _savedActiveMarkers = [_persistenceKey + "_ACTIVE"] call Recondo_fnc_getSaveData;
private _savedDestroyedMarkers = [_persistenceKey + "_DESTROYED"] call Recondo_fnc_getSaveData;
private _savedCompositionMap = [_persistenceKey + "_COMPMAP"] call Recondo_fnc_getSaveData;

if (isNil "_savedActiveMarkers") then { _savedActiveMarkers = [] };
if (isNil "_savedDestroyedMarkers") then { _savedDestroyedMarkers = [] };
if (isNil "_savedCompositionMap") then { _savedCompositionMap = [] };

// Update global destroyed list
{
    if (!(_x in RECONDO_OBJDESTROY_DESTROYED)) then {
        RECONDO_OBJDESTROY_DESTROYED pushBack _x;
    };
} forEach _savedDestroyedMarkers;
publicVariable "RECONDO_OBJDESTROY_DESTROYED";

// ========================================
// SELECT OR LOAD MARKERS
// ========================================

private _selectedMarkers = [];
private _compositionMap = []; // [markerId, [activeComp, destroyedComp, isModPath]]

if (count _savedActiveMarkers > 0) then {
    // Use saved state
    _selectedMarkers = _savedActiveMarkers;
    _compositionMap = _savedCompositionMap;
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_OBJDESTROY] Loaded %1 saved markers for '%2'", count _selectedMarkers, _objectiveName];
    };
} else {
    // Fresh generation
    _selectedMarkers = [_markerPrefix, _spawnPercentage, _debugLogging] call Recondo_fnc_selectObjectiveMarkers;
    
    // Assign random compositions from pool to each marker
    // Each pool entry is [activeComp, destroyedComp, isModPath]
    {
        private _compData = selectRandom _compositionPool;
        _compositionMap pushBack [_x, _compData];
    } forEach _selectedMarkers;
    
    // Save to persistence
    [_persistenceKey + "_ACTIVE", _selectedMarkers] call Recondo_fnc_setSaveData;
    [_persistenceKey + "_COMPMAP", _compositionMap] call Recondo_fnc_setSaveData;
    [_persistenceKey + "_DESTROYED", []] call Recondo_fnc_setSaveData;
    saveMissionProfileNamespace;
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_OBJDESTROY] Generated %1 new markers for '%2'", count _selectedMarkers, _objectiveName];
    };
};

// ========================================
// CHECK SYNC TO INTEL MODULE
// ========================================

private _syncedModules = synchronizedObjects _logic;
private _linkedToIntel = false;

{
    if (typeOf _x == "Recondo_Module_Intel") exitWith {
        _linkedToIntel = true;
    };
} forEach _syncedModules;

// ========================================
// REGISTER ACTIVE OBJECTIVES WITH INTEL
// ========================================

if (_linkedToIntel) then {
    {
        private _markerId = _x;
        
        // Skip destroyed objectives
        if (_markerId in _savedDestroyedMarkers) then { continue };
        
        private _markerPos = getMarkerPos _markerId;
        private _targetId = format ["%1_%2", _instanceId, _markerId];
        
        // Register with Intel system
        [
            "objective",
            _targetId,
            _markerPos,
            createHashMapFromArray [
                ["name", _objectiveName],
                ["marker", _markerId],
                ["revealMessagesDoc", _intelRevealMessagesDoc],
                ["revealMessagesPOW", _intelRevealMessagesPOW]
            ],
            _intelWeight
        ] call Recondo_fnc_registerIntelTarget;
        
        if (_debugLogging) then {
            diag_log format ["[RECONDO_OBJDESTROY] Registered '%1' at %2 with Intel system (weight: %3)", _objectiveName, _markerId, _intelWeight];
        };
    } forEach _selectedMarkers;
    
    diag_log format ["[RECONDO_OBJDESTROY] Registered %1 '%2' objectives with Intel system", 
        count _selectedMarkers - count _savedDestroyedMarkers, _objectiveName];
};

// ========================================
// SPAWN OR CREATE TRIGGERS
// ========================================

{
    _x params ["_markerId", "_compData"];
    _compData params ["_activeComp", "_destroyedComp", "_isModPath"];
    
    private _isDestroyed = _markerId in _savedDestroyedMarkers;
    private _finalComposition = if (_isDestroyed && _destroyedComp != "") then {
        _destroyedComp
    } else {
        _activeComp
    };
    
    // Track active objective
    RECONDO_OBJDESTROY_ACTIVE pushBack [_instanceId, _markerId, _compData, if (_isDestroyed) then { "destroyed" } else { "active" }];
    
    if (_spawnMode == 0) then {
        // Immediate spawn
        [_settings, _markerId, _finalComposition, _isDestroyed, _isModPath] call Recondo_fnc_spawnObjective;
    } else {
        // Proximity trigger
        [_settings, _markerId, _compData, _isDestroyed] call Recondo_fnc_createObjectiveTrigger;
    };
    
    // Create debug markers
    if (_debugMarkers) then {
        private _markerPos = getMarkerPos _markerId;
        private _debugMarker = createMarker [format ["RECONDO_OBJ_DEBUG_%1", _markerId], _markerPos];
        _debugMarker setMarkerShape "ICON";
        _debugMarker setMarkerType "mil_objective";
        _debugMarker setMarkerColor (if (_isDestroyed) then { "ColorGrey" } else { "ColorRed" });
        _debugMarker setMarkerText format ["%1 - %2", _objectiveName, if (_isDestroyed) then { "DESTROYED" } else { "ACTIVE" }];
    };
} forEach _compositionMap;

publicVariable "RECONDO_OBJDESTROY_ACTIVE";

// ========================================
// CREATE SMELL TRIGGERS
// ========================================

if (_enableSmellHints) then {
    {
        _x params ["_markerId", "_composition"];
        
        // Only create smell triggers for active (not destroyed) objectives
        if !(_markerId in _savedDestroyedMarkers) then {
            [_settings, _markerId] call Recondo_fnc_createObjDestroySmellTrigger;
        };
    } forEach _compositionMap;
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_OBJDESTROY] Created smell triggers for %1 active objectives", count _selectedMarkers - count _savedDestroyedMarkers];
    };
};

// ========================================
// START NIGHT LIGHT LOOP
// ========================================

if (_enableNightLights && !RECONDO_OBJDESTROY_NIGHT_LIGHT_LOOP_STARTED) then {
    RECONDO_OBJDESTROY_NIGHT_LIGHTS_ENABLED = true;
    publicVariable "RECONDO_OBJDESTROY_NIGHT_LIGHTS_ENABLED";
    
    RECONDO_OBJDESTROY_NIGHT_LIGHT_LOOP_STARTED = true;
    [] call Recondo_fnc_updateObjDestroyNightLights;
    
    if (_debugLogging) then {
        diag_log "[RECONDO_OBJDESTROY] Night light update loop started";
    };
};

// ========================================
// LOG INITIALIZATION
// ========================================

private _activeCount = count _selectedMarkers - count _savedDestroyedMarkers;
diag_log format ["[RECONDO_OBJDESTROY] '%1' initialized: %2 active, %3 destroyed, Total: %4",
    _objectiveName, _activeCount, count _savedDestroyedMarkers, count _selectedMarkers];

if (_debugLogging) then {
    diag_log "[RECONDO_OBJDESTROY] === Objective Destroy Settings ===";
    diag_log format ["[RECONDO_OBJDESTROY] Instance ID: %1", _instanceId];
    diag_log format ["[RECONDO_OBJDESTROY] Marker Prefix: %1", _markerPrefix];
    diag_log format ["[RECONDO_OBJDESTROY] Composition Pool: %1 entries", count _compositionPool];
    diag_log format ["[RECONDO_OBJDESTROY] Spawn Mode: %1", if (_spawnMode == 0) then { "Immediate" } else { "Proximity" }];
    diag_log format ["[RECONDO_OBJDESTROY] Linked to Intel: %1", _linkedToIntel];
};
