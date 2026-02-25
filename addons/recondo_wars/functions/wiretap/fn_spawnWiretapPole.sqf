/*
    Recondo_fnc_spawnWiretapPole
    Spawns a single telephone pole at a marker position
    
    Description:
        Creates a pole object near the marker, attempting to align
        with nearby roads. Clears terrain and adds ACE actions.
    
    Parameters:
        _markerName - STRING - Name of the marker
        _markerPos - ARRAY - Position of the marker [x, y, z]
    
    Returns:
        OBJECT - The spawned pole object
*/

if (!isServer) exitWith { objNull };

params [
    ["_markerName", "", [""]],
    ["_markerPos", [0,0,0], [[]]]
];

// Get settings
private _poleClassname = RECONDO_WIRETAP_SETTINGS get "poleClassname";
private _roadSearchRadius = RECONDO_WIRETAP_SETTINGS get "roadSearchRadius";
private _roadOffset = RECONDO_WIRETAP_SETTINGS get "roadOffset";
private _clearRadius = RECONDO_WIRETAP_SETTINGS get "clearRadius";
private _debugLogging = RECONDO_WIRETAP_SETTINGS get "debugLogging";

private _pole = objNull;
private _polePos = _markerPos;
private _poleDir = random 360;

// Try to find a nearby road
private _roads = _markerPos nearRoads _roadSearchRadius;

if (count _roads > 0) then {
    private _nearestRoad = _roads select 0;
    private _roadPos = getPosATL _nearestRoad;
    
    // Get road direction
    private _connectedRoads = roadsConnectedTo _nearestRoad;
    private _roadDir = 0;
    
    if (count _connectedRoads > 0) then {
        _roadDir = _nearestRoad getDir (_connectedRoads select 0);
    };
    
    // Calculate position perpendicular to road
    private _perpDir = _roadDir + 90;
    _polePos = _roadPos getPos [_roadOffset, _perpDir];
    _poleDir = _roadDir;
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_WIRETAP] Pole at %1 aligned to road, dir: %2", _markerName, _roadDir];
    };
} else {
    if (_debugLogging) then {
        diag_log format ["[RECONDO_WIRETAP] No road found near %1, using marker position", _markerName];
    };
};

// Clear terrain objects around pole position
{
    _x hideObjectGlobal true;
} forEach (nearestTerrainObjects [_polePos, ["TREE", "SMALL TREE", "BUSH", "HOUSE", "WALL", "FENCE"], _clearRadius, false, true]);

// Create the pole
_pole = createVehicle [_poleClassname, _polePos, [], 0, "CAN_COLLIDE"];
_pole setDir _poleDir;
_pole setVectorUp [0, 0, 1];

// Store pole data
_pole setVariable ["RECONDO_WIRETAP_markerName", _markerName, true];
_pole setVariable ["RECONDO_WIRETAP_hasWiretap", false, true];

// Store direction AWAY from road (the perpendicular direction pole was offset in)
// This is used later to spawn the ground wiretap item on the opposite side from the road
private _dirAwayFromRoad = _poleDir + 90; // _poleDir is parallel to road, +90 is direction pole was offset
_pole setVariable ["RECONDO_WIRETAP_dirToRoad", _dirAwayFromRoad, true];

// Disable simulation if configured (prevents accidental destruction by vehicles)
private _disableSimulation = RECONDO_WIRETAP_SETTINGS getOrDefault ["disableSimulation", true];
if (_disableSimulation) then {
    _pole enableSimulationGlobal false;
    if (_debugLogging) then {
        diag_log format ["[RECONDO_WIRETAP] Disabled simulation on pole at %1", _markerName];
    };
};

// Add to global tracking
RECONDO_WIRETAP_POLES pushBack _pole;

// Add ACE interaction to pole on all clients (with JIP)
[_pole] remoteExec ["Recondo_fnc_addWiretapPlaceAction", 0, _pole];

if (_debugLogging) then {
    diag_log format ["[RECONDO_WIRETAP] Spawned pole at marker %1, pos: %2", _markerName, _polePos];
};

_pole
