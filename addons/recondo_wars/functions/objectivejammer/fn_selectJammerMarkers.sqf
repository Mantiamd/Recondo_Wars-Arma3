/*
    Recondo_fnc_selectJammerMarkers
    Selects markers for jammer placement based on prefix
    
    Description:
        Finds all markers with the given prefix and randomly selects
        a specified number of them for jammer spawning.
    
    Parameters:
        _markerPrefix - STRING - Prefix for markers (e.g., "JAMMER_")
        _locationCount - NUMBER - Number of locations to select
        _debugLogging - BOOL - Enable debug logging
    
    Returns:
        ARRAY - Array of selected marker names
*/

if (!isServer) exitWith { [] };

params [
    ["_markerPrefix", "JAMMER_", [""]],
    ["_locationCount", 1, [0]],
    ["_debugLogging", false, [false]]
];

// Find all markers with prefix
private _allMarkers = allMapMarkers select { _x find _markerPrefix == 0 };

if (count _allMarkers == 0) exitWith {
    diag_log format ["[RECONDO_JAMMER] WARNING: No markers found with prefix '%1'", _markerPrefix];
    []
};

// Ensure we don't try to select more markers than exist
private _selectCount = _locationCount min (count _allMarkers);

if (_selectCount < _locationCount) then {
    diag_log format ["[RECONDO_JAMMER] WARNING: Requested %1 locations but only %2 markers available with prefix '%3'", 
        _locationCount, count _allMarkers, _markerPrefix];
};

// Randomly select markers
private _shuffled = _allMarkers call BIS_fnc_arrayShuffle;
private _selected = _shuffled select [0, _selectCount];

if (_debugLogging) then {
    diag_log format ["[RECONDO_JAMMER] Selected %1 of %2 markers with prefix '%3'", count _selected, count _allMarkers, _markerPrefix];
    diag_log format ["[RECONDO_JAMMER] Selected markers: %1", _selected];
};

_selected
