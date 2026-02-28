/*
    Recondo_fnc_spawnHub
    Spawns a hub composition at a marker
    
    Description:
        Clears terrain, loads and spawns hub composition, finds target object,
        adds destruction handler, and spawns hub AI.
    
    Parameters:
        _settings - HASHMAP - Module settings
        _hubMarker - STRING - Hub marker ID
        _composition - STRING - Composition name to spawn
        _isDestroyed - BOOL - Whether hub is already destroyed
        _isModPath - BOOL - Whether composition is from mod folder (default: false)
    
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [
    ["_settings", nil, [createHashMap]],
    ["_hubMarker", "", [""]],
    ["_composition", "", [""]],
    ["_isDestroyed", false, [false]],
    ["_isModPath", false, [false]]
];

if (isNil "_settings" || _hubMarker == "" || _composition == "") exitWith {
    diag_log format ["[RECONDO_HUBSUBS] ERROR: Invalid parameters for spawnHub - marker: %1, comp: %2", _hubMarker, _composition];
};

private _compositionPath = if (_isModPath) then { "\recondo_wars\compositions" } else { _settings get "customCompPath" };
private _clearRadius = _settings get "clearRadius";
private _targetClassname = _settings get "targetClassname";
private _instanceId = _settings get "instanceId";
private _objectiveName = _settings get "objectiveName";
private _debugLogging = _settings get "debugLogging";

private _markerPos = getMarkerPos _hubMarker;
private _markerDir = markerDir _hubMarker;

if (_debugLogging) then {
    diag_log format ["[RECONDO_HUBSUBS] Spawning hub at %1 with composition %2", _hubMarker, _composition];
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
    params ["_settings", "_hubMarker", "_composition", "_isDestroyed", "_markerPos", "_markerDir", "_compositionPath"];
    private _targetClassname = _settings get "targetClassname";
    private _instanceId = _settings get "instanceId";
    private _objectiveName = _settings get "objectiveName";
    private _debugLogging = _settings get "debugLogging";
    
    // Load and spawn composition
    private _isModPath = _compositionPath select [0, 1] == "\";
    private _result = [_compositionPath, _composition, _markerPos, _markerDir, _debugLogging, _isModPath] call Recondo_fnc_loadComposition;
    _result params ["_spawnedObjects", "_targetObject"];
    
    if (count _spawnedObjects == 0) exitWith {
        diag_log format ["[RECONDO_HUBSUBS] ERROR: Failed to spawn hub composition %1 at %2", _composition, _hubMarker];
    };
    
    // Track spawned objects
    RECONDO_HUBSUBS_SPAWNED_OBJECTS append _spawnedObjects;
    
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
        _targetObject setVariable ["RECONDO_HUBSUBS_instanceId", _instanceId, true];
        _targetObject setVariable ["RECONDO_HUBSUBS_hubMarker", _hubMarker, true];
        _targetObject setVariable ["RECONDO_HUBSUBS_objectiveName", _objectiveName, true];
        
        _targetObject addEventHandler ["Killed", {
            params ["_unit", "_killer", "_instigator", "_useEffects"];
            
            private _instanceId = _unit getVariable ["RECONDO_HUBSUBS_instanceId", ""];
            private _hubMarker = _unit getVariable ["RECONDO_HUBSUBS_hubMarker", ""];
            private _objectiveName = _unit getVariable ["RECONDO_HUBSUBS_objectiveName", ""];
            
            [_instanceId, _hubMarker, _objectiveName] call Recondo_fnc_handleHubDestroyed;
        }];
        
        if (_debugLogging) then {
            diag_log format ["[RECONDO_HUBSUBS] Added destruction handler to %1 at %2", typeOf _targetObject, _hubMarker];
        };
    };
    
    // ========================================
    // DISABLE SIMULATION ON COMPOSITION OBJECTS
    // ========================================
    
    private _disableSimulation = _settings getOrDefault ["disableSimulation", true];
    
    if (_disableSimulation) then {
        private _disabledCount = 0;
        {
            // For active hubs: disable all EXCEPT target
            // For destroyed hubs: disable ALL (no target needed)
            if (_isDestroyed || _x != _targetObject) then {
                _x enableSimulationGlobal false;
                _disabledCount = _disabledCount + 1;
            };
        } forEach _spawnedObjects;
        
        if (_debugLogging) then {
            diag_log format ["[RECONDO_HUBSUBS] Disabled simulation on %1 of %2 objects at %3 (destroyed: %4, target excluded: %5)", 
                _disabledCount, count _spawnedObjects, _hubMarker, _isDestroyed, !_isDestroyed && !isNull _targetObject];
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
    
    // Spawn hub AI if not destroyed
    if (!_isDestroyed) then {
        // Spawn sentries after 5 seconds
        [{
            params ["_settings", "_markerPos", "_hubMarker"];
            
            private _hubAISide = _settings get "hubAISide";
            private _hubSentryClassnames = _settings get "hubSentryClassnames";
            private _hubSentryMin = _settings get "hubSentryMin";
            private _hubSentryMax = _settings get "hubSentryMax";
            private _debugLogging = _settings get "debugLogging";
            
            // Create AI settings hashmap - sentries only (patrolCount = 0)
            private _aiSettings = createHashMapFromArray [
                ["aiSide", _hubAISide],
                ["sentryClassnames", _hubSentryClassnames],
                ["sentryMin", _hubSentryMin],
                ["sentryMax", _hubSentryMax],
                ["patrolCount", 0],
                ["patrolMin", 0],
                ["patrolMax", 0],
                ["patrolRadius", 0],
                ["patrolFormation", "WEDGE"],
                ["debugLogging", _debugLogging]
            ];
            
            // Reuse objective destroy AI spawn function (sentries only)
            [_aiSettings, _markerPos, _hubMarker] call Recondo_fnc_spawnObjectiveAI;
            
        }, [_settings, _markerPos, _hubMarker], 5] call CBA_fnc_waitAndExecute;
        
        // Spawn security patrols after 30 seconds
        [{
            params ["_settings", "_markerPos", "_hubMarker"];
            [_settings, _markerPos, _hubMarker] call Recondo_fnc_spawnSecurityPatrol;
        }, [_settings, _markerPos, _hubMarker], 30] call CBA_fnc_waitAndExecute;
    };
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_HUBSUBS] Spawned %1 objects at hub %2, target: %3", 
            count _spawnedObjects, _hubMarker, if (isNull _targetObject) then { "NONE" } else { typeOf _targetObject }];
    };
    
}, [_settings, _hubMarker, _composition, _isDestroyed, _markerPos, _markerDir, _compositionPath], 2] call CBA_fnc_waitAndExecute;
