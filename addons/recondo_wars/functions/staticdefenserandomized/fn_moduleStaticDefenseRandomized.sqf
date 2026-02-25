/*
    Recondo_fnc_moduleStaticDefenseRandomized
    Main module initialization - runs on server only
    
    Description:
        Called when the Static Defense Randomized module is activated.
        Finds invisible markers matching the prefix, randomly selects a percentage,
        and spawns static weapons with AI gunners at those positions.
    
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
    diag_log "[RECONDO_SDR] Module attempted to run on non-server. Exiting.";
};

// Get all module attributes
private _settings = createHashMap;

// General Settings
_settings set ["targetSide", _logic getVariable ["targetside", 0]];
_settings set ["markerPrefix", _logic getVariable ["markerprefix", ""]];
_settings set ["spawnPercentage", (_logic getVariable ["spawnpercentage", 0.5]) * 100];

// Static Weapon Settings
private _staticClassnamesStr = _logic getVariable ["staticclassnames", ""];
private _staticClassnames = [_staticClassnamesStr] call Recondo_fnc_parseClassnames;
_settings set ["staticClassnames", _staticClassnames];

// Unit Settings
private _unitClassnamesStr = _logic getVariable ["unitclassnames", ""];
private _unitClassnames = [_unitClassnamesStr] call Recondo_fnc_parseClassnames;
_settings set ["unitClassnames", _unitClassnames];

// Terrain Settings
_settings set ["clearRadius", _logic getVariable ["clearradius", 10]];

// Persistence Settings
_settings set ["enablePersistence", _logic getVariable ["enablepersistence", false]];

// Debug
_settings set ["enableDebug", _logic getVariable ["enabledebug", false]];

// Store settings globally
RECONDO_SDR_SETTINGS = _settings;

private _debug = _settings get "enableDebug";
private _markerPrefix = _settings get "markerPrefix";
private _spawnPercentage = _settings get "spawnPercentage";
private _enablePersistence = _settings get "enablePersistence";

// Validate settings
if (_markerPrefix == "") exitWith {
    diag_log "[RECONDO_SDR] ERROR: No marker prefix specified. Module disabled.";
};

if (count _staticClassnames == 0) exitWith {
    diag_log "[RECONDO_SDR] ERROR: No static weapon classnames specified. Module disabled.";
};

if (count _unitClassnames == 0) exitWith {
    diag_log "[RECONDO_SDR] ERROR: No unit classnames specified. Module disabled.";
};

// Convert side number to side value
private _sideMap = [east, west, independent, civilian];
private _targetSideValue = _sideMap select (_settings get "targetSide");
_settings set ["targetSideValue", _targetSideValue];

if (_debug) then {
    diag_log format ["[RECONDO_SDR] Target side: %1", _targetSideValue];
    diag_log format ["[RECONDO_SDR] Marker prefix: '%1'", _markerPrefix];
    diag_log format ["[RECONDO_SDR] Spawn percentage: %1%%", _spawnPercentage];
    diag_log format ["[RECONDO_SDR] Static weapons: %1", _staticClassnames];
    diag_log format ["[RECONDO_SDR] Unit classnames: %1", _unitClassnames];
    diag_log format ["[RECONDO_SDR] Clear radius: %1m", _settings get "clearRadius"];
    diag_log format ["[RECONDO_SDR] Persistence enabled: %1", _enablePersistence];
};

// Find all markers matching the prefix
private _allMarkers = allMapMarkers select {
    (_x find _markerPrefix) == 0
};

if (count _allMarkers == 0) exitWith {
    diag_log format ["[RECONDO_SDR] WARNING: No markers found with prefix '%1'. Module disabled.", _markerPrefix];
};

if (_debug) then {
    diag_log format ["[RECONDO_SDR] Found %1 markers with prefix '%2'", count _allMarkers, _markerPrefix];
};

// Determine which markers to use (from persistence or randomize)
private _selectedMarkers = [];
private _persistenceTag = format ["SDR_%1", _markerPrefix];

if (_enablePersistence && {!isNil "RECONDO_PERSISTENCE_SETTINGS"}) then {
    // Try to load from persistence
    private _savedMarkers = [_persistenceTag, []] call Recondo_fnc_getSaveData;
    
    if (count _savedMarkers > 0) then {
        // Filter to only markers that still exist
        _selectedMarkers = _savedMarkers select { _x in _allMarkers };
        
        if (_debug) then {
            diag_log format ["[RECONDO_SDR] Loaded %1 markers from persistence", count _selectedMarkers];
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
        diag_log format ["[RECONDO_SDR] Randomly selected %1 of %2 markers (%3%%)", count _selectedMarkers, count _allMarkers, _spawnPercentage];
    };
    
    // Save to persistence if enabled
    if (_enablePersistence && {!isNil "RECONDO_PERSISTENCE_SETTINGS"}) then {
        [_persistenceTag, _selectedMarkers] call Recondo_fnc_setSaveData;
        saveMissionProfileNamespace; // Commit to disk immediately
        
        if (_debug) then {
            diag_log format ["[RECONDO_SDR] Saved %1 markers to persistence and committed to disk", count _selectedMarkers];
        };
    };
};

// Store selected markers globally
RECONDO_SDR_SELECTED_MARKERS = _selectedMarkers;
RECONDO_SDR_SPAWNED_STATICS = [];
RECONDO_SDR_SPAWNED_UNITS = [];

// Spawn static defenses at selected markers
{
    private _markerName = _x;
    private _result = [_markerName, _settings] call Recondo_fnc_spawnStaticDefense;
    
    if (_result isEqualType []) then {
        _result params ["_static", "_unit"];
        RECONDO_SDR_SPAWNED_STATICS pushBack _static;
        RECONDO_SDR_SPAWNED_UNITS pushBack _unit;
    };
} forEach _selectedMarkers;

// Final log
diag_log format ["[RECONDO_SDR] Initialized. Spawned %1 static defenses at prefix '%2'.", count RECONDO_SDR_SPAWNED_STATICS, _markerPrefix];
