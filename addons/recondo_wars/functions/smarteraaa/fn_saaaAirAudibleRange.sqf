/*
    Recondo_fnc_saaaAirAudibleRange
    How far away this aircraft is audible to gun crews

    Description:
        Returns the audible range in meters, 0 = not tracked. Category
        (HELO/PROP/NONE) is cached per classname; the range itself is read
        from the module settings on every call so it can be tuned live.
        Jets (config maxSpeed above the prop ceiling) are ignored entirely -
        they arrive faster than their sound.

    Parameters:
        0: _air - OBJECT - an aircraft

    Returns:
        NUMBER - audible range in meters (0 = ignore this aircraft)
*/

params [
    ["_air", objNull, [objNull]]
];

if (isNull _air) exitWith { 0 };

private _type = typeOf _air;
private _cat = RECONDO_SAAA_AIR_CACHE getOrDefault [_type, ""];

if (_cat isEqualTo "") then {
    _cat = "NONE";
    if (!(_air isKindOf "ParachuteBase")) then {  // parachutes inherit from Helicopter
        if (_air isKindOf "Helicopter") then {
            _cat = "HELO";
        } else {
            if (_air isKindOf "Plane" &&
                {getNumber (configFile >> "CfgVehicles" >> _type >> "maxSpeed") <= RECONDO_SAAA_PROP_MAX_SPEED}) then {
                _cat = "PROP";
            };
        };
    };
    RECONDO_SAAA_AIR_CACHE set [_type, _cat];
};

switch (_cat) do {
    case "HELO": { RECONDO_SAAA_AUDIBLE_HELO };
    case "PROP": { RECONDO_SAAA_AUDIBLE_PLANE };
    default { 0 };
}
