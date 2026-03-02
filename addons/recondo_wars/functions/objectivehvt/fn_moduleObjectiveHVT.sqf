/*
    Recondo_fnc_moduleObjectiveHVT
    Main initialization for Objective HVT module
    
    Description:
        Creates a High Value Target capture objective. One location is
        randomly selected as the real HVT location, others become decoys.
        HVT must be brought to Intel turn-in location to complete.
    
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
    diag_log "[RECONDO_HVT] Module not activated.";
};

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

// Profile Pool Settings (individual checkboxes)
private _profileHVT1 = _logic getVariable ["profile_hvt1", false];
private _profileHVT2 = _logic getVariable ["profile_hvt2", false];
private _profileHVT3 = _logic getVariable ["profile_hvt3", false];
private _profileVCTaxman = _logic getVariable ["profile_vc_taxman", false];

// General
private _objectiveName = _logic getVariable ["objectivename", "High Value Target"];
private _objectiveDescription = _logic getVariable ["objectivedescription", ""];
private _intelBoardCategoryName = _logic getVariable ["intelboardcategoryname", ""];
private _markerPrefix = _logic getVariable ["markerprefix", "HVT_"];

// Composition Pool (individual checkboxes)
private _compHVTBASE1 = _logic getVariable ["comp_hvtbase_1", false];
private _compHVTBASE2 = _logic getVariable ["comp_hvtbase_2", false];
private _compHVTBASE3 = _logic getVariable ["comp_hvtbase_3", false];
private _compVCcamp1 = _logic getVariable ["comp_vc_camp1", false];
private _compVCcamp2 = _logic getVariable ["comp_vc_camp2", false];
private _compVCPOWcamp1 = _logic getVariable ["comp_vc_pow_camp1", false];
private _compVCPOWcamp2 = _logic getVariable ["comp_vc_pow_camp2", false];
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

// HVT (values populated from profile)
private _hvtClassname = "";  // Classname from profile
private _hvtName = "";       // Name from profile
private _hvtPhoto = "";      // Photo path from profile
private _hvtBackground = ""; // Background from profile
private _hvtSide = _logic getVariable ["hvtside", "EAST"];
private _hvtFace = "";       // Face from profile
private _hvtIdentity = "";   // Identity class from profile
private _hvtLoadout = [];    // Full loadout array from profile
private _hvtSpeaker = "";    // Voice/speaker class from profile
private _hvtTurnInRadius = _logic getVariable ["hvtturninradius", 10];
private _hvtEnableWandering = _logic getVariable ["hvtenablewandering", false];
private _hvtWanderWaitTime = _logic getVariable ["hvtwanderwaittime", 15];
private _hvtWanderTimeout = _logic getVariable ["hvtwandertimeout", 60];

// Decoys
private _decoyCount = _logic getVariable ["decoycount", 3];
private _decoyAIChance = _logic getVariable ["decoyaichance", 0.5];

// Garrison AI
private _aiSide = _logic getVariable ["aiside", "EAST"];
private _garrisonClassnamesRaw = _logic getVariable ["garrisonclassnames", ""];
private _garrisonMin = _logic getVariable ["garrisonmin", 2];
private _garrisonMax = _logic getVariable ["garrisonmax", 4];
private _enableRovingSentry = _logic getVariable ["enablerovingsentry", true];
private _invulnTime = _logic getVariable ["invulntime", 30];

// Civilians
private _enableCivilians = _logic getVariable ["enablecivilians", true];
private _civilianChance = _logic getVariable ["civilianchance", 0.5];
private _civilianClassnamesRaw = _logic getVariable ["civilianclassnames", ""];

// Animals
private _enableAnimals = _logic getVariable ["enableanimals", true];
private _animalChance = _logic getVariable ["animalchance", 0.75];
private _animalClassnamesRaw = _logic getVariable ["animalclassnames", ""];
private _animalMin = _logic getVariable ["animalmin", 3];
private _animalMax = _logic getVariable ["animalmax", 6];

// Night Lights
private _enableNightLights = _logic getVariable ["enablenightlights", true];

// Smell Hints
private _enableSmellHints = _logic getVariable ["enablesmellhints", true];
private _smellHintRadius = _logic getVariable ["smellhintradius", 300];
private _smellHintMessagesRaw = _logic getVariable ["smellhintmessages", "A faint smell of cigarette smoke drifts on the breeze...,The air carries the scent of wood smoke...,You catch a whiff of cooking fires nearby...,Something burning... somewhere close."];

// Intel
private _intelWeight = _logic getVariable ["intelweight", 0.5];
private _intelRevealMessagesDocRaw = _logic getVariable ["intelrevealmessagesdoc", ""];
private _intelRevealMessagesPOWRaw = _logic getVariable ["intelrevealmessagespow", ""];
private _intelConfirmMessage = _logic getVariable ["intelconfirmmessage", "This confirms earlier reports about %NAME% near grid %GRID%."];

// Debug
private _debugLogging = _logic getVariable ["debuglogging", false];
private _debugMarkers = _logic getVariable ["debugmarkers", false];

// Invincibility
private _makeInvincible = _logic getVariable ["makeinvincible", false];

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
// PROFILE SYSTEM (required - one random profile selected)
// ========================================

// Build profile list from enabled checkboxes
private _profilePoolList = [];
if (_profileHVT1) then { _profilePoolList pushBack "HVT1.sqf"; };
if (_profileHVT2) then { _profilePoolList pushBack "HVT2.sqf"; };
if (_profileHVT3) then { _profilePoolList pushBack "HVT3.sqf"; };
if (_profileVCTaxman) then { _profilePoolList pushBack "VC_Taxman.sqf"; };

// Validate - at least one profile must be selected
if (count _profilePoolList == 0) exitWith {
    diag_log format ["[RECONDO_HVT] ERROR: No HVT profiles selected for '%1'. Check at least one profile in the module settings.", _objectiveName];
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_HVT] Available HVT profiles: %1", _profilePoolList];
};

// Check for saved profile (persistence)
private _profilePersistenceKey = format ["HVT_%1_PROFILE", _objectiveName];
private _savedProfileFile = [_profilePersistenceKey, ""] call Recondo_fnc_getSaveData;

private _profileToLoad = [];
private _selectedProfileFile = "";

if (!isNil "_savedProfileFile" && {_savedProfileFile isEqualType "" && {_savedProfileFile != ""}}) then {
    // Use saved profile filename
    _profileToLoad = [_savedProfileFile];
    _selectedProfileFile = _savedProfileFile;
    if (_debugLogging) then {
        diag_log format ["[RECONDO_HVT] Loading saved profile: %1", _savedProfileFile];
    };
} else {
    // No saved profile - select one random profile and save
    _selectedProfileFile = selectRandom _profilePoolList;
    _profileToLoad = [_selectedProfileFile];
    [_profilePersistenceKey, _selectedProfileFile] call Recondo_fnc_setSaveData;
    if (_debugLogging) then {
        diag_log format ["[RECONDO_HVT] Selected random profile: %1", _selectedProfileFile];
    };
};

// Load the selected profile from mod
private _loadedProfiles = ["hvt", _profileToLoad, false, "", _debugLogging] call Recondo_fnc_loadProfiles;

if (count _loadedProfiles == 0) exitWith {
    diag_log format ["[RECONDO_HVT] ERROR: Failed to load HVT profile '%1' for '%2'. Check profile file exists.", _selectedProfileFile, _objectiveName];
};

// Get profile data
private _profile = _loadedProfiles select 0;

// Set all HVT values from profile
_hvtName = _profile getOrDefault ["name", "Unknown Target"];
_hvtClassname = _profile getOrDefault ["classname", "C_man_1"];
_hvtPhoto = _profile getOrDefault ["photo", "\recondo_wars\images\intel\default_photo.paa"];
_hvtBackground = _profile getOrDefault ["background", ""];
_hvtFace = _profile getOrDefault ["face", ""];
_hvtIdentity = _profile getOrDefault ["identity", ""];
_hvtLoadout = _profile getOrDefault ["loadout", []];
_hvtSpeaker = _profile getOrDefault ["speaker", ""];

if (_debugLogging) then {
    diag_log format ["[RECONDO_HVT] Using profile: %1 (%2) face: %3", _hvtName, _hvtClassname, if (_hvtFace != "") then {_hvtFace} else {"default"}];
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

// Parse and add custom compositions from mission folder
private _customCompositions = [_customActiveCompsRaw] call _fnc_parseClassnames;
{
    _compositionPool pushBack [_x, false];  // false = mission path
} forEach _customCompositions;

if (_debugLogging) then {
    diag_log format ["[RECONDO_HVT] Composition pool built: %1 compositions", count _compositionPool];
    diag_log format ["[RECONDO_HVT] Pool contents: %1", _compositionPool];
};

// Validate composition pool
if (count _compositionPool == 0) exitWith {
    diag_log format ["[RECONDO_HVT] ERROR: No compositions defined for '%1'. Check at least one checkbox or add custom compositions.", _objectiveName];
};

// Legacy compatibility: create _compositions array (just names for settings storage)
private _compositions = _compositionPool apply { _x select 0 };
private _garrisonClassnames = [_garrisonClassnamesRaw] call _fnc_parseClassnames;
private _civilianClassnames = [_civilianClassnamesRaw] call _fnc_parseClassnames;
private _animalClassnames = [_animalClassnamesRaw] call _fnc_parseClassnames;
private _intelRevealMessagesDoc = [_intelRevealMessagesDocRaw] call _fnc_parseClassnames;
private _intelRevealMessagesPOW = [_intelRevealMessagesPOWRaw] call _fnc_parseClassnames;
private _smellHintMessages = [_smellHintMessagesRaw] call _fnc_parseClassnames;

// Use default photo path if none specified
if (_hvtPhoto == "") then {
    _hvtPhoto = "\recondo_wars\images\intel\default_photo.paa";
};

// Convert side strings
private _aiSideEnum = switch (toUpper _aiSide) do {
    case "EAST": { east };
    case "WEST": { west };
    case "GUER": { independent };
    default { east };
};

private _hvtSideEnum = switch (toUpper _hvtSide) do {
    case "EAST": { east };
    case "WEST": { west };
    case "GUER": { independent };
    case "CIV": { civilian };
    default { east };
};

// ========================================
// GENERATE INSTANCE ID
// ========================================

private _instanceId = format ["hvt_%1_%2", _objectiveName, count RECONDO_HVT_INSTANCES];

// ========================================
// STORE SETTINGS
// ========================================

private _settings = createHashMapFromArray [
    ["instanceId", _instanceId],
    ["objectiveName", _objectiveName],
    ["hvtName", _hvtName],
    ["hvtPhoto", _hvtPhoto],
    ["hvtBackground", _hvtBackground],
    ["objectiveDescription", _objectiveDescription],
    ["intelBoardCategoryName", _intelBoardCategoryName],
    ["markerPrefix", _markerPrefix],
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
    ["hvtClassname", _hvtClassname],
    ["hvtSide", _hvtSideEnum],
    ["hvtFace", _hvtFace],
    ["hvtIdentity", _hvtIdentity],
    ["hvtLoadout", _hvtLoadout],
    ["hvtSpeaker", _hvtSpeaker],
    ["hvtTurnInRadius", _hvtTurnInRadius],
    ["hvtEnableWandering", _hvtEnableWandering],
    ["hvtWanderWaitTime", _hvtWanderWaitTime],
    ["hvtWanderTimeout", _hvtWanderTimeout],
    ["decoyCount", _decoyCount],
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
    ["enableNightLights", _enableNightLights],
    ["enableSmellHints", _enableSmellHints],
    ["smellHintRadius", _smellHintRadius],
    ["smellHintMessages", _smellHintMessages],
    ["intelWeight", _intelWeight],
    ["intelRevealMessagesDoc", _intelRevealMessagesDoc],
    ["intelRevealMessagesPOW", _intelRevealMessagesPOW],
    ["intelConfirmMessage", _intelConfirmMessage],
    ["debugLogging", _debugLogging],
    ["debugMarkers", _debugMarkers],
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

RECONDO_HVT_INSTANCES pushBack _settings;
publicVariable "RECONDO_HVT_INSTANCES";

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
    diag_log format ["[RECONDO_HVT] Linked to Intel module: %1", _linkedToIntel];
};

if (!_linkedToIntel) then {
    diag_log "[RECONDO_HVT] WARNING: Not synced to Intel module. Turn-in and intel features will not work.";
};

// ========================================
// PERSISTENCE - LOAD SAVED DATA
// ========================================

private _persistenceKey = format ["HVT_%1", _objectiveName];
private _savedHVTMarker = [_persistenceKey + "_HVTMARKER"] call Recondo_fnc_getSaveData;
private _savedDecoyMarkers = [_persistenceKey + "_DECOYMARKERS"] call Recondo_fnc_getSaveData;
private _savedCompositions = [_persistenceKey + "_COMPOSITIONS"] call Recondo_fnc_getSaveData;
private _savedCaptured = [_persistenceKey + "_CAPTURED"] call Recondo_fnc_getSaveData;

// ========================================
// SELECT HVT AND DECOY LOCATIONS
// ========================================

private _hvtMarker = "";
private _decoyMarkers = [];
private _compositionMap = createHashMap;  // marker -> composition name

if (!isNil "_savedHVTMarker" && {_savedHVTMarker isEqualType "" && {_savedHVTMarker != ""}}) then {
    // Use saved locations
    _hvtMarker = _savedHVTMarker;
    _decoyMarkers = if (_savedDecoyMarkers isEqualType []) then { _savedDecoyMarkers } else { [] };
    _compositionMap = if (_savedCompositions isEqualType createHashMap) then { _savedCompositions } else { createHashMap };
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_HVT] Loaded saved state - HVT: %1, Decoys: %2", _hvtMarker, _decoyMarkers];
    };
} else {
    // Generate new locations
    private _result = [_markerPrefix, _decoyCount, _debugLogging] call Recondo_fnc_selectHVTLocation;
    _result params ["_selectedHVT", "_selectedDecoys"];
    
    _hvtMarker = _selectedHVT;
    _decoyMarkers = _selectedDecoys;
    
    // Assign random compositions from pool (stores [name, isModPath] pairs)
    _compositionMap set [_hvtMarker, selectRandom _compositionPool];
    {
        _compositionMap set [_x, selectRandom _compositionPool];
    } forEach _decoyMarkers;
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_HVT] Generated new locations - HVT: %1, Decoys: %2", _hvtMarker, _decoyMarkers];
    };
    
    // Save to persistence
    [_persistenceKey + "_HVTMARKER", _hvtMarker] call Recondo_fnc_setSaveData;
    [_persistenceKey + "_DECOYMARKERS", _decoyMarkers] call Recondo_fnc_setSaveData;
    [_persistenceKey + "_COMPOSITIONS", _compositionMap] call Recondo_fnc_setSaveData;
    [_persistenceKey + "_CAPTURED", false] call Recondo_fnc_setSaveData;
};

// Check if already captured
private _isCaptured = if (_savedCaptured isEqualTo true) then { true } else { false };

if (_isCaptured) then {
    RECONDO_HVT_CAPTURED pushBack _instanceId;
    publicVariable "RECONDO_HVT_CAPTURED";
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_HVT] HVT '%1' already captured, skipping spawn setup", _hvtName];
    };
};

// Store location data
RECONDO_HVT_LOCATIONS set [_instanceId, [_hvtMarker, _decoyMarkers]];
publicVariable "RECONDO_HVT_LOCATIONS";

// ========================================
// REGISTER WITH INTEL SYSTEM
// ========================================

if (_linkedToIntel && !_isCaptured) then {
    private _markerPos = getMarkerPos _hvtMarker;
    private _targetId = format ["%1_%2", _instanceId, _hvtMarker];
    
    // Register with Intel system
    [
        "hvt",
        _targetId,
        _markerPos,
        createHashMapFromArray [
            ["name", _objectiveName],
            ["hvtName", _hvtName],
            ["hvtPhoto", _hvtPhoto],
            ["hvtBackground", _hvtBackground],
            ["marker", _hvtMarker],
            ["revealMessagesDoc", _intelRevealMessagesDoc],
            ["revealMessagesPOW", _intelRevealMessagesPOW],
            ["confirmMessage", _intelConfirmMessage]
        ],
        _intelWeight
    ] call Recondo_fnc_registerIntelTarget;
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_HVT] Registered '%1' (%2) with Intel system", _hvtName, _hvtMarker];
    };
};

// ========================================
// ADD HVT TURN-IN ACTION
// ========================================

if (_linkedToIntel && !_isCaptured) then {
    // Add turn-in action to Intel turn-in objects
    [_settings] call Recondo_fnc_addHVTTurnIn;
};

// ========================================
// CREATE TRIGGERS OR SPAWN IMMEDIATELY
// ========================================

if (!_isCaptured) then {
    private _hvtCompositionData = _compositionMap getOrDefault [_hvtMarker, selectRandom _compositionPool];
    private _hvtComposition = _hvtCompositionData select 0;  // Name
    private _hvtCompIsModPath = _hvtCompositionData select 1;  // isModPath flag
    
    if (_spawnMode == "immediate") then {
        // Spawn HVT location immediately
        [_settings, _hvtMarker, _hvtComposition, true, _hvtCompIsModPath] call Recondo_fnc_spawnHVTComposition;
        
        // Spawn bad civis at real HVT location after composition sets up
        if (_badCiviMax > 0) then {
            [{
                params ["_settings", "_marker", "_pos"];
                [_settings, _marker, _pos] call Recondo_fnc_spawnBadCivis;
            }, [_settings, _hvtMarker, getMarkerPos _hvtMarker], 6] call CBA_fnc_waitAndExecute;
        };

        // Spawn civilians at HVT location
        if (_enableCivilians) then {
            [{
                params ["_settings", "_marker", "_pos"];
                [_settings, _marker, _pos] call Recondo_fnc_spawnHVTCivilians;
            }, [_settings, _hvtMarker, getMarkerPos _hvtMarker], 6] call CBA_fnc_waitAndExecute;
        };
    } else {
        // Create proximity trigger for HVT location
        [_settings, _hvtMarker, _hvtComposition, true, _hvtCompIsModPath] call Recondo_fnc_createHVTTrigger;
    };
    
    // Create smell trigger for HVT location
    if (_enableSmellHints && count _smellHintMessages > 0) then {
        [_settings, _hvtMarker] call Recondo_fnc_createSmellTrigger;
    };
    
    // Create debug marker for HVT
    if (_debugMarkers) then {
        private _debugMkr = createMarker [format ["HVT_debug_%1", _hvtMarker], getMarkerPos _hvtMarker];
        _debugMkr setMarkerType "mil_objective";
        _debugMkr setMarkerColor "ColorRed";
        _debugMkr setMarkerText format ["HVT: %1", _hvtName];
    };
};

// Create decoy triggers
{
    private _decoyMarker = _x;
    private _decoyCompositionData = _compositionMap getOrDefault [_decoyMarker, selectRandom _compositionPool];
    private _decoyComposition = _decoyCompositionData select 0;  // Name
    private _decoyCompIsModPath = _decoyCompositionData select 1;  // isModPath flag
    
    if (_spawnMode == "immediate") then {
        // Spawn decoy immediately
        [_settings, _decoyMarker, _decoyComposition, false, _decoyCompIsModPath] call Recondo_fnc_spawnHVTComposition;
        
        // Roll for decoy AI
        if (random 1 < _decoyAIChance) then {
            [{
                params ["_settings", "_marker"];
                private _pos = getMarkerPos _marker;
                [_settings, _marker, _pos] call Recondo_fnc_spawnHVTAI;
            }, [_settings, _decoyMarker], 5] call CBA_fnc_waitAndExecute;
        };

        // Spawn civilians at decoy location
        if (_enableCivilians) then {
            [{
                params ["_settings", "_marker", "_pos"];
                [_settings, _marker, _pos] call Recondo_fnc_spawnHVTCivilians;
            }, [_settings, _decoyMarker, getMarkerPos _decoyMarker], 6] call CBA_fnc_waitAndExecute;
        };
    } else {
        // Create proximity trigger for decoy
        [_settings, _decoyMarker, _decoyComposition, false, _decoyCompIsModPath] call Recondo_fnc_createDecoyTrigger;
    };
    
    // Create smell trigger for decoy location
    if (_enableSmellHints && count _smellHintMessages > 0) then {
        [_settings, _decoyMarker] call Recondo_fnc_createSmellTrigger;
    };
    
    // Create debug marker for decoy
    if (_debugMarkers) then {
        private _debugMkr = createMarker [format ["HVT_decoy_debug_%1", _decoyMarker], getMarkerPos _decoyMarker];
        _debugMkr setMarkerType "mil_dot";
        _debugMkr setMarkerColor "ColorOrange";
        _debugMkr setMarkerText "DECOY";
    };
} forEach _decoyMarkers;

// ========================================
// LOG INITIALIZATION
// ========================================

private _totalLocations = 1 + count _decoyMarkers;
private _statusText = if (_isCaptured) then { "CAPTURED" } else { "ACTIVE" };

diag_log format ["[RECONDO_HVT] '%1' (%2) initialized: %3, Locations: %4 (1 HVT + %5 decoys)", 
    _objectiveName, _hvtName, _statusText, _totalLocations, count _decoyMarkers];

if (_debugLogging) then {
    diag_log "[RECONDO_HVT] === Objective HVT Module Settings ===";
    diag_log format ["[RECONDO_HVT] Instance ID: %1", _instanceId];
    diag_log format ["[RECONDO_HVT] Marker Prefix: %1", _markerPrefix];
    diag_log format ["[RECONDO_HVT] HVT Location: %1", _hvtMarker];
    diag_log format ["[RECONDO_HVT] Decoy Locations: %1", _decoyMarkers];
    diag_log format ["[RECONDO_HVT] Compositions: %1", _compositions];
    diag_log format ["[RECONDO_HVT] Spawn Mode: %1", _spawnMode];
    diag_log format ["[RECONDO_HVT] Linked to Intel: %1", _linkedToIntel];
};

// ========================================
// START NIGHT LIGHT LOOP
// ========================================

if (_enableNightLights && !RECONDO_HVT_NIGHT_LIGHT_LOOP_STARTED) then {
    RECONDO_HVT_NIGHT_LIGHTS_ENABLED = true;
    publicVariable "RECONDO_HVT_NIGHT_LIGHTS_ENABLED";
    
    RECONDO_HVT_NIGHT_LIGHT_LOOP_STARTED = true;
    [] call Recondo_fnc_updateHVTNightLights;
    
    if (_debugLogging) then {
        diag_log "[RECONDO_HVT] Night lights enabled - starting update loop";
    };
};
