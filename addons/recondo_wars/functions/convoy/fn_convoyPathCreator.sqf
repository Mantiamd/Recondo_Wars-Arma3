/*
    Recondo_fnc_convoyPathCreator
    Records leader vehicle path for followers
    
    Description:
        Continuously records the leader vehicle's position as a
        breadcrumb trail. Followers use setDriveOnPath to follow
        this exact path.
    
    Parameters:
        0: OBJECT - Leader vehicle
        1: ARRAY - All vehicles in convoy
        2: HASHMAP - Settings from module
        
    Returns:
        Nothing
*/

params [
    ["_leaderVeh", objNull, [objNull]],
    ["_vehicles", [], [[]]],
    ["_settings", nil, [createHashMap]]
];

if (isNull _leaderVeh || count _vehicles < 2 || isNil "_settings") exitWith {
    diag_log "[RECONDO_CONVOY] PathCreator: Invalid parameters or single-vehicle convoy";
};

private _pathFreq = _settings get "pathFreq";
private _debugLogging = _settings get "debugLogging";
private _debugMarkers = _settings get "debugMarkers";

private _convoyLength = count _vehicles;
private _chopDistance = 10; // Distance threshold for path trimming

if (_debugLogging) then {
    diag_log format ["[RECONDO_CONVOY] PathCreator started, update frequency: %1s", _pathFreq];
};

// Initialize debug draw objects if enabled
if (_debugMarkers) then {
    private _drawObjects = [];
    for "_i" from 0 to (_convoyLength - 2) do {
        _drawObjects pushBack [];
    };
    _leaderVeh setVariable ["RECONDO_CONVOY_DrawObjects", _drawObjects];
};

