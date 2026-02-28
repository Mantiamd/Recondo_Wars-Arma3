/*
    Recondo_fnc_spawnCustomSite
    Spawns a custom site composition at a marker with optional AI
    
    Description:
        Clears terrain, loads and spawns composition, optionally spawns
        garrison AI and patrol groups, registers buildings for night lights.
    
    Parameters:
        _settings - HASHMAP - Module settings
        _markerId - STRING - Marker ID for the site
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
    diag_log format ["[RECONDO_CSS] ERROR: Invalid parameters for spawnCustomSite - marker: %1, comp: %2", _markerId, _composition];
};

private _compositionPath = _settings get "compositionPath";
private _clearRadius = _settings get "clearRadius";
private _debugLogging = _settings get "debugLogging";

private _markerPos = getMarkerPos _markerId;
private _markerDir = markerDir _markerId;

if (_debugLogging) then {
    diag_log format ["[RECONDO_CSS] Spawning site at %1 with composition %2", _markerId, _composition];
};

// ========================================
// CLEAR TERRAIN
// ========================================

if (_clearRadius > 0) then {
    {
        _x hideObjectGlobal true;
    } forEach (nearestTerrainObjects [_markerPos, [
        "TREE", "SMALL TREE", "BUSH", "HOUSE", "WALL", "FENCE", "BUILDING",
        "ROCK", "ROCKS", "HIDE", "FOREST BORDER", "FOREST TRIANGLE", "FOREST SQUARE"
    ], _clearRadius, false, true]);
};

// ========================================
// SPAWN COMPOSITION (delayed after terrain clear)
// ========================================

[{
    params ["_settings", "_markerId", "_composition", "_markerPos", "_markerDir", "_compositionPath"];
    
    private _debugLogging = _settings get "debugLogging";
    private _disableSimulation = _settings get "disableSimulation";
    private _enableNightLights = _settings get "enableNightLights";
    
    // Load composition from mission folder
    private _result = [_compositionPath, _composition, _markerPos, _markerDir, _debugLogging, false] call Recondo_fnc_loadComposition;
    _result params ["_spawnedObjects", "_targetObject"];
    
    if (count _spawnedObjects == 0) exitWith {
        diag_log format ["[RECONDO_CSS] ERROR: Failed to spawn composition %1 at %2", _composition, _markerId];
    };
    
    RECONDO_CSS_SPAWNED_OBJECTS append _spawnedObjects;
    
    // ========================================
    // REGISTER BUILDINGS FOR NIGHT LIGHTS
    // ========================================
    
    if (_enableNightLights) then {
        private _buildingsFound = 0;
        {
            if (!(_x isKindOf "CAManBase") && !(_x isKindOf "LandVehicle") && !(_x isKindOf "Air") && !(_x isKindOf "Ship")) then {
                private _testPos = _x buildingPos 0;
                if !(_testPos isEqualTo [0,0,0]) then {
                    if !(_x in RECONDO_CSS_NIGHT_LIGHT_BUILDINGS) then {
                        RECONDO_CSS_NIGHT_LIGHT_BUILDINGS pushBack _x;
                        _buildingsFound = _buildingsFound + 1;
                    };
                };
            };
        } forEach _spawnedObjects;
        
        if (_debugLogging && _buildingsFound > 0) then {
            diag_log format ["[RECONDO_CSS] Registered %1 buildings for night lights at %2", _buildingsFound, _markerId];
        };
    };
    
    // ========================================
    // DISABLE SIMULATION
    // ========================================
    
    if (_disableSimulation) then {
        private _disabledCount = 0;
        {
            _x enableSimulationGlobal false;
            _disabledCount = _disabledCount + 1;
        } forEach _spawnedObjects;
        
        if (_debugLogging) then {
            diag_log format ["[RECONDO_CSS] Disabled simulation on %1 objects at %2", _disabledCount, _markerId];
        };
    };
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_CSS] Spawned %1 objects at %2", count _spawnedObjects, _markerId];
    };
    
    // ========================================
    // SPAWN GARRISON AI
    // ========================================
    
    private _garrisonClassnames = _settings get "garrisonClassnames";
    private _garrisonCount = _settings get "garrisonCount";
    private _garrisonSide = _settings get "garrisonSide";
    
    if (count _garrisonClassnames > 0 && _garrisonCount > 0) then {
        [{
            params ["_garrisonClassnames", "_garrisonCount", "_garrisonSide", "_markerPos", "_markerId", "_debugLogging"];
            
            private _group = createGroup [_garrisonSide, true];
            
            for "_i" from 1 to _garrisonCount do {
                private _classname = selectRandom _garrisonClassnames;
                private _unit = _group createUnit [_classname, _markerPos, [], 15, "NONE"];
                _unit setDir (random 360);
            };
            
            // Garrison behavior: defend position
            _group setBehaviourStrong "SAFE";
            
            // Find buildings to garrison
            private _buildings = nearestObjects [_markerPos, ["House", "Building"], 50];
            
            if (count _buildings > 0) then {
                // Place units in building positions
                private _allPositions = [];
                {
                    private _bldg = _x;
                    private _posIndex = 0;
                    private _pos = _bldg buildingPos _posIndex;
                    while { !(_pos isEqualTo [0,0,0]) } do {
                        _allPositions pushBack _pos;
                        _posIndex = _posIndex + 1;
                        _pos = _bldg buildingPos _posIndex;
                    };
                } forEach _buildings;
                
                if (count _allPositions > 0) then {
                    {
                        if (_forEachIndex < count _allPositions) then {
                            _x setPos (_allPositions select _forEachIndex);
                        };
                    } forEach (units _group);
                };
            };
            
            // Set waypoint to hold position
            private _wp = _group addWaypoint [_markerPos, 0];
            _wp setWaypointType "HOLD";
            _wp setWaypointBehaviour "SAFE";
            
            if (_debugLogging) then {
                diag_log format ["[RECONDO_CSS] Spawned %1 garrison units at %2", count (units _group), _markerId];
            };
            
        }, [_garrisonClassnames, _garrisonCount, _garrisonSide, _markerPos, _markerId, _debugLogging], 5] call CBA_fnc_waitAndExecute;
    };
    
    // ========================================
    // SPAWN PATROLS
    // ========================================
    
    private _enablePatrols = _settings get "enablePatrols";
    
    if (_enablePatrols) then {
        private _patrolClassnames = _settings get "patrolClassnames";
        private _patrolCount = _settings get "patrolCount";
        private _patrolSize = _settings get "patrolSize";
        private _patrolRadius = _settings get "patrolRadius";
        private _patrolFormation = _settings get "patrolFormation";
        private _garrisonSide = _settings get "garrisonSide";
        
        if (count _patrolClassnames > 0) then {
            [{
                params ["_patrolClassnames", "_patrolCount", "_patrolSize", "_patrolRadius", "_patrolFormation", "_garrisonSide", "_markerPos", "_markerId", "_debugLogging"];
                
                for "_p" from 1 to _patrolCount do {
                    private _patrolGroup = createGroup [_garrisonSide, true];
                    
                    private _spawnPos = _markerPos getPos [20 + random 30, random 360];
                    
                    for "_i" from 1 to _patrolSize do {
                        private _classname = selectRandom _patrolClassnames;
                        _patrolGroup createUnit [_classname, _spawnPos, [], 5, "NONE"];
                    };
                    
                    _patrolGroup setFormation _patrolFormation;
                    _patrolGroup setBehaviourStrong "SAFE";
                    _patrolGroup setSpeedMode "LIMITED";
                    
                    // Create patrol waypoints in a circle
                    for "_w" from 0 to 3 do {
                        private _angle = _w * 90 + (random 45);
                        private _wpPos = _markerPos getPos [_patrolRadius * 0.5 + random (_patrolRadius * 0.5), _angle];
                        private _wp = _patrolGroup addWaypoint [_wpPos, 10];
                        _wp setWaypointType "MOVE";
                        _wp setWaypointBehaviour "SAFE";
                        _wp setWaypointSpeed "LIMITED";
                        _wp setWaypointCompletionRadius 20;
                    };
                    
                    // Cycle waypoint
                    private _wpCycle = _patrolGroup addWaypoint [_markerPos, 20];
                    _wpCycle setWaypointType "CYCLE";
                    
                    if (_debugLogging) then {
                        diag_log format ["[RECONDO_CSS] Spawned patrol group %1 (%2 units) at %3, radius: %4m", _p, count (units _patrolGroup), _markerId, _patrolRadius];
                    };
                };
                
            }, [_patrolClassnames, _patrolCount, _patrolSize, _patrolRadius, _patrolFormation, _garrisonSide, _markerPos, _markerId, _debugLogging], 10] call CBA_fnc_waitAndExecute;
        };
    };
    
}, [_settings, _markerId, _composition, _markerPos, _markerDir, _compositionPath], 2] call CBA_fnc_waitAndExecute;
