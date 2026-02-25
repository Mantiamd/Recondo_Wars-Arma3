/*
    Recondo_fnc_moduleFootPatrols
    Main module initialization - runs on server only
    
    Description:
        Called when the Foot Patrols module is activated.
        Finds invisible markers matching the prefix, randomly selects a percentage,
        and creates triggers at those positions to spawn patrols when activated.
    
    Parameters:
        0: OBJECT - Logic module
        1: ARRAY - Synced units (unused)
        2: BOOL - Is activated
        
    Returns:
        Nothing
*/

params ["_logic", "_units", "_activated"];

// Only run on server
if (!isServer) exitWith {
    diag_log "[RECONDO_FP] Module attempted to run on non-server. Exiting.";
};

// Get all module attributes
private _settings = createHashMap;

// General Settings
private _targetSideNum = _logic getVariable ["targetside", 0];
private _sideMap = [east, west, independent, civilian];
_settings set ["targetSide", _sideMap select _targetSideNum];
_settings set ["markerPrefix", _logic getVariable ["markerprefix", ""]];
_settings set ["spawnPercentage", (_logic getVariable ["spawnpercentage", 0.5]) * 100];

// Unit Settings
private _unitClassnamesStr = _logic getVariable ["unitclassnames", ""];
private _unitClassnames = [_unitClassnamesStr] call Recondo_fnc_parseClassnames;
_settings set ["unitClassnames", _unitClassnames];
_settings set ["minGroupSize", _logic getVariable ["mingroupsize", 3]];
_settings set ["maxGroupSize", _logic getVariable ["maxgroupsize", 6]];

// Patrol Behavior Settings
_settings set ["patrolRadius", _logic getVariable ["patrolradius", 300]];
_settings set ["waypointCount", _logic getVariable ["waypointcount", 4]];
_settings set ["waypointPauseMin", _logic getVariable ["waypointpausemin", 15]];
_settings set ["waypointPauseMax", _logic getVariable ["waypointpausemax", 45]];
_settings set ["behaviour", _logic getVariable ["behaviour", "SAFE"]];
_settings set ["speedMode", _logic getVariable ["speedmode", "LIMITED"]];
_settings set ["combatMode", _logic getVariable ["combatmode", "YELLOW"]];
_settings set ["formation", _logic getVariable ["formation", "STAG COLUMN"]];

// Trigger Settings
_settings set ["triggerSide", _logic getVariable ["triggerside", "WEST"]];
_settings set ["triggerRadius", _logic getVariable ["triggerradius", 500]];
_settings set ["triggerHeight", _logic getVariable ["triggerheight", 20]];

// Performance Settings
_settings set ["simulationDistance", _logic getVariable ["simulationdistance", 1000]];
_settings set ["lambsReinforce", _logic getVariable ["lambsreinforce", true]];

// Persistence Settings
_settings set ["enablePersistence", _logic getVariable ["enablepersistence", false]];

// Debug
_settings set ["enableDebug", _logic getVariable ["enabledebug", false]];

// Store settings globally
RECONDO_FP_SETTINGS = _settings;
publicVariable "RECONDO_FP_SETTINGS";

private _debug = _settings get "enableDebug";
private _markerPrefix = _settings get "markerPrefix";
private _spawnPercentage = _settings get "spawnPercentage";
private _enablePersistence = _settings get "enablePersistence";

// Validate settings
if (_markerPrefix == "") exitWith {
    diag_log "[RECONDO_FP] ERROR: No marker prefix specified. Module disabled.";
};

if (count _unitClassnames == 0) exitWith {
    diag_log "[RECONDO_FP] ERROR: No unit classnames specified. Module disabled.";
};

