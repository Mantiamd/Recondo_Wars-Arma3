/*
    Recondo_fnc_moduleCivilianPOL
    Main initialization for Civilian - Patterns of Life module
    
    Description:
        Creates a system where civilians have homes, jobs, and daily routines.
        They wake up, go to work (fields, fishing), return home, and sleep.
        Night lights appear in occupied homes. Civilians flee from combat.
    
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
    diag_log "[RECONDO_CIVPOL] Module not activated.";
};

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

private _villageMarkerPrefix = _logic getVariable ["villagemarkerprefix", "VILLAGE_"];
private _fieldsMarkerPrefix = _logic getVariable ["fieldsmarkerprefix", "FIELDS_"];
private _fishermanMarkerPrefix = _logic getVariable ["fishermanmarkerprefix", "FISHERMAN_"];

private _civiliansPerVillage = _logic getVariable ["civilianspervillage", 3];
private _homeSearchRadius = _logic getVariable ["homesearchradius", 150];

private _spawnDistance = _logic getVariable ["spawndistance", 400];
private _despawnDistance = _logic getVariable ["despawndistance", 500];
private _triggerSide = _logic getVariable ["triggerside", "WEST"];

private _unitClassnamesRaw = _logic getVariable ["unitclassnames", "vn_c_men_01,vn_c_men_02,vn_c_men_03"];
private _documentDropChance = _logic getVariable ["documentdropchance", 10];
private _documentClass = _logic getVariable ["documentclass", "ACE_Documents"];

private _workAnimationsRaw = _logic getVariable ["workanimations", "AinvPknlMstpSnonWnonDnon_medic_1,AinvPknlMstpSnonWnonDnon_medic0,Acts_carFixingWheel"];
private _fishAnimationsRaw = _logic getVariable ["fishanimations", "AinvPknlMstpSlayWnonDnon_medic,Acts_PercMwlkSlowWrflDf_FlvG1"];

private _fleeOnCombat = _logic getVariable ["fleeoncombat", true];
private _combatDetectRadius = _logic getVariable ["combatdetectradius", 150];

private _fieldWorkRadius = _logic getVariable ["fieldworkradius", 30];
private _fishermanWorkRadius = _logic getVariable ["fishermanworkradius", 20];
private _workMoveDistanceMin = _logic getVariable ["workmovedistancemin", 5];
private _workMoveDistanceMax = _logic getVariable ["workmovedistancemax", 15];
private _workDurationMin = _logic getVariable ["workdurationmin", 15];
private _workDurationMax = _logic getVariable ["workdurationmax", 45];

private _enableNightLights = _logic getVariable ["enablenightlights", true];
private _lightBrightnessMin = _logic getVariable ["lightbrightnessmin", 0.02];
private _lightBrightnessMax = _logic getVariable ["lightbrightnessmax", 0.08];

private _debugLogging = _logic getVariable ["debuglogging", false];
private _debugMarkers = _logic getVariable ["debugmarkers", false];

// Sleeping bag classnames (spawned under civilians when sleeping)
private _sleepingBagClasses = [
    "Land_Sleeping_bag_brown_F",
    "Land_Sleeping_bag_blue_F",
    "Land_Sleeping_bag_F"
];

// Work area props
private _fieldPropsCount = _logic getVariable ["fieldpropscount", 4];
private _fishermanPropsCount = _logic getVariable ["fishermanpropscount", 4];
private _fieldPropsClassesRaw = _logic getVariable ["fieldpropsclasses", "Land_WoodenCart_F,Land_Sacks_goods_F,Land_Sack_F,Land_Basket_F"];
private _fishermanPropsClassesRaw = _logic getVariable ["fishermanpropsclasses", "Land_FishingGear_01_F,Land_FishingGear_02_F,Land_Cages_F,Land_CrabCages_F,Land_vn_boat_01_abandoned_blue_f,Land_vn_boat_03_abandoned_f,Land_vn_boat_02_abandoned_f,Land_vn_boat_01_abandoned_red_f,Land_RowBoat_V1_F,Land_RowBoat_V2_F"];

// ========================================
// PARSE STRING INPUTS
// ========================================

private _unitClassnames = [_unitClassnamesRaw] call Recondo_fnc_parseClassnames;
private _workAnimations = [_workAnimationsRaw] call Recondo_fnc_parseClassnames;
private _fishAnimations = [_fishAnimationsRaw] call Recondo_fnc_parseClassnames;
private _fieldPropsClasses = [_fieldPropsClassesRaw] call Recondo_fnc_parseClassnames;
private _fishermanPropsClasses = [_fishermanPropsClassesRaw] call Recondo_fnc_parseClassnames;

// Validate classnames
if (count _unitClassnames == 0) then {
    _unitClassnames = ["C_man_1", "C_man_polo_1_F", "C_man_polo_2_F"];
    diag_log "[RECONDO_CIVPOL] WARNING: No unit classnames specified, using defaults";
};

// Validate animations
if (count _workAnimations == 0) then {
    _workAnimations = ["AinvPknlMstpSnonWnonDnon_medic_1", "AinvPknlMstpSnonWnonDnon_medic0"];
};
if (count _fishAnimations == 0) then {
    _fishAnimations = ["AinvPknlMstpSlayWnonDnon_medic"];
};

// Validate props classes
if (count _fieldPropsClasses == 0) then {
    _fieldPropsClasses = ["Land_WoodenCart_F", "Land_Sacks_goods_F", "Land_Sack_F", "Land_Basket_F"];
};
if (count _fishermanPropsClasses == 0) then {
    _fishermanPropsClasses = ["Land_FishingGear_01_F", "Land_FishingGear_02_F", "Land_Cages_F", "Land_CrabCages_F"];
};

// ========================================
// STORE GLOBAL SETTINGS
// ========================================

RECONDO_CIVPOL_SETTINGS = createHashMapFromArray [
    ["villageMarkerPrefix", _villageMarkerPrefix],
    ["fieldsMarkerPrefix", _fieldsMarkerPrefix],
    ["fishermanMarkerPrefix", _fishermanMarkerPrefix],
    ["civiliansPerVillage", _civiliansPerVillage],
    ["homeSearchRadius", _homeSearchRadius],
    ["spawnDistance", _spawnDistance],
    ["despawnDistance", _despawnDistance],
    ["triggerSide", _triggerSide],
    ["unitClassnames", _unitClassnames],
    ["documentDropChance", _documentDropChance],
    ["documentClass", _documentClass],
    ["workAnimations", _workAnimations],
    ["fishAnimations", _fishAnimations],
    ["fleeOnCombat", _fleeOnCombat],
    ["combatDetectRadius", _combatDetectRadius],
    ["fieldWorkRadius", _fieldWorkRadius],
    ["fishermanWorkRadius", _fishermanWorkRadius],
    ["workMoveDistanceMin", _workMoveDistanceMin],
    ["workMoveDistanceMax", _workMoveDistanceMax],
    ["workDurationMin", _workDurationMin],
    ["workDurationMax", _workDurationMax],
    ["sleepingBagClasses", _sleepingBagClasses],
    ["fieldPropsCount", _fieldPropsCount],
    ["fishermanPropsCount", _fishermanPropsCount],
    ["fieldPropsClasses", _fieldPropsClasses],
    ["fishermanPropsClasses", _fishermanPropsClasses],
    ["enableNightLights", _enableNightLights],
    ["lightBrightnessMin", _lightBrightnessMin],
    ["lightBrightnessMax", _lightBrightnessMax],
    ["debugLogging", _debugLogging],
    ["debugMarkers", _debugMarkers]
];

publicVariable "RECONDO_CIVPOL_SETTINGS";

// Initialize village tracking
RECONDO_CIVPOL_VILLAGES = createHashMap;
publicVariable "RECONDO_CIVPOL_VILLAGES";
RECONDO_CIVPOL_ACTIVE_LIGHTS = [];

// ========================================
// LOAD PERSISTENCE DATA
// ========================================

[] call Recondo_fnc_loadCivilianPOL;

// ========================================
// FIND AND INITIALIZE VILLAGES
// ========================================

private _villageMarkers = allMapMarkers select { _x find _villageMarkerPrefix == 0 };

if (count _villageMarkers == 0) then {
    diag_log format ["[RECONDO_CIVPOL] WARNING: No village markers found with prefix '%1'", _villageMarkerPrefix];
} else {
    diag_log format ["[RECONDO_CIVPOL] Found %1 village markers", count _villageMarkers];
};

// Find job markers
private _fieldsMarkers = allMapMarkers select { _x find _fieldsMarkerPrefix == 0 };
private _fishermanMarkers = allMapMarkers select { _x find _fishermanMarkerPrefix == 0 };

RECONDO_CIVPOL_SETTINGS set ["fieldsMarkers", _fieldsMarkers];
RECONDO_CIVPOL_SETTINGS set ["fishermanMarkers", _fishermanMarkers];

if (_debugLogging) then {
    diag_log format ["[RECONDO_CIVPOL] Found %1 fields markers, %2 fisherman markers", 
        count _fieldsMarkers, count _fishermanMarkers];
};

// Initialize each village
{
    [_x] call Recondo_fnc_initVillage;
} forEach _villageMarkers;

// ========================================
// SETUP ACE INTERACTIONS (CLIENT-SIDE)
// ========================================

// Broadcast to all clients to add ACE interactions
[] remoteExec ["Recondo_fnc_addCivilianPOLAction", 0, true];

// ========================================
// START NIGHT LIGHT LOOP
// ========================================

if (_enableNightLights) then {
    [] call Recondo_fnc_nightLightLoop;
};

// ========================================
// SETUP PERSISTENCE HOOK
// ========================================

// Hook into the save system if persistence module is present
if (!isNil "RECONDO_PERSISTENCE_SETTINGS") then {
    // Add to auto-save (this gets called by fn_saveMission)
    RECONDO_CIVPOL_PERSISTENCE_ENABLED = true;
    
    if (_debugLogging) then {
        diag_log "[RECONDO_CIVPOL] Persistence integration enabled";
    };
};

// ========================================
// LOG INITIALIZATION
// ========================================

diag_log format ["[RECONDO_CIVPOL] Initialized: %1 villages, %2 civs/village, Spawn: %3m, Despawn: %4m",
    count _villageMarkers, _civiliansPerVillage, _spawnDistance, _despawnDistance];

if (_debugLogging) then {
    diag_log "[RECONDO_CIVPOL] === Settings ===";
    diag_log format ["[RECONDO_CIVPOL] Unit Classnames: %1", _unitClassnames];
    diag_log format ["[RECONDO_CIVPOL] Work Animations: %1", _workAnimations];
    diag_log format ["[RECONDO_CIVPOL] Fish Animations: %1", _fishAnimations];
    diag_log format ["[RECONDO_CIVPOL] Document Drop Chance: %1%%", _documentDropChance];
    diag_log format ["[RECONDO_CIVPOL] Night Lights: %1", _enableNightLights];
};
