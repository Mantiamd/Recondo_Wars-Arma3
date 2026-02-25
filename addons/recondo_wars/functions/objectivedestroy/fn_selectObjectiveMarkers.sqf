/*
    Recondo_fnc_selectObjectiveMarkers
    Selects markers based on prefix and percentage
    
    Description:
        Finds all markers with the given prefix and randomly
        selects a percentage of them for objective placement.
    
    Parameters:
        _markerPrefix - STRING - Prefix to search for (e.g., "CACHE_")
        _spawnPercentage - NUMBER - Percentage of markers to select (0-1)
        _debugLogging - BOOL - Enable debug logging
    
    Returns:
        ARRAY - Array of selected marker names
    
    Example:
        ["CACHE_", 0.5, false] call Recondo_fnc_selectObjectiveMarkers;
*/

params [
    ["_markerPrefix", "", [""]],
    ["_spawnPercentage", 0.5, [0]],
    ["_debugLogging", false, [false]]
];

if (_markerPrefix == "") exitWith {
    diag_log "[RECONDO_OBJDESTROY] ERROR: No marker prefix specified";
    []
};

// Find all markers with prefix
private _prefixLength = count _markerPrefix;
private _allMarkers = [];

{
    if ((_x select [0, _prefixLength]) == _markerPrefix) then {
        _allMarkers pushBack _x;
    };
} forEach allMapMarkers;

if (count _allMarkers == 0) exitWith {
    diag_log format ["[RECONDO_OBJDESTROY] ERROR: No markers found with prefix '%1'", _markerPrefix];
    []
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_OBJDESTROY] Found %1 markers with prefix '%2'", count _allMarkers, _markerPrefix];
};

// Calculate number to select
private _numToSelect = round ((count _allMarkers) * _spawnPercentage);
_numToSelect = _numToSelect max 1; // At least 1

// Random selection
private _selectedMarkers = [];
private _availableMarkers = +_allMarkers;

while {count _selectedMarkers < _numToSelect && count _availableMarkers > 0} do {
    private _randomMarker = selectRandom _availableMarkers;
    _availableMarkers = _availableMarkers - [_randomMarker];
    _selectedMarkers pushBack _randomMarker;
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_OBJDESTROY] Selected %1 of %2 markers (%3%): %4",
        count _selectedMarkers, count _allMarkers, round(_spawnPercentage * 100), _selectedMarkers];
};

_selectedMarkers
