/*
    Recondo_fnc_moduleObjectivePhotographs
    Main initialization for Objective - Photographs module
    
    Description:
        Spawns photo reconnaissance objectives using compositions at invisible map markers.
        Players must photograph a specific target object within each composition using the
        SOG Prairie Fire camera. Successful photos yield an item that can be turned in
        at the Intel module for location reveals.
    
    Parameters:
        _logic - Module logic object
        _units - Synchronized units (unused)
        _activated - Whether module is activated
*/

params ["_logic", "_units", "_activated"];

if (!isServer) exitWith {};

if (!_activated) exitWith {
    diag_log "[RECONDO_PHOTO] Module not activated.";
};

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

private _objectiveName = _logic getVariable ["objectivename", "Recon Photo"];
private _objectiveDesc = _logic getVariable ["objectivedesc", "A site requiring photographic reconnaissance."];
private _intelBoardCategoryName = _logic getVariable ["intelboardcategoryname", ""];
private _markerPrefix = _logic getVariable ["markerprefix", "PHOTO_"];
private _spawnPercentage = _logic getVariable ["spawnpercentage", 0.5];

// Composition
private _compMassGrave1 = _logic getVariable ["comp_massgrave1", false];
private _compBulldozer1 = _logic getVariable ["comp_bulldozer1", false];
private _compNVALogisticTrucks1 = _logic getVariable ["comp_nvalogistictrucks1", false];
private _compDevice1 = _logic getVariable ["comp_device1", false];
private _compNVASAM1 = _logic getVariable ["comp_nvasam1", false];
private _customCompPath = _logic getVariable ["customcomppath", "compositions"];
private _customActiveCompsRaw = _logic getVariable ["customactivecomps", ""];
private _customTargetClassname = _logic getVariable ["customtargetclassname", ""];
private _clearRadius = _logic getVariable ["clearradius", 25];
private _disableSimulation = _logic getVariable ["disablesimulation", true];

// Photography
private _maxPhotoDistance = _logic getVariable ["maxphotodistance", 100];
private _minPhotoDistance = _logic getVariable ["minphotodistance", 1];
private _rewardItemClassname = _logic getVariable ["rewarditemclassname", "vn_b_item_map"];
private _successMessage = _logic getVariable ["successmessage", "Photo captured! You received a reconnaissance photograph."];
private _failMessage = _logic getVariable ["failmessage", "No valid target in view. Ensure the target is clearly visible."];

// Spawning
private _spawnMode = _logic getVariable ["spawnmode", 1];
private _triggerRadius = _logic getVariable ["triggerradius", 500];
private _triggerSideNum = _logic getVariable ["triggerside", 1];
private _simulationDistance = _logic getVariable ["simulationdistance", 1000];

// Garrison AI
private _sentryClassnamesRaw = _logic getVariable ["sentryclassnames", ""];
private _sentryMinCount = _logic getVariable ["sentrymincount", 2];
private _sentryMaxCount = _logic getVariable ["sentrymaxcount", 4];
private _sentrySideNum = _logic getVariable ["sentryside", 0];

// Patrol AI
private _patrolClassnamesRaw = _logic getVariable ["patrolclassnames", ""];
private _patrolCount = _logic getVariable ["patrolcount", 1];
private _patrolMinSize = _logic getVariable ["patrolminsize", 2];
private _patrolMaxSize = _logic getVariable ["patrolmaxsize", 4];
private _patrolRadius = _logic getVariable ["patrolradius", 50];
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
private _smellHintMessagesRaw = _logic getVariable ["smellhintmessages", "Something feels out of place here...,You notice unusual activity in the area...,There are signs of enemy presence nearby...,The area looks like it could be worth investigating."];

// ========================================
// PARSE CONFIGURATIONS
// ========================================

private _sentryClassnames = if (_sentryClassnamesRaw != "") then {
    [_sentryClassnamesRaw] call Recondo_fnc_parseClassnames
} else { [] };

private _patrolClassnames = if (_patrolClassnamesRaw != "") then {
    [_patrolClassnamesRaw] call Recondo_fnc_parseClassnames
} else { [] };

// ========================================
// BUILD COMPOSITION POOL
// ========================================
// Pool format: [compFile, targetClassname, isModPath]

private _compositionPool = [];

