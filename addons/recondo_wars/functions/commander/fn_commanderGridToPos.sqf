/*
    Recondo_fnc_commanderGridToPos
    Converts an 8-figure grid reference to a world position

    Description:
        Arma has a built-in for position -> grid (mapGridPosition) but none for the
        reverse, so this does it manually. An 8-figure grid is 4 easting + 4 northing
        digits at 10 m precision, interpreted against the standard metric map grid
        (origin at [0,0], 1 m scale). The northing axis direction is auto-detected
        from the engine's own grid convention (some maps count northing from the
        north edge), so the result matches what the player reads off the in-game map.

    Parameters:
        0: _gridStr - STRING - Exactly 8 digits, e.g. "12345678" (already cleaned)

    Returns:
        ARRAY - [x, y, 0] world position, or [] if the input is not 8 digits
*/

params [["_gridStr", "", [""]]];

if (count _gridStr != 8) exitWith { [] };

private _easting  = parseNumber (_gridStr select [0, 4]);
private _northing = parseNumber (_gridStr select [4, 4]);

private _x = _easting * 10;
private _y = _northing * 10;
private _ws = worldSize;

// Detect the northing direction from the engine's grid at two known world points.
private _pA = [_ws * 0.25, _ws * 0.25, 0];
private _pB = [_ws * 0.25, _ws * 0.75, 0];
private _gA = mapGridPosition _pA;
private _gB = mapGridPosition _pB;

if (count _gA >= 2 && {count _gA == count _gB} && {((count _gA) mod 2) == 0}) then {
    private _half = (count _gA) / 2;
    private _nA = parseNumber (_gA select [_half, _half]);
    private _nB = parseNumber (_gB select [_half, _half]);
    // Northing value drops as world Y rises => grid is measured from the north edge.
    if (_nB < _nA) then { _y = _ws - _y; };
};

diag_log format ["[RECONDO_CMD] Grid '%1' -> %2 (worldSize %3)", _gridStr, [_x, _y, 0], _ws];

[_x, _y, 0]
