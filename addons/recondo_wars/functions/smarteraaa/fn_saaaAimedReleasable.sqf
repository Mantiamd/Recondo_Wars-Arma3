/*
    Recondo_fnc_saaaAimedReleasable
    Should this gun be firing scripted AIMED bursts at this VISIBLE target?

    Description:
        For targets the crew can see but the engine AI is unwilling to engage
        (outside its fire-mode willingness envelope - e.g. a plane loitering
        at 1500m+). Visibility and engine-silence timing are checked by the
        prep tick; this covers the rest.

    Parameters:
        0: _gun - OBJECT - managed static weapon
        1: _tgt - OBJECT - visible hostile aircraft
        2: _dist - NUMBER - current gun-to-target distance

    Returns:
        BOOL
*/

params [
    ["_gun", objNull, [objNull]],
    ["_tgt", objNull, [objNull]],
    ["_dist", 1e9, [0]]
];

if (!RECONDO_SAAA_AIMEDFIRE) exitWith { false };
if (isNull _tgt) exitWith { false };
if (_gun getVariable ["RECONDO_SAAA_noScriptFire", false]) exitWith { false };
if (_dist > RECONDO_SAAA_AIMED_RANGE) exitWith { false };
if (!([_tgt] call Recondo_fnc_saaaScriptFireAllowed)) exitWith { false };

[_gun, _tgt, _dist] call Recondo_fnc_saaaCanReach
