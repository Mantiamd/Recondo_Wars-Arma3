/*
    Recondo_fnc_findHomePositions
    Find valid indoor positions in buildings for civilian homes
    
    Description:
        Searches for buildings near a position and finds indoor positions
        (positions with a roof above). Assigns jobs based on nearby job markers.
    
    Parameters:
        _center - ARRAY - Center position to search from
        _radius - NUMBER - Search radius
        _count - NUMBER - Number of homes to find
        _markerName - STRING - Village marker name (for job assignment)
    
    Returns:
        ARRAY - Array of [homePos, job, building] entries
*/

params [
    ["_center", [0,0,0], [[]]],
    ["_radius", 150, [0]],
    ["_count", 3, [0]],
    ["_markerName", "", [""]]
];

private _debugLogging = RECONDO_CIVPOL_SETTINGS getOrDefault ["debugLogging", false];

// ========================================
// FIND BUILDINGS
// ========================================

private _buildings = nearestObjects [_center, ["House"], _radius];

// Filter out small/invalid buildings (need at least 1 building position)
_buildings = _buildings select {
    count (_x buildingPos -1) > 0
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_CIVPOL] findHomePositions: Found %1 valid buildings in %2m radius", count _buildings, _radius];
};

if (count _buildings == 0) exitWith {
    diag_log format ["[RECONDO_CIVPOL] WARNING: No valid buildings found near %1", _center];
    []
};

// ========================================
// FIND INDOOR POSITIONS
// ========================================

private _validHomes = [];

{
    private _building = _x;
    private _positions = _building buildingPos -1;
    
    // Filter for truly indoor positions (has roof above)
    private _indoorPositions = _positions select {
        private _pos = _x;
        private _posASL = AGLtoASL _pos;
        
        // Check if there's something above (roof check)
        lineIntersects [
            _posASL vectorAdd [0, 0, 0.5],
            _posASL vectorAdd [0, 0, 3]
        ]
    };
    
    if (count _indoorPositions > 0) then {
        // Pick a random indoor position in this building
        private _homePos = selectRandom _indoorPositions;
        _validHomes pushBack [_homePos, _building];
    };
} forEach _buildings;

if (_debugLogging) then {
    diag_log format ["[RECONDO_CIVPOL] findHomePositions: Found %1 buildings with indoor positions", count _validHomes];
};

// ========================================
// ASSIGN JOBS BASED ON NEARBY MARKERS
// ========================================

private _fieldsMarkers = RECONDO_CIVPOL_SETTINGS getOrDefault ["fieldsMarkers", []];
private _fishermanMarkers = RECONDO_CIVPOL_SETTINGS getOrDefault ["fishermanMarkers", []];

// Check if there's a fisherman marker nearby (within 500m of village)
private _nearbyFisherman = _fishermanMarkers select {
    (_center distance2D (getMarkerPos _x)) < 500
};

// Check if there's a fields marker nearby
private _nearbyFields = _fieldsMarkers select {
    (_center distance2D (getMarkerPos _x)) < 500
};

// Shuffle to randomize which homes get which jobs
_validHomes = _validHomes call BIS_fnc_arrayShuffle;

// Limit to requested count
if (count _validHomes > _count) then {
    _validHomes resize _count;
};

// ========================================
// ASSIGN JOBS
// ========================================

private _homes = [];
private _fishermanCount = 0;
private _maxFishermen = if (count _nearbyFisherman > 0) then { ceil (_count * 0.3) } else { 0 }; // 30% fishermen max

{
    _x params ["_homePos", "_building"];
    
    private _job = "Farmer"; // Default job
    
    // Assign some as fishermen if there's a fishing spot nearby
    if (_fishermanCount < _maxFishermen && count _nearbyFisherman > 0) then {
        _job = "Fisherman";
        _fishermanCount = _fishermanCount + 1;
    };
    
    _homes pushBack [_homePos, _job, _building];
} forEach _validHomes;

if (_debugLogging) then {
    private _farmerCount = { (_x select 1) == "Farmer" } count _homes;
    diag_log format ["[RECONDO_CIVPOL] %1: Assigned %2 farmers, %3 fishermen", 
        _markerName, _farmerCount, _fishermanCount];
};

_homes
