/*
    Recondo_fnc_moduleObjectiveJammer
    Main initialization for Objective - Jamming ACRE module
    
    Description:
        Spawns ACRE radio jamming objectives using compositions at invisible map markers.
        When the jammer object is destroyed, jamming stops and the objective is marked complete.
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
    diag_log "[RECONDO_JAMMER] Module not activated.";
};

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

// General
private _objectiveName = _logic getVariable ["objectivename", "Radio Jammer"];
private _objectiveDesc = _logic getVariable ["objectivedesc", "An enemy radio jamming station disrupting communications."];
private _intelBoardCategoryName = _logic getVariable ["intelboardcategoryname", ""];
private _markerPrefix = _logic getVariable ["markerprefix", "JAMMER_"];
private _activeLocationCount = _logic getVariable ["activelocationcount", 1];

// Default Compositions (Mod-bundled)
private _useTowerComp = _logic getVariable ["usetowercomp", true];
private _useCampComp = _logic getVariable ["usecampcomp", true];
private _clearRadius = _logic getVariable ["clearradius", 25];
private _disableSimulation = _logic getVariable ["disablesimulation", true];

// Custom Compositions (Mission folder)
private _customCompPath = _logic getVariable ["customcomppath", "compositions"];
private _customActiveCompsRaw = _logic getVariable ["customactivecomps", ""];
private _customDestroyedCompsRaw = _logic getVariable ["customdestroyedcomps", ""];

// Jammer Settings
private _jammerClassname = _logic getVariable ["jammerclassname", "Land_TTowerBig_1_F"];
private _partialJamRadius = _logic getVariable ["partialjamradius", 1000];
private _fullJamRadius = _logic getVariable ["fulljamradius", 800];
private _jamStrength = _logic getVariable ["jamstrength", 49];
private _sideToJamNum = _logic getVariable ["sidetojam", 1];

// Spawning
private _spawnMode = _logic getVariable ["spawnmode", 1];
private _compositionTriggerRadius = _logic getVariable ["compositiontriggerradius", 800];
private _aiTriggerRadius = _logic getVariable ["aitriggerradius", 600];
private _triggerSideNum = _logic getVariable ["triggerside", 1];
private _simulationDistance = _logic getVariable ["simulationdistance", 1000];

// Sentry AI
private _sentryClassnamesRaw = _logic getVariable ["sentryclassnames", ""];
private _sentryMinCount = _logic getVariable ["sentrymincount", 2];
private _sentryMaxCount = _logic getVariable ["sentrymaxcount", 4];
private _sentryBuildingRadius = _logic getVariable ["sentrybuildingradius", 50];
private _sentrySideNum = _logic getVariable ["sentryside", 0];

// Patrol AI
private _patrolClassnamesRaw = _logic getVariable ["patrolclassnames", ""];
private _patrolCount = _logic getVariable ["patrolcount", 1];
private _patrolMinSize = _logic getVariable ["patrolminsize", 2];
private _patrolMaxSize = _logic getVariable ["patrolmaxsize", 4];
private _patrolRadius = _logic getVariable ["patrolradius", 75];
private _patrolFormation = _logic getVariable ["patrolformation", "WEDGE"];

// Intel
private _intelWeight = _logic getVariable ["intelweight", 5];
private _intelRevealMessagesDocRaw = _logic getVariable ["intelrevealmessagesdoc", ""];
private _intelRevealMessagesPOWRaw = _logic getVariable ["intelrevealmessagespow", ""];

// Debug
private _debugLogging = _logic getVariable ["debuglogging", false];
if (RECONDO_MASTER_DEBUG) then { _debugLogging = true; };
private _debugMarkers = _logic getVariable ["debugmarkers", false];

// Night Lights
private _enableNightLights = _logic getVariable ["enablenightlights", true];

// Smell Hints
private _enableSmellHints = _logic getVariable ["enablesmellhints", true];
private _smellHintRadius = _logic getVariable ["smellhintradius", 200];
private _smellHintMessagesRaw = _logic getVariable ["smellhintmessages", "You sense a low electricity hum in the air...,A faint buzzing fills your ears...,Static crackles at the edge of your hearing...,The air feels charged with electromagnetic energy."];

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

// Parse intel reveal messages (split by newlines)
private _intelRevealMessagesDoc = ((_intelRevealMessagesDocRaw splitString (toString [10, 13])) apply { _x trim [" ", 0] }) select { _x != "" };
private _intelRevealMessagesPOW = ((_intelRevealMessagesPOWRaw splitString (toString [10, 13])) apply { _x trim [" ", 0] }) select { _x != "" };

// ========================================
// BUILD COMPOSITION POOL
// ========================================
// Pool format: [activeComposition, destroyedComposition, isModPath]

private _compositionPool = [];

// Add default (mod-bundled) compositions based on checkboxes
if (_useTowerComp) then {
    _compositionPool pushBack ["JAMMER_TOWER1.sqe", "JAMMER_TOWER1_destroyed.sqe", true];
};

if (_useCampComp) then {
    _compositionPool pushBack ["JAMMER_Camp1.sqe", "JAMMER_Camp1_destroyed.sqe", true];
};

// Parse and add custom compositions from mission folder
private _customActiveComps = ((_customActiveCompsRaw splitString (toString [10, 13] + ",")) apply { _x trim [" ", 0] }) select { _x != "" && !(_x select [0, 2] == "//") };
private _customDestroyedComps = ((_customDestroyedCompsRaw splitString (toString [10, 13] + ",")) apply { _x trim [" ", 0] }) select { _x != "" && !(_x select [0, 2] == "//") };

// Add custom compositions to pool
{
    private _activeComp = _x;
    private _destroyedComp = "";
    
    // Try to get matching destroyed composition from list
    if (_forEachIndex < count _customDestroyedComps) then {
        _destroyedComp = _customDestroyedComps select _forEachIndex;
    } else {
        // Auto-generate destroyed name by adding _destroyed before .sqe
        private _baseName = _activeComp select [0, count _activeComp - 4]; // Remove .sqe
        _destroyedComp = _baseName + "_destroyed.sqe";
    };
    
    _compositionPool pushBack [_activeComp, _destroyedComp, false]; // false = mission path
} forEach _customActiveComps;

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

private _sideToJam = switch (_sideToJamNum) do {
    case 0: { east };
    case 1: { west };
    case 2: { independent };
    default { west };
};

// ========================================
// VALIDATE SETTINGS
// ========================================

if (_jammerClassname == "") then {
    diag_log format ["[RECONDO_JAMMER] WARNING: No jammer classname specified for '%1'", _objectiveName];
};

if (count _compositionPool == 0) then {
    diag_log format ["[RECONDO_JAMMER] ERROR: No compositions enabled for '%1'. Enable at least one default or add custom compositions.", _objectiveName];
};

if (_fullJamRadius >= _partialJamRadius) then {
    diag_log format ["[RECONDO_JAMMER] WARNING: Full jam radius (%1) should be less than partial jam radius (%2)", _fullJamRadius, _partialJamRadius];
    _fullJamRadius = _partialJamRadius * 0.8;
};

// ========================================
// GENERATE UNIQUE INSTANCE ID
// ========================================

private _instanceId = format ["jammer_%1_%2", _objectiveName, count RECONDO_JAMMER_INSTANCES];

// ========================================
// STORE SETTINGS
// ========================================

private _settings = createHashMapFromArray [
    ["instanceId", _instanceId],
    ["objectiveName", _objectiveName],
    ["objectiveDesc", _objectiveDesc],
    ["intelBoardCategoryName", _intelBoardCategoryName],
    ["markerPrefix", _markerPrefix],
    ["activeLocationCount", _activeLocationCount],
    ["compositionPool", _compositionPool],
    ["customCompPath", _customCompPath],
    ["clearRadius", _clearRadius],
    ["disableSimulation", _disableSimulation],
    ["jammerClassname", _jammerClassname],
    ["partialJamRadius", _partialJamRadius],
    ["fullJamRadius", _fullJamRadius],
    ["jamStrength", _jamStrength],
    ["sideToJam", _sideToJam],
    ["spawnMode", _spawnMode],
    ["compositionTriggerRadius", _compositionTriggerRadius],
    ["aiTriggerRadius", _aiTriggerRadius],
    ["triggerSide", _triggerSide],
    ["simulationDistance", _simulationDistance],
    ["sentryClassnames", _sentryClassnames],
    ["sentryMinCount", _sentryMinCount],
    ["sentryMaxCount", _sentryMaxCount],
    ["sentryBuildingRadius", _sentryBuildingRadius],
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
    ["smellHintMessages", ((_smellHintMessagesRaw splitString ",") apply { _x trim [" ", 0] }) select { _x != "" }]
];

RECONDO_JAMMER_INSTANCES pushBack _settings;
publicVariable "RECONDO_JAMMER_INSTANCES";

// ========================================
// LOAD PERSISTENCE DATA
// ========================================

private _persistenceKey = format ["JAMMER_%1", _objectiveName];
private _savedActiveMarkers = [_persistenceKey + "_ACTIVE"] call Recondo_fnc_getSaveData;
private _savedDestroyedMarkers = [_persistenceKey + "_DESTROYED"] call Recondo_fnc_getSaveData;
private _savedCompositionMap = [_persistenceKey + "_COMPMAP"] call Recondo_fnc_getSaveData;

if (isNil "_savedActiveMarkers") then { _savedActiveMarkers = [] };
if (isNil "_savedDestroyedMarkers") then { _savedDestroyedMarkers = [] };
if (isNil "_savedCompositionMap") then { _savedCompositionMap = [] };

// Update global destroyed list
{
    if (!(_x in RECONDO_JAMMER_DESTROYED)) then {
        RECONDO_JAMMER_DESTROYED pushBack _x;
    };
} forEach _savedDestroyedMarkers;
publicVariable "RECONDO_JAMMER_DESTROYED";

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
        diag_log format ["[RECONDO_JAMMER] Loaded %1 saved markers for '%2'", count _selectedMarkers, _objectiveName];
    };
} else {
    // Fresh generation
    _selectedMarkers = [_markerPrefix, _activeLocationCount, _debugLogging] call Recondo_fnc_selectJammerMarkers;
    
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
        diag_log format ["[RECONDO_JAMMER] Generated %1 new markers for '%2'", count _selectedMarkers, _objectiveName];
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
// REGISTER ACTIVE JAMMERS WITH INTEL AND GLOBAL TRACKING
// ========================================

{
    _x params ["_markerId", "_compData"];
    // _compData is [activeComp, destroyedComp, isModPath]
    
    private _isDestroyed = _markerId in _savedDestroyedMarkers;
    private _markerPos = getMarkerPos _markerId;
    
    // Track in global jammer data (for client-side jamming loop)
    if (!_isDestroyed) then {
        private _jammerData = createHashMapFromArray [
            ["instanceId", _instanceId],
            ["markerId", _markerId],
            ["position", _markerPos],
            ["partialJamRadius", _partialJamRadius],
            ["fullJamRadius", _fullJamRadius],
            ["jamStrength", _jamStrength],
            ["sideToJam", _sideToJam],
            ["active", true]
        ];
        RECONDO_JAMMER_ACTIVE_DATA pushBack _jammerData;
        
        // Register with Intel system
        if (_linkedToIntel) then {
            private _targetId = format ["%1_%2", _instanceId, _markerId];
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
                diag_log format ["[RECONDO_JAMMER] Registered '%1' at %2 with Intel system (weight: %3)", _objectiveName, _markerId, _intelWeight];
            };
        };
    };
    
    // Track active jammer (store full composition data)
    RECONDO_JAMMER_ACTIVE pushBack [_instanceId, _markerId, _compData, if (_isDestroyed) then { "destroyed" } else { "active" }];
} forEach _compositionMap;

publicVariable "RECONDO_JAMMER_ACTIVE";
publicVariable "RECONDO_JAMMER_ACTIVE_DATA";

// ========================================
// SPAWN OR CREATE TRIGGERS
// ========================================

{
    _x params ["_markerId", "_compData"];
    // _compData is [activeComp, destroyedComp, isModPath]
    _compData params ["_activeComp", "_destroyedComp", "_isModPath"];
    
    private _isDestroyed = _markerId in _savedDestroyedMarkers;
    
    if (_spawnMode == 0) then {
        // Immediate spawn
        [_settings, _markerId, _compData, _isDestroyed] call Recondo_fnc_spawnJammerComposition;
    } else {
        // Proximity trigger
        [_settings, _markerId, _compData, _isDestroyed] call Recondo_fnc_createJammerTrigger;
    };
    
    // Create debug markers
    if (_debugMarkers) then {
        private _markerPos = getMarkerPos _markerId;
        
        // Objective marker
        private _debugMarker = createMarker [format ["RECONDO_JAMMER_DEBUG_%1", _markerId], _markerPos];
        _debugMarker setMarkerShape "ICON";
        _debugMarker setMarkerType "mil_objective";
        _debugMarker setMarkerColor (if (_isDestroyed) then { "ColorGrey" } else { "ColorRed" });
        _debugMarker setMarkerText format ["%1 - %2", _objectiveName, if (_isDestroyed) then { "DESTROYED" } else { "ACTIVE" }];
        
        // Jam radius markers (only for active jammers)
        if (!_isDestroyed) then {
            private _partialMarker = createMarker [format ["RECONDO_JAMMER_PARTIAL_%1", _markerId], _markerPos];
            _partialMarker setMarkerShape "ELLIPSE";
            _partialMarker setMarkerSize [_partialJamRadius, _partialJamRadius];
            _partialMarker setMarkerColor "ColorYellow";
            _partialMarker setMarkerAlpha 0.2;
            _partialMarker setMarkerBrush "Border";
            
            private _fullMarker = createMarker [format ["RECONDO_JAMMER_FULL_%1", _markerId], _markerPos];
            _fullMarker setMarkerShape "ELLIPSE";
            _fullMarker setMarkerSize [_fullJamRadius, _fullJamRadius];
            _fullMarker setMarkerColor "ColorRed";
            _fullMarker setMarkerAlpha 0.2;
            _fullMarker setMarkerBrush "Border";
        };
    };
} forEach _compositionMap;

// ========================================
// BROADCAST TO CLIENTS FOR JAMMING
// ========================================

// Tell all clients to initialize/update their jamming loops
[] remoteExec ["Recondo_fnc_initACREJamming", 0, true]; // JIP compatible

// ========================================
// CREATE SMELL TRIGGERS
// ========================================

if (_enableSmellHints) then {
    {
        _x params ["_markerId", "_composition"];
        
        // Only create smell triggers for active (not destroyed) jammers
        if !(_markerId in _savedDestroyedMarkers) then {
            [_settings, _markerId] call Recondo_fnc_createJammerSmellTrigger;
        };
    } forEach _compositionMap;
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_JAMMER] Created smell triggers for %1 active jammers", count _selectedMarkers - count _savedDestroyedMarkers];
    };
};

// ========================================
// START NIGHT LIGHT LOOP
// ========================================

if (_enableNightLights && !RECONDO_JAMMER_NIGHT_LIGHT_LOOP_STARTED) then {
    RECONDO_JAMMER_NIGHT_LIGHTS_ENABLED = true;
    publicVariable "RECONDO_JAMMER_NIGHT_LIGHTS_ENABLED";
    
    RECONDO_JAMMER_NIGHT_LIGHT_LOOP_STARTED = true;
    [] call Recondo_fnc_updateJammerNightLights;
    
    if (_debugLogging) then {
        diag_log "[RECONDO_JAMMER] Night light update loop started";
    };
};

// ========================================
// LOG INITIALIZATION
// ========================================

private _activeCount = count _selectedMarkers - count _savedDestroyedMarkers;
diag_log format ["[RECONDO_JAMMER] '%1' initialized: %2 active, %3 destroyed, Total: %4",
    _objectiveName, _activeCount, count _savedDestroyedMarkers, count _selectedMarkers];

if (_debugLogging) then {
    diag_log "[RECONDO_JAMMER] === Objective Jammer Settings ===";
    diag_log format ["[RECONDO_JAMMER] Instance ID: %1", _instanceId];
    diag_log format ["[RECONDO_JAMMER] Marker Prefix: %1", _markerPrefix];
    diag_log format ["[RECONDO_JAMMER] Composition Pool: %1 entries", count _compositionPool];
    diag_log format ["[RECONDO_JAMMER] - Tower: %1, Camp: %2", _useTowerComp, _useCampComp];
    diag_log format ["[RECONDO_JAMMER] - Custom: %1", count _customActiveComps];
    diag_log format ["[RECONDO_JAMMER] Jammer Classname: %1", _jammerClassname];
    diag_log format ["[RECONDO_JAMMER] Jam Radii: Partial=%1m, Full=%2m", _partialJamRadius, _fullJamRadius];
    diag_log format ["[RECONDO_JAMMER] Jam Strength: %1", _jamStrength];
    diag_log format ["[RECONDO_JAMMER] Side to Jam: %1", _sideToJam];
    diag_log format ["[RECONDO_JAMMER] Spawn Mode: %1", if (_spawnMode == 0) then { "Immediate" } else { "Proximity" }];
    diag_log format ["[RECONDO_JAMMER] Linked to Intel: %1", _linkedToIntel];
};
