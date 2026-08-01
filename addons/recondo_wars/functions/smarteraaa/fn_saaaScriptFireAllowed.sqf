/*
    Recondo_fnc_saaaScriptFireAllowed
    May script fire (blind fire / aimed fire) target this aircraft?

    Description:
        Filters by aircraft category and explicit class blacklist. AUDIO PREP
        is never filtered - guns still hear and track everything; only the
        scripted trigger is withheld. Vanilla ENGAGING is also unaffected.
        Use case: guns hammer helicopters but leave the high-orbiting FAC
        plane alone.

    Parameters:
        0: _tgt - OBJECT - candidate aircraft

    Returns:
        BOOL
*/

params [
    ["_tgt", objNull, [objNull]]
];

if (isNull _tgt) exitWith { false };
private _type = typeOf _tgt;

// Explicit blacklist first - entries match exact class OR any descendant
if (RECONDO_SAAA_FIRE_BLACKLIST findIf { _type isKindOf _x } > -1) exitWith { false };

// Category toggles (category cache shared with the hearing model)
private _cat = RECONDO_SAAA_AIR_CACHE getOrDefault [_type, ""];
if (_cat isEqualTo "") then {
    [_tgt] call Recondo_fnc_saaaAirAudibleRange;  // fills the cache
    _cat = RECONDO_SAAA_AIR_CACHE getOrDefault [_type, "NONE"];
};

switch (_cat) do {
    case "HELO": { RECONDO_SAAA_FIRE_HELOS };
    case "PROP": { RECONDO_SAAA_FIRE_PLANES };
    default      { false };
}
