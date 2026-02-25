/*
    Recondo_fnc_spawnSubSite
    Spawns a sub-site object at a marker
    
    Description:
        Clears terrain, spawns a single object (static weapon/bunker)
        at the marker position with random facing, then schedules
        garrison AI spawn after 20 seconds.
    
    Parameters:
        _settings - HASHMAP - Module settings
        _hubMarker - STRING - Parent hub marker name
        _subSiteMarker - STRING - Sub-site marker name
        _classname - STRING - Object classname to spawn
    
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [
    ["_settings", nil, [createHashMap]],
    ["_hubMarker", "", [""]],
    ["_subSiteMarker", "", [""]],
    ["_classname", "", [""]]
];

if (isNil "_settings" || _subSiteMarker == "" || _classname == "") exitWith {
    diag_log format ["[RECONDO_HUBSUBS] ERROR: Invalid parameters for spawnSubSite - marker: %1, classname: %2", _subSiteMarker, _classname];
};

// Check if parent hub is destroyed
if (_hubMarker in RECONDO_HUBSUBS_DESTROYED) exitWith {
    diag_log format ["[RECONDO_HUBSUBS] Parent hub %1 destroyed, not spawning sub-site %2", _hubMarker, _subSiteMarker];
};

private _clearRadius = _settings get "subSiteClearRadius";
private _debugLogging = _settings get "debugLogging";

private _markerPos = getMarkerPos _subSiteMarker;

if (_debugLogging) then {
    diag_log format ["[RECONDO_HUBSUBS] Spawning sub-site at %1 with classname %2", _subSiteMarker, _classname];
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
    params ["_settings", "_hubMarker", "_subSiteMarker", "_classname", "_markerPos"];
    
    private _debugLogging = _settings get "debugLogging";
    
    // Validate classname exists
    if (!isClass (configFile >> "CfgVehicles" >> _classname)) exitWith {
        diag_log format ["[RECONDO_HUBSUBS] ERROR: Invalid classname %1 for sub-site %2", _classname, _subSiteMarker];
    };
    
    // Create the object at marker position with random facing
    private _spawnedObject = createVehicle [_classname, _markerPos, [], 0, "CAN_COLLIDE"];
    
    if (isNull _spawnedObject) exitWith {
        diag_log format ["[RECONDO_HUBSUBS] ERROR: Failed to spawn object %1 at %2", _classname, _subSiteMarker];
    };
    
    // Set random facing direction
    _spawnedObject setDir (random 360);
    
    // Ensure object is on ground
    _spawnedObject setPosATL [getPosATL _spawnedObject select 0, getPosATL _spawnedObject select 1, 0];
    
    // Track spawned object
    RECONDO_HUBSUBS_SPAWNED_OBJECTS pushBack _spawnedObject;
    
    // Mark sub-site as spawned
    {
        _x params ["_hm", "_ssm", "_spawned"];
        if (_ssm == _subSiteMarker) exitWith {
            RECONDO_HUBSUBS_SUBSITES set [_forEachIndex, [_hm, _ssm, true]];
        };
    } forEach RECONDO_HUBSUBS_SUBSITES;
    publicVariable "RECONDO_HUBSUBS_SUBSITES";
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_HUBSUBS] Spawned %1 at sub-site %2, facing: %3", _classname, _subSiteMarker, getDir _spawnedObject];
    };
    
    // Schedule garrison spawn after 20 seconds
    [{
        params ["_settings", "_markerPos", "_subSiteMarker", "_spawnedObject"];
        [_settings, _markerPos, _subSiteMarker, _spawnedObject] call Recondo_fnc_spawnSubSiteGarrison;
    }, [_settings, _markerPos, _subSiteMarker, _spawnedObject], 20] call CBA_fnc_waitAndExecute;
    
}, [_settings, _hubMarker, _subSiteMarker, _classname, _markerPos], 2] call CBA_fnc_waitAndExecute;