if (_compMassGrave1) then { _compositionPool pushBack ["Photo\MassGrave_1.sqe", "Land_Grave_11_F", true]; };
if (_compBulldozer1) then { _compositionPool pushBack ["Photo\Bulldozer_1.sqe", "Land_vn_bulldozer_01_abandoned_f", true]; };
if (_compNVALogisticTrucks1) then { _compositionPool pushBack ["Photo\NVALogisticTrucks_1.sqe", "vn_o_wheeled_z157_02", true]; };
if (_compDevice1) then { _compositionPool pushBack ["Photo\Device_1.sqe", "Land_Device_assembled_F", true]; };
if (_compNVASAM1) then { _compositionPool pushBack ["Photo\NVASAM_1.sqe", "vn_sa2", true]; };

// Parse custom compositions from mission folder
private _customActiveComps = ((_customActiveCompsRaw splitString (toString [10, 13] + ",")) apply { _x trim [" ", 0] }) select { _x != "" && !(_x select [0, 2] == "//") };

{
    _compositionPool pushBack [_x, _customTargetClassname, false];
} forEach _customActiveComps;

if (count _compositionPool == 0) exitWith {
    diag_log format ["[RECONDO_PHOTO] ERROR: No compositions configured for '%1'. Enable a checkbox or add custom compositions.", _objectiveName];
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_PHOTO] Composition pool built: %1 entries", count _compositionPool];
};

// Parse other settings
private _smellHintMessages = ((_smellHintMessagesRaw splitString ",") apply { _x trim [" ", 0] }) select { _x != "" };
private _intelRevealMessagesDoc = ((_intelRevealMessagesDocRaw splitString (toString [10, 13])) apply { _x trim [" ", 0] }) select { _x != "" };
private _intelRevealMessagesPOW = ((_intelRevealMessagesPOWRaw splitString (toString [10, 13])) apply { _x trim [" ", 0] }) select { _x != "" };

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
// GENERATE UNIQUE INSTANCE ID
// ========================================

private _instanceId = format ["objphoto_%1_%2", _objectiveName, count RECONDO_PHOTO_INSTANCES];

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
    ["disableSimulation", _disableSimulation],
    ["maxPhotoDistance", _maxPhotoDistance],
    ["minPhotoDistance", _minPhotoDistance],
    ["rewardItemClassname", _rewardItemClassname],
    ["successMessage", _successMessage],
    ["failMessage", _failMessage],
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

RECONDO_PHOTO_INSTANCES pushBack _settings;
publicVariable "RECONDO_PHOTO_INSTANCES";

// ========================================
// LOAD PERSISTENCE DATA
// ========================================

private _persistenceKey = format ["OBJPHOTO_%1", _objectiveName];
private _savedActiveMarkers = [_persistenceKey + "_ACTIVE"] call Recondo_fnc_getSaveData;
private _savedCompletedMarkers = [_persistenceKey + "_COMPLETED"] call Recondo_fnc_getSaveData;
private _savedCompositionMap = [_persistenceKey + "_COMPMAP"] call Recondo_fnc_getSaveData;

if (isNil "_savedActiveMarkers") then { _savedActiveMarkers = [] };
if (isNil "_savedCompletedMarkers") then { _savedCompletedMarkers = [] };
if (isNil "_savedCompositionMap") then { _savedCompositionMap = [] };

{
    if (!(_x in RECONDO_PHOTO_COMPLETED)) then {
        RECONDO_PHOTO_COMPLETED pushBack _x;
    };
} forEach _savedCompletedMarkers;
publicVariable "RECONDO_PHOTO_COMPLETED";

// ========================================
// SELECT OR LOAD MARKERS
// ========================================

private _selectedMarkers = [];
private _compositionMap = [];

