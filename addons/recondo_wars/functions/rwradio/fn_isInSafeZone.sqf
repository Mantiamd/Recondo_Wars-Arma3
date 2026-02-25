/*
    Recondo_fnc_isInSafeZone
    Check if a unit is in a radio safe zone
    
    Description:
        Checks if the unit is within the radius of any NO_RADIO marker.
        Units in safe zones don't have transmissions counted for triangulation
        or enemy spawn.
    
    Parameters:
        0: OBJECT - Unit to check
        
    Returns:
        BOOL - True if in safe zone
*/

params ["_unit"];

if (isNil "RECONDO_RWR_SETTINGS") exitWith { false };

private _noCountPrefix = RECONDO_RWR_SETTINGS get "noCountPrefix";
private _noCountRadius = RECONDO_RWR_SETTINGS get "noCountRadius";

if (_noCountPrefix == "") exitWith { false };

private _unitPos = getPos _unit;
private _isInSafeZone = false;

{
    if (toUpper _x find toUpper _noCountPrefix >= 0) then {
        private _markerPos = getMarkerPos _x;
        if (_unitPos distance _markerPos <= _noCountRadius) exitWith {
            _isInSafeZone = true;
        };
    };
} forEach allMapMarkers;

_isInSafeZone
