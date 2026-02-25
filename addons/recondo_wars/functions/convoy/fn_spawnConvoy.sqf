/*
    Recondo_fnc_spawnConvoy
    Spawns a convoy with vehicles and crews
    
    Description:
        Creates vehicles at the start marker, populates them with
        crews, creates waypoints, and initializes convoy behavior.
        
        If an objective is provided, route is: Start -> Objective -> End
        If no objective (empty array), route is: Start -> End (direct)
    
    Parameters:
        0: HASHMAP - Settings from module
        1: ARRAY - Objective data [markerName, position, type] or empty [] for direct route
        
    Returns:
        ARRAY - [group, createTime, vehicles, destinationMarker, leaderVehicle]
*/

params [
    ["_settings", nil, [createHashMap]],
    ["_objective", [], [[]]]
];

if (isNil "_settings") exitWith {
    diag_log "[RECONDO_CONVOY] ERROR: No settings provided for spawnConvoy";
    [grpNull, 0, [], "", objNull]
};

// Determine if we have an objective or using direct route
private _hasObjective = count _objective >= 3;
private _destMarker = "";
private _destPos = [];
private _destType = "";

if (_hasObjective) then {
    _objective params ["_dm", "_dp", "_dt"];
    _destMarker = _dm;
    _destPos = _dp;
    _destType = _dt;
};

private _debugLogging = _settings get "debugLogging";
private _debugMarkers = _settings get "debugMarkers";

// Get settings
private _convoySide = _settings get "convoySide";
private _startMarker = _settings get "startMarker";
private _endMarker = _settings get "endMarker";
private _vehicleClassnames = _settings get "vehicleClassnames";
private _minVehicles = _settings get "minVehicles";
private _maxVehicles = _settings get "maxVehicles";
private _driverClassnames = _settings get "driverClassnames";
private _gunnerClassnames = _settings get "gunnerClassnames";
private _cargoClassnames = _settings get "cargoClassnames";
private _fillCargo = _settings get "fillCargo";
private _stopAtObjective = _settings get "stopAtObjective";
private _stopDuration = _settings get "stopDuration";

// Convert side string to side
private _side = switch (toUpper _convoySide) do {
    case "EAST": { east };
    case "WEST": { west };
    case "GUER": { independent };
    default { east };
};

// Get positions
private _startPos = getMarkerPos _startMarker;
private _endPos = getMarkerPos _endMarker;

// Calculate spawn direction - check for direction marker first
private _dirMarkerSuffix = _settings get "dirMarkerSuffix";
private _dirMarkerName = _startMarker + _dirMarkerSuffix;
private _startDir = 0;

if (_dirMarkerSuffix != "" && {getMarkerColor _dirMarkerName != ""}) then {
    // Direction marker exists - face toward it
    private _dirPos = getMarkerPos _dirMarkerName;
    _startDir = _startPos getDir _dirPos;
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_CONVOY] Using direction marker '%1', convoy facing %2°", _dirMarkerName, round _startDir];
    };
} else {
    // No direction marker - use start marker rotation (existing behavior)
    _startDir = markerDir _startMarker;
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_CONVOY] Using marker rotation %1° (no direction marker '%2')", round _startDir, _dirMarkerName];
    };
};

// Find nearest road to destination for realistic routing (if we have an objective)
private _destRoadPos = [];
if (_hasObjective) then {
    private _nearestRoads = _destPos nearRoads 100;
    _destRoadPos = _destPos;
    
    if (count _nearestRoads > 0) then {
        private _nearestRoad = _nearestRoads select 0;
        _destRoadPos = getPosATL _nearestRoad;
        
        if (_debugLogging) then {
            diag_log format ["[RECONDO_CONVOY] Found road %1m from destination %2", _destPos distance _destRoadPos, _destMarker];
        };
    };
};

// Create group
private _group = createGroup [_side, true];
private _vehicles = [];

// Determine convoy size
private _vehicleCount = _minVehicles + floor(random (_maxVehicles - _minVehicles + 1));
_vehicleCount = _vehicleCount min (count _vehicleClassnames max _minVehicles);

if (_debugLogging) then {
    private _routeType = if (_hasObjective) then { format ["objective (%1)", _destMarker] } else { "direct" };
    diag_log format ["[RECONDO_CONVOY] Spawning %1 vehicles for %2 route", _vehicleCount, _routeType];
};

