/*
    Recondo_fnc_moduleCampsRandom
    Main initialization for Camps - Random module
    
    Description:
        Spawns small enemy campsites with intel at random marker locations.
        Camps are NOT persistent between mission restarts.
        Features 2-3 AI in sitting animations that stand up when alerted.
        Integrates with Intel system for location reveals.
    
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
    diag_log "[RECONDO_CAMPS] Module not activated.";
};

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

private _campName = _logic getVariable ["campname", "Enemy Camp"];
private _campDesc = _logic getVariable ["campdesc", "A small enemy campsite with potential intelligence."];
private _markerPrefix = _logic getVariable ["markerprefix", "CAMP_"];
private _spawnPercentage = _logic getVariable ["spawnpercentage", 0.5];

// Composition Pool (individual checkboxes)
private _compVCCamp1 = _logic getVariable ["comp_vc_camp1", false];
private _compVCCamp2 = _logic getVariable ["comp_vc_camp2", false];
private _customCompPath = _logic getVariable ["customcomppath", "compositions"];
private _customCompositionsRaw = _logic getVariable ["customcompositions", ""];

// Spawning Settings
private _spawnMode = _logic getVariable ["spawnmode", 1];
private _triggerRadius = _logic getVariable ["triggerradius", 500];
private _triggerSideNum = _logic getVariable ["triggerside", 1];
private _clearRadius = _logic getVariable ["clearradius", 15];
private _simulationDistance = _logic getVariable ["simulationdistance", 150];
private _useSimpleObjects = _logic getVariable ["usesimpleobjects", true];
private _simpleObjectExclusionsRaw = _logic getVariable ["simpleobjectexclusions", ""];

// AI Settings
private _sentryClassnamesRaw = _logic getVariable ["sentryclassnames", ""];
private _sentryMinCount = _logic getVariable ["sentrymincount", 2];
private _sentryMaxCount = _logic getVariable ["sentrymaxcount", 3];
private _sentrySideNum = _logic getVariable ["sentryside", 0];
private _sentryAnimationsRaw = _logic getVariable ["sentryanimations", "AmovPsitMstpSrasWrflDnon, AmovPsitMstpSrasWrflDnon_WeaponCheck1, AmovPsitMstpSrasWrflDnon_WeaponCheck2, AmovPsitMstpSrasWrflDnon_Smoking"];

// Intel Object Settings
private _enableIntelObject = _logic getVariable ["enableintelobject", true];
private _intelObjectClassname = _logic getVariable ["intelobjectclassname", "Land_File1_F"];
private _intelObjectActionText = _logic getVariable ["intelobjectactiontext", "Take Documents"];
private _intelObjectDisplayName = _logic getVariable ["intelobjectdisplayname", "Field Documents"];
private _intelObjectItemClassname = _logic getVariable ["intelobjectitemclassname", ""];

// Intel Unit Settings
private _enableIntelUnit = _logic getVariable ["enableintelunit", false];
private _intelUnitChance = _logic getVariable ["intelunitchance", 0.5];

// Intel Integration
private _intelWeight = _logic getVariable ["intelweight", 3];

// Smell Hints
private _enableSmellHints = _logic getVariable ["enablesmellhints", true];
private _smellHintRadius = _logic getVariable ["smellhintradius", 150];
private _smellHintMessagesRaw = _logic getVariable ["smellhintmessages", "The smell of woodsmoke drifts on the breeze...,A faint campfire scent hangs in the air...,You catch a whiff of smoke nearby...,Something is burning nearby..."];

// Debug
private _debugLogging = _logic getVariable ["debuglogging", false];
private _debugMarkers = _logic getVariable ["debugmarkers", false];

// ========================================
// PARSE CONFIGURATIONS
// ========================================

// Parse sentry classnames
private _sentryClassnames = if (_sentryClassnamesRaw != "") then {
    [_sentryClassnamesRaw] call Recondo_fnc_parseClassnames
} else { [] };

// Parse sentry animations
private _sentryAnimations = if (_sentryAnimationsRaw != "") then {
    ((_sentryAnimationsRaw splitString ",") apply { _x trim [" ", 0] }) select { _x != "" }
} else {
    ["AmovPsitMstpSrasWrflDnon", "AmovPsitMstpSrasWrflDnon_WeaponCheck1", "AmovPsitMstpSrasWrflDnon_WeaponCheck2", "AmovPsitMstpSrasWrflDnon_Smoking"]
};

// Parse simple object exclusions (one per line or comma-separated)
private _simpleObjectExclusions = if (_simpleObjectExclusionsRaw != "") then {
    ((_simpleObjectExclusionsRaw splitString (toString [10, 13] + ",")) apply { _x trim [" ", 0] }) select { _x != "" }
} else { [] };

// ========================================
// BUILD COMPOSITION POOL
// ========================================
// Pool format: [compositionName, isModPath]

private _compositionPool = [];

// Add mod compositions based on enabled checkboxes
if (_compVCCamp1) then { _compositionPool pushBack ["VC_camp1.sqe", true]; };
if (_compVCCamp2) then { _compositionPool pushBack ["VC_camp2.sqe", true]; };

// Parse and add custom compositions from mission folder
private _customCompositions = if (_customCompositionsRaw != "") then {
    ((_customCompositionsRaw splitString (toString [10, 13] + ",")) apply { _x trim [" ", 0] }) select { _x != "" && !(_x select [0, 2] == "//") }
} else { [] };

{
    _compositionPool pushBack [_x, false]; // false = mission path
} forEach _customCompositions;

// Validate composition pool
if (count _compositionPool == 0) exitWith {
    diag_log format ["[RECONDO_CAMPS] ERROR: No compositions enabled for '%1'. Check at least one checkbox or add custom compositions.", _campName];
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_CAMPS] Composition pool built: %1 entries", count _compositionPool];
    diag_log format ["[RECONDO_CAMPS] Pool contents: %1", _compositionPool];
};

// Parse smell hint messages
private _smellHintMessages = ((_smellHintMessagesRaw splitString ",") apply { _x trim [" ", 0] }) select { _x != "" };

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

if (_markerPrefix == "") exitWith {
    diag_log "[RECONDO_CAMPS] ERROR: No marker prefix specified. Module disabled.";
};

if (count _sentryClassnames == 0) exitWith {
    diag_log "[RECONDO_CAMPS] ERROR: No sentry classnames specified. Module disabled.";
};

// ========================================
// GENERATE UNIQUE INSTANCE ID
// ========================================

private _instanceId = format ["campsrandom_%1_%2", _campName, count RECONDO_CAMPSRANDOM_INSTANCES];

// ========================================
// STORE SETTINGS
// ========================================

private _settings = createHashMapFromArray [
    ["instanceId", _instanceId],
    ["campName", _campName],
    ["campDesc", _campDesc],
    ["markerPrefix", _markerPrefix],
    ["spawnPercentage", _spawnPercentage],
    ["compositionPool", _compositionPool],
    ["customCompPath", _customCompPath],
    ["spawnMode", _spawnMode],
    ["triggerRadius", _triggerRadius],
    ["triggerSide", _triggerSide],
    ["clearRadius", _clearRadius],
    ["simulationDistance", _simulationDistance],
    ["useSimpleObjects", _useSimpleObjects],
    ["simpleObjectExclusions", _simpleObjectExclusions],
    ["sentryClassnames", _sentryClassnames],
    ["sentryMinCount", _sentryMinCount],
    ["sentryMaxCount", _sentryMaxCount],
    ["sentrySide", _sentrySide],
    ["sentryAnimations", _sentryAnimations],
    ["enableIntelObject", _enableIntelObject],
    ["intelObjectClassname", _intelObjectClassname],
    ["intelObjectActionText", _intelObjectActionText],
    ["intelObjectDisplayName", _intelObjectDisplayName],
    ["intelObjectItemClassname", _intelObjectItemClassname],
    ["enableIntelUnit", _enableIntelUnit],
    ["intelUnitChance", _intelUnitChance],
    ["intelWeight", _intelWeight],
    ["enableSmellHints", _enableSmellHints],
    ["smellHintRadius", _smellHintRadius],
    ["smellHintMessages", _smellHintMessages],
    ["debugLogging", _debugLogging],
    ["debugMarkers", _debugMarkers]
];

RECONDO_CAMPSRANDOM_INSTANCES pushBack _settings;
publicVariable "RECONDO_CAMPSRANDOM_INSTANCES";

// ========================================
// SELECT RANDOM MARKERS
// ========================================

private _selectedMarkers = [_markerPrefix, _spawnPercentage, _debugLogging] call Recondo_fnc_selectCampMarkers;

if (count _selectedMarkers == 0) exitWith {
    diag_log format ["[RECONDO_CAMPS] WARNING: No markers selected for '%1'. Module disabled.", _campName];
};

// Assign random compositions to each marker from pool
// Pool format: [compositionName, isModPath]
private _compositionMap = []; // [markerId, compositionName, isModPath]
{
    private _compData = selectRandom _compositionPool;
    _compData params ["_comp", "_isModPath"];
    _compositionMap pushBack [_x, _comp, _isModPath];
} forEach _selectedMarkers;

// Store composition map in settings
_settings set ["compositionMap", _compositionMap];

if (_debugLogging) then {
    diag_log format ["[RECONDO_CAMPS] Selected %1 markers for '%2'", count _selectedMarkers, _campName];
    {
        _x params ["_marker", "_comp", "_isModPath"];
        diag_log format ["[RECONDO_CAMPS]   - %1: %2 (mod: %3)", _marker, _comp, _isModPath];
    } forEach _compositionMap;
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

_settings set ["linkedToIntel", _linkedToIntel];

// ========================================
// REGISTER WITH INTEL SYSTEM
// ========================================

if (_linkedToIntel) then {
    {
        _x params ["_markerId", "_comp", "_isModPath"];
        
        private _markerPos = getMarkerPos _markerId;
        private _targetId = format ["%1_%2", _instanceId, _markerId];
        
        // Register with Intel system
        ["camp", _targetId, _markerPos, _campName, _intelWeight] call Recondo_fnc_registerIntelTarget;
        
        if (_debugLogging) then {
            diag_log format ["[RECONDO_CAMPS] Registered '%1' at %2 with Intel system (weight: %3)", _campName, _markerId, _intelWeight];
        };
    } forEach _compositionMap;
    
    diag_log format ["[RECONDO_CAMPS] Registered %1 '%2' camps with Intel system", count _selectedMarkers, _campName];
};

// ========================================
// SPAWN OR CREATE TRIGGERS
// ========================================

{
    _x params ["_markerId", "_composition", "_isModPath"];
    
    // Track active camp
    RECONDO_CAMPSRANDOM_ACTIVE pushBack [_instanceId, _markerId, _composition, _isModPath, "pending"];
    
    if (_spawnMode == 0) then {
        // Immediate spawn
        [_settings, _markerId, _composition, _isModPath] call Recondo_fnc_spawnCamp;
    } else {
        // Proximity trigger
        [_settings, _markerId, _composition, _isModPath] call Recondo_fnc_createCampTrigger;
    };
    
    // Create debug markers
    if (_debugMarkers) then {
        private _markerPos = getMarkerPos _markerId;
        private _debugMarker = createMarker [format ["RECONDO_CAMP_DEBUG_%1", _markerId], _markerPos];
        _debugMarker setMarkerShape "ICON";
        _debugMarker setMarkerType "mil_triangle";
        _debugMarker setMarkerColor "ColorOrange";
        _debugMarker setMarkerText format ["%1", _campName];
    };
} forEach _compositionMap;

publicVariable "RECONDO_CAMPSRANDOM_ACTIVE";

// ========================================
// CREATE SMELL TRIGGERS
// ========================================

if (_enableSmellHints) then {
    {
        _x params ["_markerId", "_composition", "_isModPath"];
        [_settings, _markerId] call Recondo_fnc_createCampSmellTrigger;
    } forEach _compositionMap;
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_CAMPS] Created smell triggers for %1 camps", count _compositionMap];
    };
};

// ========================================
// LOG INITIALIZATION
// ========================================

diag_log format ["[RECONDO_CAMPS] '%1' initialized: %2 camps, Spawn Mode: %3, Intel Linked: %4",
    _campName, count _selectedMarkers, if (_spawnMode == 0) then { "Immediate" } else { "Proximity" }, _linkedToIntel];

if (_debugLogging) then {
    diag_log "[RECONDO_CAMPS] === Camps Random Settings ===";
    diag_log format ["[RECONDO_CAMPS] Instance ID: %1", _instanceId];
    diag_log format ["[RECONDO_CAMPS] Marker Prefix: %1", _markerPrefix];
    diag_log format ["[RECONDO_CAMPS] Composition Pool: %1 entries", count _compositionPool];
    diag_log format ["[RECONDO_CAMPS] Sentry Classnames: %1", _sentryClassnames];
    diag_log format ["[RECONDO_CAMPS] Intel Object Enabled: %1", _enableIntelObject];
    diag_log format ["[RECONDO_CAMPS] Intel Unit Enabled: %1", _enableIntelUnit];
};