if (count _savedActiveMarkers > 0) then {
    _selectedMarkers = _savedActiveMarkers;
    _compositionMap = _savedCompositionMap;

    if (_debugLogging) then {
        diag_log format ["[RECONDO_PHOTO] Loaded %1 saved markers for '%2'", count _selectedMarkers, _objectiveName];
    };
} else {
    _selectedMarkers = [_markerPrefix, _spawnPercentage, _debugLogging] call Recondo_fnc_selectObjectiveMarkers;

    {
        private _compData = selectRandom _compositionPool;
        _compositionMap pushBack [_x, _compData];
    } forEach _selectedMarkers;

    [_persistenceKey + "_ACTIVE", _selectedMarkers] call Recondo_fnc_setSaveData;
    [_persistenceKey + "_COMPMAP", _compositionMap] call Recondo_fnc_setSaveData;
    [_persistenceKey + "_COMPLETED", []] call Recondo_fnc_setSaveData;
    saveMissionProfileNamespace;

    if (_debugLogging) then {
        diag_log format ["[RECONDO_PHOTO] Generated %1 new markers for '%2'", count _selectedMarkers, _objectiveName];
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
        if (_markerId in _savedCompletedMarkers) then { continue };

        private _markerPos = getMarkerPos _markerId;
        private _targetId = format ["%1_%2", _instanceId, _markerId];

        [
            "photograph",
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
            diag_log format ["[RECONDO_PHOTO] Registered '%1' at %2 with Intel system (weight: %3)", _objectiveName, _markerId, _intelWeight];
        };
    } forEach _selectedMarkers;
};

// ========================================
// SPAWN OR CREATE TRIGGERS
// ========================================

{
    _x params ["_markerId", "_compData"];
    _compData params ["_activeComp", "_targetClassname", "_isModPath"];

    private _isCompleted = _markerId in _savedCompletedMarkers;

    RECONDO_PHOTO_ACTIVE pushBack [_instanceId, _markerId, _compData, if (_isCompleted) then { "completed" } else { "active" }];

    if (!_isCompleted) then {
        // Register marker data for camera system (classname-based matching)
        RECONDO_PHOTO_MARKER_DATA pushBack [_markerId, getMarkerPos _markerId, _targetClassname, _instanceId, _clearRadius * 2];

        if (_spawnMode == 0) then {
            [_settings, _markerId, _activeComp, _isModPath] call Recondo_fnc_spawnPhotoObjective;
        } else {
            [_settings, _markerId, _compData] call Recondo_fnc_createPhotoTrigger;
        };
    };

    if (_debugMarkers) then {
        private _markerPos = getMarkerPos _markerId;
        private _dbgMarker = createMarker [format ["RECONDO_PHOTO_DEBUG_%1", _markerId], _markerPos];
        _dbgMarker setMarkerShape "ICON";
        _dbgMarker setMarkerType "mil_objective";
        _dbgMarker setMarkerColor (if (_isCompleted) then { "ColorGrey" } else { "ColorBlue" });
        _dbgMarker setMarkerText format ["%1 - %2", _objectiveName, if (_isCompleted) then { "COMPLETE" } else { "ACTIVE" }];
    };
} forEach _compositionMap;

publicVariable "RECONDO_PHOTO_MARKER_DATA";
publicVariable "RECONDO_PHOTO_ACTIVE";

// ========================================
// CREATE SMELL TRIGGERS
// ========================================

if (_enableSmellHints) then {
    {
        _x params ["_markerId", "_compData"];
        if !(_markerId in _savedCompletedMarkers) then {
            [_settings, _markerId] call Recondo_fnc_createPhotoSmellTrigger;
        };
    } forEach _compositionMap;
};

// ========================================
// START NIGHT LIGHT LOOP
// ========================================

if (_enableNightLights && !RECONDO_PHOTO_NIGHT_LIGHT_LOOP_STARTED) then {
    RECONDO_PHOTO_NIGHT_LIGHT_LOOP_STARTED = true;
    [] call Recondo_fnc_updatePhotoNightLights;
};

// ========================================
// INIT CAMERA SYSTEM ON CLIENTS
// ========================================

[_settings] remoteExec ["Recondo_fnc_initPhotoCamera", 0, true];

// ========================================
// SETUP TURN-IN AT INTEL OBJECTS
// ========================================

if (_linkedToIntel) then {
    [_settings] call Recondo_fnc_addPhotoTurnIn;
};

// ========================================
// LOG INITIALIZATION
// ========================================

private _activeCount = count _selectedMarkers - count _savedCompletedMarkers;
diag_log format ["[RECONDO_PHOTO] '%1' initialized: %2 active, %3 completed, Total: %4",
    _objectiveName, _activeCount, count _savedCompletedMarkers, count _selectedMarkers];
