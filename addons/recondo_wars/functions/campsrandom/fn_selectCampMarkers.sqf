/*
    Recondo_fnc_selectCampMarkers
    Selects random markers for camp spawning
    
    Description:
        Finds all markers matching the prefix and randomly selects
        a percentage of them for camp placement.
        Selection is NOT persistent between mission restarts.
    
    Parameters:
        _markerPrefix - STRING - Prefix to match markers
        _spawnPercentage - NUMBER - Percentage of markers to select (0-1)
        _debugLogging - BOOL - Enable debug logging
    
    Returns:
        ARRAY - Array of selected marker names
    
    Example:
        ["CAMP_", 0.5, false] call Recondo_fnc_selectCampMarkers;
*/

params [
    ["_markerPrefix", "", [""]],
    ["_spawnPercentage", 0.5, [0]],
    ["_debugLogging", false, [false]]
];

if (_markerPrefix == "") exitWith {
    diag_log "[RECONDO_CAMPS] ERROR: selectCampMarkers - No marker prefix specified";
    []
};

// Find all markers matching the prefix
private _allMarkers = allMapMarkers select {
    (_x find _markerPrefix) == 0
};

if (count _allMarkers == 0) exitWith {
    diag_log format ["[RECONDO_CAMPS] WARNING: No markers found with prefix '%1'", _markerPrefix];
    []
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_CAMPS] Found %1 markers with prefix '%2'", count _allMarkers, _markerPrefix];
};

// Calculate how many markers to select
private _spawnCount = round ((count _allMarkers) * _spawnPercentage);
_spawnCount = _spawnCount max 1 min (count _allMarkers);

// Shuffle and select
private _shuffled = +_allMarkers;
_shuffled = _shuffled call BIS_fnc_arrayShuffle;

private _selectedMarkers = _shuffled select [0, _spawnCount];

if (_debugLogging) then {
    diag_log format ["[RECONDO_CAMPS] Selected %1 of %2 markers (%3%%)", 
        count _selectedMarkers, count _allMarkers, round (_spawnPercentage * 100)];
};

_selectedMarkers