if (_debug) then {
    diag_log format ["[RECONDO_FP] Target side: %1", _settings get "targetSide"];
    diag_log format ["[RECONDO_FP] Marker prefix: '%1'", _markerPrefix];
    diag_log format ["[RECONDO_FP] Spawn percentage: %1%%", _spawnPercentage];
    diag_log format ["[RECONDO_FP] Unit classnames: %1", _unitClassnames];
    diag_log format ["[RECONDO_FP] Group size: %1-%2", _settings get "minGroupSize", _settings get "maxGroupSize"];
    diag_log format ["[RECONDO_FP] Patrol radius: %1m, Waypoints: %2", _settings get "patrolRadius", _settings get "waypointCount"];
    diag_log format ["[RECONDO_FP] Behaviour: %1, Speed: %2, Combat: %3", _settings get "behaviour", _settings get "speedMode", _settings get "combatMode"];
    diag_log format ["[RECONDO_FP] Trigger side: %1, Radius: %2m, Height: %3m", _settings get "triggerSide", _settings get "triggerRadius", _settings get "triggerHeight"];
    diag_log format ["[RECONDO_FP] Persistence enabled: %1", _enablePersistence];
};

// Find all markers matching the prefix
private _allMarkers = allMapMarkers select {
    (_x find _markerPrefix) == 0
};

if (count _allMarkers == 0) exitWith {
    diag_log format ["[RECONDO_FP] WARNING: No markers found with prefix '%1'. Module disabled.", _markerPrefix];
};

if (_debug) then {
    diag_log format ["[RECONDO_FP] Found %1 markers with prefix '%2'", count _allMarkers, _markerPrefix];
};

// Determine which markers to use (from persistence or randomize)
private _selectedMarkers = [];
private _persistenceTag = format ["FP_%1", _markerPrefix];

if (_enablePersistence && {!isNil "RECONDO_PERSISTENCE_SETTINGS"}) then {
    // Try to load from persistence
    private _savedMarkers = [_persistenceTag, []] call Recondo_fnc_getSaveData;
    
    if (count _savedMarkers > 0) then {
        // Filter to only markers that still exist
        _selectedMarkers = _savedMarkers select { _x in _allMarkers };
        
        if (_debug) then {
            diag_log format ["[RECONDO_FP] Loaded %1 markers from persistence", count _selectedMarkers];
        };
    };
};

// If no saved markers or persistence disabled, randomize selection
if (count _selectedMarkers == 0) then {
    // Calculate how many markers to spawn
    private _spawnCount = round ((count _allMarkers) * (_spawnPercentage / 100));
    _spawnCount = _spawnCount max 0 min (count _allMarkers);
    
    if (_spawnCount > 0) then {
        // Shuffle the markers array
        private _shuffled = +_allMarkers;
        _shuffled = _shuffled call BIS_fnc_arrayShuffle;
        
        // Take the first N markers
        _selectedMarkers = _shuffled select [0, _spawnCount];
    };
    
    if (_debug) then {
        diag_log format ["[RECONDO_FP] Randomly selected %1 of %2 markers (%3%%)", count _selectedMarkers, count _allMarkers, _spawnPercentage];
    };
    
    // Save to persistence if enabled
    if (_enablePersistence && {!isNil "RECONDO_PERSISTENCE_SETTINGS"}) then {
        [_persistenceTag, _selectedMarkers] call Recondo_fnc_setSaveData;
        saveMissionProfileNamespace; // Commit to disk immediately
        
        if (_debug) then {
            diag_log format ["[RECONDO_FP] Saved %1 markers to persistence and committed to disk", count _selectedMarkers];
        };
    };
};

// Store selected markers globally
RECONDO_FP_SELECTED_MARKERS = _selectedMarkers;
RECONDO_FP_ACTIVE_TRIGGERS = [];
RECONDO_FP_SPAWNED_GROUPS = [];

// Create triggers at selected markers
{
    private _markerName = _x;
    private _trigger = [_markerName, _settings] call Recondo_fnc_createPatrolTrigger;
    
    if (!isNull _trigger) then {
        RECONDO_FP_ACTIVE_TRIGGERS pushBack _trigger;
    };
} forEach _selectedMarkers;

// Final log
diag_log format ["[RECONDO_FP] Initialized. Created %1 patrol triggers at prefix '%2'.", count RECONDO_FP_ACTIVE_TRIGGERS, _markerPrefix];
