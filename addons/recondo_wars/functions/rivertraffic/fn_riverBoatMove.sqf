/*
    Recondo_fnc_riverBoatMove
    Server-side per-frame steering engine for river boats.

    Description:
        Drives every active river boat along its baked path. Each frame the boat
        is rotated toward its current target point (rate-limited for a smooth
        turn) and pushed forward horizontally while vertical velocity is left to
        buoyancy. Boats that reach the end of their river are retired here.
        Destroyed hulls and dead-crew boats are left in place (they drift to a
        stop); their deletion, and despawn-by-distance, are handled in the scan
        loop, not here.

        Contact reaction (SOG AI style) via a per-boat state machine:
          CRUISE      - normal path following.
          FLEE        - accelerate along the path; armed OPFOR gunners engage,
                        civilians simply run. Entered on first contact.
          BEACHING    - unarmed OPFOR boats steer to the nearest bank.
          DISEMBARKED - crew has left the boat to fight on foot; boat idles.
        Contact is flagged by Hit/FiredNear event handlers set in the spawn fn.

    Parameters (CBA PFH):
        _args   - unused
        _handle - PFH handle
*/

params ["_args", "_handle"];

if (isNil "RECONDO_RIVERTRAFFIC_BOATS") exitWith {};
if (count RECONDO_RIVERTRAFFIC_BOATS == 0) exitWith {};

// Frame delta time for rate-limited turning.
private _now = diag_tickTime;
if (isNil "RECONDO_RIVERTRAFFIC_LASTT") then { RECONDO_RIVERTRAFFIC_LASTT = _now; };
private _dt = _now - RECONDO_RIVERTRAFFIC_LASTT;
RECONDO_RIVERTRAFFIC_LASTT = _now;
if (_dt <= 0) exitWith {};
if (_dt > 0.5) then { _dt = 0.5 }; // clamp after a hitch

private _maxTurn = 70 * _dt; // degrees this frame

private _toRemove = [];

