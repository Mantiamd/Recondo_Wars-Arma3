/*
    Recondo_fnc_findSubSiteMarkers
    Finds all sub-site markers for a given hub marker
    
    Description:
        Given a hub marker like "HUB_1", finds all sub-site markers
        with letter suffixes like "HUB_1a", "HUB_1b", "HUB_1c", etc.
    
    Parameters:
        _hubMarker - STRING - Hub marker name
    
    Returns:
        ARRAY - Sub-site marker names
*/

params [["_hubMarker", "", [""]]];

if (_hubMarker == "") exitWith {
    diag_log "[RECONDO_HUBSUBS] ERROR: No hub marker specified for sub-site search";
    []
};

private _subSiteMarkers = [];
private _letters = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"];

// Check for each letter suffix
{
    private _potentialMarker = _hubMarker + _x;
    
    // Check if marker exists (has a color set means it exists)
    if (getMarkerColor _potentialMarker != "") then {
        _subSiteMarkers pushBack _potentialMarker;
    };
} forEach _letters;

_subSiteMarkers
