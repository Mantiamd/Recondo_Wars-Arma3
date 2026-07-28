/*
    Recondo_fnc_isSurvInSafeZone
    Check if a unit is in a Survival Radio safe zone

    Description:
        Checks if the unit is within the radius of any map marker whose
        name contains the configured no-count prefix. Transmissions from
        inside a safe zone are never triangulated. Default prefix matches
        RW Radio's (NO_RADIO_) so one marker can silence both systems.

    Parameters:
        0: OBJECT - Unit to check

    Returns:
        BOOL - True if in safe zone
*/

params ["_unit"];

if (isNil "RECONDO_SURV_SETTINGS") exitWith { false };

private _noCountPrefix = RECONDO_SURV_SETTINGS get "noCountPrefix";
private _noCountRadius = RECONDO_SURV_SETTINGS get "noCountRadius";

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
