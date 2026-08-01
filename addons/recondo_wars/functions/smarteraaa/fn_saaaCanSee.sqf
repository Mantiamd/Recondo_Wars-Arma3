/*
    Recondo_fnc_saaaCanSee
    Can this gun's crew physically see the target?

    Description:
        checkVisibility against the VIEW geometry LOD - the same geometry AI
        vision uses - so canopy blocks it exactly like it blocks the AI.
        Three sample rays (center, +3m, -3m) so a partially exposed aircraft
        in a canopy gap still counts as seen; a single center ray kept guns
        blind-firing at targets a vanilla gunner would engage.
        Gun and target are excluded from the rays.

    Parameters:
        0: _gun - OBJECT - static weapon
        1: _tgt - OBJECT - aircraft

    Returns:
        BOOL - true if best-ray visibility >= RECONDO_SAAA_VIS_THRESHOLD
*/

params [
    ["_gun", objNull, [objNull]],
    ["_tgt", objNull, [objNull]]
];

private _gnr = gunner _gun;
if (isNull _gnr || {isNull _tgt}) exitWith { false };

private _from = eyePos _gnr;
private _to = aimPos _tgt;

private _vis = [_gun, "VIEW", _tgt] checkVisibility [_from, _to];
if (_vis < RECONDO_SAAA_VIS_THRESHOLD) then {
    _vis = _vis max ([_gun, "VIEW", _tgt] checkVisibility [_from, _to vectorAdd [0, 0, 3]]);
};
if (_vis < RECONDO_SAAA_VIS_THRESHOLD) then {
    _vis = _vis max ([_gun, "VIEW", _tgt] checkVisibility [_from, _to vectorAdd [0, 0, -3]]);
};

_vis >= RECONDO_SAAA_VIS_THRESHOLD
