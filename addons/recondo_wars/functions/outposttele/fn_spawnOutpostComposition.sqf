/*
    Recondo_fnc_spawnOutpostComposition
    Spawns a composition at an outpost marker
    
    Description:
        Clears terrain and spawns the specified composition at the marker position.
        Uses the existing Recondo_fnc_loadComposition function.
        If a destroyable classname is configured, finds the matching object
        in the composition, keeps its simulation enabled, and monitors it
        for destruction.
    
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
private _destroyableClassname = _settings getOrDefault ["destroyableClassname", ""];
private _instanceId = _settings get "instanceId";

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
    params ["_compositionPath", "_composition", "_markerPos", "_markerDir", "_debugLogging", "_useModCompositions", "_markerId", "_destroyableClassname", "_instanceId", "_settings"];
    
    private _result = [_compositionPath, _composition, _markerPos, _markerDir, _debugLogging, _useModCompositions] call Recondo_fnc_loadComposition;
    _result params ["_spawnedObjects", "_targetObject"];
    
    if (count _spawnedObjects == 0) exitWith {
        diag_log format ["[RECONDO_OUTPOSTTELE] ERROR: Failed to spawn composition '%1' at marker '%2'", _composition, _markerId];
    };
    
    RECONDO_OUTPOSTTELE_SPAWNED_OBJECTS append _spawnedObjects;
    
    // Find and tag destroyable object
    private _destroyableObj = objNull;
    if (_destroyableClassname != "") then {
        {
            if (typeOf _x == _destroyableClassname) exitWith {
                _destroyableObj = _x;
            };
        } forEach _spawnedObjects;
        
        if (isNull _destroyableObj) then {
            diag_log format ["[RECONDO_OUTPOSTTELE] WARNING: Destroyable classname '%1' not found in composition at marker '%2'", _destroyableClassname, _markerId];
        } else {
            _destroyableObj setVariable ["RECONDO_OUTPOSTTELE_MARKER_ID", _markerId, true];
            _destroyableObj setVariable ["RECONDO_OUTPOSTTELE_INSTANCE_ID", _instanceId, true];
            
            _destroyableObj addEventHandler ["Killed", {
                params ["_unit", "_killer"];
                
                private _markerId = _unit getVariable ["RECONDO_OUTPOSTTELE_MARKER_ID", ""];
                private _instanceId = _unit getVariable ["RECONDO_OUTPOSTTELE_INSTANCE_ID", ""];
                
                if (_markerId == "" || _instanceId == "") exitWith {
                    diag_log "[RECONDO_OUTPOSTTELE] ERROR: Killed EH fired but marker/instance data missing from destroyed object.";
                };
                
                [_instanceId, _markerId] call Recondo_fnc_outpostDestroyed;
            }];
            
            if (_debugLogging) then {
                diag_log format ["[RECONDO_OUTPOSTTELE] Tagged destroyable object: %1 at marker '%2' (Killed EH registered)", typeOf _destroyableObj, _markerId];
            };
        };
    };
    
    // Make non-destroyable objects invulnerable temporarily to prevent physics issues
    // Excludes the destroyable object so it can be damaged immediately
    {
        if (_x != _destroyableObj) then {
            _x allowDamage false;
        };
    } forEach _spawnedObjects;
    
    // Re-enable damage on remaining objects after 30 seconds
    [{
        params ["_objects", "_destroyableObj"];
        {
            if (!isNull _x && _x != _destroyableObj) then {
                _x allowDamage true;
            };
        } forEach _objects;
    }, [_spawnedObjects, _destroyableObj], 30] call CBA_fnc_waitAndExecute;
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_OUTPOSTTELE] Spawned %1 objects at marker '%2'", count _spawnedObjects, _markerId];
    };
    
}, [_compositionPath, _composition, _markerPos, _markerDir, _debugLogging, _useModCompositions, _markerId, _destroyableClassname, _instanceId, _settings], 2] call CBA_fnc_waitAndExecute;
