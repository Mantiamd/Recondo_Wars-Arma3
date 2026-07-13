/*
    Recondo_fnc_commanderMapDrawIcons
    Draws the officer's squad icons on the command map (Draw event handler)

    Description:
        Runs each frame the command map is visible (bound to the map control's Draw
        event). Draws a side-matched infantry icon + label for every one of this
        officer's squads, highlighting the currently selected squad. Dead/empty
        squads are pruned from the client registry here so nothing is drawn for them.

    Parameters:
        0: _map - CONTROL - The command map control (passed by the Draw event)

    Returns:
        Nothing
*/

params [["_map", controlNull, [controlNull]]];
if (isNull _map) exitWith {};

// Prune squads that no longer exist.
RECONDO_CMD_CLIENT_SQUADS = RECONDO_CMD_CLIENT_SQUADS select {
    private _g = _x select 0;
    !isNull _g && {({alive _x} count units _g) > 0}
};

{
    _x params ["_grp", "_label"];

    // Resolve a living leader to anchor the icon.
    private _ldr = leader _grp;
    if (!alive _ldr) then {
        { if (alive _x) exitWith { _ldr = _x; }; } forEach (units _grp);
    };
    if (isNull _ldr) then { continue };

    private _pos = getPosVisual _ldr;
    private _icon = switch (side _grp) do {
        case west:        { "\A3\ui_f\data\map\markers\nato\b_inf.paa" };
        case east:        { "\A3\ui_f\data\map\markers\nato\o_inf.paa" };
        case independent: { "\A3\ui_f\data\map\markers\nato\n_inf.paa" };
        default           { "\A3\ui_f\data\map\markers\nato\n_unknown.paa" };
    };

    // Side colour, overridden to yellow when this squad is selected.
    private _color = switch (side _grp) do {
        case west:        { [0.2, 0.4, 1, 1] };
        case east:        { [0.85, 0.15, 0.15, 1] };
        case independent: { [0.15, 0.75, 0.15, 1] };
        default           { [0.7, 0.7, 0.7, 1] };
    };
    if (_grp isEqualTo RECONDO_CMD_SELECTED_GROUP) then { _color = [1, 1, 0.2, 1]; };

    _map drawIcon [
        _icon, _color, _pos,
        24, 24, 0, _label,
        1, 0.04, "PuristaMedium", "right"
    ];

    // Draw the current move destination (if any) with a line from the squad to it.
    private _dest = RECONDO_CMD_SQUAD_DEST getOrDefault [netId _grp, []];
    if (_dest isNotEqualTo []) then {
        if ((_ldr distance2D _dest) < 25) then {
            // Arrived: drop the marker.
            RECONDO_CMD_SQUAD_DEST deleteAt (netId _grp);
        } else {
            _map drawIcon [
                "\A3\ui_f\data\map\markers\military\destination_ca.paa",
                _color, _dest,
                24, 24, 0, "", 0, 0.04, "PuristaMedium", "right"
            ];
            _map drawLine [_pos, _dest, _color];
        };
    };
} forEach RECONDO_CMD_CLIENT_SQUADS;
