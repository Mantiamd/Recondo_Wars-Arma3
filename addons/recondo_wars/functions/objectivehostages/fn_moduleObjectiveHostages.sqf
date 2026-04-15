/*
    Recondo_fnc_moduleObjectiveHostages
    Main initialization for Objective Hostages module
    
    Description:
        Creates a Hostage Rescue objective. Hostages are distributed across
        selected locations based on distribution mode. Decoy locations can
        also be configured. Hostages must be brought to Intel turn-in location
        to complete the rescue. Each hostage can be turned in individually.
        
    Priority: 5 (Feature module - depends on persistence and Intel)
    
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
    diag_log "[RECONDO_HOSTAGE] Module not activated.";
};

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

// Profile Pool Settings (individual checkboxes)
private _profileHostage1 = _logic getVariable ["profile_hostage1", false];
private _profileHostage2 = _logic getVariable ["profile_hostage2", false];
private _profileHostage3 = _logic getVariable ["profile_hostage3", false];
private _profileHostageARVN = _logic getVariable ["profile_hostage_arvn", false];
private _profileHostageCalloway = _logic getVariable ["profile_hostage_calloway", false];
private _profileHostageVandermeer = _logic getVariable ["profile_hostage_vandermeer", false];
private _profileHostageGreer = _logic getVariable ["profile_hostage_greer", false];

// General
private _objectiveName = _logic getVariable ["objectivename", "Hostage Rescue"];
private _objectiveDescription = _logic getVariable ["objectivedescription", ""];
private _intelBoardCategoryName = _logic getVariable ["intelboardcategoryname", ""];
private _markerPrefix = _logic getVariable ["markerprefix", "HOSTAGE_"];

// Hostage Location Settings
private _hostageLocationCount = _logic getVariable ["hostagelocationcount", 1];
private _decoyCount = _logic getVariable ["decoycount", 2];
private _distributionMode = _logic getVariable ["distributionmode", "random"];
private _hostageTurnInRadius = _logic getVariable ["hostageturninradius", 10];

// Animation Settings
private _animationMode = _logic getVariable ["animationmode", "random"];
private _hostageAnimation = _logic getVariable ["hostageanimation", "Acts_AidlPsitMstpSsurWnonDnon01"];

// Composition Pool (individual checkboxes)
private _compHVTBASE1 = _logic getVariable ["comp_hvtbase_1", false];
private _compHVTBASE2 = _logic getVariable ["comp_hvtbase_2", false];
private _compHVTBASE3 = _logic getVariable ["comp_hvtbase_3", false];
private _compVCcamp1 = _logic getVariable ["comp_vc_camp1", false];
private _compVCcamp2 = _logic getVariable ["comp_vc_camp2", false];
private _compVCPOWcamp1 = _logic getVariable ["comp_vc_pow_camp1", false];
private _compVCPOWcamp2 = _logic getVariable ["comp_vc_pow_camp2", false];
private _compShack1 = _logic getVariable ["comp_shack_1", false];
private _compShack2 = _logic getVariable ["comp_shack_2", false];
private _compShack3 = _logic getVariable ["comp_shack_3", false];
private _compShack4 = _logic getVariable ["comp_shack_4", false];
private _compShack5 = _logic getVariable ["comp_shack_5", false];
private _compShack6 = _logic getVariable ["comp_shack_6", false];
private _compShack7 = _logic getVariable ["comp_shack_7", false];
private _compShack8 = _logic getVariable ["comp_shack_8", false];
private _customCompPath = _logic getVariable ["customcomppath", "compositions"];
private _customActiveCompsRaw = _logic getVariable ["customactivecomps", ""];
private _clearRadius = _logic getVariable ["clearradius", 25];
private _disableSimulation = _logic getVariable ["disablesimulation", true];

// Spawning
private _spawnMode = _logic getVariable ["spawnmode", "proximity"];
private _compositionTriggerRadius = _logic getVariable ["compositiontriggerradius", 800];
private _aiTriggerRadius = _logic getVariable ["aitriggerradius", 600];
private _triggerSide = _logic getVariable ["triggerside", "WEST"];
private _simulationDistance = _logic getVariable ["simulationdistance", 1000];

// Decoy AI chance
private _decoyAIChance = _logic getVariable ["decoyaichance", 0.5];

// Garrison AI
private _aiSide = _logic getVariable ["aiside", "EAST"];
private _garrisonClassnamesRaw = _logic getVariable ["garrisonclassnames", ""];
private _garrisonMin = _logic getVariable ["garrisonmin", 2];
private _garrisonMax = _logic getVariable ["garrisonmax", 4];
private _enableRovingSentry = _logic getVariable ["enablerovingsentry", true];
private _invulnTime = _logic getVariable ["invulntime", 30];

// Civilians
private _enableCivilians = _logic getVariable ["enablecivilians", false];
private _civilianChance = _logic getVariable ["civilianchance", 0.5];
private _civilianClassnamesRaw = _logic getVariable ["civilianclassnames", ""];

// Animals
private _enableAnimals = _logic getVariable ["enableanimals", false];
private _animalChance = _logic getVariable ["animalchance", 0.75];
private _animalClassnamesRaw = _logic getVariable ["animalclassnames", ""];
private _animalMin = _logic getVariable ["animalmin", 3];
private _animalMax = _logic getVariable ["animalmax", 6];

// Intel
private _intelWeight = _logic getVariable ["intelweight", 0.5];
private _intelRevealMessagesDocRaw = _logic getVariable ["intelrevealmessagesdoc", ""];
private _intelRevealMessagesPOWRaw = _logic getVariable ["intelrevealmessagespow", ""];
private _intelConfirmMessage = _logic getVariable ["intelconfirmmessage", "This confirms earlier reports about hostages near grid %GRID%."];

// Debug
private _debugLogging = _logic getVariable ["debuglogging", false];
if (RECONDO_MASTER_DEBUG) then { _debugLogging = true; };
private _debugMarkers = _logic getVariable ["debugmarkers", false];

// Invincibility
private _makeInvincible = _logic getVariable ["makeinvincible", false];

// Night Lights
private _enableNightLights = _logic getVariable ["enablenightlights", true];

// Smell Hints
private _enableSmellHints = _logic getVariable ["enablesmellhints", true];
private _smellHintRadius = _logic getVariable ["smellhintradius", 200];
private _smellHintMessagesRaw = _logic getVariable ["smellhintmessages", "You catch the faint smell of sweat and fear...,The air carries a hint of desperation...,A stale human odor drifts from nearby...,You sense the presence of captives somewhere close."];

// Bad Civi
private _badCiviMax = _logic getVariable ["badcivimax", 0];
private _badCiviSpawnChance = _logic getVariable ["badcivispawnchance", 50];
private _badCiviPullChance = _logic getVariable ["badcivipullchance", 100];
private _badCiviDetectionDistance = _logic getVariable ["badcividetectiondistance", 5];
private _badCiviTriggerSide = _logic getVariable ["badcivitriggerside", "WEST"];
private _badCiviClassname = _logic getVariable ["badciviclassname", "C_man_1"];
private _badCiviWeapon = _logic getVariable ["badciviweapon", "hgun_Pistol_01_F"];
private _badCiviMagazine = _logic getVariable ["badcivimagazine", "10Rnd_9x21_Mag"];

// ========================================
// PROFILE SYSTEM (required - all checked profiles are used)
// ========================================

// Build profile list from enabled checkboxes
private _profilePoolList = [];
if (_profileHostage1) then { _profilePoolList pushBack "Hostage1.sqf"; };
if (_profileHostage2) then { _profilePoolList pushBack "Hostage2.sqf"; };
if (_profileHostage3) then { _profilePoolList pushBack "Hostage3.sqf"; };
if (_profileHostageARVN) then { _profilePoolList pushBack "Hostage_ARVN.sqf"; };
if (_profileHostageCalloway) then { _profilePoolList pushBack "Hostage_Calloway.sqf"; };
if (_profileHostageVandermeer) then { _profilePoolList pushBack "Hostage_Vandermeer.sqf"; };
if (_profileHostageGreer) then { _profilePoolList pushBack "Hostage_Greer.sqf"; };

// Validate - at least one profile must be selected
if (count _profilePoolList == 0) exitWith {
    diag_log format ["[RECONDO_HOSTAGE] ERROR: No hostage profiles selected for '%1'. Check at least one profile in the module settings.", _objectiveName];
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_HOSTAGE] Using %1 hostage profiles: %2", count _profilePoolList, _profilePoolList];
};

// Load all checked profiles from mod
private _loadedProfiles = ["hostages", _profilePoolList, false, "", _debugLogging] call Recondo_fnc_loadProfiles;

if (count _loadedProfiles == 0) exitWith {
    diag_log format ["[RECONDO_HOSTAGE] ERROR: Failed to load hostage profiles for '%1'. Check profile files exist.", _objectiveName];
};

// Arrays to hold profile data
private _hostageClassnames = [];
private _hostageNames = [];
private _hostagePhotos = [];
private _hostageBackgrounds = [];
private _hostageFaces = [];
private _hostageIdentities = [];
private _hostageLoadouts = [];
private _hostageSpeakers = [];

// Build arrays from loaded profiles
{
    private _profile = _x;
    private _name = _profile getOrDefault ["name", format ["Hostage %1", _forEachIndex + 1]];
    private _classname = _profile getOrDefault ["classname", "C_man_1"];
    private _photo = _profile getOrDefault ["photo", "\recondo_wars\images\intel\default_photo.paa"];
    private _background = _profile getOrDefault ["background", ""];
    private _face = _profile getOrDefault ["face", ""];
    private _identity = _profile getOrDefault ["identity", ""];
    private _loadout = _profile getOrDefault ["loadout", []];
    private _speaker = _profile getOrDefault ["speaker", ""];
    
    _hostageNames pushBack _name;
    _hostageClassnames pushBack _classname;
    _hostagePhotos pushBack _photo;
    _hostageBackgrounds pushBack _background;
    _hostageFaces pushBack _face;
    _hostageIdentities pushBack _identity;
    _hostageLoadouts pushBack _loadout;
    _hostageSpeakers pushBack _speaker;
} forEach _loadedProfiles;

// Hostage count = number of profiles selected
private _hostageCount = count _loadedProfiles;

if (_debugLogging) then {
    diag_log format ["[RECONDO_HOSTAGE] Loaded %1 hostages: %2", _hostageCount, _hostageNames];
};

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
// Composition pool is an array of [compositionName, isModPath] pairs

private _compositionPool = [];

// Add mod compositions based on enabled checkboxes
if (_compHVTBASE1) then { _compositionPool pushBack ["HVTBASE_comp_1.sqe", true]; };
if (_compHVTBASE2) then { _compositionPool pushBack ["HVTBASE_comp_2.sqe", true]; };
if (_compHVTBASE3) then { _compositionPool pushBack ["HVTBASE_comp_3.sqe", true]; };
if (_compVCcamp1) then { _compositionPool pushBack ["VC_camp1.sqe", true]; };
if (_compVCcamp2) then { _compositionPool pushBack ["VC_camp2.sqe", true]; };
if (_compVCPOWcamp1) then { _compositionPool pushBack ["VC_POW_camp1.sqe", true]; };
if (_compVCPOWcamp2) then { _compositionPool pushBack ["VC_POW_camp2.sqe", true]; };
if (_compShack1) then { _compositionPool pushBack ["Shack_1.sqe", true]; };
if (_compShack2) then { _compositionPool pushBack ["Shack_2.sqe", true]; };
if (_compShack3) then { _compositionPool pushBack ["Shack_3.sqe", true]; };
if (_compShack4) then { _compositionPool pushBack ["Shack_4.sqe", true]; };
if (_compShack5) then { _compositionPool pushBack ["Shack_5.sqe", true]; };
if (_compShack6) then { _compositionPool pushBack ["Shack_6.sqe", true]; };
if (_compShack7) then { _compositionPool pushBack ["Shack_7.sqe", true]; };
if (_compShack8) then { _compositionPool pushBack ["Shack_8.sqe", true]; };

// Parse and add custom compositions from mission folder
private _customCompositions = [_customActiveCompsRaw] call _fnc_parseClassnames;
{
    _compositionPool pushBack [_x, false];  // false = mission path
} forEach _customCompositions;

if (_debugLogging) then {
    diag_log format ["[RECONDO_HOSTAGE] Composition pool built: %1 compositions", count _compositionPool];
    diag_log format ["[RECONDO_HOSTAGE] Pool contents: %1", _compositionPool];
};

// Validate composition pool
if (count _compositionPool == 0) exitWith {
    diag_log format ["[RECONDO_HOSTAGE] ERROR: No compositions defined for '%1'. Check at least one checkbox or add custom compositions.", _objectiveName];
};

// Legacy compatibility: create _compositions array (just names for settings storage)
private _compositions = _compositionPool apply { _x select 0 };

private _garrisonClassnames = [_garrisonClassnamesRaw] call _fnc_parseClassnames;
private _civilianClassnames = [_civilianClassnamesRaw] call _fnc_parseClassnames;
private _animalClassnames = [_animalClassnamesRaw] call _fnc_parseClassnames;
private _intelRevealMessagesDoc = [_intelRevealMessagesDocRaw] call _fnc_parseClassnames;
private _intelRevealMessagesPOW = [_intelRevealMessagesPOWRaw] call _fnc_parseClassnames;

// Validate hostage classnames
if (count _hostageClassnames == 0) then {
    _hostageClassnames = ["C_man_1"];
    diag_log "[RECONDO_HOSTAGE] WARNING: No hostage classnames defined, using default C_man_1";
};

// Generate default names if none provided
if (count _hostageNames == 0) then {
    for "_i" from 1 to _hostageCount do {
        _hostageNames pushBack format ["Hostage %1", _i];
    };
};

// Ensure we have enough names for all hostages
while {count _hostageNames < _hostageCount} do {
    _hostageNames pushBack format ["Unknown Hostage %1", count _hostageNames + 1];
};

// Fill in default photos for any missing
private _defaultPhoto = "\recondo_wars\images\intel\default_photo.paa";
while {count _hostagePhotos < _hostageCount} do {
    _hostagePhotos pushBack _defaultPhoto;
};

// Fill in empty backgrounds for any missing
while {count _hostageBackgrounds < _hostageCount} do {
    _hostageBackgrounds pushBack "";
};

// Fill in empty faces for any missing (no face = use default from classname)
while {count _hostageFaces < _hostageCount} do {
    _hostageFaces pushBack "";
};

// Fill in empty identities for any missing (no identity = use face/speaker individually)
while {count _hostageIdentities < _hostageCount} do {
    _hostageIdentities pushBack "";
};

// Fill in empty loadouts for any missing (empty = strip to basic civilian)
while {count _hostageLoadouts < _hostageCount} do {
    _hostageLoadouts pushBack [];
};

// Fill in empty speakers for any missing (no speaker = use default from classname)
while {count _hostageSpeakers < _hostageCount} do {
    _hostageSpeakers pushBack "";
};

// Convert side strings
private _aiSideEnum = switch (toUpper _aiSide) do {
    case "EAST": { east };
    case "WEST": { west };
    case "GUER": { independent };
    default { east };
};

// ========================================
// GENERATE INSTANCE ID
// ========================================

if (isNil "RECONDO_HOSTAGE_INSTANCES") then {
    RECONDO_HOSTAGE_INSTANCES = [];
    publicVariable "RECONDO_HOSTAGE_INSTANCES";
};

if (isNil "RECONDO_HOSTAGE_LOCATIONS") then {
    RECONDO_HOSTAGE_LOCATIONS = createHashMap;
    publicVariable "RECONDO_HOSTAGE_LOCATIONS";
};

if (isNil "RECONDO_HOSTAGE_UNITS") then {
    RECONDO_HOSTAGE_UNITS = createHashMap;
    publicVariable "RECONDO_HOSTAGE_UNITS";
};

if (isNil "RECONDO_HOSTAGE_RESCUED") then {
    RECONDO_HOSTAGE_RESCUED = [];
    publicVariable "RECONDO_HOSTAGE_RESCUED";
};

if (isNil "RECONDO_HOSTAGE_TRIGGERS") then {
    RECONDO_HOSTAGE_TRIGGERS = [];
};

private _instanceId = format ["hostage_%1_%2", _objectiveName, count RECONDO_HOSTAGE_INSTANCES];

// ========================================
// STORE SETTINGS
// ========================================

private _settings = createHashMapFromArray [
    ["instanceId", _instanceId],
    ["objectiveName", _objectiveName],
    ["objectiveDescription", _objectiveDescription],
    ["intelBoardCategoryName", _intelBoardCategoryName],
    ["markerPrefix", _markerPrefix],
    ["hostageClassnames", _hostageClassnames],
    ["hostageNames", _hostageNames],
    ["hostagePhotos", _hostagePhotos],
    ["hostageBackgrounds", _hostageBackgrounds],
    ["hostageFaces", _hostageFaces],
    ["hostageIdentities", _hostageIdentities],
    ["hostageLoadouts", _hostageLoadouts],
    ["hostageSpeakers", _hostageSpeakers],
    ["hostageCount", _hostageCount],
    ["hostageLocationCount", _hostageLocationCount],
    ["decoyCount", _decoyCount],
    ["distributionMode", _distributionMode],
    ["hostageTurnInRadius", _hostageTurnInRadius],
    ["animationMode", _animationMode],
    ["hostageAnimation", _hostageAnimation],
    ["compositionPool", _compositionPool],
    ["customCompPath", _customCompPath],
    ["compositions", _compositions],
    ["clearRadius", _clearRadius],
    ["disableSimulation", _disableSimulation],
    ["spawnMode", _spawnMode],
    ["compositionTriggerRadius", _compositionTriggerRadius],
    ["aiTriggerRadius", _aiTriggerRadius],
    ["triggerSide", _triggerSide],
    ["simulationDistance", _simulationDistance],
    ["decoyAIChance", _decoyAIChance],
    ["aiSide", _aiSideEnum],
    ["garrisonClassnames", _garrisonClassnames],
    ["garrisonMin", _garrisonMin],
    ["garrisonMax", _garrisonMax],
    ["enableRovingSentry", _enableRovingSentry],
    ["invulnTime", _invulnTime],
    ["enableCivilians", _enableCivilians],
    ["civilianChance", _civilianChance],
    ["civilianClassnames", _civilianClassnames],
    ["enableAnimals", _enableAnimals],
    ["animalChance", _animalChance],
    ["animalClassnames", _animalClassnames],
    ["animalMin", _animalMin],
    ["animalMax", _animalMax],
    ["intelWeight", _intelWeight],
    ["intelRevealMessagesDoc", _intelRevealMessagesDoc],
    ["intelRevealMessagesPOW", _intelRevealMessagesPOW],
    ["intelConfirmMessage", _intelConfirmMessage],
    ["debugLogging", _debugLogging],
    ["debugMarkers", _debugMarkers],
    ["enableNightLights", _enableNightLights],
    ["enableSmellHints", _enableSmellHints],
    ["smellHintRadius", _smellHintRadius],
    ["smellHintMessages", ((_smellHintMessagesRaw splitString ",") apply { _x trim [" ", 0] }) select { _x != "" }],
    ["makeInvincible", _makeInvincible],
    ["badCiviMax", _badCiviMax],
    ["badCiviSpawnChance", _badCiviSpawnChance],
    ["badCiviPullChance", _badCiviPullChance],
    ["badCiviDetectionDistance", _badCiviDetectionDistance],
    ["badCiviTriggerSide", _badCiviTriggerSide],
    ["badCiviClassname", _badCiviClassname],
    ["badCiviWeapon", _badCiviWeapon],
    ["badCiviMagazine", _badCiviMagazine]
];

RECONDO_HOSTAGE_INSTANCES pushBack _settings;
publicVariable "RECONDO_HOSTAGE_INSTANCES";

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
    diag_log format ["[RECONDO_HOSTAGE] Linked to Intel module: %1", _linkedToIntel];
};

if (!_linkedToIntel) then {
    diag_log "[RECONDO_HOSTAGE] WARNING: Not synced to Intel module. Turn-in and intel features will not work.";
};

// ========================================
// PERSISTENCE - LOAD SAVED DATA
// ========================================

private _persistenceKey = format ["HOSTAGE_%1_%2", _markerPrefix, _objectiveName];
private _savedHostageMarkers = [_persistenceKey + "_HOSTAGEMARKERS"] call Recondo_fnc_getSaveData;
private _savedDecoyMarkers = [_persistenceKey + "_DECOYMARKERS"] call Recondo_fnc_getSaveData;
private _savedCompositions = [_persistenceKey + "_COMPOSITIONS"] call Recondo_fnc_getSaveData;
private _savedHostageAssignments = [_persistenceKey + "_ASSIGNMENTS"] call Recondo_fnc_getSaveData;
private _savedRescued = [_persistenceKey + "_RESCUED"] call Recondo_fnc_getSaveData;

// ========================================
// SELECT HOSTAGE AND DECOY LOCATIONS
// ========================================

private _hostageMarkers = [];
private _decoyMarkers = [];
private _compositionMap = createHashMap;  // marker -> composition name
private _hostageAssignments = createHashMap;  // marker -> array of [hostageIndex, hostageName]

if (!isNil "_savedHostageMarkers" && {_savedHostageMarkers isEqualType [] && {count _savedHostageMarkers > 0}}) then {
    // Use saved locations
    _hostageMarkers = _savedHostageMarkers;
    _decoyMarkers = if (_savedDecoyMarkers isEqualType []) then { _savedDecoyMarkers } else { [] };
    _compositionMap = if (_savedCompositions isEqualType createHashMap) then { _savedCompositions } else { createHashMap };
    _hostageAssignments = if (_savedHostageAssignments isEqualType createHashMap) then { _savedHostageAssignments } else { createHashMap };
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_HOSTAGE] Loaded saved state - Hostage markers: %1, Decoys: %2", _hostageMarkers, _decoyMarkers];
    };
} else {
    // Generate new locations
    private _result = [_markerPrefix, _hostageLocationCount, _decoyCount, _debugLogging] call Recondo_fnc_selectHostageLocations;
    _result params ["_selectedHostage", "_selectedDecoys"];
    
    _hostageMarkers = _selectedHostage;
    _decoyMarkers = _selectedDecoys;
    
    // Assign random compositions from pool to all markers (stores [name, isModPath] pairs)
    {
        _compositionMap set [_x, selectRandom _compositionPool];
    } forEach _hostageMarkers;
    {
        _compositionMap set [_x, selectRandom _compositionPool];
    } forEach _decoyMarkers;
    
    // Distribute hostages to markers
    _hostageAssignments = [_settings, _hostageMarkers] call Recondo_fnc_distributeHostages;
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_HOSTAGE] Generated new locations - Hostage markers: %1, Decoys: %2", _hostageMarkers, _decoyMarkers];
        diag_log format ["[RECONDO_HOSTAGE] Hostage assignments: %1", _hostageAssignments];
    };
    
    // Save to persistence
    [_persistenceKey + "_HOSTAGEMARKERS", _hostageMarkers] call Recondo_fnc_setSaveData;
    [_persistenceKey + "_DECOYMARKERS", _decoyMarkers] call Recondo_fnc_setSaveData;
    [_persistenceKey + "_COMPOSITIONS", _compositionMap] call Recondo_fnc_setSaveData;
    [_persistenceKey + "_ASSIGNMENTS", _hostageAssignments] call Recondo_fnc_setSaveData;
    [_persistenceKey + "_RESCUED", []] call Recondo_fnc_setSaveData;
};

// Load rescued hostages
private _rescuedHostages = if (_savedRescued isEqualType []) then { _savedRescued } else { [] };

// Add rescued hostages to global array
{
    if !(_x in RECONDO_HOSTAGE_RESCUED) then {
        RECONDO_HOSTAGE_RESCUED pushBack _x;
    };
} forEach _rescuedHostages;
publicVariable "RECONDO_HOSTAGE_RESCUED";

// Store location and assignment data
RECONDO_HOSTAGE_LOCATIONS set [_instanceId, [_hostageMarkers, _decoyMarkers, _hostageAssignments]];
publicVariable "RECONDO_HOSTAGE_LOCATIONS";

// Initialize empty units array for this instance
RECONDO_HOSTAGE_UNITS set [_instanceId, []];
publicVariable "RECONDO_HOSTAGE_UNITS";

// Check if all hostages already rescued
private _allRescued = true;
for "_i" from 0 to (_hostageCount - 1) do {
    private _hostageId = format ["%1_hostage_%2", _instanceId, _i];
    if !(_hostageId in RECONDO_HOSTAGE_RESCUED) exitWith {
        _allRescued = false;
    };
};

if (_allRescued) then {
    if (_debugLogging) then {
        diag_log format ["[RECONDO_HOSTAGE] All hostages for '%1' already rescued, skipping spawn setup", _objectiveName];
    };
};

// ========================================
// REGISTER WITH INTEL SYSTEM
// ========================================

if (_linkedToIntel && !_allRescued) then {
    // Register each hostage location with Intel system
    {
        private _marker = _x;
        private _markerPos = getMarkerPos _marker;
        private _targetId = format ["%1_%2", _instanceId, _marker];
        
        // Get hostage names, photos, and backgrounds at this location
        private _hostagesAtMarker = _hostageAssignments getOrDefault [_marker, []];
        private _hostageNamesAtLocation = _hostagesAtMarker apply { _x select 1 };
        
        // Get photos, backgrounds, and faces for hostages at this location
        private _hostagePhotosAtLocation = _hostagesAtMarker apply {
            private _idx = _x select 0;
            _hostagePhotos select (_idx min (count _hostagePhotos - 1))
        };
        private _hostageBackgroundsAtLocation = _hostagesAtMarker apply {
            private _idx = _x select 0;
            _hostageBackgrounds select (_idx min (count _hostageBackgrounds - 1))
        };
        private _hostageFacesAtLocation = _hostagesAtMarker apply {
            private _idx = _x select 0;
            _hostageFaces select (_idx min (count _hostageFaces - 1))
        };
        
        [
            "hostage",
            _targetId,
            _markerPos,
            createHashMapFromArray [
                ["name", _objectiveName],
                ["marker", _marker],
                ["hostageNames", _hostageNamesAtLocation],
                ["hostagePhotos", _hostagePhotosAtLocation],
                ["hostageBackgrounds", _hostageBackgroundsAtLocation],
                ["hostageFaces", _hostageFacesAtLocation],
                ["revealMessagesDoc", _intelRevealMessagesDoc],
                ["revealMessagesPOW", _intelRevealMessagesPOW],
                ["confirmMessage", _intelConfirmMessage]
            ],
            _intelWeight
        ] call Recondo_fnc_registerIntelTarget;
        
        if (_debugLogging) then {
            diag_log format ["[RECONDO_HOSTAGE] Registered location '%1' with Intel system (hostages: %2)", _marker, _hostageNamesAtLocation];
        };
    } forEach _hostageMarkers;
};

// ========================================
// ADD HOSTAGE TURN-IN ACTION
// ========================================

if (_linkedToIntel && !_allRescued) then {
    [_settings] call Recondo_fnc_addHostageTurnIn;
};

// ========================================
// CREATE TRIGGERS OR SPAWN IMMEDIATELY
// ========================================

if (!_allRescued) then {
    // Create triggers/spawn for hostage locations
    {
        private _marker = _x;
        private _compositionData = _compositionMap getOrDefault [_marker, selectRandom _compositionPool];
        private _composition = _compositionData select 0;  // Name
        private _compIsModPath = _compositionData select 1;  // isModPath flag
        private _hostagesAtMarker = _hostageAssignments getOrDefault [_marker, []];
        
        if (_spawnMode == "immediate") then {
            // Spawn immediately
            [_settings, _marker, _composition, _hostagesAtMarker, _compIsModPath] call Recondo_fnc_spawnHostageComposition;
        } else {
            // Create proximity trigger
            [_settings, _marker, _composition, _hostagesAtMarker, _compIsModPath] call Recondo_fnc_createHostageTrigger;
        };
        
        // Create debug marker
        if (_debugMarkers) then {
            private _debugMkr = createMarker [format ["HOSTAGE_debug_%1", _marker], getMarkerPos _marker];
            _debugMkr setMarkerType "mil_objective";
            _debugMkr setMarkerColor "ColorBlue";
            _debugMkr setMarkerText format ["HOSTAGES: %1", count _hostagesAtMarker];
        };
    } forEach _hostageMarkers;
};

// Create decoy triggers
{
    private _decoyMarker = _x;
    private _decoyCompositionData = _compositionMap getOrDefault [_decoyMarker, selectRandom _compositionPool];
    private _decoyComposition = _decoyCompositionData select 0;  // Name
    private _decoyCompIsModPath = _decoyCompositionData select 1;  // isModPath flag
    
    if (_spawnMode == "immediate") then {
        // Spawn decoy immediately (uses HVT composition spawner)
        [_settings, _decoyMarker, _decoyComposition, false, _decoyCompIsModPath] call Recondo_fnc_spawnHVTComposition;
        
        // Roll for decoy AI
        if (random 1 < _decoyAIChance) then {
            [{
                params ["_settings", "_marker"];
                private _pos = getMarkerPos _marker;
                [_settings, _marker, _pos] call Recondo_fnc_spawnHVTAI;
            }, [_settings, _decoyMarker], 5] call CBA_fnc_waitAndExecute;
        };
    } else {
        // Create proximity trigger for decoy
        [_settings, _decoyMarker, _decoyComposition, _decoyCompIsModPath] call Recondo_fnc_createHostageDecoyTrigger;
    };
    
    // Create debug marker for decoy
    if (_debugMarkers) then {
        private _debugMkr = createMarker [format ["HOSTAGE_decoy_debug_%1", _decoyMarker], getMarkerPos _decoyMarker];
        _debugMkr setMarkerType "mil_dot";
        _debugMkr setMarkerColor "ColorOrange";
        _debugMkr setMarkerText "DECOY";
    };
} forEach _decoyMarkers;

// ========================================
// CREATE SMELL TRIGGERS
// ========================================

if (_enableSmellHints) then {
    // Create smell triggers for hostage locations
    {
        [_settings, _x] call Recondo_fnc_createHostageSmellTrigger;
    } forEach _hostageMarkers;
    
    // Create smell triggers for decoy locations (same hints)
    {
        [_settings, _x] call Recondo_fnc_createHostageSmellTrigger;
    } forEach _decoyMarkers;
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_HOSTAGE] Created smell triggers for %1 locations (%2 hostage + %3 decoy)", 
            count _hostageMarkers + count _decoyMarkers, count _hostageMarkers, count _decoyMarkers];
    };
};

// ========================================
// START NIGHT LIGHT LOOP
// ========================================

if (_enableNightLights && !RECONDO_HOSTAGE_NIGHT_LIGHT_LOOP_STARTED) then {
    RECONDO_HOSTAGE_NIGHT_LIGHTS_ENABLED = true;
    publicVariable "RECONDO_HOSTAGE_NIGHT_LIGHTS_ENABLED";
    
    RECONDO_HOSTAGE_NIGHT_LIGHT_LOOP_STARTED = true;
    [] call Recondo_fnc_updateHostageNightLights;
    
    if (_debugLogging) then {
        diag_log "[RECONDO_HOSTAGE] Night light update loop started";
    };
};

// ========================================
// LOG INITIALIZATION
// ========================================

private _totalLocations = count _hostageMarkers + count _decoyMarkers;
private _rescuedCount = {
    private _hostageId = format ["%1_hostage_%2", _instanceId, _x];
    _hostageId in RECONDO_HOSTAGE_RESCUED
} count [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];  // Check first 10 indices
_rescuedCount = _rescuedCount min _hostageCount;

private _statusText = if (_allRescued) then { "COMPLETE" } else { format ["%1/%2 rescued", _rescuedCount, _hostageCount] };

diag_log format ["[RECONDO_HOSTAGE] '%1' initialized: %2, Locations: %3 (%4 hostage + %5 decoy), Hostages: %6", 
    _objectiveName, _statusText, _totalLocations, count _hostageMarkers, count _decoyMarkers, _hostageCount];

if (_debugLogging) then {
    diag_log "[RECONDO_HOSTAGE] === Objective Hostages Module Settings ===";
    diag_log format ["[RECONDO_HOSTAGE] Instance ID: %1", _instanceId];
    diag_log format ["[RECONDO_HOSTAGE] Marker Prefix: %1", _markerPrefix];
    diag_log format ["[RECONDO_HOSTAGE] Hostage Locations: %1", _hostageMarkers];
    diag_log format ["[RECONDO_HOSTAGE] Decoy Locations: %1", _decoyMarkers];
    diag_log format ["[RECONDO_HOSTAGE] Compositions: %1", _compositions];
    diag_log format ["[RECONDO_HOSTAGE] Distribution Mode: %1", _distributionMode];
    diag_log format ["[RECONDO_HOSTAGE] Spawn Mode: %1", _spawnMode];
    diag_log format ["[RECONDO_HOSTAGE] Linked to Intel: %1", _linkedToIntel];
};
