/*
    Recondo_fnc_survFootprintLoop
    Server-side footprint producer for the Survival Radio system

    Description:
        Creates footprints for individually-hunted transmitters so hunter
        groups can follow their trail. Independent of the Trackers module:
        footprints are per-individual (keyed by the target ID assigned at
        triangulation), always produced regardless of movement speed, and
        stored in RECONDO_SURV_FOOTPRINTS as [position, time, targetId].
        Tracking of a unit stops when it dies, disconnects, or enters a
        vehicle (no trail while mounted). Idles cheaply while nothing is
        tracked. One instance runs for the mission.

    Parameters:
        None

    Returns:
        Nothing (endless loop, spawned)
*/

if (!isServer) exitWith {};

private _footprintSpacing = 10;          // meters between footprints
private _footprintLifetime = 20 * 60;    // seconds before a footprint expires

while {true} do {
    sleep 5;

    if (isNil "RECONDO_SURV_SETTINGS") then { continue };

    // Clean expired footprints
    private _now = time;
    RECONDO_SURV_FOOTPRINTS = RECONDO_SURV_FOOTPRINTS select {
        (_now - (_x select 1)) <= _footprintLifetime
    };

    if (count RECONDO_SURV_TRACKED == 0) then { continue };

    // Produce footprints for each tracked transmitter
    private _staleIds = [];
    {
        private _targetId = _x;
        _y params ["_unit", "_lastPos"];

        // Stop tracking dead/disconnected units
        if (isNull _unit || {!alive _unit}) then {
            _staleIds pushBack _targetId;
            continue;
        };

        // No trail while in a vehicle
        if (vehicle _unit != _unit) then { continue };

        private _currentPos = getPos _unit;
        if (_lastPos distance _currentPos >= _footprintSpacing) then {
            RECONDO_SURV_FOOTPRINTS pushBack [_currentPos, time, _targetId];
            RECONDO_SURV_TRACKED set [_targetId, [_unit, _currentPos]];

            if (RECONDO_SURV_SETTINGS get "debugMarkers") then {
                private _marker = createMarker [format ["RECONDO_SURV_fp_%1_%2", _targetId, time], _currentPos];
                _marker setMarkerType "mil_dot";
                _marker setMarkerColor "ColorBlue";
                _marker setMarkerSize [0.4, 0.4];
            };
        };
    } forEach RECONDO_SURV_TRACKED;

    // Drop stale entries only when no active hunter group still hunts that ID
    {
        private _staleId = _x;
        private _stillHunted = (RECONDO_SURV_ACTIVE_GROUPS findIf {
            !isNull _x &&
            {({alive _x} count units _x) > 0} &&
            {(_x getVariable ["RECONDO_SURV_targetId", ""]) == _staleId}
        }) != -1;

        // Keep the entry while hunted so existing footprints stay relevant,
        // but null the unit reference to stop producing new ones.
        if (_stillHunted) then {
            RECONDO_SURV_TRACKED set [_staleId, [objNull, [0,0,0]]];
        } else {
            RECONDO_SURV_TRACKED deleteAt _staleId;
        };
    } forEach _staleIds;
};
