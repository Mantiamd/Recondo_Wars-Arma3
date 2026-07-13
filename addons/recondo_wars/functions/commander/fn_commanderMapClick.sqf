/*
    Recondo_fnc_commanderMapClick
    Command-map click handler (officer's client, bound to the map control)

    Description:
        Bound to the command map's onMouseButtonClick. Clicking selects the nearest
        own squad whose icon is near the click (screen-space test, Antistasi-style).
        Move orders are given by 8-digit grid entry, not by clicking the map.

    Parameters (from the control event):
        0: _map    - CONTROL - The command map control
        1: _button - NUMBER  - Mouse button (0 = left)
        2: _sx     - NUMBER  - Click screen X
        3: _sy     - NUMBER  - Click screen Y

    Returns:
        BOOL - true to consume the click
*/

params [["_map", controlNull, [controlNull]], ["_button", -1, [0]], ["_sx", 0, [0]], ["_sy", 0, [0]]];
if (isNull _map) exitWith { false };
if (_button != 0) exitWith { false };

// Select the nearest own squad by icon screen distance.
if (RECONDO_CMD_CLIENT_SQUADS isEqualTo []) exitWith { false };

private _best = grpNull;
private _bestLabel = "";
private _bestDist = 1e9;

{
    _x params ["_grp", "_label"];
    if (!isNull _grp && {({alive _x} count units _grp) > 0}) then {
        private _ldr = leader _grp;
        if (!alive _ldr) then {
            { if (alive _x) exitWith { _ldr = _x; }; } forEach (units _grp);
        };
        private _scr = _map ctrlMapWorldToScreen (getPosVisual _ldr);
        private _d = (_scr select 0) - _sx;
        private _e = (_scr select 1) - _sy;
        private _dist = sqrt ((_d * _d) + (_e * _e));
        if (_dist < _bestDist) then {
            _bestDist = _dist;
            _best = _grp;
            _bestLabel = _label;
        };
    };
} forEach RECONDO_CMD_CLIENT_SQUADS;

// Screen-space hit radius (fraction of screen).
if (isNull _best || {_bestDist > 0.05}) exitWith { true };

RECONDO_CMD_SELECTED_GROUP = _best;
private _dlg = findDisplay 58330;
if (!isNull _dlg) then {
    (_dlg displayCtrl 58332) ctrlSetText format ["Selected: %1", _bestLabel];
    (_dlg displayCtrl 58335) ctrlSetText format ["%1 selected. Choose an order.", _bestLabel];
};
true
