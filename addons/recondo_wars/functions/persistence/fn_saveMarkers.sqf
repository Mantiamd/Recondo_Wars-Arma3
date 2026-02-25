/*
    Recondo_fnc_saveMarkers
    Save global map markers to persistence storage
    
    Description:
        Saves all player-created global markers (non-Eden markers) to persistence.
        Eden-placed markers are excluded as they auto-appear on mission start.
        
        Player-drawn markers use the "_USER_DEFINED" naming convention.
        Any other runtime-created markers are also saved.
    
    Parameters:
        None
        
    Returns:
        NUMBER - Count of markers saved
        
    Example:
        private _count = [] call Recondo_fnc_saveMarkers;
*/

// Only run on server
if (!isServer) exitWith {
    diag_log "[RECONDO_PERSISTENCE] saveMarkers called on non-server.";
    0
};

private _settings = RECONDO_PERSISTENCE_SETTINGS;
private _debug = _settings get "enableDebug";

// Get all markers
private _allMarkers = allMapMarkers;

// Filter markers - save all global markers EXCEPT Eden-placed ones
// Eden markers have specific patterns: typically numeric IDs or specific prefixes
private _markersToSave = [];

// Track Eden marker count for exclusion
private _edenMarkerCount = getNumber (missionConfigFile >> "ScenarioData" >> "markerCount");

{
    private _markerName = _x;
    private _shouldSave = false;
    
    // Check if marker exists and has a shape (valid marker)
    if (markerShape _markerName != "") then {
        
        // Always save player-drawn markers (these start with "_USER_DEFINED")
        if (_markerName find "_USER_DEFINED" == 0) then {
            _shouldSave = true;
        } else {
            // Check if this is likely an Eden-placed marker
            // Eden markers are typically just numbers or have specific system prefixes
            private _isEdenMarker = false;
            
            // Pure numeric markers are Eden-placed
            if (_markerName regexMatch "^\d+$") then {
                _isEdenMarker = true;
            };
            
            // Markers starting with "BIS_" are system markers
            if (_markerName find "BIS_" == 0) then {
                _isEdenMarker = true;
            };
            
            // Markers in format "marker_X" where X is a number are often Eden
            if (_markerName regexMatch "^marker_\d+$") then {
                _isEdenMarker = true;
            };
            
            // If not identified as Eden marker, save it
            if (!_isEdenMarker) then {
                _shouldSave = true;
            };
        };
    };
    
    if (_shouldSave) then {
        _markersToSave pushBack _markerName;
    };
} forEach _allMarkers;

// Build marker data array
private _markersData = [];

{
    private _markerName = _x;
    
    private _markerData = createHashMapFromArray [
        ["name", _markerName],
        ["pos", getMarkerPos _markerName],
        ["type", getMarkerType _markerName],
        ["color", getMarkerColor _markerName],
        ["text", markerText _markerName],
        ["shape", markerShape _markerName],
        ["size", getMarkerSize _markerName],
        ["alpha", markerAlpha _markerName],
        ["dir", markerDir _markerName],
        ["brush", markerBrush _markerName]
    ];
    
    // For user-defined markers, also save the channel
    if (_markerName find "_USER_DEFINED" == 0) then {
        // Extract channel from marker name format: "_USER_DEFINED #id/owner/channel"
        private _parts = _markerName splitString " ";
        if (count _parts > 1) then {
            private _data = (_parts select 1) splitString "/";
            if (count _data > 2) then {
                _markerData set ["channel", parseNumber (_data select 2)];
            };
        };
    };
    
    _markersData pushBack _markerData;
} forEach _markersToSave;

// Save to persistence
["markers", _markersData] call Recondo_fnc_setSaveData;

if (_debug) then {
    diag_log format ["[RECONDO_PERSISTENCE] Saved %1 markers (excluded Eden-placed markers)", count _markersData];
};

count _markersData
