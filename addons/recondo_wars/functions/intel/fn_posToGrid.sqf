/*
    Recondo_fnc_posToGrid
    Converts a position to a 4-digit grid reference
    
    Description:
        Converts a world position to a military-style 4-digit
        grid reference (e.g., "03 85"). This provides ~100m accuracy
        which is appropriate for intel-based location reveals.
    
    Parameters:
        _pos - ARRAY - Position [x, y] or [x, y, z]
    
    Returns:
        STRING - 4-digit grid reference formatted as "XX YY"
    
    Example:
        [[1234.5, 5678.9, 0]] call Recondo_fnc_posToGrid;
        // Returns "01 05" (approximate, depends on map)
*/

params [["_pos", [], [[]]]];

if (count _pos < 2) exitWith {
    "00 00"
};

// Get the map grid reference
private _grid = mapGridPosition _pos;

// mapGridPosition returns a string like "012345" (varies by map)
// We want 4-digit format "XX YY" for ~100m accuracy

private _gridLen = count _grid;

if (_gridLen >= 6) then {
    // Standard 6+ digit grid - take first 2 digits of each component
    private _easting = _grid select [0, 2];
    private _northing = _grid select [3, 2];
    format ["%1 %2", _easting, _northing]
} else {
    if (_gridLen >= 4) then {
        // 4-digit grid (some maps)
        private _easting = _grid select [0, 2];
        private _northing = _grid select [2, 2];
        format ["%1 %2", _easting, _northing]
    } else {
        // Fallback - just return the raw grid
        _grid
    }
};
