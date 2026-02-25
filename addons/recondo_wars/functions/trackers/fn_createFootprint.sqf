/*
    Recondo_fnc_createFootprint
    Creates a footprint for tracking
    
    Description:
        Creates an invisible footprint at the given position for the given group.
        Footprints are used by trackers to follow player movements.
    
    Parameters:
        _pos - Position of the footprint
        _group - Group that created the footprint
    
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params ["_pos", "_group"];

private _settings = RECONDO_TRACKERS_SETTINGS;
private _debugMarkers = _settings get "debugMarkers";
private _debugLogging = _settings get "debugLogging";

// Check if group is being tracked
private _groupIdStr = groupId _group;
if !(_groupIdStr in RECONDO_TRACKERS_TRACKED_GROUPS) exitWith {};

// Check if position is in no-footprint zone
if ([_pos] call Recondo_fnc_isInNoFootprintZone) exitWith {
    if (_debugLogging) then {
        diag_log format ["[RECONDO_TRACKERS] Footprint suppressed - no-footprint zone"];
    };
};

// Create footprint entry
// Format: [position, time, groupIdString, trackerGroups[]]
private _footprint = [_pos, time, _groupIdStr, []];
RECONDO_TRACKERS_FOOTPRINTS pushBack _footprint;
publicVariable "RECONDO_TRACKERS_FOOTPRINTS";

// Create debug marker if enabled
if (_debugMarkers) then {
    private _markerName = format ["RECONDO_TRACKERS_fp_%1_%2", _groupIdStr, count RECONDO_TRACKERS_FOOTPRINTS];
    private _marker = createMarker [_markerName, _pos];
    _marker setMarkerType "mil_dot";
    _marker setMarkerColor "ColorBlue";
    _marker setMarkerText format ["FP_%1", count RECONDO_TRACKERS_FOOTPRINTS];
    _marker setMarkerSize [0.5, 0.5];
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_TRACKERS] Footprint created for %1 at %2", _groupIdStr, _pos];
};