while {!(_leaderVeh getVariable ["RECONDO_CONVOY_Terminate", false])} do {
    // Check if leader is valid
    if (isNull _leaderVeh || !alive _leaderVeh) exitWith {
        if (_debugLogging) then {
            diag_log "[RECONDO_CONVOY] PathCreator: Leader vehicle destroyed, exiting";
        };
    };
    
    // Record current leader position
    private _path = _leaderVeh getVariable ["RECONDO_CONVOY_Path", []];
    _path pushBack (getPosATL _leaderVeh);
    
    // Trim old path points behind the last vehicle
    private _vehicleInBack = _vehicles select (_convoyLength - 1);
    
    if (!isNull _vehicleInBack && alive _vehicleInBack) then {
        private _backPos = getPosATL _vehicleInBack;
        private _foundCandidate = false;
        
        // Find and remove path points that are behind the last vehicle
        for "_j" from (count _path - 1) to 0 step -1 do {
            private _wpPos = _path select _j;
            private _distBack = _wpPos distance _backPos;
            
            if (_distBack < _chopDistance && !_foundCandidate) then {
                _foundCandidate = true;
            };
            
            if (_distBack > _chopDistance && _foundCandidate) then {
                _path deleteAt _j;
            };
        };
    };
    
    // Store updated path
    _leaderVeh setVariable ["RECONDO_CONVOY_Path", _path];
    
    // Create vehicle-specific paths for each follower
    for "_i" from 1 to (_convoyLength - 1) do {
        private _vehicle = _vehicles select _i;
        
        if (isNull _vehicle || !alive _vehicle) then { continue };
        
        private _vehicleInFront = _vehicles select (_i - 1);
        
        if (isNull _vehicleInFront || !alive _vehicleInFront) then { continue };
        
        // Build path segment for this vehicle
        private _vehiclePathChop = [];
        private _foundCandidate = false;
        private _foundLast = false;
        private _foundFirst = false;
        private _lastPoint = 0;
        private _firstPoint = 0;
        
        private _vehPos = getPosATL _vehicle;
        private _frontPos = getPosATL _vehicleInFront;
        
        for "_j" from (count _path - 1) to 0 step -1 do {
            private _wpPos = _path select _j;
            private _distFront = _wpPos distance _frontPos;
            private _distBack = _wpPos distance _vehPos;
            
            // Find first point candidate (near front vehicle)
            if (_distFront < _chopDistance && !_foundCandidate && !_foundLast && !_foundFirst) then {
                _foundCandidate = true;
            };
            
            // Find last point (beyond front vehicle)
            if (_distFront > _chopDistance && _foundCandidate && !_foundLast && !_foundFirst) then {
                _foundLast = true;
                _lastPoint = _j;
            };
            
            // Find first point (near this vehicle)
            if ((_distBack < _chopDistance || _j == 0) && _foundCandidate && _foundLast && !_foundFirst) then {
                _foundFirst = true;
                _firstPoint = _j;
                
                if (_firstPoint < _lastPoint) then {
                    _vehiclePathChop = _path select [_firstPoint, _lastPoint - _firstPoint + 1];
                };
            };
        };
        
        // Apply path to vehicle
        private _minPathPoints = 3; // Minimum points needed for reliable setDriveOnPath
        private _stuckDistance = 20; // Distance threshold to consider vehicle stuck
        
        if (count _vehiclePathChop >= _minPathPoints) then {
            // Check if vehicle is stuck (speed near 0 and behind front vehicle)
            if (speed _vehicle < 2 && _vehPos distance _frontPos > _stuckDistance) then {
                // Vehicle has path but isn't moving - likely stuck on obstacle
                private _driver = driver _vehicle;
                if (!isNull _driver && alive _driver) then {
                    
                    // ========================================
                    // CLEAR NEARBY TERRAIN OBSTACLES
                    // ========================================
                    // Only clear once per location to avoid spam
                    private _lastClearPos = _vehicle getVariable ["RECONDO_CONVOY_LastClearPos", [0,0,0]];
                    if (_vehPos distance _lastClearPos > 10) then {
                        // Find trees, bushes, rocks, fences, and walls within 8m of the stuck vehicle
                        private _obstacles = nearestTerrainObjects [_vehPos, ["TREE", "SMALL TREE", "BUSH", "ROCK", "ROCKS", "FENCE", "WALL"], 8];
                        
                        // Find buildings within 5m (smaller radius to avoid clearing large structures unnecessarily)
                        private _buildings = nearestTerrainObjects [_vehPos, ["BUILDING", "HOUSE"], 5];
                        
                        // Combine all obstacles
                        _obstacles append _buildings;
                        
                        if (count _obstacles > 0) then {
                            {
                                _x hideObjectGlobal true;
                            } forEach _obstacles;
                            
                            // Remember where we cleared so we don't spam
                            _vehicle setVariable ["RECONDO_CONVOY_LastClearPos", _vehPos];
                            
                            if (_debugLogging) then {
                                diag_log format ["[RECONDO_CONVOY] PathCreator: Vehicle %1 stuck - cleared %2 obstacles at %3", 
                                    _i, count _obstacles, _vehPos];
                            };
                        };
                    };
                    
                    // Apply doMove fallback
                    _driver doMove _frontPos;
                    
                    if (_debugLogging) then {
                        diag_log format ["[RECONDO_CONVOY] PathCreator: Vehicle %1 stuck with path, forcing doMove (dist: %2m)", _i, round(_vehPos distance _frontPos)];
                    };
                };
            } else {
                _vehicle setDriveOnPath _vehiclePathChop;
            };
        } else {
            // Path too short or empty - use doMove fallback
            private _driver = driver _vehicle;
            if (!isNull _driver && alive _driver) then {
                
                // Check if vehicle is stuck (speed near 0 and behind front vehicle)
                // Also clear obstacles here since we can't rely on path-following
                if (speed _vehicle < 2 && _vehPos distance _frontPos > _stuckDistance) then {
                    
                    // ========================================
                    // CLEAR NEARBY TERRAIN OBSTACLES
                    // ========================================
                    // Only clear once per location to avoid spam
                    private _lastClearPos = _vehicle getVariable ["RECONDO_CONVOY_LastClearPos", [0,0,0]];
                    if (_vehPos distance _lastClearPos > 10) then {
                        // Find trees, bushes, rocks, fences, and walls within 8m of the stuck vehicle
                        private _obstacles = nearestTerrainObjects [_vehPos, ["TREE", "SMALL TREE", "BUSH", "ROCK", "ROCKS", "FENCE", "WALL"], 8];
                        
                        // Find buildings within 5m (smaller radius to avoid clearing large structures unnecessarily)
                        private _buildings = nearestTerrainObjects [_vehPos, ["BUILDING", "HOUSE"], 5];
                        
                        // Combine all obstacles
                        _obstacles append _buildings;
                        
                        if (count _obstacles > 0) then {
                            {
                                _x hideObjectGlobal true;
                            } forEach _obstacles;
                            
                            // Remember where we cleared so we don't spam
                            _vehicle setVariable ["RECONDO_CONVOY_LastClearPos", _vehPos];
                            
                            if (_debugLogging) then {
                                diag_log format ["[RECONDO_CONVOY] PathCreator: Vehicle %1 stuck (no path) - cleared %2 obstacles at %3", 
                                    _i, count _obstacles, _vehPos];
                            };
                        };
                    };
                    
                    if (_debugLogging) then {
                        diag_log format ["[RECONDO_CONVOY] PathCreator: Vehicle %1 stuck with short path, forcing doMove (dist: %2m)", _i, round(_vehPos distance _frontPos)];
                    };
                } else {
                    if (_debugLogging) then {
                        diag_log format ["[RECONDO_CONVOY] PathCreator: Vehicle %1 path too short (%2 pts), using doMove fallback", _i, count _vehiclePathChop];
                    };
                };
                
                _driver doMove _frontPos;
            };
        };
        
        // Debug visualization
        if (_debugMarkers) then {
            private _drawObjects = _leaderVeh getVariable ["RECONDO_CONVOY_DrawObjects", []];
            
            if (_i - 1 < count _drawObjects) then {
                // Clean up old markers
                { deleteVehicle _x } forEach (_drawObjects select (_i - 1));
                
                // Create new markers for path (limit to every 5th point for performance)
                private _newObjects = [];
                for "_k" from 0 to (count _vehiclePathChop - 1) step 5 do {
                    private _iconPos = _vehiclePathChop select _k;
                    private _arrowType = switch (_i mod 6) do {
                        case 1: { "Sign_Arrow_Blue_F" };
                        case 2: { "Sign_Arrow_Cyan_F" };
                        case 3: { "Sign_Arrow_Green_F" };
                        case 4: { "Sign_Arrow_Pink_F" };
                        case 5: { "Sign_Arrow_Yellow_F" };
                        default { "Sign_Arrow_F" };
                    };
                    _newObjects pushBack (createVehicle [_arrowType, _iconPos, [], 0, "CAN_COLLIDE"]);
                };
                
                _drawObjects set [_i - 1, _newObjects];
                _leaderVeh setVariable ["RECONDO_CONVOY_DrawObjects", _drawObjects];
            };
        };
    };
    
    sleep _pathFreq;
};

// Cleanup debug markers
if (_debugMarkers) then {
    private _drawObjects = _leaderVeh getVariable ["RECONDO_CONVOY_DrawObjects", []];
    {
        { deleteVehicle _x } forEach _x;
    } forEach _drawObjects;
};

if (_debugLogging) then {
    diag_log "[RECONDO_CONVOY] PathCreator stopped";
};
