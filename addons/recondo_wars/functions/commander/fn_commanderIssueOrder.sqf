/*
    Recondo_fnc_commanderIssueOrder
    Applies a commander order to a squad (server-side, authoritative)

    Description:
        Runs on the server (called via remoteExec from the officer's map menu).
        The squad is local to the server, so orders are applied directly. Validates
        that the requesting officer actually owns the squad before doing anything.

    Parameters:
        0: _officer - OBJECT - The officer issuing the order
        1: _group   - GROUP  - The target squad
        2: _order   - STRING - "MOVE" | "HALT" | "BEHAVIOUR" | "FORMATION"
        3: _data    - ANY    - MOVE: position; BEHAVIOUR/FORMATION: string; HALT: unused

    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [
    ["_officer", objNull, [objNull]],
    ["_group", grpNull, [grpNull]],
    ["_order", "", [""]],
    ["_data", nil, ["", [], 0]]
];

if (isNull _group) exitWith {};

// Authorise: only the squad's own commanding officer may order it.
private _owner = _group getVariable ["RECONDO_CMD_Officer", objNull];
if (!isNull _officer && {!(_owner isEqualTo _officer)}) exitWith {
    diag_log format ["[RECONDO_CMD] Rejected order '%1': %2 does not command that squad.", _order, name _officer];
};

switch (toUpper _order) do {
    case "MOVE": {
        if (isNil "_data") exitWith {};
        while { count (waypoints _group) > 0 } do {
            deleteWaypoint ((waypoints _group) select 0);
        };
        private _wp = _group addWaypoint [_data, 0];
        _wp setWaypointType "MOVE";
        _group setCurrentWaypoint _wp;
    };
    case "HALT": {
        // Hold at the current position via a group-level HOLD waypoint (no unit-level
        // doStop, which would leave the squad ignoring later MOVE orders).
        while { count (waypoints _group) > 0 } do {
            deleteWaypoint ((waypoints _group) select 0);
        };
        private _wp = _group addWaypoint [getPosATL (leader _group), 0];
        _wp setWaypointType "HOLD";
        _group setCurrentWaypoint _wp;
    };
    case "BEHAVIOUR": {
        if (_data isEqualType "") then { _group setBehaviour _data; };
    };
    case "FORMATION": {
        if (_data isEqualType "") then { _group setFormation _data; };
    };
    default {
        diag_log format ["[RECONDO_CMD] Unknown order type '%1'.", _order];
    };
};
