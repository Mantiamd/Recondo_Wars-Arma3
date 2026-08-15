/*
    Recondo_fnc_moduleReinforcementWaves
    Main initialization for Reinforcement Waves module
    
    Description:
        Creates a detection zone where OPFOR units trigger reinforcement waves
        when they detect BLUFOR. Spawns progressive waves of pursuit groups.
        Multiple modules can be placed for different areas.
    
    Priority: 5 (Feature module)
    
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
    diag_log "[RECONDO_RW] Module not activated.";
};

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

// General Settings
private _reinforcementSideNum = _logic getVariable ["reinforcementside", 0];
private _targetSideNum = _logic getVariable ["targetside", 1];
private _reinforcementChance = _logic getVariable ["reinforcementchance", 1];
private _unitClassnamesRaw = _logic getVariable ["unitclassnames", ""];
private _maxActiveGroups = _logic getVariable ["maxactivegroups", 20];
private _releaseForceWalk = _logic getVariable ["releaseforcewalk", false];
private _spawnTrackerTeam = _logic getVariable ["spawntrackerteam", true];

// Detection Settings
private _triggerRadius = _logic getVariable ["triggerradius", 500];
private _detectionThreshold = _logic getVariable ["detectionthreshold", 1.5];
private _heightLimit = _logic getVariable ["heightlimit", 20];

// Spawn Settings
private _spawnDistance = _logic getVariable ["spawndistance", 300];
private _safetyDistance = _logic getVariable ["safetydistance", 200];

// Wave 1 Settings
private _wave1MinSize = _logic getVariable ["wave1minsize", 2];
private _wave1MaxSize = _logic getVariable ["wave1maxsize", 4];
private _soundInterval = _logic getVariable ["soundinterval", 30];
private _enableSilent = _logic getVariable ["enablesilent", false];
private _enableBambooSticks = _logic getVariable ["enablebamboosticks", true];
private _enableWhistling = _logic getVariable ["enablewhistling", false];
private _enableRadio = _logic getVariable ["enableradio", false];

// Side Group Settings (Wave 1 pincer from the players' flanks)
private _enableSideGroups = _logic getVariable ["enablesidegroups", true];
private _sideGroupDistance = _logic getVariable ["sidegroupdistance", 200];

// Dog Settings
private _dogSpawnChance = _logic getVariable ["dogspawnchance", 0.5];
private _dogClassnamesRaw = _logic getVariable ["dogclassnames", "Alsatian_Random_F,Alsatian_Black_F,Alsatian_Sandblack_F,Fin_random_F,Fin_blackwhite_F,Fin_ocherwhite_F"];
private _dogDetectionDay = _logic getVariable ["dogdetectionday", 15];
private _dogDetectionNight = _logic getVariable ["dogdetectionnight", 10];
private _dogLeadDistance = _logic getVariable ["dogleaddistance", 12];
private _dogHarassmentRange = _logic getVariable ["dogharassmentrange", 5];

// Wave 2+ Settings
private _numberOfWaves = _logic getVariable ["numberofwaves", 3];
private _pursuitMinSize = _logic getVariable ["pursuitminsize", 4];
private _pursuitMaxSize = _logic getVariable ["pursuitmaxsize", 6];
private _giveUpTime = _logic getVariable ["giveuptime", 360];

// Debug Settings
private _debugMarkers = _logic getVariable ["debugmarkers", false];
private _debugLogging = _logic getVariable ["debuglogging", false];
if (RECONDO_MASTER_DEBUG) then { _debugLogging = true; };

// Target Filter Settings
private _targetFilterHeight = _logic getVariable ["targetfilterheight", 60];
private _targetFilterUnitsRaw = _logic getVariable ["targetfilterunits", ""];
private _targetFilterVehiclesRaw = _logic getVariable ["targetfiltervehicles", ""];

// ========================================
// VALIDATE SETTINGS
// ========================================

// Parse classnames
private _unitClassnames = [_unitClassnamesRaw] call Recondo_fnc_parseClassnames;
private _dogClassnames = [_dogClassnamesRaw] call Recondo_fnc_parseClassnames;
private _targetFilterUnits = [_targetFilterUnitsRaw] call Recondo_fnc_parseClassnames;
private _targetFilterVehicles = [_targetFilterVehiclesRaw] call Recondo_fnc_parseClassnames;

if (count _unitClassnames == 0) exitWith {
    diag_log "[RECONDO_RW] ERROR: No unit classnames specified. Module disabled.";
};

// Convert side numbers to side types
private _reinforcementSide = switch (_reinforcementSideNum) do {
    case 0: { east };
    case 1: { west };
    case 2: { independent };
    default { east };
};

private _targetSide = switch (_targetSideNum) do {
    case 0: { east };
    case 1: { west };
    case 2: { independent };
    default { west };
};

// Validate group sizes
_wave1MinSize = _wave1MinSize max 1;
_wave1MaxSize = _wave1MaxSize max _wave1MinSize;
_pursuitMinSize = _pursuitMinSize max 1;
_pursuitMaxSize = _pursuitMaxSize max _pursuitMinSize;
_numberOfWaves = _numberOfWaves max 0 min 4;
_giveUpTime = _giveUpTime max 0; // 0 disables give-up
_sideGroupDistance = _sideGroupDistance max 50;

// Generate unique module ID
private _moduleId = format ["RW_%1_%2", getPos _logic, time];

// ========================================
// STORE SETTINGS FOR THIS MODULE INSTANCE
// ========================================

// Ambient sounds are organized as category pools so each checked option has an
// equal chance per tick regardless of file count. Silent is an empty pool: when
// drawn, the group plays nothing that interval. Dog sounds are always a category
// for dog groups.
private _bambooStickSounds = ["bamboo1", "mallet3hits", "mallet6hits", "sticks1"];
private _whistlingSounds = ["enemy_whistle_2", "enemy_whistle_3", "enemy_whistle_4", "enemy_whistling_2", "enemy_whistling_3", "enemy_whistling_4"];
private _dogGroupSounds = ["bark_hound", "bark1", "bark2"];
private _soundPoolsNoDog = [];
if (_enableSilent) then { _soundPoolsNoDog pushBack []; };
if (_enableBambooSticks) then { _soundPoolsNoDog pushBack _bambooStickSounds; };
if (_enableWhistling) then { _soundPoolsNoDog pushBack _whistlingSounds; };
private _soundPoolsWithDog = _soundPoolsNoDog + [_dogGroupSounds];
private _dogDetectionSounds = ["bark1", "bark2", "barkmean1", "barkmean2", "barkmean3", "dog_growl_vicious"];
private _dogDeathSounds = ["boomerYelp", "boomerYelp2"];

// Radio chatter is a separate proximity channel, not part of the category
// pools above: groups within 100m of a player play one of these on their own
// timer (see fn_rwTrackerBehavior). Two series of 20 files each
private _radioSounds = [];
{
    private _series = _x;
    for "_i" from 1 to 20 do {
        _radioSounds pushBack format ["vn-radio-%1-%2%3", _series, ["", "0"] select (_i < 10), _i];
    };
} forEach ["n", "y"];

private _moduleSettings = createHashMapFromArray [
    // Identity
    ["moduleId", _moduleId],
    ["modulePos", getPos _logic],
    
    // General
    ["reinforcementSide", _reinforcementSide],
    ["targetSide", _targetSide],
    ["reinforcementChance", _reinforcementChance],
    ["unitClassnames", _unitClassnames],
    ["maxActiveGroups", _maxActiveGroups],
    ["releaseForceWalk", _releaseForceWalk],
    ["spawnTrackerTeam", _spawnTrackerTeam],
    
    // Detection
    ["triggerRadius", _triggerRadius],
    ["detectionThreshold", _detectionThreshold],
    ["heightLimit", _heightLimit],
    
    // Spawn
    ["spawnDistance", _spawnDistance],
    ["safetyDistance", _safetyDistance],
    
    // Wave 1
    ["wave1MinSize", _wave1MinSize],
    ["wave1MaxSize", _wave1MaxSize],
    ["soundInterval", _soundInterval],
    ["enableSilent", _enableSilent],
    ["enableBambooSticks", _enableBambooSticks],
    ["enableWhistling", _enableWhistling],
    
    // Side Groups
    ["enableSideGroups", _enableSideGroups],
    ["sideGroupDistance", _sideGroupDistance],
    
    // Dogs
    ["dogSpawnChance", _dogSpawnChance],
    ["dogClassnames", _dogClassnames],
    ["dogDetectionDay", _dogDetectionDay],
    ["dogDetectionNight", _dogDetectionNight],
    ["dogLeadDistance", _dogLeadDistance],
    ["dogHarassmentRange", _dogHarassmentRange],
    
    // Wave 2+
    ["numberOfWaves", _numberOfWaves],
    ["pursuitMinSize", _pursuitMinSize],
    ["pursuitMaxSize", _pursuitMaxSize],
    ["giveUpTime", _giveUpTime],
    
    // Sounds
    ["soundPoolsNoDog", _soundPoolsNoDog],
    ["soundPoolsWithDog", _soundPoolsWithDog],
    ["dogDetectionSounds", _dogDetectionSounds],
    ["dogDeathSounds", _dogDeathSounds],
    ["enableRadio", _enableRadio],
    ["radioSounds", _radioSounds],
    
    // Target Filter
    ["ignoreHeight", _targetFilterHeight],
    ["ignoreUnitClassnames", _targetFilterUnits],
    ["ignoreVehicleClassnames", _targetFilterVehicles],
    
    // Debug
    ["debugMarkers", _debugMarkers],
    ["debugLogging", _debugLogging],
    
    // Runtime tracking
    ["activeGroups", []],
    ["triggered", false]
];

// Store this module instance
RECONDO_RW_INSTANCES pushBack _moduleSettings;

// ========================================
// INITIALIZE SOUND FUNCTION (if not already defined by Trackers module)
// ========================================

if (isNil "RECONDO_RW_fnc_playSound") then {
    RECONDO_RW_fnc_playSound = compileFinal "
        if (!hasInterface) exitWith {};
        params ['_unit', '_sounds'];
        if (_sounds isEqualTo []) exitWith {};
        if (player distance _unit > 300) exitWith {};
        private _sound = selectRandom _sounds;
        private _soundPath = '\recondo_wars\sounds\trackers\' + _sound + '.ogg';
        playSound3D [_soundPath, _unit, false, getPosASL _unit, 5, 1, 300];
    ";
    publicVariable "RECONDO_RW_fnc_playSound";
};

// Radio chatter is quieter than the whistle/mallet ambience - a manpack radio
// should read as close-range noise, not jungle-wide sound
if (isNil "RECONDO_RW_fnc_playRadioSound") then {
    RECONDO_RW_fnc_playRadioSound = compileFinal "
        if (!hasInterface) exitWith {};
        params ['_unit', '_sounds'];
        if (_sounds isEqualTo []) exitWith {};
        if (player distance _unit > 150) exitWith {};
        private _sound = selectRandom _sounds;
        private _soundPath = '\recondo_wars\sounds\trackers\' + _sound + '.ogg';
        playSound3D [_soundPath, _unit, false, getPosASL _unit, 2, 1, 150];
    ";
    publicVariable "RECONDO_RW_fnc_playRadioSound";
};

// ========================================
// CREATE DETECTION TRIGGER
// ========================================

[_moduleSettings] call Recondo_fnc_createRWDetectionTrigger;

// Start RW-owned footprint producer once. This keeps strict footprint pursuit
// functional even when the Trackers module is not running.
if (isNil "RECONDO_RW_FOOTPRINT_LOOP_RUNNING") then {
    RECONDO_RW_FOOTPRINT_LOOP_RUNNING = true;
    [] spawn Recondo_fnc_rwFootprintLoop;
};

// ========================================
// LOG INITIALIZATION
// ========================================

if (_debugLogging) then {
    diag_log format ["[RECONDO_RW] Module %1 settings:", _moduleId];
    diag_log format ["[RECONDO_RW]   Reinforcement side: %1, Target side: %2", _reinforcementSide, _targetSide];
    diag_log format ["[RECONDO_RW]   Trigger radius: %1m, Detection threshold: %2", _triggerRadius, _detectionThreshold];
    diag_log format ["[RECONDO_RW]   Spawn distance: %1m, Safety distance: %2m", _spawnDistance, _safetyDistance];
    diag_log format ["[RECONDO_RW]   Wave 1 size: %1-%2, Side groups: %3 (%4m)", _wave1MinSize, _wave1MaxSize, _enableSideGroups, _sideGroupDistance];
    diag_log format ["[RECONDO_RW]   Pursuit waves: %1, Size: %2-%3", _numberOfWaves, _pursuitMinSize, _pursuitMaxSize];
    diag_log format ["[RECONDO_RW]   Dog chance: %1%", round(_dogSpawnChance * 100)];
};

diag_log format ["[RECONDO_RW] Module initialized at %1. Trigger radius: %2m, Reinforcement chance: %3%", 
    getPos _logic, _triggerRadius, round(_reinforcementChance * 100)];
