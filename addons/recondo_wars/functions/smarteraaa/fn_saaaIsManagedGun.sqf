/*
    Recondo_fnc_saaaIsManagedGun
    Predicate - should Smarter AAA manage this static weapon?

    Description:
        Whitelist-driven: a gun is managed only if its classname matches the
        module's REQUIRED gun whitelist (inheritance-aware, so a base class
        covers all variants). Verdict is cached per classname.

        Mission-maker per-gun overrides:
            _gun setVariable ["RECONDO_SAAA_manage", true] -> always managed
            _gun setVariable ["RECONDO_SAAA_ignore", true] -> NOT checked here:
                ignored guns stay in the managed list and are parked in the OFF
                state by the prep tick, so the A/B toggle reacts instantly.

    Parameters:
        0: _gun - OBJECT - a StaticWeapon entity

    Returns:
        BOOL - true if this gun should be managed
*/

params [
    ["_gun", objNull, [objNull]]
];

if (isNull _gun) exitWith { false };
if (_gun getVariable ["RECONDO_SAAA_manage", false]) exitWith { true };

private _type = typeOf _gun;
private _verdict = RECONDO_SAAA_CLASS_CACHE getOrDefault [_type, -1];

if (_verdict < 0) then {
    _verdict = parseNumber (RECONDO_SAAA_GUN_WHITELIST findIf { _type isKindOf _x } > -1);
    RECONDO_SAAA_CLASS_CACHE set [_type, _verdict];
};

_verdict == 1
