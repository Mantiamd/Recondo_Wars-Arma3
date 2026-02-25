/*
    Recondo_fnc_selectHostageLocations
    Selects hostage and decoy markers from available markers
    
    Description:
        Finds all markers with the given prefix and randomly selects
        the specified number for hostage locations and decoys.
    
    Parameters:
        _markerPrefix - STRING - Prefix for markers to search
        _hostageLocationCount - NUMBER - Number of hostage locations to select
        _decoyCount - NUMBER - Number of decoy locations to select
        _debugLogging - BOOL - Enable debug logging
    
    Returns:
        ARRAY - [hostageMarkers, decoyMarkers]
*/

if (!isServer) exitWith { [[], []] };

params [
    ["_markerPrefix", "HOSTAGE_", [""]],
    ["_hostageLocationCount", 1, [0]],
    ["_decoyCount", 2, [0]],
    ["_debugLogging", false, [false]]
];

// Find all markers with prefix
private _allMarkers = allMapMarkers select { _x find _markerPrefix == 0 };

if (count _allMarkers == 0) exitWith {
    diag_log format ["[RECONDO_HOSTAGE] ERROR: No markers found with prefix '%1'", _markerPrefix];
    [[], []]
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_HOSTAGE] Found %1 markers with prefix '%2': %3", count _allMarkers, _markerPrefix, _allMarkers];
};

// Validate counts
private _totalNeeded = _hostageLocationCount + _decoyCount;
if (_totalNeeded > count _allMarkers) then {
    diag_log format ["[RECONDO_HOSTAGE] WARNING: Requested %1 locations but only %2 markers available. Adjusting...", 
        _totalNeeded, count _allMarkers];
    
    // Prioritize hostage locations over decoys
    if (_hostageLocationCount > count _allMarkers) then {
        _hostageLocationCount = count _allMarkers;
        _decoyCount = 0;
    } else {
        _decoyCount = (count _allMarkers) - _hostageLocationCount;
    };
};

// Shuffle markers for random selection
private _shuffled = _allMarkers call BIS_fnc_arrayShuffle;

// Select hostage location markers
private _hostageMarkers = _shuffled select [0, _hostageLocationCount];

// Select decoy markers from remaining
private _remainingMarkers = _shuffled select [_hostageLocationCount, count _shuffled - _hostageLocationCount];
private _decoyMarkers = _remainingMarkers select [0, _decoyCount min count _remainingMarkers];

if (_debugLogging) then {
    diag_log format ["[RECONDO_HOSTAGE] Selected hostage markers: %1", _hostageMarkers];
    diag_log format ["[RECONDO_HOSTAGE] Selected decoy markers: %1", _decoyMarkers];
};

[_hostageMarkers, _decoyMarkers]
