/*
    Recondo_fnc_clearTerrainObjects
    Clear terrain objects within a radius of a position
    
    Description:
        Deletes all terrain objects (trees, rocks, bushes, etc.) within
        the specified radius of the given position. This prepares the
        area for static weapon placement.
    
    Parameters:
        0: ARRAY - Position [x, y, z]
        1: NUMBER - Radius in meters
        
    Returns:
        NUMBER - Count of objects deleted
        
    Example:
        private _count = [[1000, 2000, 0], 5] call Recondo_fnc_clearTerrainObjects;
*/

params ["_pos", "_radius"];

private _debug = false;
if (!isNil "RECONDO_SDR_SETTINGS") then {
    _debug = RECONDO_SDR_SETTINGS getOrDefault ["enableDebug", false];
};

// Get all terrain objects in radius
// nearestTerrainObjects returns map objects like trees, rocks, bushes, etc.
private _terrainObjects = nearestTerrainObjects [_pos, [], _radius, false];

// Also get any simple objects or other objects that might block placement
private _nearObjects = nearestObjects [_pos, ["Bush", "Tree", "Rock", "Stone", "Wall", "Fence"], _radius];

// Combine and remove duplicates
private _allObjects = _terrainObjects + _nearObjects;
_allObjects = _allObjects arrayIntersect _allObjects;

private _deletedCount = 0;

{
    private _obj = _x;
    
    // Check if it's a terrain object (map object)
    if (_obj isKindOf "All" || {!isNull _obj}) then {
        // Hide and delete terrain objects
        _obj hideObjectGlobal true;
        deleteVehicle _obj;
        _deletedCount = _deletedCount + 1;
    };
} forEach _allObjects;

if (_debug && _deletedCount > 0) then {
    diag_log format ["[RECONDO_SDR] Cleared %1 terrain objects within %2m of %3", _deletedCount, _radius, _pos];
};

_deletedCount
