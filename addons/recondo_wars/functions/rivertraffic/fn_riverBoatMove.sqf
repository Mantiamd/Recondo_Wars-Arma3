/*
    Recondo_fnc_riverBoatMove
    Server-side per-frame steering engine for river boats.

    Description:
        Drives every active river boat along its baked path. Each frame the boat
        is rotated toward its current target point (rate-limited for a smooth
        turn) and pushed forward horizontally while vertical velocity is left to
        buoyancy. Boats that die or reach the end of their river are retired.
        Despawn-by-distance is handled in the scan loop, not here.

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

    if (isNull _boat || {!alive _boat} || {{alive _x} count (crew _boat) == 0}) then {
        _toRemove pushBack _rec;
        continue;
    };

    private _positions = _rec get "positions";
    private _count = count _positions;
    private _idx = _rec get "index";
    private _bpos = getPos _boat;
    private _target = _positions select _idx;
    private _driver = driver _boat;
    private _driverInvalid =
        isNull _driver
        || {!alive _driver}
        || {(lifeState _driver) == "INCAPACITATED"}
        || {_driver getVariable ["ace_isUnconscious", false]};

    // Driver killed/incapacitated: stop pushing the boat and let it drift down.
    if (_driverInvalid) then {
        private _v = velocity _boat;
        private _drag = 0.92;
        _boat setVelocity [(_v # 0) * _drag, (_v # 1) * _drag, _v # 2];
        if ((vectorMagnitude [_v # 0, _v # 1, 0]) < 0.35) then {
            _boat setVelocity [0, 0, _v # 2];
        };
        continue;
    };

    // Advance to the next point once close enough.
    if ((_bpos distance2D _target) < (_rec get "arrival")) then {
        _idx = _idx + 1;
        if (_idx >= _count) then {
            // Reached the end of the river — retire.
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

    // Civilian flee speed-up.
    if ((_rec get "sideType") == "CIV" && {_boat getVariable ["RECONDO_RT_FLEE", false]} && {!(_rec get "fleeing")}) then {
        _rec set ["fleeing", true];
        (_rec get "group") setBehaviour "COMBAT";
    };

    // Forward push; keep vertical velocity so buoyancy/gravity still act.
    private _spd = (_rec get "speed") / 3.6; // km/h -> m/s
    if (_rec get "fleeing") then { _spd = _spd * 1.4 };
    private _hdg = getDir _boat;
    private _vel = velocity _boat;
    _boat setVelocity [(sin _hdg) * _spd, (cos _hdg) * _spd, _vel select 2];

} forEach RECONDO_RIVERTRAFFIC_BOATS;

// Retire finished/dead boats.
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
