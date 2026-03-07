/*
    Recondo_fnc_spawnPhotoObjective
    Spawns a photo objective composition at a marker
    
    Parameters:
        _settings - HASHMAP - Module settings
        _markerId - STRING - Marker ID for the objective
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
    diag_log format ["[RECONDO_PHOTO] ERROR: Invalid parameters for spawnPhotoObjective - marker: %1, comp: %2", _markerId, _composition];
};

private _compositionPath = if (_isModPath) then { "\recondo_wars\compositions" } else { _settings get "customCompPath" };
private _clearRadius = _settings get "clearRadius";
private _instanceId = _settings get "instanceId";
private _objectiveName = _settings get "objectiveName";
private _debugLogging = _settings get "debugLogging";

private _markerPos = getMarkerPos _markerId;
private _markerDir = markerDir _markerId;

if (_debugLogging) then {
    diag_log format ["[RECONDO_PHOTO] Spawning photo objective at %1 with composition %2", _markerId, _composition];
};

// Clear terrain
{
    _x hideObjectGlobal true;
} forEach (nearestTerrainObjects [_markerPos, [
    "TREE", "SMALL TREE", "BUSH", "HOUSE", "WALL", "FENCE", "BUILDING",
    "ROCK", "ROCKS", "HIDE", "FOREST BORDER", "FOREST TRIANGLE", "FOREST SQUARE"
], _clearRadius, false, true]);

[{
    params ["_settings", "_markerId", "_composition", "_markerPos", "_markerDir", "_compositionPath"];
    
    private _instanceId = _settings get "instanceId";
    private _objectiveName = _settings get "objectiveName";
    private _debugLogging = _settings get "debugLogging";
    
    private _isModPath = _compositionPath select [0, 1] == "\";
    private _result = [_compositionPath, _composition, _markerPos, _markerDir, _debugLogging, _isModPath] call Recondo_fnc_loadComposition;
    _result params ["_spawnedObjects", "_targetObject"];
    
    if (count _spawnedObjects == 0) exitWith {
        diag_log format ["[RECONDO_PHOTO] ERROR: Failed to spawn composition %1 at %2", _composition, _markerId];
    };
    
    RECONDO_PHOTO_SPAWNED_OBJECTS append _spawnedObjects;
    
    // Suppress grass/clutter around the composition
    private _clutterCutter = createVehicle ["Land_ClutterCutter_large_F", _markerPos, [], 0, "CAN_COLLIDE"];
    _clutterCutter setPosATL _markerPos;
    RECONDO_PHOTO_SPAWNED_OBJECTS pushBack _clutterCutter;
    
    // Register buildings for night lights
    private _enableNightLights = _settings get "enableNightLights";
    if (_enableNightLights) then {
        {
            if (!(_x isKindOf "CAManBase") && !(_x isKindOf "LandVehicle") && !(_x isKindOf "Air") && !(_x isKindOf "Ship")) then {
                private _testPos = _x buildingPos 0;
                if !(_testPos isEqualTo [0,0,0]) then {
                    if !(_x in RECONDO_PHOTO_NIGHT_LIGHT_BUILDINGS) then {
                        RECONDO_PHOTO_NIGHT_LIGHT_BUILDINGS pushBack _x;
                    };
                };
            };
        } forEach _spawnedObjects;
    };
    
    // Disable simulation on composition objects
    private _disableSimulation = _settings get "disableSimulation";
    if (_disableSimulation) then {
        { _x enableSimulationGlobal false; } forEach _spawnedObjects;
    };
    
    // Temporary invulnerability
    { _x allowDamage false; } forEach _spawnedObjects;
    
    [{
        params ["_objects"];
        { if (!isNull _x) then { _x allowDamage true; }; } forEach _objects;
    }, [_spawnedObjects], 30] call CBA_fnc_waitAndExecute;
    
    // Spawn AI
    [{
        params ["_settings", "_markerPos", "_markerId"];
        [_settings, _markerPos, _markerId] call Recondo_fnc_spawnPhotoAI;
    }, [_settings, _markerPos, _markerId], 5] call CBA_fnc_waitAndExecute;
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_PHOTO] Spawned %1 objects at %2", count _spawnedObjects, _markerId];
    };
    
}, [_settings, _markerId, _composition, _markerPos, _markerDir, _compositionPath], 2] call CBA_fnc_waitAndExecute;