{
    private _rec = _x;
    private _boat = _rec get "boat";

    // Only drop the record if the boat object itself is gone. Destroyed hulls
    // and dead-crew boats are left in place (cleaned up later by distance
    // despawn) rather than deleted here.
    if (isNull _boat) then {
        _toRemove pushBack _rec;
        continue;
    };
    // A destroyed hull can't be steered; leave the wreck where it is.
    if (!alive _boat) then { continue };

    private _positions = _rec get "positions";
    private _count = count _positions;
    private _idx = _rec get "index";
    private _bpos = getPos _boat;
    private _state = _rec get "state";

    // Crew already disembarked to fight on foot: leave the abandoned boat idle.
    if (_state == "DISEMBARKED") then { continue };

    // --- CONTACT TRANSITION (SOG AI style reaction) ---
    if (_state == "CRUISE" && {_boat getVariable ["RECONDO_RT_CONTACT", false]}) then {
        private _grp = _rec get "group";
        if ((_rec get "sideType") == "CIV") then {
            // Captive civilians just run for it, no fighting.
            _state = "FLEE";
        } else {
            if (_rec get "armed") then {
                // Armed boat presses on and fights from the water (gunners engage).
                _grp setBehaviour "COMBAT";
                _state = "FLEE";
            } else {
                // Unarmed boat makes for the nearest bank to drop off its crew.
                // Sample starboard then port for the closest shore point.
                private _beach = [];
                private _bASL = getPosASL _boat;
                private _hdg0 = getDir _boat;
                {
                    private _sideDir = _hdg0 + _x;
                    for "_r" from 8 to 60 step 8 do {
                        private _cx = (_bASL # 0) + (sin _sideDir) * _r;
                        private _cy = (_bASL # 1) + (cos _sideDir) * _r;
                        if !(surfaceIsWater [_cx, _cy]) exitWith { _beach = [_cx, _cy, 0]; };
                    };
                    if !(_beach isEqualTo []) exitWith {};
                } forEach [90, -90];

                if (_beach isEqualTo []) then {
                    // No shore found nearby: just run for it.
                    _grp setBehaviour "COMBAT";
                    _state = "FLEE";
                } else {
                    _rec set ["beachPos", _beach];
                    _state = "BEACHING";
                };
            };
        };
        _rec set ["state", _state];
    };

    private _driver = driver _boat;
    private _driverInvalid =
        isNull _driver
        || {!alive _driver}
        || {(lifeState _driver) == "INCAPACITATED"}
        || {_driver getVariable ["ace_isUnconscious", false]};

    // Driver killed/incapacitated: cut the engine (silences the running sound)
    // and let the boat drift to a stop.
    if (_driverInvalid) then {
        if (isEngineOn _boat) then { _boat engineOn false; };
        private _v = velocity _boat;
        private _drag = 0.92;
        _boat setVelocity [(_v # 0) * _drag, (_v # 1) * _drag, _v # 2];
        if ((vectorMagnitude [_v # 0, _v # 1, 0]) < 0.35) then {
            _boat setVelocity [0, 0, _v # 2];
        };
        continue;
    };

    // --- BEACHING: steer to the bank, then disembark the crew to fight ---
    if (_state == "BEACHING") then {
        private _bp = _rec get "beachPos";

        // Rate-limited turn toward the beach point.
        private _curDirB = getDir _boat;
        private _wantDirB = _bpos getDir _bp;
        private _diffB = _wantDirB - _curDirB;
        while { _diffB > 180 } do { _diffB = _diffB - 360 };
        while { _diffB < -180 } do { _diffB = _diffB + 360 };
        if (abs _diffB > 0.5) then {
            _diffB = (_diffB max (-_maxTurn)) min _maxTurn;
            _boat setDir (_curDirB + _diffB);
        };

        // Push toward shore.
        private _spdB = (_rec get "speed") / 3.6;
        private _hdgB = getDir _boat;
        private _velB = velocity _boat;
        _boat setVelocity [(sin _hdgB) * _spdB, (cos _hdgB) * _spdB, _velB select 2];

        // Arrived / grounded / stalled: disembark and hand crew to normal AI.
        if ((_bpos distance2D _bp) < 8
            || {!surfaceIsWater (getPosASL _boat)}
            || {(speed _boat) < 1.5 && {(_bpos distance2D _bp) < 25}}
        ) then {
            private _grp = _rec get "group";
            private _units = crew _boat;
            {
                unassignVehicle _x;
                moveOut _x;
                _x enableAI "ALL";
                _x enableAI "PATH";
                _x enableAI "MOVE";
                _x setPosATL [(_bp # 0) + (random 4 - 2), (_bp # 1) + (random 4 - 2), 0];
                _x doMove _bp;
            } forEach _units;
            _grp setBehaviour "COMBAT";
            _grp setCombatMode "RED";
            _grp setSpeedMode "FULL";
            _rec set ["disembarked", _units];
            _rec set ["state", "DISEMBARKED"];
            if (isEngineOn _boat) then { _boat engineOn false; };
        };
        continue;
    };

    // --- CRUISE / FLEE: follow the river path ---
    private _target = _positions select _idx;

    // Advance to the next point (in the boat's travel direction) once close.
    if ((_bpos distance2D _target) < (_rec get "arrival")) then {
        _idx = _idx + (_rec get "dir");
        if (_idx < 0 || {_idx >= _count}) then {
            // Reached the far end of the river — retire.
            _toRemove pushBack _rec;
            continue;
        };
        _rec set ["index", _idx];
        _target = _positions select _idx;
    };

    // Rate-limited turn toward the target heading. setDir broadcasts, so skip
    // it on straight stretches where the heading error is negligible.
    private _curDir = getDir _boat;
    private _wantDir = _bpos getDir _target;
    private _diff = _wantDir - _curDir;
    while { _diff > 180 } do { _diff = _diff - 360 };
    while { _diff < -180 } do { _diff = _diff + 360 };
    if (abs _diff > 0.5) then {
        _diff = (_diff max (-_maxTurn)) min _maxTurn;
        _boat setDir (_curDir + _diff);
    };

    // Forward push; boosted while fleeing/under contact. Keep vertical velocity
    // so buoyancy/gravity still act.
    private _spd = (_rec get "speed") / 3.6; // km/h -> m/s
    if (_state == "FLEE") then { _spd = _spd * 1.4 };
    private _hdg = getDir _boat;
    private _vel = velocity _boat;
    _boat setVelocity [(sin _hdg) * _spd, (cos _hdg) * _spd, _vel select 2];

} forEach RECONDO_RIVERTRAFFIC_BOATS;

// Retire boats that reached the end of their river (plus any orphaned records).
{
    private _rec = _x;
    private _boat = _rec get "boat";
    if (!isNull _boat) then {
        { deleteVehicle _x } forEach crew _boat;
        deleteVehicle _boat;
    };
    private _g = _rec get "group";
    if (!isNull _g) then { deleteGroup _g };
    RECONDO_RIVERTRAFFIC_BOATS deleteAt (RECONDO_RIVERTRAFFIC_BOATS find _rec);
} forEach _toRemove;
