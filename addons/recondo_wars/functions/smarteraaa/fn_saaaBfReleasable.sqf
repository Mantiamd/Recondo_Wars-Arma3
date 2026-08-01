/*
    Recondo_fnc_saaaBfReleasable
    Should this gun be blind-firing at this UNSEEN target right now?

    Description:
        Conditions: master setting on, gun not opted out, target inside the
        blind-fire envelope (with exit hysteresis so the state doesn't flap
        at the boundary), and physically reachable (ammo + turret elevation).
        NOTE: visibility is NOT checked here - the prep tick owns the
        seen/unseen split.

    Parameters:
        0: _gun - OBJECT - managed static weapon
        1: _tgt - OBJECT - audible hostile aircraft
        2: _dist - NUMBER - current gun-to-target distance

    Returns:
        BOOL
*/

params [
    ["_gun", objNull, [objNull]],
    ["_tgt", objNull, [objNull]],
    ["_dist", 1e9, [0]]
];

if (!RECONDO_SAAA_BLINDFIRE) exitWith { false };
if (isNull _tgt) exitWith { false };
if (_gun getVariable ["RECONDO_SAAA_noBlindfire", false]) exitWith { false };
if (_gun getVariable ["RECONDO_SAAA_noScriptFire", false]) exitWith { false };
if (!([_tgt] call Recondo_fnc_saaaScriptFireAllowed)) exitWith { false };

// Range envelope with exit hysteresis
private _rng = RECONDO_SAAA_BLINDFIRE_RANGE;
if ((_gun getVariable ["RECONDO_SAAA_state", ""]) in ["BLINDFIRE", "AIMEDFIRE"]) then {
    _rng = _rng * RECONDO_SAAA_BF_EXIT_FACTOR;
};
if (_dist > _rng) exitWith { false };

[_gun, _tgt, _dist] call Recondo_fnc_saaaCanReach
