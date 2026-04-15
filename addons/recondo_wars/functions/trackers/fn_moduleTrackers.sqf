/*
    Recondo_fnc_moduleTrackers
    Main initialization for Trackers module
    
    Description:
        Initializes the tracker system that hunts players by following their footprints.
        Trackers spawn when players enter trigger areas near configured map markers.
        Optional tracker dogs can detect players at close range.
    
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
    diag_log "[RECONDO_TRACKERS] Module not activated.";
};

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

// General Settings
private _trackerSideNum = _logic getVariable ["trackerside", 0];
private _targetSideNum = _logic getVariable ["targetside", 1];
private _trackerClassnamesRaw = _logic getVariable ["trackerclassnames", ""];
private _minGroupSize = _logic getVariable ["mingroupsize", 2];
private _maxGroupSize = _logic getVariable ["maxgroupsize", 4];
private _maxActiveGroups = _logic getVariable ["maxactivegroups", 20];

// Marker Settings
private _markerPrefix = _logic getVariable ["markerprefix", "TRACKER_"];
private _noFootprintPrefix = _logic getVariable ["nofootprintprefix", "NO_FOOTPRINT_"];
private _spawnProbability = _logic getVariable ["spawnprobability", 0.2];
private _triggerDistance = _logic getVariable ["triggerdistance", 1000];
private _noFootprintRadius = _logic getVariable ["nofootprintradius", 500];
private _heightLimit = _logic getVariable ["heightlimit", 45];

// Footprint Settings
private _footprintSpacing = _logic getVariable ["footprintspacing", 10];
private _alwaysTrackChance = _logic getVariable ["alwaystrackchance", 0.2];
private _footprintLifetime = _logic getVariable ["footprintlifetime", 20];
private _footprintSpeedThreshold = 6; // Hardcoded: walking pace is ~6 km/h

// Tracker Behavior Settings
private _movementSpeed = _logic getVariable ["movementspeed", "LIMITED"];
private _soundInterval = _logic getVariable ["soundinterval", 30];
private _predictiveDistanceMin = _logic getVariable ["predictivedistancemin", 200];
private _predictiveDistanceMax = _logic getVariable ["predictivedistancemax", 300];

// Dog Settings
private _dogSpawnChance = _logic getVariable ["dogspawnchance", 0.5];
private _dogClassnamesRaw = _logic getVariable ["dogclassnames", "Alsatian_Random_F,Alsatian_Black_F,Alsatian_Sandblack_F,Fin_random_F,Fin_blackwhite_F,Fin_ocherwhite_F"];
private _dogDetectionDay = _logic getVariable ["dogdetectionday", 15];
private _dogDetectionNight = _logic getVariable ["dogdetectionnight", 10];
private _dogLeadDistance = _logic getVariable ["dogleaddistance", 12];
private _dogHarassmentRange = _logic getVariable ["dogharassmentrange", 5];

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
private _trackerClassnames = [_trackerClassnamesRaw] call Recondo_fnc_parseClassnames;
private _dogClassnames = [_dogClassnamesRaw] call Recondo_fnc_parseClassnames;
private _targetFilterUnits = [_targetFilterUnitsRaw] call Recondo_fnc_parseClassnames;
private _targetFilterVehicles = [_targetFilterVehiclesRaw] call Recondo_fnc_parseClassnames;

if (count _trackerClassnames == 0) exitWith {
    diag_log "[RECONDO_TRACKERS] ERROR: No tracker classnames specified. Module disabled.";
};

// Convert side numbers to side types
private _trackerSide = switch (_trackerSideNum) do {
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
_minGroupSize = _minGroupSize max 1;
_maxGroupSize = _maxGroupSize max _minGroupSize;

// ========================================
// STORE SETTINGS GLOBALLY
// ========================================

// Define sound arrays based on whether dog is present
private _soundsNoDog = ["bamboo1", "mallet3hits", "mallet6hits", "sticks1"];
private _soundsWithDog = ["bamboo1", "mallet3hits", "mallet6hits", "sticks1", "bark_hound", "bark1", "bark2"];
private _dogDetectionSounds = ["bark1", "bark2", "barkmean1", "barkmean2", "barkmean3", "dog_growl_vicious"];
private _dogDeathSounds = ["boomerYelp", "boomerYelp2"];

RECONDO_TRACKERS_SETTINGS = createHashMapFromArray [
    // General
    ["trackerSide", _trackerSide],
    ["targetSide", _targetSide],
    ["trackerClassnames", _trackerClassnames],
    ["minGroupSize", _minGroupSize],
    ["maxGroupSize", _maxGroupSize],
    ["maxActiveGroups", _maxActiveGroups],
    
    // Markers
    ["markerPrefix", toUpper _markerPrefix],
    ["noFootprintPrefix", toUpper _noFootprintPrefix],
    ["spawnProbability", _spawnProbability],
    ["triggerDistance", _triggerDistance],
    ["noFootprintRadius", _noFootprintRadius],
    ["heightLimit", _heightLimit],
    
    // Footprints
    ["footprintSpacing", _footprintSpacing],
    ["footprintSpeedThreshold", _footprintSpeedThreshold], // Hardcoded 6 km/h
    ["alwaysTrackChance", _alwaysTrackChance],
    ["footprintLifetime", _footprintLifetime * 60], // Convert to seconds
    
    // Behavior
    ["movementSpeed", _movementSpeed],
    ["soundInterval", _soundInterval],
    ["predictiveDistanceMin", _predictiveDistanceMin],
    ["predictiveDistanceMax", _predictiveDistanceMax],
    
    // Dog
    ["dogSpawnChance", _dogSpawnChance],
    ["dogClassnames", _dogClassnames],
    ["dogDetectionDay", _dogDetectionDay],
    ["dogDetectionNight", _dogDetectionNight],
    ["dogLeadDistance", _dogLeadDistance],
    ["dogHarassmentRange", _dogHarassmentRange],
    
    // Sounds
    ["soundsNoDog", _soundsNoDog],
    ["soundsWithDog", _soundsWithDog],
    ["dogDetectionSounds", _dogDetectionSounds],
    ["dogDeathSounds", _dogDeathSounds],
    
    // Target Filter
    ["ignoreHeight", _targetFilterHeight],
    ["ignoreUnitClassnames", _targetFilterUnits],
    ["ignoreVehicleClassnames", _targetFilterVehicles],
    
    // Debug
    ["debugMarkers", _debugMarkers],
    ["debugLogging", _debugLogging]
];

publicVariable "RECONDO_TRACKERS_SETTINGS";

// ========================================
// INITIALIZE CLIENT-SIDE SOUND FUNCTION
// ========================================

// Define sound playback function for clients
RECONDO_TRACKERS_fnc_playSound = compileFinal "
    if (!hasInterface) exitWith {};
    params ['_unit', '_sounds'];
    if (player distance _unit > 300) exitWith {};
    private _sound = selectRandom _sounds;
    private _soundPath = '\recondo_wars\sounds\trackers\' + _sound + '.ogg';
    playSound3D [_soundPath, _unit, false, getPosASL _unit, 5, 1, 300];
";
publicVariable "RECONDO_TRACKERS_fnc_playSound";

// ========================================
// FIND AND PROCESS TRACKER MARKERS
// ========================================

private _markerPrefixUpper = toUpper _markerPrefix;
private _enabledCount = 0;
private _alwaysTrackCount = 0;

{
    private _markerName = _x;
    private _markerNameUpper = toUpper _markerName;
    
    if (_markerNameUpper find _markerPrefixUpper == 0) then {
        // Check spawn probability
        if (random 1 < _spawnProbability) then {
            RECONDO_TRACKERS_ENABLED_MARKERS pushBack _markerName;
            _enabledCount = _enabledCount + 1;
            
            // Roll for "always track" - this marker will track regardless of player speed
            private _isAlwaysTrack = random 1 < _alwaysTrackChance;
            if (_isAlwaysTrack) then {
                RECONDO_TRACKERS_ALWAYS_TRACK_MARKERS pushBack _markerName;
                _alwaysTrackCount = _alwaysTrackCount + 1;
            };
            
            // Create trigger for this marker
            [_markerName] call Recondo_fnc_createTrackerTrigger;
            
            if (_debugLogging) then {
                private _trackType = if (_isAlwaysTrack) then {"ALWAYS TRACK"} else {"speed-based"};
                diag_log format ["[RECONDO_TRACKERS] Marker %1 enabled for spawning (%2)", _markerName, _trackType];
            };
        } else {
            if (_debugLogging) then {
                diag_log format ["[RECONDO_TRACKERS] Marker %1 disabled (probability)", _markerName];
            };
        };
    };
} forEach allMapMarkers;

publicVariable "RECONDO_TRACKERS_ENABLED_MARKERS";
publicVariable "RECONDO_TRACKERS_ALWAYS_TRACK_MARKERS";

// ========================================
// START FOOTPRINT SYSTEM
// ========================================

// Footprint creation and cleanup loop
// Uses AVERAGE speed over distance traveled (not instant speed) to prevent exploits
// where players walk slowly then briefly sprint to trigger footprints
[] spawn {
    private _settings = RECONDO_TRACKERS_SETTINGS;
    private _footprintSpacing = _settings get "footprintSpacing";
    private _speedThreshold = _settings get "footprintSpeedThreshold"; // 6 km/h (walking pace)
    private _targetSide = _settings get "targetSide";
    private _debugLogging = _settings get "debugLogging";
    
    // Wait for mission to fully initialize
    sleep 5;
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_TRACKERS] Footprint system started. Speed threshold: %1 km/h (average over %2m)", _speedThreshold, _footprintSpacing];
    };
    
    while {true} do {
        // Clean old footprints
        [] call Recondo_fnc_cleanFootprints;
        
        // Create footprints for target side groups
        {
            private _group = _x;
            
            if (side _group == _targetSide) then {
                // Get first living unit in group (more robust than leader for dedicated server)
                private _livingUnits = (units _group) select { alive _x };
                if (count _livingUnits == 0) then { continue };
                
                private _firstLiving = _livingUnits select 0;
                private _currentPos = getPos _firstLiving;
                private _currentTime = time;
                
                // Initialize last position and timestamp if needed
                if (isNil {_group getVariable "RECONDO_TRACKERS_lastPos"}) then {
                    _group setVariable ["RECONDO_TRACKERS_lastPos", _currentPos];
                    _group setVariable ["RECONDO_TRACKERS_lastPosTime", _currentTime];
                };
                
                private _lastPos = _group getVariable "RECONDO_TRACKERS_lastPos";
                private _lastPosTime = _group getVariable ["RECONDO_TRACKERS_lastPosTime", _currentTime];
                private _distance = _lastPos distance _currentPos;
                
                // Check if unit is on foot and moved enough distance
                if (_distance >= _footprintSpacing && vehicle _firstLiving == _firstLiving) then {
                    // Calculate average speed over the distance traveled
                    private _elapsedTime = _currentTime - _lastPosTime;
                    private _avgSpeed = if (_elapsedTime > 0) then {
                        (_distance / _elapsedTime) * 3.6  // Convert m/s to km/h
                    } else {
                        0
                    };
                    
                    // Check if this group is "always tracked" (set when they triggered a marker)
                    private _groupIdStr = groupId _group;
                    private _isAlwaysTracked = _groupIdStr in RECONDO_TRACKERS_ALWAYS_TRACK_GROUPS;
                    
                    // Create footprint if:
                    // 1. Group is "always tracked" (triggered an always-track marker), OR
                    // 2. Group's AVERAGE speed over the distance exceeds walking pace (6 km/h)
                    if (_isAlwaysTracked || _avgSpeed > _speedThreshold) then {
                        [_currentPos, _group] call Recondo_fnc_createFootprint;
                        
                        if (_debugLogging && !_isAlwaysTracked) then {
                            diag_log format ["[RECONDO_TRACKERS] Footprint created for %1 - avg speed: %2 km/h over %3m in %4s", 
                                _groupIdStr, round(_avgSpeed * 10) / 10, round _distance, round(_elapsedTime * 10) / 10];
                        };
                    };
                    
                    // Always update position and timestamp after checking (whether footprint created or not)
                    // This resets the measurement window for the next footprint spacing distance
                    _group setVariable ["RECONDO_TRACKERS_lastPos", _currentPos];
                    _group setVariable ["RECONDO_TRACKERS_lastPosTime", _currentTime];
                };
            };
        } forEach allGroups;
        
        sleep 5;
    };
};

// ========================================
// LOG INITIALIZATION
// ========================================

if (_debugLogging) then {
    diag_log format ["[RECONDO_TRACKERS] Settings: Tracker side=%1, Target side=%2", _trackerSide, _targetSide];
    diag_log format ["[RECONDO_TRACKERS] Settings: Group size=%1-%2, Max groups=%3", _minGroupSize, _maxGroupSize, _maxActiveGroups];
    diag_log format ["[RECONDO_TRACKERS] Settings: Trigger distance=%1m, Height limit=%2m", _triggerDistance, _heightLimit];
    diag_log format ["[RECONDO_TRACKERS] Settings: Footprint spacing=%1m, Lifetime=%2min", _footprintSpacing, _footprintLifetime];
    diag_log format ["[RECONDO_TRACKERS] Settings: Always track chance=%1%, Speed threshold=%2 km/h", round(_alwaysTrackChance * 100), _footprintSpeedThreshold];
    diag_log format ["[RECONDO_TRACKERS] Settings: Dog chance=%1%", round(_dogSpawnChance * 100)];
};

diag_log format ["[RECONDO_TRACKERS] Initialized. %1 markers enabled (%2 always-track, %3 speed-based) at prefix '%4'.", 
    _enabledCount, _alwaysTrackCount, _enabledCount - _alwaysTrackCount, _markerPrefix];
