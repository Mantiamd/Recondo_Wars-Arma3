/*
    Recondo_fnc_findRandomRoadPos
    Finds a random road position within a radius
    
    Description:
        Searches for roads within the specified radius of a center point
        and returns a random position on a road with appropriate direction.
    
    Parameters:
        _center - ARRAY - Center position [x, y, z]
        _radius - NUMBER - Search radius in meters
    
    Returns:
        ARRAY - [position, direction] or [] if no road found
    
    Example:
        _roadData = [getMarkerPos "marker1", 500] call Recondo_fnc_findRandomRoadPos;
*/

params [
    ["_center", [0,0,0], [[]]],
    ["_radius", 500, [0]]
];

// Find all roads in radius
private _roads = _center nearRoads _radius;

if (count _roads == 0) exitWith {
    []
};

// Try multiple times to find a valid road position
for "_i" from 0 to 9 do {
    private _road = selectRandom _roads;
    
    if (!isNull _road) then {
        private _roadPos = getPos _road;
        
        // Get road direction from connected roads
        private _connectedRoads = roadsConnectedTo _road;
        private _roadDir = 0;
        
        if (count _connectedRoads > 0) then {
            private _connectedRoad = _connectedRoads select 0;
            _roadDir = _roadPos getDir (getPos _connectedRoad);
            
            // Randomly flip direction (50% chance to go the other way)
            if (random 1 > 0.5) then {
                _roadDir = _roadDir + 180;
            };
        } else {
            // No connected roads, use random direction
            _roadDir = random 360;
        };
        
        // Check if position is valid (not too close to players)
        private _tooClose = false;
        {
            if (_roadPos distance _x < 100) exitWith {
                _tooClose = true;
            };
        } forEach allPlayers;
        
        if (!_tooClose) exitWith {
            [_roadPos, _roadDir]
        };
    };
};

// Fallback: return any road if all attempts failed
private _road = selectRandom _roads;
if (!isNull _road) then {
    private _roadPos = getPos _road;
    private _connectedRoads = roadsConnectedTo _road;
    private _roadDir = if (count _connectedRoads > 0) then {
        _roadPos getDir (getPos (_connectedRoads select 0))
    } else {
        random 360
    };
    
    [_roadPos, _roadDir]
} else {
    []
};
