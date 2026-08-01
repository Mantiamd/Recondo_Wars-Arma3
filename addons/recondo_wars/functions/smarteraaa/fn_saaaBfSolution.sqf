/*
    Recondo_fnc_saaaBfSolution
    Computes one blind-fire aim point (ASL)

    Description:
        Sound-tracked target position + ballistic lead (time-of-flight x target
        velocity, drag-averaged shell speed) + angular-speed-scaled error. Error
        direction is random per burst - each burst is a fresh "correction" by
        the crew.

        Accuracy model: error = (base + tangentialSpeed * perMs) * trackRamp.
        - A hovering helo gets base error only (lethal); a fast crossing helo
          gets suppression fire. "Speed is armor" - the core balance dial.
        - trackRamp: the crew walks fire onto a target the longer they
          continuously track it - x rampStart on first burst, converging to
          x rampEnd after rampTime seconds. Loitering near a blind gun is a
          death sentence; transient contacts get wild first bursts.

    Parameters:
        0: _gun - OBJECT - firing gun
        1: _tgt - OBJECT - target aircraft
        2: _extraLead - NUMBER - extra lead seconds beyond TOF (optional,
           default 0); the burst loop passes half the burst duration so the
           burst BRACKETS the target's path instead of trailing it

    Returns:
        ARRAY - aim position ASL
*/

params [
    ["_gun", objNull, [objNull]],
    ["_tgt", objNull, [objNull]],
    ["_extraLead", 0, [0]]
];

private _gp = getPosASL _gun;
private _tp = getPosASL _tgt;
private _dist = _gp vectorDistance _tp;

// Shell speed from the gun's ammo config (cached per classname)
private _spd = RECONDO_SAAA_BALL_CACHE getOrDefault [typeOf _gun, -1];
if (_spd < 0) then {
    _spd = 800;
    private _mag = ((magazinesAllTurrets _gun) param [0, []]) param [0, ""];
    if (_mag != "") then {
        private _ammo = getText (configFile >> "CfgMagazines" >> _mag >> "ammo");
        private _ts = getNumber (configFile >> "CfgAmmo" >> _ammo >> "typicalSpeed");
        if (_ts > 0) then { _spd = _ts };
    };
    RECONDO_SAAA_BALL_CACHE set [typeOf _gun, _spd];
};

// Lead: predicted position after time-of-flight (+ burst centering)
private _tof = _dist / ((_spd * RECONDO_SAAA_SPEED_FACTOR) max 100);
private _pred = _tp vectorAdd ((velocity _tgt) vectorMultiply (_tof + _extraLead));

// Angular-rate error: tangential (crossing) speed relative to the gun's line of sight
private _vel = velocity _tgt;
private _los = _tp vectorDiff _gp;
_los = _los vectorMultiply (1 / (_dist max 1));
private _radial = _los vectorMultiply (_vel vectorDotProduct _los);
private _tangSpeed = vectorMagnitude (_vel vectorDiff _radial);

// Track-time ramp: continuous tracking of the SAME target tightens the error
if ((_gun getVariable ["RECONDO_SAAA_trackTgt", objNull]) isNotEqualTo _tgt) then {
    _gun setVariable ["RECONDO_SAAA_trackTgt", _tgt];
    _gun setVariable ["RECONDO_SAAA_trackSince", time];
};
private _ramp = linearConversion [
    0, RECONDO_SAAA_BF_RAMP_TIME,
    time - (_gun getVariable ["RECONDO_SAAA_trackSince", time]),
    RECONDO_SAAA_BF_RAMP_START, RECONDO_SAAA_BF_RAMP_END, true
];

private _err = (RECONDO_SAAA_BF_BASE_ERROR + _tangSpeed * RECONDO_SAAA_BF_ERROR_PER_MS) * _ramp;

// AIMEDFIRE (visible target, engine unwilling): visual tracking, much tighter error
if ((_gun getVariable ["RECONDO_SAAA_state", ""]) == "AIMEDFIRE") then {
    _err = _err * RECONDO_SAAA_AIMED_ERR_FACTOR;
};

// Fear shaping: cap the error, and bias the scatter into the plane PERPENDICULAR
// to the line of sight - misses pass visibly AROUND the aircraft (cracks and
// tracers the pilot experiences) instead of short/long along the ray where a
// miss is invisible.
_err = _err min RECONDO_SAAA_BF_MAX_ERROR;
private _right = _los vectorCrossProduct [0, 0, 1];
if (vectorMagnitude _right < 0.01) then { _right = [1, 0, 0] };  // near-vertical LOS
_right = vectorNormalized _right;
private _up = _right vectorCrossProduct _los;

_pred vectorAdd (
    (_right vectorMultiply (_err * (random 2 - 1)))
    vectorAdd (_up vectorMultiply (_err * (random 2 - 1)))
    vectorAdd (_los vectorMultiply (_err * 0.3 * (random 2 - 1)))
)
