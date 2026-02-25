/*
    Recondo_fnc_spawnHVTComposition
    Spawns a composition at an HVT location
    
    Description:
        Clears terrain and loads the composition at the marker position.
        Supports loading from both mod folder and mission folder.
    
    Parameters:
        _settings - HASHMAP - Module settings
        _marker - STRING - Location marker name
        _composition - STRING - Composition name (with or without .sqe)
        _isHVTLocation - BOOL - True if this is the real HVT location
        _isModPath - BOOL - True to load from mod folder, false for mission folder
    
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [
    ["_settings", nil, [createHashMap]],
    ["_marker", "", [""]],
    ["_composition", "", [""]],
    ["_isHVTLocation", false, [false]],
    ["_isModPath", true, [false]]
];

if (isNil "_settings" || _marker == "" || _composition == "") exitWith {
    diag_log format ["[RECONDO_HVT] ERROR: Invalid parameters for spawnHVTComposition - marker: %1, comp: %2", _marker, _composition];
};

private _customCompPath = _settings getOrDefault ["customCompPath", "compositions"];
private _clearRadius = _settings get "clearRadius";
private _debugLogging = _settings get "debugLogging";

private _markerPos = getMarkerPos _marker;
private _markerDir = markerDir _marker;

if (_debugLogging) then {
    diag_log format ["[RECONDO_HVT] Spawning composition %1 at %2", _composition, _marker];
};

// Clear terrain
{
    _x hideObjectGlobal true;
} forEach (nearestTerrainObjects [_markerPos, [
    "TREE", "SMALL TREE", "BUSH", "HOUSE", "WALL", "FENCE", "BUILDING",
    "ROCK", "ROCKS", "HIDE", "FOREST BORDER", "FOREST TRIANGLE", "FOREST SQUARE"
], _clearRadius, false, true]);

// Small delay after clearing terrain
[{
    params ["_settings", "_marker", "_composition", "_markerPos", "_markerDir", "_isHVTLocation", "_isModPath"];
    
    private _customCompPath = _settings getOrDefault ["customCompPath", "compositions"];
    private _debugLogging = _settings get "debugLogging";
    
    // Load and spawn composition (pass isModPath to loadComposition)
    private _result = [_customCompPath, _composition, _markerPos, _markerDir, _debugLogging, _isModPath] call Recondo_fnc_loadComposition;
    _result params ["_spawnedObjects", "_targetObject"];
    
    if (count _spawnedObjects == 0) exitWith {
        diag_log format ["[RECONDO_HVT] ERROR: Failed to spawn composition %1 at %2 (isModPath: %3)", _composition, _marker, _isModPath];
    };
    
    // Track spawned objects
    RECONDO_HVT_SPAWNED_OBJECTS append _spawnedObjects;
    
    // ========================================
    // DISABLE SIMULATION ON COMPOSITION OBJECTS
    // ========================================
    
    private _disableSimulation = _settings getOrDefault ["disableSimulation", true];
    
    if (_disableSimulation) then {
        private _disabledCount = 0;
        {
            // Disable simulation on ALL composition objects (no destroyable target)
            _x enableSimulationGlobal false;
            _disabledCount = _disabledCount + 1;
        } forEach _spawnedObjects;
        
        if (_debugLogging) then {
            diag_log format ["[RECONDO_HVT] Disabled simulation on %1 of %2 objects at %3", 
                _disabledCount, count _spawnedObjects, _marker];
        };
    };
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_HVT] Spawned %1 objects at %2 (isModPath: %3)", count _spawnedObjects, _marker, _isModPath];
    };
    
    // ========================================
    // REGISTER BUILDINGS FOR NIGHT LIGHTS
    // ========================================
    
    private _enableNightLights = _settings getOrDefault ["enableNightLights", true];
    
    if (_enableNightLights && RECONDO_HVT_NIGHT_LIGHTS_ENABLED) then {
        // Find all objects with building positions in the composition
        private _buildingsFound = 0;
        
        {
            private _obj = _x;
            // Skip units and vehicles - only want static objects
            if (!(_obj isKindOf "CAManBase") && !(_obj isKindOf "LandVehicle") && !(_obj isKindOf "Air") && !(_obj isKindOf "Ship")) then {
                // Check if object has any building positions
                private _testPos = _obj buildingPos 0;
                if !(_testPos isEqualTo [0,0,0]) then {
                    // This object has building positions - register it for night lights
                    if !(_obj in RECONDO_HVT_NIGHT_LIGHT_BUILDINGS) then {
                        RECONDO_HVT_NIGHT_LIGHT_BUILDINGS pushBack _obj;
                        _buildingsFound = _buildingsFound + 1;
                    };
                };
            };
        } forEach _spawnedObjects;
        
        if (_debugLogging && _buildingsFound > 0) then {
            diag_log format ["[RECONDO_HVT] Registered %1 buildings for night lights at %2", _buildingsFound, _marker];
        };
    };
    
}, [_settings, _marker, _composition, _markerPos, _markerDir, _isHVTLocation, _isModPath], 2] call CBA_fnc_waitAndExecute;
