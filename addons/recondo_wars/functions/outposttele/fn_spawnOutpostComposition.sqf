/*
    Recondo_fnc_spawnOutpostComposition
    Spawns a composition at an outpost marker
    
    Description:
        Clears terrain and spawns the specified composition at the marker position.
        Uses the existing Recondo_fnc_loadComposition function.
    
    Parameters:
        _settings - HASHMAP - Module settings
        _markerId - STRING - Marker ID for the outpost
        _composition - STRING - Composition filename to spawn
    
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [
    ["_settings", nil, [createHashMap]],
    ["_markerId", "", [""]],
    ["_composition", "", [""]]
];

if (isNil "_settings" || _markerId == "" || _composition == "") exitWith {
    diag_log format ["[RECONDO_OUTPOSTTELE] ERROR: Invalid parameters for spawnOutpostComposition - marker: %1, comp: %2", _markerId, _composition];
};

private _compositionPath = _settings get "compositionPath";
private _useModCompositions = _settings get "useModCompositions";
private _clearRadius = _settings get "clearRadius";
private _debugLogging = _settings get "debugLogging";

private _markerPos = getMarkerPos _markerId;
private _markerDir = markerDir _markerId;

if (_markerPos isEqualTo [0,0,0]) exitWith {
    diag_log format ["[RECONDO_OUTPOSTTELE] ERROR: Invalid marker position for '%1'", _markerId];
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_OUTPOSTTELE] Spawning composition '%1' at marker '%2'", _composition, _markerId];
};

// Clear terrain objects
{
    _x hideObjectGlobal true;
} forEach (nearestTerrainObjects [_markerPos, [
    "TREE", "SMALL TREE", "BUSH", "HOUSE", "WALL", "FENCE", "BUILDING",
    "ROCK", "ROCKS", "HIDE", "FOREST BORDER", "FOREST TRIANGLE", "FOREST SQUARE"
], _clearRadius, false, true]);

// Small delay after clearing terrain, then spawn composition
[{
    params ["_compositionPath", "_composition", "_markerPos", "_markerDir", "_debugLogging", "_useModCompositions", "_markerId"];
    
    // Load and spawn composition using existing function
    private _result = [_compositionPath, _composition, _markerPos, _markerDir, _debugLogging, _useModCompositions] call Recondo_fnc_loadComposition;
    _result params ["_spawnedObjects", "_targetObject"];
    
    if (count _spawnedObjects == 0) exitWith {
        diag_log format ["[RECONDO_OUTPOSTTELE] ERROR: Failed to spawn composition '%1' at marker '%2'", _composition, _markerId];
    };
    
    // Track spawned objects for cleanup
    RECONDO_OUTPOSTTELE_SPAWNED_OBJECTS append _spawnedObjects;
    
    // Make objects invulnerable temporarily to prevent physics issues
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
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_OUTPOSTTELE] Spawned %1 objects at marker '%2'", count _spawnedObjects, _markerId];
    };
    
}, [_compositionPath, _composition, _markerPos, _markerDir, _debugLogging, _useModCompositions, _markerId], 2] call CBA_fnc_waitAndExecute;
