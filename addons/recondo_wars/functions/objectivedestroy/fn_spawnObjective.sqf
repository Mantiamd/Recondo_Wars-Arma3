/*
    Recondo_fnc_spawnObjective
    Spawns an objective composition at a marker
    
    Description:
        Clears terrain, loads and spawns composition, finds target object,
        adds destruction handler, and spawns AI.
    
    Parameters:
        _settings - HASHMAP - Module settings
        _markerId - STRING - Marker ID for the objective
        _composition - STRING - Composition name to spawn
        _isDestroyed - BOOL - Whether objective is already destroyed
        _isModPath - BOOL - Whether composition is from mod folder (default: false)
    
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [
    ["_settings", nil, [createHashMap]],
    ["_markerId", "", [""]],
    ["_composition", "", [""]],
    ["_isDestroyed", false, [false]],
    ["_isModPath", false, [false]]
];

if (isNil "_settings" || _markerId == "" || _composition == "") exitWith {
    diag_log format ["[RECONDO_OBJDESTROY] ERROR: Invalid parameters for spawnObjective - marker: %1, comp: %2", _markerId, _composition];
};

private _compositionPath = if (_isModPath) then { "\recondo_wars\compositions" } else { _settings get "customCompPath" };
private _clearRadius = _settings get "clearRadius";
private _targetClassname = _settings get "targetClassname";
private _instanceId = _settings get "instanceId";
private _objectiveName = _settings get "objectiveName";
private _debugLogging = _settings get "debugLogging";

private _markerPos = getMarkerPos _markerId;
private _markerDir = markerDir _markerId;

if (_debugLogging) then {
    diag_log format ["[RECONDO_OBJDESTROY] Spawning objective at %1 with composition %2", _markerId, _composition];
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
    params ["_settings", "_markerId", "_composition", "_isDestroyed", "_markerPos", "_markerDir", "_compositionPath"];
    
    private _targetClassname = _settings get "targetClassname";
    private _instanceId = _settings get "instanceId";
    private _objectiveName = _settings get "objectiveName";
    private _debugLogging = _settings get "debugLogging";
    
    // Load and spawn composition
    private _isModPath = _compositionPath select [0, 1] == "\";
    private _result = [_compositionPath, _composition, _markerPos, _markerDir, _debugLogging, _isModPath] call Recondo_fnc_loadComposition;
    _result params ["_spawnedObjects", "_targetObject"];
    
    if (count _spawnedObjects == 0) exitWith {
        diag_log format ["[RECONDO_OBJDESTROY] ERROR: Failed to spawn composition %1 at %2", _composition, _markerId];
    };
    
    // Track spawned objects
    RECONDO_OBJDESTROY_SPAWNED_OBJECTS append _spawnedObjects;
    
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
                    if !(_x in RECONDO_OBJDESTROY_NIGHT_LIGHT_BUILDINGS) then {
                        RECONDO_OBJDESTROY_NIGHT_LIGHT_BUILDINGS pushBack _x;
                        _buildingsFound = _buildingsFound + 1;
                    };
                };
            };
        } forEach _spawnedObjects;
        
        if (_debugLogging && _buildingsFound > 0) then {
            diag_log format ["[RECONDO_OBJDESTROY] Registered %1 buildings for night lights at %2", _buildingsFound, _markerId];
        };
    };
    
    // Find target object if not already found
    if (isNull _targetObject && _targetClassname != "") then {
        {
            if (typeOf _x == _targetClassname) exitWith {
                _targetObject = _x;
            };
        } forEach _spawnedObjects;
    };
    
    // Add destruction handler if not destroyed and target exists
    if (!_isDestroyed && !isNull _targetObject) then {
        _targetObject setVariable ["RECONDO_OBJ_instanceId", _instanceId, true];
        _targetObject setVariable ["RECONDO_OBJ_markerId", _markerId, true];
        _targetObject setVariable ["RECONDO_OBJ_objectiveName", _objectiveName, true];
        
        _targetObject addEventHandler ["Killed", {
            params ["_unit", "_killer", "_instigator", "_useEffects"];
            
            private _instanceId = _unit getVariable ["RECONDO_OBJ_instanceId", ""];
            private _markerId = _unit getVariable ["RECONDO_OBJ_markerId", ""];
            private _objectiveName = _unit getVariable ["RECONDO_OBJ_objectiveName", ""];
            
            [_instanceId, _markerId, _objectiveName] call Recondo_fnc_handleObjectiveDestroyed;
        }];
        
        if (_debugLogging) then {
            diag_log format ["[RECONDO_OBJDESTROY] Added destruction handler to %1 at %2", typeOf _targetObject, _markerId];
        };
    };
    
    // ========================================
    // DISABLE SIMULATION ON COMPOSITION OBJECTS
    // ========================================
    
    private _disableSimulation = _settings get "disableSimulation";
    
    if (_disableSimulation) then {
        private _disabledCount = 0;
        {
            // For active objectives: disable all EXCEPT target
            // For destroyed objectives: disable ALL (no target needed)
            if (_isDestroyed || _x != _targetObject) then {
                _x enableSimulationGlobal false;
                _disabledCount = _disabledCount + 1;
            };
        } forEach _spawnedObjects;
        
        if (_debugLogging) then {
            diag_log format ["[RECONDO_OBJDESTROY] Disabled simulation on %1 of %2 objects at %3 (destroyed: %4, target excluded: %5)", 
                _disabledCount, count _spawnedObjects, _markerId, _isDestroyed, !_isDestroyed && !isNull _targetObject];
        };
    };
    
    // Make objects invulnerable temporarily
    {
        _x allowDamage false;
    } forEach _spawnedObjects;
    
    // Enable damage after 30 seconds
    [{
        params ["_objects"];
        {
            if (!isNull _x) then {
                _x allowDamage true;
            };
        } forEach _objects;
    }, [_spawnedObjects], 30] call CBA_fnc_waitAndExecute;
    
    // Spawn AI if not destroyed
    if (!_isDestroyed) then {
        [{
            params ["_settings", "_markerPos", "_markerId"];
            [_settings, _markerPos, _markerId] call Recondo_fnc_spawnObjectiveAI;
        }, [_settings, _markerPos, _markerId], 5] call CBA_fnc_waitAndExecute;
    };
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_OBJDESTROY] Spawned %1 objects at %2, target: %3", 
            count _spawnedObjects, _markerId, if (isNull _targetObject) then { "NONE" } else { typeOf _targetObject }];
    };
    
}, [_settings, _markerId, _composition, _isDestroyed, _markerPos, _markerDir, _compositionPath], 2] call CBA_fnc_waitAndExecute;
