/*
    Recondo_fnc_saaaGetAudibleAir
    Builds the list of aircraft gun crews could currently hear

    Description:
        Engine must be running. Called once per main loop tick, shared by
        all managed guns.

    Parameters:
        None

    Returns:
        ARRAY - [[aircraft, audibleRange], ...]
*/

private _list = [];

{
    private _air = _x;
    if (alive _air && {isEngineOn _air}) then {
        private _range = [_air] call Recondo_fnc_saaaAirAudibleRange;
        if (_range > 0) then {
            _list pushBack [_air, _range];
        };
    };
} forEach entities [["Helicopter", "Plane"], [], false, true];

_list
