/*
    Recondo_fnc_spawnJammerComposition
    Spawns a jammer composition at the marker position
    
    Description:
        Clears terrain, loads the composition (active or destroyed based on state),
        finds the jammer object, and sets up the destruction event handler.
    
    Parameters:
        _settings - HASHMAP - Module settings
        _markerId - STRING - Marker ID for this jammer
        _compData - ARRAY - Composition data [activeComp, destroyedComp, isModPath]
        _isDestroyed - BOOL - Whether the jammer is already destroyed
    
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [
    ["_settings", nil, [createHashMap]],
    ["_markerId", "", [""]],
    ["_compData", [], [[]]],
    ["_isDestroyed", false, [false]]
];

if (isNil "_settings" || _markerId == "" || count _compData == 0) exitWith {
    diag_log format ["[RECONDO_JAMMER] ERROR: Invalid parameters for spawnJammerComposition - marker: %1, compData: %2", _markerId, _compData];
};

// Extract composition data
_compData params ["_activeComp", "_destroyedComp", "_isModPath"];

private _customCompPath = _settings get "customCompPath";
private _clearRadius = _settings get "clearRadius";
private _jammerClassname = _settings get "jammerClassname";
private _instanceId = _settings get "instanceId";
private _objectiveName = _settings get "objectiveName";
private _debugLogging = _settings get "debugLogging";

private _markerPos = getMarkerPos _markerId;
private _markerDir = markerDir _markerId;

// Select which composition to spawn based on destroyed state
private _compositionToSpawn = if (_isDestroyed) then { _destroyedComp } else { _activeComp };

if (_debugLogging) then {
    diag_log format ["[RECONDO_JAMMER] Spawning composition %1 at %2 (destroyed: %3, isModPath: %4)", 
        _compositionToSpawn, _markerId, _isDestroyed, _isModPath];
};

// ========================================
// CLEAR TERRAIN
// ========================================

{
    _x hideObjectGlobal true;
} forEach (nearestTerrainObjects [_markerPos, [
    "TREE", "SMALL TREE", "BUSH", "HOUSE", "WALL", "FENCE", "BUILDING",
    "ROCK", "ROCKS", "HIDE", "FOREST BORDER", "FOREST TRIANGLE", "FOREST SQUARE"
], _clearRadius, false, true]);

// ========================================
// SPAWN COMPOSITION
// ========================================

[{
    params ["_settings", "_markerId", "_compositionToSpawn", "_markerPos", "_markerDir", "_isDestroyed", "_isModPath"];
    
    private _customCompPath = _settings get "customCompPath";
    private _jammerClassname = _settings get "jammerClassname";
    private _instanceId = _settings get "instanceId";
    private _objectiveName = _settings get "objectiveName";
    private _debugLogging = _settings get "debugLogging";
    
    // Determine composition path based on isModPath
    // For mod compositions: use "compositions" folder in mod
    // For custom compositions: use customCompPath in mission folder
    private _compPath = if (_isModPath) then { "compositions" } else { _customCompPath };
    
    // Load composition
    private _result = [_compPath, _compositionToSpawn, _markerPos, _markerDir, _debugLogging, _isModPath] call Recondo_fnc_loadComposition;
    _result params ["_spawnedObjects", "_targetObject"];
    
    if (count _spawnedObjects == 0) exitWith {
        diag_log format ["[RECONDO_JAMMER] ERROR: Failed to spawn composition %1 at %2 (isModPath: %3)", 
            _compositionToSpawn, _markerId, _isModPath];
    };
    
    // Track spawned objects
    RECONDO_JAMMER_SPAWNED_OBJECTS append _spawnedObjects;
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_JAMMER] Spawned %1 objects at %2 (isModPath: %3)", 
            count _spawnedObjects, _markerId, _isModPath];
    };
    
    // ========================================
    // REGISTER BUILDINGS FOR NIGHT LIGHTS
    // ========================================
    
    private _enableNightLights = _settings get "enableNightLights";
    if (_enableNightLights) then {
        private _buildingsFound = 0;
        {
            // Check if object is a building (not a unit or vehicle)
            if (!(_x isKindOf "CAManBase") && !(_x isKindOf "LandVehicle") && !(_x isKindOf "Air") && !(_x isKindOf "Ship")) then {
                // Check if object has any building positions
                private _testPos = _x buildingPos 0;
                if !(_testPos isEqualTo [0,0,0]) then {
                    // This object has building positions - register it for night lights
                    if !(_x in RECONDO_JAMMER_NIGHT_LIGHT_BUILDINGS) then {
                        RECONDO_JAMMER_NIGHT_LIGHT_BUILDINGS pushBack _x;
                        _buildingsFound = _buildingsFound + 1;
                    };
                };
            };
        } forEach _spawnedObjects;
        
        if (_debugLogging && _buildingsFound > 0) then {
            diag_log format ["[RECONDO_JAMMER] Registered %1 buildings for night lights at %2", _buildingsFound, _markerId];
        };
    };
    
    // ========================================
    // DISABLE SIMULATION ON COMPOSITION OBJECTS
    // ========================================
    
    private _disableSimulation = _settings getOrDefault ["disableSimulation", true];
    
    if (_disableSimulation) then {
        private _disabledCount = 0;
        private _jammerObject = objNull;
        
        // First find the jammer object
        {
            if (typeOf _x == _jammerClassname) exitWith {
                _jammerObject = _x;
            };
        } forEach _spawnedObjects;
        
        // Disable simulation on all objects except jammer (if active) or all (if destroyed)
        {
            if (_isDestroyed || _x != _jammerObject) then {
                _x enableSimulationGlobal false;
                _disabledCount = _disabledCount + 1;
            };
        } forEach _spawnedObjects;
        
        if (_debugLogging) then {
            diag_log format ["[RECONDO_JAMMER] Disabled simulation on %1 of %2 objects at %3 (destroyed: %4, jammer excluded: %5)", 
                _disabledCount, count _spawnedObjects, _markerId, _isDestroyed, !_isDestroyed && !isNull _jammerObject];
        };
    };
    
    // ========================================
    // FIND AND SETUP JAMMER OBJECT
    // ========================================
    
    if (!_isDestroyed) then {
        // Find the jammer object in spawned objects
        private _jammerObject = objNull;
        
        {
            if (typeOf _x == _jammerClassname) exitWith {
                _jammerObject = _x;
            };
        } forEach _spawnedObjects;
        
        // If not found in composition, search nearby
        if (isNull _jammerObject) then {
            private _nearby = nearestObjects [_markerPos, [_jammerClassname], 50];
            if (count _nearby > 0) then {
                _jammerObject = _nearby select 0;
            };
        };
        
        if (isNull _jammerObject) then {
            diag_log format ["[RECONDO_JAMMER] WARNING: No jammer object (%1) found at %2", _jammerClassname, _markerId];
        } else {
            // Store reference data on jammer
            _jammerObject setVariable ["RECONDO_JAMMER_INSTANCE", _instanceId, true];
            _jammerObject setVariable ["RECONDO_JAMMER_MARKER", _markerId, true];
            _jammerObject setVariable ["RECONDO_JAMMER_NAME", _objectiveName, true];
            
            // Track jammer object globally
            RECONDO_JAMMER_OBJECTS set [_markerId, _jammerObject];
            publicVariable "RECONDO_JAMMER_OBJECTS";
            
            // Add killed event handler
            _jammerObject addEventHandler ["Killed", {
                params ["_unit", "_killer", "_instigator", "_useEffects"];
                
                private _instanceId = _unit getVariable ["RECONDO_JAMMER_INSTANCE", ""];
                private _markerId = _unit getVariable ["RECONDO_JAMMER_MARKER", ""];
                private _objectiveName = _unit getVariable ["RECONDO_JAMMER_NAME", ""];
                
                [_instanceId, _markerId, _objectiveName] call Recondo_fnc_handleJammerDestroyed;
            }];
            
            if (_debugLogging) then {
                diag_log format ["[RECONDO_JAMMER] Jammer object setup complete at %1: %2", _markerId, typeOf _jammerObject];
            };
        };
    };
    
}, [_settings, _markerId, _compositionToSpawn, _markerPos, _markerDir, _isDestroyed, _isModPath], 2] call CBA_fnc_waitAndExecute;