// Spawn vehicles
for "_i" from 0 to (_vehicleCount - 1) do {
    // Select vehicle classname (cycle through available classnames)
    private _vehicleType = _vehicleClassnames select (_i mod count _vehicleClassnames);
    
    // Calculate spawn position (vehicles behind each other based on marker direction)
    private _offsetDist = _i * 15; // 15m spacing at spawn
    private _spawnPos = _startPos getPos [_offsetDist, _startDir + 180];
    
    // Create vehicle
    private _vehicle = createVehicle [_vehicleType, _spawnPos, [], 0, "NONE"];
    _vehicle setDir _startDir;
    _vehicle setPos _spawnPos;
    _vehicles pushBack _vehicle;
    
    // Store convoy info on vehicle
    _vehicle setVariable ["RECONDO_CONVOY_Vehicle", true, true];
    _vehicle setVariable ["RECONDO_CONVOY_Index", _i, true];
    _vehicle setVariable ["RECONDO_CONVOY_Group", _group, true];
    
    // Get crew positions
    private _crewPositions = fullCrew [_vehicle, "", true];
    
    // Create crew
    {
        _x params ["_veh", "_role", "_cargoIndex", "_turretPath"];
        
        private _unitType = "";
        
        switch (_role) do {
            case "driver": {
                if (count _driverClassnames > 0) then {
                    _unitType = selectRandom _driverClassnames;
                } else {
                    if (count _cargoClassnames > 0) then {
                        _unitType = _cargoClassnames select 0;
                    };
                };
            };
            case "gunner": {
                if (count _gunnerClassnames > 0) then {
                    _unitType = selectRandom _gunnerClassnames;
                } else {
                    if (count _cargoClassnames > 0) then {
                        _unitType = _cargoClassnames select 0;
                    };
                };
            };
            case "commander": {
                if (count _cargoClassnames > 0) then {
                    _unitType = selectRandom _cargoClassnames;
                };
            };
            case "cargo": {
                if (_fillCargo && count _cargoClassnames > 0) then {
                    _unitType = selectRandom _cargoClassnames;
                };
            };
        };
        
        if (_unitType != "") then {
            private _unit = _group createUnit [_unitType, _startPos, [], 0, "NONE"];
            
            switch (_role) do {
                case "driver": { _unit moveInDriver _vehicle; };
                case "gunner": { _unit moveInGunner _vehicle; };
                case "commander": { _unit moveInCommander _vehicle; };
                case "cargo": { _unit moveInCargo _vehicle; };
            };
            
            _unit enableDynamicSimulation true;
        };
    } forEach _crewPositions;
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_CONVOY] Spawned vehicle %1: %2 at %3", _i + 1, _vehicleType, _spawnPos];
    };
};

// Check we have valid vehicles
if (count _vehicles == 0) exitWith {
    diag_log "[RECONDO_CONVOY] ERROR: No vehicles spawned";
    deleteGroup _group;
    [grpNull, 0, [], "", objNull]
};

private _leaderVeh = _vehicles select 0;

// Set group behavior - CARELESS so drivers don't stop for combat
_group setBehaviour "CARELESS";
_group setSpeedMode "NORMAL";
_group setFormation "COLUMN";

// Disable combat behavior for vehicles - gunners still engage but vehicles keep moving
{
    _x setUnloadInCombat [false, false];
    _x allowCrewInImmobile true;
} forEach _vehicles;

// Store convoy info on leader
_leaderVeh setVariable ["RECONDO_CONVOY_Stopped", false, true];
_leaderVeh setVariable ["RECONDO_CONVOY_Terminate", false, true];
_leaderVeh setVariable ["RECONDO_CONVOY_Path", [_startPos], true];
_leaderVeh setVariable ["RECONDO_CONVOY_Vehicles", _vehicles, true];
_leaderVeh setVariable ["RECONDO_CONVOY_Settings", _settings, true];
_leaderVeh setVariable ["RECONDO_CONVOY_Destination", _destMarker, true];
_leaderVeh setVariable ["RECONDO_CONVOY_DestType", _destType, true];
_leaderVeh setVariable ["RECONDO_CONVOY_DirectRoute", !_hasObjective, true];

// Store on group for easy access
_group setVariable ["RECONDO_CONVOY_LeaderVeh", _leaderVeh, true];
_group setVariable ["RECONDO_CONVOY_Vehicles", _vehicles, true];

// ========================================
// CREATE WAYPOINTS
// ========================================

