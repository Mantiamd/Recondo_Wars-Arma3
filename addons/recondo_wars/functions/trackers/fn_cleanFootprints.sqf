/*
    Recondo_fnc_cleanFootprints
    Cleans up expired footprints
    
    Description:
        Removes footprints that have exceeded their lifetime.
    
    Parameters:
        None
    
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

private _settings = RECONDO_TRACKERS_SETTINGS;
private _footprintLifetime = _settings get "footprintLifetime";
private _debugMarkers = _settings get "debugMarkers";

private _currentTime = time;
private _originalCount = count RECONDO_TRACKERS_FOOTPRINTS;

// Filter out expired footprints
RECONDO_TRACKERS_FOOTPRINTS = RECONDO_TRACKERS_FOOTPRINTS select {
    private _footprintTime = _x select 1;
    (_currentTime - _footprintTime) <= _footprintLifetime
};

// If any were removed, sync
if (count RECONDO_TRACKERS_FOOTPRINTS != _originalCount) then {
    publicVariable "RECONDO_TRACKERS_FOOTPRINTS";
    
    // Clean up debug markers if enabled
    if (_debugMarkers) then {
        {
            private _markerName = _x;
            if (_markerName find "RECONDO_TRACKERS_fp_" == 0) then {
                // Check if this marker's footprint still exists
                // (Simple approach: delete all debug markers, they'll be recreated)
            };
        } forEach allMapMarkers;
    };
};
