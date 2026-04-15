/*
    Recondo_fnc_moduleObjectiveHubSubs
    Main initialization for Objective Hub & Subs module
    
    Description:
        Creates destroyable hub objectives with surrounding sub-site
        defensive positions. Sub-sites only spawn if their parent hub
        is active. When hub is destroyed, sub-sites persist for session
        but don't spawn on restart.
    
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
    diag_log "[RECONDO_HUBSUBS] Module not activated.";
};

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

// General
private _objectiveName = _logic getVariable ["objectivename", "Command Post"];
private _objectiveDescription = _logic getVariable ["objectivedescription", ""];
private _intelBoardCategoryName = _logic getVariable ["intelboardcategoryname", ""];
private _markerPrefix = _logic getVariable ["markerprefix", "HUB_"];
private _activePercentage = _logic getVariable ["activepercentage", 0.5];

// Hub Composition Pool (individual checkboxes)
private _compOneRow = _logic getVariable ["comp_one_row", false];
private _compTwoRows = _logic getVariable ["comp_two_rows", false];
private _compGatesTents = _logic getVariable ["comp_gates_tents", false];
private _compTwoHuts = _logic getVariable ["comp_two_huts", false];
private _compTower = _logic getVariable ["comp_tower", false];
private _compMapTents = _logic getVariable ["comp_map_tents", false];
private _compHVTBASE1 = _logic getVariable ["comp_hvtbase_1", false];
private _compHVTBASE2 = _logic getVariable ["comp_hvtbase_2", false];
private _compHVTBASE3 = _logic getVariable ["comp_hvtbase_3", false];
private _customCompPath = _logic getVariable ["customcomppath", "compositions"];
private _customActiveCompsRaw = _logic getVariable ["customactivecomps", ""];
private _customDestroyedCompsRaw = _logic getVariable ["customdestroyedcomps", ""];
private _clearRadius = _logic getVariable ["clearradius", 30];
private _disableSimulation = _logic getVariable ["disablesimulation", true];

// Hub Target
private _targetClassname = _logic getVariable ["targetclassname", ""];

// Hub Spawning
private _hubSpawnMode = _logic getVariable ["hubspawnmode", "proximity"];
private _hubTriggerRadius = _logic getVariable ["hubtriggerradius", 1500];
private _hubTriggerSide = _logic getVariable ["hubtriggerside", "WEST"];
private _simulationDistance = _logic getVariable ["simulationdistance", 1000];

// Hub AI
private _hubAISide = _logic getVariable ["hubaiside", "EAST"];
private _hubSentryClassnamesRaw = _logic getVariable ["hubsentryclassnames", ""];
private _hubSentryMin = _logic getVariable ["hubsentrymin", 2];
private _hubSentryMax = _logic getVariable ["hubsentrymax", 4];

// Security Patrol
private _securityPatrolCount = _logic getVariable ["securitypatrolcount", 1];
private _securityPatrolMin = _logic getVariable ["securitypatrolmin", 2];
private _securityPatrolMax = _logic getVariable ["securitypatrolmax", 4];
private _securityPatrolPauseMin = _logic getVariable ["securitypatrolpausemin", 30];
private _securityPatrolPauseMax = _logic getVariable ["securitypatrolpausemax", 60];
private _securityPatrolBehaviour = _logic getVariable ["securitypatrolbehaviour", "SAFE"];
private _securityPatrolSpeed = _logic getVariable ["securitypatrolspeed", "LIMITED"];
private _securityPatrolFormation = _logic getVariable ["securitypatrolformation", "STAG COLUMN"];

// Sub-Sites
private _enableSubSites = _logic getVariable ["enablesubsites", true];
private _subSiteMin = _logic getVariable ["subsitemin", 1];
private _subSiteMax = _logic getVariable ["subsitemax", 3];
private _subSiteClassnamesRaw = _logic getVariable ["subsiteclassnames", ""];
private _subSiteClearRadius = _logic getVariable ["subsiteclearradius", 15];
private _subSiteSpawnMode = _logic getVariable ["subsitespawnmode", "proximity"];
private _subSiteTriggerRadius = _logic getVariable ["subsitetriggerradius", 800];

// Sub-Site AI
private _subSiteAIClassnamesRaw = _logic getVariable ["subsiteaiclassnames", ""];
private _subSiteGarrisonMin = _logic getVariable ["subsitegarrisonmin", 2];
private _subSiteGarrisonMax = _logic getVariable ["subsitegarrisonmax", 4];
private _subSiteGarrisonRadius = _logic getVariable ["subsitegarrisonradius", 50];

// Intel
private _intelWeight = _logic getVariable ["intelweight", 0.5];
private _intelRevealMessagesDocRaw = _logic getVariable ["intelrevealmessagesdoc", ""];
private _intelRevealMessagesPOWRaw = _logic getVariable ["intelrevealmessagespow", ""];

// Debug
private _debugLogging = _logic getVariable ["debuglogging", false];
if (RECONDO_MASTER_DEBUG) then { _debugLogging = true; };
private _debugMarkers = _logic getVariable ["debugmarkers", false];

// Smell Hints
private _enableSmellHints = _logic getVariable ["enablesmellhints", true];
private _smellHintRadius = _logic getVariable ["smellhintradius", 200];
private _smellHintMessagesRaw = _logic getVariable ["smellhintmessages", "Wood smoke and the scent of a camp fire drift nearby...,The smell of cooked rice and fish sauce lingers in the air...,You catch a whiff of burning charcoal and tobacco...,Something cooking wafts on the breeze."];

// ========================================
// PARSE STRING INPUTS
// ========================================

private _fnc_parseClassnames = {
    params ["_raw"];
    ((_raw splitString (toString [10, 13] + ",")) apply { _x trim [" ", 0] }) select { _x != "" }
};

// ========================================
// BUILD COMPOSITION POOL
// ========================================
// Pool format: [activeComp, destroyedComp, isModPath]

private _compositionPool = [];

// Add mod compositions based on enabled checkboxes
if (_compOneRow) then { _compositionPool pushBack ["comp_one_row.sqe", "comp_one_row_destroyed.sqe", true]; };
if (_compTwoRows) then { _compositionPool pushBack ["comp_two_rows.sqe", "comp_two_rows_destroyed.sqe", true]; };
if (_compGatesTents) then { _compositionPool pushBack ["comp_gates_tents.sqe", "comp_gates_tents_destroyed.sqe", true]; };
if (_compTwoHuts) then { _compositionPool pushBack ["comp_two_huts.sqe", "comp_two_huts_destroyed.sqe", true]; };
if (_compTower) then { _compositionPool pushBack ["comp_tower.sqe", "comp_tower_destroyed.sqe", true]; };
if (_compMapTents) then { _compositionPool pushBack ["comp_map_tents.sqe", "comp_map_tents_destroyed.sqe", true]; };
if (_compHVTBASE1) then { _compositionPool pushBack ["HVTBASE_comp_1.sqe", "", true]; };
if (_compHVTBASE2) then { _compositionPool pushBack ["HVTBASE_comp_2.sqe", "", true]; };
if (_compHVTBASE3) then { _compositionPool pushBack ["HVTBASE_comp_3.sqe", "", true]; };

// Parse custom compositions from mission folder
private _customActiveComps = [_customActiveCompsRaw] call _fnc_parseClassnames;
private _customDestroyedComps = [_customDestroyedCompsRaw] call _fnc_parseClassnames;

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
    diag_log format ["[RECONDO_HUBSUBS] ERROR: No compositions enabled for '%1'. Check at least one checkbox or add custom compositions.", _objectiveName];
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_HUBSUBS] Composition pool built: %1 entries", count _compositionPool];
    diag_log format ["[RECONDO_HUBSUBS] Pool contents: %1", _compositionPool];
};

private _hubSentryClassnames = [_hubSentryClassnamesRaw] call _fnc_parseClassnames;
private _subSiteClassnames = [_subSiteClassnamesRaw] call _fnc_parseClassnames;
private _subSiteAIClassnames = [_subSiteAIClassnamesRaw] call _fnc_parseClassnames;

// Parse intel reveal messages (split by newlines)
private _intelRevealMessagesDoc = ((_intelRevealMessagesDocRaw splitString (toString [10, 13])) apply { _x trim [" ", 0] }) select { _x != "" };
private _intelRevealMessagesPOW = ((_intelRevealMessagesPOWRaw splitString (toString [10, 13])) apply { _x trim [" ", 0] }) select { _x != "" };

// Convert side strings
private _hubAISideEnum = switch (toUpper _hubAISide) do {
    case "EAST": { east };
    case "WEST": { west };
    case "GUER": { independent };
    default { east };
};

// ========================================
// GENERATE INSTANCE ID
// ========================================

private _instanceId = format ["hubsubs_%1_%2", _objectiveName, count RECONDO_HUBSUBS_INSTANCES];

// ========================================
// STORE SETTINGS
// ========================================

private _settings = createHashMapFromArray [
    ["instanceId", _instanceId],
    ["objectiveName", _objectiveName],
    ["objectiveDescription", _objectiveDescription],
    ["intelBoardCategoryName", _intelBoardCategoryName],
    ["markerPrefix", _markerPrefix],
    ["compositionPool", _compositionPool],
    ["customCompPath", _customCompPath],
    ["clearRadius", _clearRadius],
    ["disableSimulation", _disableSimulation],
    ["targetClassname", _targetClassname],
    ["hubSpawnMode", _hubSpawnMode],
    ["hubTriggerRadius", _hubTriggerRadius],
    ["hubTriggerSide", _hubTriggerSide],
    ["simulationDistance", _simulationDistance],
    ["hubAISide", _hubAISideEnum],
    ["hubSentryClassnames", _hubSentryClassnames],
    ["hubSentryMin", _hubSentryMin],
    ["hubSentryMax", _hubSentryMax],
    ["securityPatrolCount", _securityPatrolCount],
    ["securityPatrolMin", _securityPatrolMin],
    ["securityPatrolMax", _securityPatrolMax],
    ["securityPatrolPauseMin", _securityPatrolPauseMin],
    ["securityPatrolPauseMax", _securityPatrolPauseMax],
    ["securityPatrolBehaviour", _securityPatrolBehaviour],
    ["securityPatrolSpeed", _securityPatrolSpeed],
    ["securityPatrolFormation", _securityPatrolFormation],
    ["enableSubSites", _enableSubSites],
    ["subSiteMin", _subSiteMin],
    ["subSiteMax", _subSiteMax],
    ["subSiteClassnames", _subSiteClassnames],
    ["subSiteClearRadius", _subSiteClearRadius],
    ["subSiteSpawnMode", _subSiteSpawnMode],
    ["subSiteTriggerRadius", _subSiteTriggerRadius],
    ["subSiteAIClassnames", _subSiteAIClassnames],
    ["subSiteGarrisonMin", _subSiteGarrisonMin],
    ["subSiteGarrisonMax", _subSiteGarrisonMax],
    ["subSiteGarrisonRadius", _subSiteGarrisonRadius],
    ["intelWeight", _intelWeight],
    ["intelRevealMessagesDoc", _intelRevealMessagesDoc],
    ["intelRevealMessagesPOW", _intelRevealMessagesPOW],
    ["debugLogging", _debugLogging],
    ["debugMarkers", _debugMarkers],
    ["enableSmellHints", _enableSmellHints],
    ["smellHintRadius", _smellHintRadius],
    ["smellHintMessages", ((_smellHintMessagesRaw splitString ",") apply { _x trim [" ", 0] }) select { _x != "" }]
];

RECONDO_HUBSUBS_INSTANCES pushBack _settings;
publicVariable "RECONDO_HUBSUBS_INSTANCES";

// ========================================
// CHECK FOR INTEL MODULE SYNC
// ========================================

private _linkedToIntel = false;
{
    if (typeOf _x == "Recondo_Module_Intel") exitWith {
        _linkedToIntel = true;
    };
} forEach (synchronizedObjects _logic);

if (_debugLogging) then {
    diag_log format ["[RECONDO_HUBSUBS] Linked to Intel module: %1", _linkedToIntel];
};

// ========================================
// PERSISTENCE - LOAD SAVED DATA
// ========================================

private _persistenceKey = format ["HUBSUBS_%1", _objectiveName];
private _savedActiveMarkers = [_persistenceKey + "_ACTIVE"] call Recondo_fnc_getSaveData;
private _savedDestroyedMarkers = [_persistenceKey + "_DESTROYED"] call Recondo_fnc_getSaveData;
private _savedCompositionMap = [_persistenceKey + "_COMPMAP"] call Recondo_fnc_getSaveData;
private _savedSubSiteMap = [_persistenceKey + "_SUBSITEMAP"] call Recondo_fnc_getSaveData;

// ========================================
// SELECT HUB MARKERS
// ========================================

private _selectedMarkers = [];
private _compositionMap = createHashMap;
private _subSiteMap = createHashMap; // hubMarker -> [selectedSubSiteMarkers]

if (!isNil "_savedActiveMarkers" && {count _savedActiveMarkers > 0}) then {
    // Use saved markers
    _selectedMarkers = _savedActiveMarkers;
    _compositionMap = if (isNil "_savedCompositionMap") then { createHashMap } else { _savedCompositionMap };
    _subSiteMap = if (isNil "_savedSubSiteMap") then { createHashMap } else { _savedSubSiteMap };
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_HUBSUBS] Loaded %1 saved hub markers for '%2'", count _selectedMarkers, _objectiveName];
    };
} else {
    // Generate new markers
    _selectedMarkers = [_markerPrefix, _activePercentage, _debugLogging] call Recondo_fnc_selectHubMarkers;
    
    // Assign compositions and select sub-sites for each hub
    // Composition is stored as [activeComp, destroyedComp, isModPath]
    {
        private _hubMarker = _x;
        private _compData = selectRandom _compositionPool;
        _compositionMap set [_hubMarker, _compData];
        
        // Find and select sub-sites for this hub
        if (_enableSubSites && count _subSiteClassnames > 0) then {
            private _allSubSites = [_hubMarker] call Recondo_fnc_findSubSiteMarkers;
            
            // Select random number of sub-sites within min/max
            private _numSubSites = _subSiteMin + floor random ((_subSiteMax - _subSiteMin) + 1);
            _numSubSites = _numSubSites min (count _allSubSites);
            
            private _selectedSubSites = [];
            private _availableSubSites = +_allSubSites;
            
            for "_i" from 1 to _numSubSites do {
                if (count _availableSubSites > 0) then {
                    private _subSite = selectRandom _availableSubSites;
                    _availableSubSites = _availableSubSites - [_subSite];
                    _selectedSubSites pushBack _subSite;
                };
            };
            
            _subSiteMap set [_hubMarker, _selectedSubSites];
            
            if (_debugLogging) then {
                diag_log format ["[RECONDO_HUBSUBS] Hub %1: Selected %2 sub-sites: %3", _hubMarker, count _selectedSubSites, _selectedSubSites];
            };
        };
    } forEach _selectedMarkers;
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_HUBSUBS] Generated %1 new hub markers for '%2'", count _selectedMarkers, _objectiveName];
    };
    
    // Save to persistence
    [_persistenceKey + "_ACTIVE", _selectedMarkers] call Recondo_fnc_setSaveData;
    [_persistenceKey + "_COMPMAP", _compositionMap] call Recondo_fnc_setSaveData;
    [_persistenceKey + "_SUBSITEMAP", _subSiteMap] call Recondo_fnc_setSaveData;
    [_persistenceKey + "_DESTROYED", []] call Recondo_fnc_setSaveData;
};

// Load destroyed markers
private _destroyedMarkers = if (isNil "_savedDestroyedMarkers") then { [] } else { _savedDestroyedMarkers };
RECONDO_HUBSUBS_DESTROYED = RECONDO_HUBSUBS_DESTROYED + _destroyedMarkers;
publicVariable "RECONDO_HUBSUBS_DESTROYED";

// ========================================
// REGISTER WITH INTEL SYSTEM
// ========================================

if (_linkedToIntel) then {
    private _registeredCount = 0;
    {
        private _hubMarker = _x;
        
        // Skip destroyed hubs
        if (_hubMarker in _destroyedMarkers) then { continue };
        
        private _markerPos = getMarkerPos _hubMarker;
        private _targetId = format ["%1_%2", _instanceId, _hubMarker];
        
        // Register with Intel system
        [
            "objective",
            _targetId,
            _markerPos,
            createHashMapFromArray [
                ["name", _objectiveName],
                ["marker", _hubMarker],
                ["revealMessagesDoc", _intelRevealMessagesDoc],
                ["revealMessagesPOW", _intelRevealMessagesPOW]
            ],
            _intelWeight
        ] call Recondo_fnc_registerIntelTarget;
        
        _registeredCount = _registeredCount + 1;
        
        if (_debugLogging) then {
            diag_log format ["[RECONDO_HUBSUBS] Registered '%1' at %2 with Intel system (weight: %3)", _objectiveName, _hubMarker, _intelWeight];
        };
    } forEach _selectedMarkers;
    
    diag_log format ["[RECONDO_HUBSUBS] Registered %1 '%2' hubs with Intel system", _registeredCount, _objectiveName];
};

// ========================================
// TRACK ACTIVE HUBS
// ========================================

{
    private _hubMarker = _x;
    private _compData = _compositionMap getOrDefault [_hubMarker, selectRandom _compositionPool];
    private _subSiteMarkers = _subSiteMap getOrDefault [_hubMarker, []];
    private _isDestroyed = _hubMarker in _destroyedMarkers;
    
    RECONDO_HUBSUBS_ACTIVE pushBack [_instanceId, _hubMarker, _compData, _subSiteMarkers, _isDestroyed];
} forEach _selectedMarkers;
publicVariable "RECONDO_HUBSUBS_ACTIVE";

// ========================================
// SPAWN OR CREATE TRIGGERS
// ========================================

{
    private _hubMarker = _x;
    private _compData = _compositionMap getOrDefault [_hubMarker, selectRandom _compositionPool];
    _compData params ["_activeComp", "_destroyedComp", "_isModPath"];
    private _subSiteMarkers = _subSiteMap getOrDefault [_hubMarker, []];
    private _isDestroyed = _hubMarker in _destroyedMarkers;
    
    // Skip if hub is destroyed - sub-sites won't spawn
    if (_isDestroyed) then {
        if (_debugLogging) then {
            diag_log format ["[RECONDO_HUBSUBS] Skipping destroyed hub %1 and its sub-sites", _hubMarker];
        };
        continue;
    };
    
    private _markerPos = getMarkerPos _hubMarker;
    
    if (_hubSpawnMode == "immediate") then {
        // Spawn hub immediately
        [_settings, _hubMarker, _activeComp, false, _isModPath] call Recondo_fnc_spawnHub;
        
        // Spawn sub-sites immediately
        {
            private _subSiteMarker = _x;
            private _subSiteClass = selectRandom _subSiteClassnames;
            [_settings, _hubMarker, _subSiteMarker, _subSiteClass] call Recondo_fnc_spawnSubSite;
        } forEach _subSiteMarkers;
    } else {
        // Create proximity trigger for hub
        [_settings, _hubMarker, _compData, _subSiteMarkers] call Recondo_fnc_createHubTrigger;
        
        if (_debugLogging) then {
            diag_log format ["[RECONDO_HUBSUBS] Created trigger for hub %1 at %2, radius: %3m", _hubMarker, _markerPos, _hubTriggerRadius];
        };
        
        // Create separate triggers for sub-sites
        {
            private _subSiteMarker = _x;
            private _subSiteClass = selectRandom _subSiteClassnames;
            [_settings, _hubMarker, _subSiteMarker, _subSiteClass] call Recondo_fnc_createSubSiteTrigger;
            
            if (_debugLogging) then {
                private _subPos = getMarkerPos _subSiteMarker;
                diag_log format ["[RECONDO_HUBSUBS] Created trigger for sub-site %1 at %2, radius: %3m", _subSiteMarker, _subPos, _subSiteTriggerRadius];
            };
        } forEach _subSiteMarkers;
    };
    
    // Create debug markers
    if (_debugMarkers) then {
        private _debugName = format ["HUBSUBS_debug_%1", _hubMarker];
        private _debugMkr = createMarker [_debugName, _markerPos];
        _debugMkr setMarkerType "mil_objective";
        _debugMkr setMarkerColor "ColorRed";
        _debugMkr setMarkerText format ["HUB: %1", _objectiveName];
        
        // Sub-site debug markers
        {
            private _subPos = getMarkerPos _x;
            private _subDebugName = format ["HUBSUBS_sub_debug_%1", _x];
            private _subDebugMkr = createMarker [_subDebugName, _subPos];
            _subDebugMkr setMarkerType "mil_dot";
            _subDebugMkr setMarkerColor "ColorOrange";
            _subDebugMkr setMarkerText format ["SUB: %1", _x];
        } forEach _subSiteMarkers;
    };
} forEach _selectedMarkers;

// ========================================
// CREATE SMELL TRIGGERS
// ========================================

if (_enableSmellHints) then {
    {
        _x params ["_instanceId", "_hubMarker", "_compData", "_subSiteMarkers", "_isDestroyed"];
        
        // Only create smell triggers for active (not destroyed) hubs
        if (!_isDestroyed) then {
            [_settings, _hubMarker] call Recondo_fnc_createHubSubsSmellTrigger;
        };
    } forEach RECONDO_HUBSUBS_ACTIVE;
    
    if (_debugLogging) then {
        private _smellCount = {!(_x select 4)} count RECONDO_HUBSUBS_ACTIVE;
        diag_log format ["[RECONDO_HUBSUBS] Created smell triggers for %1 active hubs", _smellCount];
    };
};

// ========================================
// LOG INITIALIZATION
// ========================================

private _activeCount = {!(_x select 4)} count RECONDO_HUBSUBS_ACTIVE;
private _destroyedCount = count _destroyedMarkers;
private _totalCount = count _selectedMarkers;

diag_log format ["[RECONDO_HUBSUBS] '%1' initialized: %2 active, %3 destroyed, Total: %4", 
    _objectiveName, _activeCount, _destroyedCount, _totalCount];

if (_debugLogging) then {
    diag_log "[RECONDO_HUBSUBS] === Hub & Subs Module Settings ===";
    diag_log format ["[RECONDO_HUBSUBS] Instance ID: %1", _instanceId];
    diag_log format ["[RECONDO_HUBSUBS] Marker Prefix: %1", _markerPrefix];
    diag_log format ["[RECONDO_HUBSUBS] Composition Pool: %1 entries", count _compositionPool];
    diag_log format ["[RECONDO_HUBSUBS] Sub-Site Classnames: %1", _subSiteClassnames];
    diag_log format ["[RECONDO_HUBSUBS] Hub Spawn Mode: %1", _hubSpawnMode];
    diag_log format ["[RECONDO_HUBSUBS] Sub-Sites Enabled: %1", _enableSubSites];
    diag_log format ["[RECONDO_HUBSUBS] Linked to Intel: %1", _linkedToIntel];
};
