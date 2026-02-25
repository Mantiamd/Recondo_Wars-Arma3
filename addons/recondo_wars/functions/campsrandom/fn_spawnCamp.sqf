/*
    Recondo_fnc_spawnCamp
    Spawns a camp composition at a marker
    
    Description:
        Clears terrain, loads and spawns composition,
        and spawns AI sentries (intel is added to AI via IntelItems module).
    
    Parameters:
        _settings - HASHMAP - Module settings
        _markerId - STRING - Marker ID for the camp
        _composition - STRING - Composition name to spawn
        _isModPath - BOOL - Whether composition is from mod folder
    
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [
    ["_settings", nil, [createHashMap]],
    ["_markerId", "", [""]],
    ["_composition", "", [""]],
    ["_isModPath", false, [false]]
];

if (isNil "_settings" || _markerId == "" || _composition == "") exitWith {
    diag_log format ["[RECONDO_CAMPS] ERROR: Invalid parameters for spawnCamp - marker: %1, comp: %2", _markerId, _composition];
};

private _clearRadius = _settings get "clearRadius";
private _customCompPath = _settings get "customCompPath";
private _debugLogging = _settings get "debugLogging";
private _instanceId = _settings get "instanceId";
private _campName = _settings get "campName";

private _markerPos = getMarkerPos _markerId;
private _markerDir = markerDir _markerId;

if (_debugLogging) then {
    diag_log format ["[RECONDO_CAMPS] Spawning camp at %1 with composition %2 (mod: %3)", _markerId, _composition, _isModPath];
};

// Clear terrain objects
{
    _x hideObjectGlobal true;
} forEach (nearestTerrainObjects [_markerPos, [
    "TREE", "SMALL TREE", "BUSH", "HIDE", "FOREST BORDER", "FOREST TRIANGLE", "FOREST SQUARE"
], _clearRadius, false, true]);

// Small delay after clearing terrain
[{
    params ["_settings", "_markerId", "_composition", "_isModPath", "_markerPos", "_markerDir"];
    
    private _customCompPath = _settings get "customCompPath";
    private _debugLogging = _settings get "debugLogging";
    private _instanceId = _settings get "instanceId";
    private _campName = _settings get "campName";
    
    // Determine composition path
    private _compPath = if (_isModPath) then { "" } else { _customCompPath };
    
    // Load and spawn composition
    private _result = [_compPath, _composition, _markerPos, _markerDir, _debugLogging, _isModPath] call Recondo_fnc_loadComposition;
    _result params ["_spawnedObjects", "_targetObject"];
    
    if (count _spawnedObjects == 0) exitWith {
        diag_log format ["[RECONDO_CAMPS] ERROR: Failed to spawn composition %1 at %2", _composition, _markerId];
    };
    
    // ========================================
    // CONVERT TO SIMPLE OBJECTS
    // ========================================
    
    private _useSimpleObjects = _settings get "useSimpleObjects";
    private _simpleObjectExclusions = _settings get "simpleObjectExclusions";
    
    private _normalObjects = [];  // Objects that keep simulation (excluded from simple conversion)
    private _simpleObjects = [];  // Simple objects (no simulation needed)
    
    if (_useSimpleObjects) then {
        {
            private _obj = _x;
            private _classname = typeOf _obj;
            
            // Check if this classname should be excluded from simple object conversion
            if (_classname in _simpleObjectExclusions) then {
                // Keep as normal object
                _normalObjects pushBack _obj;
                
                if (_debugLogging) then {
                    diag_log format ["[RECONDO_CAMPS] Excluded from simple conversion: %1", _classname];
                };
            } else {
                // Convert to simple object
                private _posATL = getPosATL _obj;
                private _posWorld = getPosWorld _obj;
                private _dir = getDir _obj;
                private _vectorDir = vectorDir _obj;
                private _vectorUp = vectorUp _obj;
                
                // Create simple object (using world pos for initial creation)
                // Use false for global creation so all clients can see it
                private _simpleObj = createSimpleObject [_classname, _posWorld, false];
                _simpleObj setDir _dir;
                _simpleObj setVectorDirAndUp [_vectorDir, _vectorUp];
                
                // Snap to terrain using ATL position
                _simpleObj setPosATL _posATL;
                
                // Delete original object
                deleteVehicle _obj;
                
                _simpleObjects pushBack _simpleObj;
            };
        } forEach _spawnedObjects;
        
        if (_debugLogging) then {
            diag_log format ["[RECONDO_CAMPS] Converted %1 objects to simple, kept %2 normal at %3", 
                count _simpleObjects, count _normalObjects, _markerId];
        };
    } else {
        // No simple object conversion - all objects are normal
        _normalObjects = _spawnedObjects;
    };
    
    // Track all spawned objects (simple + normal for reference)
    RECONDO_CAMPSRANDOM_SPAWNED pushBack [_markerId, _normalObjects + _simpleObjects];
    
    // Store only NORMAL objects for simulation monitor (simple objects don't need simulation toggle)
    private _objectsVar = format ["RECONDO_CAMPS_%1_objects", _markerId];
    missionNamespace setVariable [_objectsVar, _normalObjects, true];
    
    // Disable simulation initially on normal objects (simulation monitor will enable when players approach)
    {
        _x enableSimulationGlobal false;
    } forEach _normalObjects;
    
    // Make normal objects invulnerable temporarily
    {
        _x allowDamage false;
    } forEach _normalObjects;
    
    // Enable damage after 30 seconds (only for normal objects - simple objects can't be damaged anyway)
    [{
        params ["_objects"];
        {
            if (!isNull _x) then {
                _x allowDamage true;
            };
        } forEach _objects;
    }, [_normalObjects], 30] call CBA_fnc_waitAndExecute;
    
    // ========================================
    // SPAWN AI SENTRIES (intel is added to one random AI via IntelItems module)
    // ========================================
    
    [{
        params ["_settings", "_markerPos", "_markerId"];
        [_settings, _markerPos, _markerId] call Recondo_fnc_spawnCampAI;
        
        // Start simulation monitor after AI are spawned
        [{
            params ["_settings", "_markerId"];
            [_settings, _markerId] call Recondo_fnc_createSimulationMonitor;
        }, [_settings, _markerId], 1] call CBA_fnc_waitAndExecute;
    }, [_settings, _markerPos, _markerId], 3] call CBA_fnc_waitAndExecute;
    
    // ========================================
    // UPDATE ACTIVE STATUS
    // ========================================
    
    private _activeIndex = RECONDO_CAMPSRANDOM_ACTIVE findIf { (_x select 1) == _markerId };
    if (_activeIndex != -1) then {
        private _entry = RECONDO_CAMPSRANDOM_ACTIVE select _activeIndex;
        _entry set [4, "spawned"];
        RECONDO_CAMPSRANDOM_ACTIVE set [_activeIndex, _entry];
        publicVariable "RECONDO_CAMPSRANDOM_ACTIVE";
    };
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_CAMPS] Spawned %1 objects at %2", count _spawnedObjects, _markerId];
    };
    
}, [_settings, _markerId, _composition, _isModPath, _markerPos, _markerDir], 2] call CBA_fnc_waitAndExecute;
