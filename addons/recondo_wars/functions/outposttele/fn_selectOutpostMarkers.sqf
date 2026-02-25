/*
    Recondo_fnc_selectOutpostMarkers
    Selects outpost markers based on prefix and count
    
    Description:
        Finds all markers with the given prefix and randomly
        selects a specified number of them for outpost placement.
    
    Parameters:
        _markerPrefix - STRING - Prefix to search for (e.g., "Outpost_")
        _randomCount - NUMBER - Number of markers to select
        _debugLogging - BOOL - Enable debug logging
    
    Returns:
        ARRAY - Array of selected marker names
    
    Example:
        ["Outpost_", 3, false] call Recondo_fnc_selectOutpostMarkers;
*/

params [
    ["_markerPrefix", "", [""]],
    ["_randomCount", 3, [0]],
    ["_debugLogging", false, [false]]
];

if (_markerPrefix == "") exitWith {
    diag_log "[RECONDO_OUTPOSTTELE] ERROR: No marker prefix specified";
    []
};

// Find all markers with prefix
private _prefixLength = count _markerPrefix;
private _allMarkers = [];

{
    if ((_x select [0, _prefixLength]) == _markerPrefix) then {
        // Verify marker has valid position
        private _markerPos = getMarkerPos _x;
        if !(_markerPos isEqualTo [0,0,0]) then {
            _allMarkers pushBack _x;
        };
    };
} forEach allMapMarkers;

if (count _allMarkers == 0) exitWith {
    diag_log format ["[RECONDO_OUTPOSTTELE] ERROR: No markers found with prefix '%1'", _markerPrefix];
    []
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_OUTPOSTTELE] Found %1 markers with prefix '%2'", count _allMarkers, _markerPrefix];
};

// Calculate number to select (cap at available markers)
private _numToSelect = _randomCount min (count _allMarkers);
_numToSelect = _numToSelect max 1;  // At least 1

// Random selection
private _selectedMarkers = [];
private _availableMarkers = +_allMarkers;

while {count _selectedMarkers < _numToSelect && count _availableMarkers > 0} do {
    private _randomMarker = selectRandom _availableMarkers;
    _availableMarkers = _availableMarkers - [_randomMarker];
    _selectedMarkers pushBack _randomMarker;
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_OUTPOSTTELE] Selected %1 of %2 markers: %3",
        count _selectedMarkers, count _allMarkers, _selectedMarkers];
};

_selectedMarkers
