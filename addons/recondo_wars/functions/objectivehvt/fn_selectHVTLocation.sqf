/*
    Recondo_fnc_selectHVTLocation
    Randomly selects HVT and decoy locations from available markers
    
    Description:
        Finds all markers matching the prefix, shuffles them,
        selects one as the HVT location and the rest as decoys.
    
    Parameters:
        _markerPrefix - STRING - Marker prefix to search for
        _decoyCount - NUMBER - Maximum number of decoys to select
        _debugLogging - BOOL - Enable debug logging
    
    Returns:
        ARRAY - [hvtMarker, decoyMarkersArray]
*/

params [
    ["_markerPrefix", "", [""]],
    ["_decoyCount", 3, [0]],
    ["_debugLogging", false, [false]]
];

if (_markerPrefix == "") exitWith {
    diag_log "[RECONDO_HVT] ERROR: Empty marker prefix provided to selectHVTLocation";
    ["", []]
};

// Find all markers with the prefix
private _allMarkers = [];
private _markerIndex = 1;

while {true} do {
    private _markerName = format ["%1%2", _markerPrefix, _markerIndex];
    
    if (getMarkerColor _markerName == "") exitWith {
        if (_debugLogging) then {
            diag_log format ["[RECONDO_HVT] Found %1 markers with prefix '%2'", _markerIndex - 1, _markerPrefix];
        };
    };
    
    _allMarkers pushBack _markerName;
    _markerIndex = _markerIndex + 1;
};

// Validate we have at least one marker
if (count _allMarkers == 0) exitWith {
    diag_log format ["[RECONDO_HVT] ERROR: No markers found with prefix '%1'", _markerPrefix];
    ["", []]
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_HVT] Available markers: %1", _allMarkers];
};

// Shuffle markers for random selection
_allMarkers = _allMarkers call BIS_fnc_arrayShuffle;

// Select HVT location (first marker after shuffle)
private _hvtMarker = _allMarkers select 0;

// Remove HVT from available markers
private _remainingMarkers = _allMarkers - [_hvtMarker];

// Select decoy locations
private _decoyMarkers = [];
private _actualDecoyCount = _decoyCount min (count _remainingMarkers);

for "_i" from 0 to (_actualDecoyCount - 1) do {
    _decoyMarkers pushBack (_remainingMarkers select _i);
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_HVT] Selected HVT: %1", _hvtMarker];
    diag_log format ["[RECONDO_HVT] Selected %1 decoys: %2", count _decoyMarkers, _decoyMarkers];
};

// Return [hvtMarker, decoyMarkers]
[_hvtMarker, _decoyMarkers]
