/*
    Recondo_fnc_selectHubMarkers
    Finds and selects hub markers based on prefix and percentage
    
    Description:
        Finds all markers matching the prefix pattern (e.g., HUB_1, HUB_2)
        excluding sub-site markers (e.g., HUB_1a, HUB_1b) and selects
        a percentage of them.
    
    Parameters:
        _markerPrefix - STRING - Marker prefix to search for
        _percentage - NUMBER - Percentage of markers to select (0-1)
        _debugLogging - BOOL - Enable debug logging
    
    Returns:
        ARRAY - Selected marker names
*/

params [
    ["_markerPrefix", "", [""]],
    ["_percentage", 0.5, [0]],
    ["_debugLogging", false, [false]]
];

if (_markerPrefix == "") exitWith {
    diag_log "[RECONDO_HUBSUBS] ERROR: No marker prefix specified";
    []
};

private _prefixLength = count _markerPrefix;
private _allHubMarkers = [];

// Find all markers with the prefix that are HUB markers (not sub-sites)
// Hub markers end with a number, sub-sites end with number+letter
{
    private _markerName = _x;
    if ((_markerName select [0, _prefixLength]) == _markerPrefix) then {
        // Check if this is a hub marker (ends with number) not a sub-site (ends with letter)
        private _suffix = _markerName select [_prefixLength];
        
        // A hub marker's suffix should be purely numeric
        // Sub-site markers have format like "1a", "2b", etc.
        private _isHub = true;
        
        if (count _suffix > 0) then {
            // Check last character - if it's a letter, it's a sub-site
            private _lastChar = _suffix select [count _suffix - 1, 1];
            if (_lastChar in ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]) then {
                _isHub = false;
            };
        };
        
        if (_isHub) then {
            _allHubMarkers pushBack _markerName;
        };
    };
} forEach allMapMarkers;

if (count _allHubMarkers == 0) exitWith {
    diag_log format ["[RECONDO_HUBSUBS] ERROR: No hub markers found with prefix '%1'", _markerPrefix];
    []
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_HUBSUBS] Found %1 hub markers with prefix '%2'", count _allHubMarkers, _markerPrefix];
};

// Select percentage of markers
private _numToSelect = round ((count _allHubMarkers) * _percentage);
_numToSelect = _numToSelect max 1; // At least 1

private _selectedMarkers = [];
private _availableMarkers = +_allHubMarkers;

while {count _selectedMarkers < _numToSelect && count _availableMarkers > 0} do {
    private _randomMarker = selectRandom _availableMarkers;
    _availableMarkers = _availableMarkers - [_randomMarker];
    _selectedMarkers pushBack _randomMarker;
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_HUBSUBS] Selected %1 of %2 hub markers (%3%%): %4", 
        count _selectedMarkers, count _allHubMarkers, round(_percentage * 100), _selectedMarkers];
};

_selectedMarkers