if (_hasObjective) then {
    // Route with objective: Start -> Objective -> End
    
    // WP1: Move to objective
    private _wp1 = _group addWaypoint [_destRoadPos, 0];
    _wp1 setWaypointType "MOVE";
    _wp1 setWaypointSpeed "NORMAL";
    _wp1 setWaypointBehaviour "CARELESS";
    _wp1 setWaypointCompletionRadius 50;
    
    if (_stopAtObjective) then {
        _wp1 setWaypointTimeout [_stopDuration, _stopDuration, _stopDuration];
        
        // Set waypoint statements to pause convoy
        private _wpStatements = format ["
            if (isServer) then {
                private _vehicles = (group this) getVariable ['RECONDO_CONVOY_Vehicles', []];
                if (count _vehicles > 0) then {
                    private _leaderVeh = _vehicles select 0;
                    _leaderVeh setVariable ['RECONDO_CONVOY_Stopped', true, true];
                    [{
                        params ['_leaderVeh'];
                        if (!isNull _leaderVeh) then {
                            _leaderVeh setVariable ['RECONDO_CONVOY_Stopped', false, true];
                        };
                    }, [_leaderVeh], %1] call CBA_fnc_waitAndExecute;
                };
            };
        ", _stopDuration];
        
        _wp1 setWaypointStatements ["true", _wpStatements];
    };
    
    // WP2: Move to end position
    private _wp2 = _group addWaypoint [_endPos, 0];
    _wp2 setWaypointType "MOVE";
    _wp2 setWaypointSpeed "NORMAL";
    _wp2 setWaypointBehaviour "CARELESS";
    _wp2 setWaypointCompletionRadius 100;
} else {
    // Direct route: Start -> Waypoint markers -> End
    
    // Check for intermediate waypoint markers (CONVOY_1, CONVOY_2, etc.)
    private _waypointPrefix = _settings get "waypointPrefix";
    private _waypointIndex = 1;
    private _waypointsAdded = 0;
    
    if (_waypointPrefix != "") then {
        while {true} do {
            private _wpMarkerName = format ["%1_%2", _waypointPrefix, _waypointIndex];
            
            // Check if marker exists (non-empty color means it exists)
            if (getMarkerColor _wpMarkerName == "") exitWith {};
            
            // Marker exists - add waypoint
            private _wpPos = getMarkerPos _wpMarkerName;
            private _wp = _group addWaypoint [_wpPos, 0];
            _wp setWaypointType "MOVE";
            _wp setWaypointSpeed "NORMAL";
            _wp setWaypointBehaviour "CARELESS";
            _wp setWaypointCompletionRadius 30;
            
            _waypointsAdded = _waypointsAdded + 1;
            _waypointIndex = _waypointIndex + 1;
            
            if (_debugLogging) then {
                diag_log format ["[RECONDO_CONVOY] Added waypoint marker: %1 at %2", _wpMarkerName, _wpPos];
            };
        };
    };
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_CONVOY] Direct route with %1 intermediate waypoints", _waypointsAdded];
    };
    
    // Final waypoint: End position
    private _wpEnd = _group addWaypoint [_endPos, 0];
    _wpEnd setWaypointType "MOVE";
    _wpEnd setWaypointSpeed "NORMAL";
    _wpEnd setWaypointBehaviour "CARELESS";
    _wpEnd setWaypointCompletionRadius 100;
};

// Initialize convoy behavior systems
[_leaderVeh, _vehicles, _settings] call Recondo_fnc_initConvoyBehavior;

// Monitor convoy for end-of-route cleanup
[_group, _leaderVeh, _vehicles, _endPos, _settings] spawn {
    params ["_group", "_leaderVeh", "_vehicles", "_endPos", "_settings"];
    
    private _debugLogging = _settings get "debugLogging";
    
    // Wait until convoy reaches end or is destroyed/terminated
    waitUntil {
        sleep 5;
        
        if (isNull _group || {count (units _group) == 0}) exitWith { true };
        if (_leaderVeh getVariable ["RECONDO_CONVOY_Terminate", false]) exitWith { true };
        
        (leader _group) distance _endPos < 100
    };
    
    // Cleanup convoy
    if (!isNull _group && {count (units _group) > 0}) then {
        if (_debugLogging) then {
            diag_log "[RECONDO_CONVOY] Convoy reached end marker, terminating";
        };
        
        [_leaderVeh] call Recondo_fnc_terminateConvoy;
    };
};

// Create debug marker if enabled
if (_debugMarkers) then {
    private _debugMkrName = format ["CONVOY_DEBUG_%1", round time];
    private _debugMkr = createMarker [_debugMkrName, _startPos];
    _debugMkr setMarkerType "mil_triangle";
    _debugMkr setMarkerColor "ColorRed";
    
    if (_hasObjective) then {
        _debugMkr setMarkerText format ["Convoy -> %1 (%2)", _destMarker, _destType];
    } else {
        _debugMkr setMarkerText "Convoy -> Direct";
    };
    
    _leaderVeh setVariable ["RECONDO_CONVOY_DebugMarker", _debugMkrName, true];
};

// Return convoy data
private _convoyData = [_group, time, _vehicles, _destMarker, _leaderVeh];

if (_debugLogging) then {
    if (_hasObjective) then {
        diag_log format ["[RECONDO_CONVOY] Convoy spawned: %1 vehicles, destination: %2 (%3)", count _vehicles, _destMarker, _destType];
    } else {
        diag_log format ["[RECONDO_CONVOY] Convoy spawned: %1 vehicles, direct route (Start -> End)", count _vehicles];
    };
};

_convoyData
