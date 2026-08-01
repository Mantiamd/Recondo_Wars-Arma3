/*
    Recondo_fnc_saaaEngineMaxRange
    The engine AI's hard fire ceiling for this gun

    Description:
        Max maxRange across the gunner-turret weapon's fire modes (cached per
        classname). Beyond this the AI will NEVER pull the trigger regardless
        of visibility (confirmed vs SOG DShK: AImode3 maxRange = 1500 with
        probab 0.1). Real willingness lives well inside it - multiply by
        RECONDO_SAAA_WILLING_FACTOR for the "engine will actually fight here"
        line.

    Parameters:
        0: _gun - OBJECT - static weapon

    Returns:
        NUMBER - meters
*/

params [
    ["_gun", objNull, [objNull]]
];

private _r = RECONDO_SAAA_RANGE_CACHE getOrDefault [typeOf _gun, -1];
if (_r < 0) then {
    _r = 0;
    private _wpn = (_gun weaponsTurret [0]) param [0, ""];
    if (_wpn != "") then {
        private _wcfg = configFile >> "CfgWeapons" >> _wpn;
        {
            private _mcfg = if (_x == "this") then { _wcfg } else { _wcfg >> _x };
            _r = _r max (getNumber (_mcfg >> "maxRange"));
        } forEach getArray (_wcfg >> "modes");
    };
    if (_r <= 0) then { _r = 1000 };  // no config data -> conservative default
    RECONDO_SAAA_RANGE_CACHE set [typeOf _gun, _r];
};
_r
