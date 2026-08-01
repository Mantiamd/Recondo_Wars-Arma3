/*
    Recondo_fnc_saaaCanReach
    Physical feasibility - can this gun put rounds on this target at all?

    Description:
        Ammo present + turret elevation limits reachable (cached per classname).
        Shared by the blind fire and aimed script fire release checks.

    Parameters:
        0: _gun - OBJECT - static weapon
        1: _tgt - OBJECT - target aircraft
        2: _dist - NUMBER - gun-to-target distance

    Returns:
        BOOL
*/

params [
    ["_gun", objNull, [objNull]],
    ["_tgt", objNull, [objNull]],
    ["_dist", 1e9, [0]]
];

if (!someAmmo _gun) exitWith { false };

private _lims = RECONDO_SAAA_ELEV_CACHE getOrDefault [typeOf _gun, []];
if (_lims isEqualTo []) then {
    private _t0 = (configFile >> "CfgVehicles" >> typeOf _gun >> "Turrets") select 0;
    private _minE = getNumber (_t0 >> "minElev");
    private _maxE = getNumber (_t0 >> "maxElev");
    if (_maxE == 0) then { _minE = -20; _maxE = 40 };  // missing config -> sane default
    _lims = [_minE, _maxE];
    RECONDO_SAAA_ELEV_CACHE set [typeOf _gun, _lims];
};
_lims params ["_minE", "_maxE"];

private _dz = ((getPosASL _tgt) select 2) - ((getPosASL _gun) select 2);
private _elevNeeded = asin ((_dz / (_dist max 1)) max -1 min 1);
(_elevNeeded <= _maxE - 2) && {_elevNeeded >= _minE + 2}
