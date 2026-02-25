/*
    Recondo_fnc_isInNoFootprintZone
    Checks if a position is in a no-footprint zone
    
    Description:
        Checks if the given position is within the radius of any no-footprint marker.
    
    Parameters:
        _pos - Position to check
    
    Returns:
        Boolean - true if in a no-footprint zone
*/

params ["_pos"];

private _settings = RECONDO_TRACKERS_SETTINGS;
private _noFootprintPrefix = _settings get "noFootprintPrefix";
private _noFootprintRadius = _settings get "noFootprintRadius";

private _result = false;

{
    private _markerName = _x;
    private _markerNameUpper = toUpper _markerName;
    
    if (_markerNameUpper find _noFootprintPrefix == 0) then {
        private _markerPos = getMarkerPos _markerName;
        if (_pos distance _markerPos <= _noFootprintRadius) exitWith {
            _result = true;
        };
    };
} forEach allMapMarkers;

_result
