/*
    Recondo_fnc_saaaPrepTick
    Per-gun state machine tick

    Description:
        States (stored on the gun, local only):
        OFF       - RECONDO_SAAA_ignore set (A/B toggle): fully vanilla
        IDLE      - nothing audible; gunner left alone
        PREPPED   - hostile aircraft audible but not engaged: gunner doWatch-es
                    the aircraft (exact sound-bearing track) + low reveal so the
                    crew is "aware" without being cleared to fire blind
        BLINDFIRE - target in the release envelope but NOT visible: sound-
                    directed probing bursts through the canopy. This tick only
                    owns the transition; the shooting lives in the blindfire
                    loop (spawned here, self-terminates on state change)
        AIMEDFIRE - target VISIBLE but the engine AI is unwilling to fire
                    (outside its fire-mode willingness envelope, e.g. loitering
                    at 1500m+): the same burst loop with a much tighter error
                    model. BLINDFIRE<->AIMEDFIRE switches are seamless
        ENGAGING  - the gun has fired recently BY ITS OWN DECISION (script-
                    forced burst shots are excluded via burstActive), the crew
                    has high target knowledge, or the engagement grace window
                    is open: release all steering so the engine fights with the
                    turret laid on. Script states hand off here only when the
                    target is inside the engine's REAL willingness range -
                    handing a 1500m target to an engine that won't fire just
                    buys silence.

        Hysteresis: ENGAGING holds until the gun has been silent for
        RECONDO_SAAA_ENGAGE_HOLD seconds AND knowsAbout has decayed to
        RECONDO_SAAA_LOST_KNOWS, so we never wrestle the engine over a target
        it is still fighting. BLINDFIRE exits at range * BF_EXIT_FACTOR.

        NOTE (in-game finding): static crews open fire with group knowsAbout
        still pinned at ~1.5 - knowsAbout alone is NOT a reliable engagement
        signal for static gunners; the Fired EH timestamp is the ground truth.

    Parameters:
        0: _gun - OBJECT - managed static weapon
        1: _airList - ARRAY - [[aircraft, audibleRange], ...]

    Returns:
        Nothing
*/

params [
    ["_gun", objNull, [objNull]],
    ["_airList", [], [[]]]
];

private _gunner = gunner _gun;
private _state = _gun getVariable ["RECONDO_SAAA_state", "IDLE"];

// A/B toggle: gun explicitly ignored -> pure vanilla behavior
if (_gun getVariable ["RECONDO_SAAA_ignore", false]) exitWith {
    if (_state != "OFF") then {
        if (!isNull _gunner && {alive _gunner} && {!isPlayer _gunner}) then { _gunner doWatch objNull };
        _gun setVariable ["RECONDO_SAAA_state", "OFF"];
        _gun setVariable ["RECONDO_SAAA_target", objNull];
        if (RECONDO_SAAA_DEBUG) then {
            systemChat format ["SAAA: %1 -> OFF (vanilla A/B)", typeOf _gun];
        };
    };
};

// No usable AI gunner -> make sure we're not steering anything
if (isNull _gunner || {!alive _gunner} || {isPlayer _gunner}) exitWith {
    if (_state != "IDLE") then {
        if (!isNull _gunner && {alive _gunner}) then { _gunner doWatch objNull };
        _gun setVariable ["RECONDO_SAAA_state", "IDLE"];
        _gun setVariable ["RECONDO_SAAA_target", objNull];
    };
};

private _side = side _gunner;

// Nearest audible hostile aircraft
private _best = objNull;
private _bestDist = 1e10;
{
    _x params ["_air", "_range"];
    private _dist = _gun distance _air;
    if (_dist <= _range && {_dist < _bestDist} && {(_side getFriend (side _air)) < 0.6}) then {
        _best = _air;
        _bestDist = _dist;
    };
} forEach _airList;

if (isNull _best) exitWith {
    if (_state != "IDLE") then {
        _gunner doWatch objNull;
        _gun setVariable ["RECONDO_SAAA_state", "IDLE"];
        _gun setVariable ["RECONDO_SAAA_target", objNull];
        if (RECONDO_SAAA_DEBUG) then {
            systemChat format ["SAAA: %1 -> IDLE (nothing audible)", typeOf _gun];
        };
    };
};

private _grp = group _gunner;
private _knows = _grp knowsAbout _best;
private _prevTarget = _gun getVariable ["RECONDO_SAAA_target", objNull];
private _sinceShot = time - (_gun getVariable ["RECONDO_SAAA_lastShot", -1e9]);

// The gun is fighting (fired recently), has solid contact, or is inside the
// engagement grace window (set on every ENGAGING entry - gives the fire control
// time to shoot before the state can fall; knowsAbout can NOT be trusted to hold it)
if (_sinceShot < RECONDO_SAAA_ENGAGE_HOLD
    || {_knows >= RECONDO_SAAA_ENGAGE_KNOWS}
    || {time < _gun getVariable ["RECONDO_SAAA_engageUntil", 0]}) exitWith {
    if (_state != "ENGAGING") then {
        _gunner doWatch objNull;
        _gun setVariable ["RECONDO_SAAA_state", "ENGAGING"];
        _gun setVariable ["RECONDO_SAAA_engageUntil", time + RECONDO_SAAA_ENGAGE_GRACE];
        if (RECONDO_SAAA_DEBUG) then {
            systemChat format ["SAAA: %1 -> ENGAGING %2 (knows %3, last shot %4s ago)",
                typeOf _gun, typeOf _best, _knows toFixed 1,
                if (_sinceShot > 1e8) then { "inf" } else { _sinceShot toFixed 0 }];
        };
    };
    _gun setVariable ["RECONDO_SAAA_target", _best];
};

// Recently engaging and knowledge still decaying -> don't fight the engine yet
if (_state == "ENGAGING" && {_knows > RECONDO_SAAA_LOST_KNOWS}) exitWith {
    _gun setVariable ["RECONDO_SAAA_target", _best];
};

private _seen = [_gun, _best] call Recondo_fnc_saaaCanSee;
_gun setVariable ["RECONDO_SAAA_dbgSeen", _seen];  // for the why-silent debug overlay

// Track how long the target has been continuously visible (aimed-fire trigger delay)
if (_seen) then {
    if (isNil {_gun getVariable "RECONDO_SAAA_seenSince"}) then {
        _gun setVariable ["RECONDO_SAAA_seenSince", time];
    };
} else {
    _gun setVariable ["RECONDO_SAAA_seenSince", nil];
};

private _willing = ([_gun] call Recondo_fnc_saaaEngineMaxRange) * RECONDO_SAAA_WILLING_FACTOR;

// Visible INSIDE the engine's real willingness range while script-firing -> hand off
// to vanilla engagement with full knowledge. Honest simulation: this crew has been
// actively firing at it - the instant it's properly in reach, they are locked on.
if (_seen && {_bestDist <= _willing} && {_state in ["BLINDFIRE", "AIMEDFIRE"]}) exitWith {
    _gunner doWatch objNull;
    _grp reveal [_best, 4];
    _gun reveal [_best, 4];   // static-weapon knowledge lives on the vehicle too
    _gun setVariable ["RECONDO_SAAA_state", "ENGAGING"];
    _gun setVariable ["RECONDO_SAAA_engageUntil", time + RECONDO_SAAA_ENGAGE_GRACE];
    _gun setVariable ["RECONDO_SAAA_target", _best];
    if (RECONDO_SAAA_DEBUG) then {
        systemChat format ["SAAA: %1 -> ENGAGING %2 (visible in engine envelope, full lock)",
            typeOf _gun, typeOf _best];
        diag_log format ["[RECONDO_SAAA] BF | %1: state -> ENGAGING (script-fire handoff, tgt visible at %2m)",
            typeOf _gun, round _bestDist];
    };
};

// AIMEDFIRE: visible, but the engine is unwilling/silent -> scripted aimed bursts.
// Courtesy delay gives the engine first refusal on a freshly visible target.
if (_seen
    && {[_gun, _best, _bestDist] call Recondo_fnc_saaaAimedReleasable}
    && {_sinceShot > RECONDO_SAAA_AIMED_DELAY}
    && {time - (_gun getVariable ["RECONDO_SAAA_seenSince", time]) >= RECONDO_SAAA_AIMED_DELAY}) exitWith {
    _gun setVariable ["RECONDO_SAAA_target", _best];
    if (_state != "AIMEDFIRE") then {
        if (_state == "BLINDFIRE") then {
            // loop serves both states - seamless switch, no respawn
            _gun setVariable ["RECONDO_SAAA_state", "AIMEDFIRE"];
            if (RECONDO_SAAA_DEBUG) then {
                systemChat format ["SAAA: %1 -> AIMEDFIRE at %2 (visible, engine out of envelope)",
                    typeOf _gun, typeOf _best];
                diag_log format ["[RECONDO_SAAA] BF | %1: state -> AIMEDFIRE (from BLINDFIRE, %2m)",
                    typeOf _gun, round _bestDist];
            };
        } else {
            private _h = _gun getVariable ["RECONDO_SAAA_bfScript", scriptNull];
            if (isNull _h || {scriptDone _h}) then {
                _gun setVariable ["RECONDO_SAAA_state", "AIMEDFIRE"];
                _gun setVariable ["RECONDO_SAAA_bfScript", [_gun] spawn Recondo_fnc_saaaBlindfireLoop];
                if (RECONDO_SAAA_DEBUG) then {
                    systemChat format ["SAAA: %1 -> AIMEDFIRE at %2 (%3m visible, engine silent)",
                        typeOf _gun, typeOf _best, round _bestDist];
                    diag_log format ["[RECONDO_SAAA] BF | %1: state -> AIMEDFIRE at %2 (%3m)",
                        typeOf _gun, typeOf _best, round _bestDist];
                };
            };
            // else: previous loop still winding down - retry next tick
        };
    };
};

// BLINDFIRE: target in envelope but unseen -> sound-directed bursts through canopy.
// State only flips once the previous loop has fully wound down (scriptDone) - combined
// with the generation guard in the loop this makes duplicate loops impossible.
if (!_seen && {[_gun, _best, _bestDist] call Recondo_fnc_saaaBfReleasable}) exitWith {
    _gun setVariable ["RECONDO_SAAA_target", _best];
    if (_state != "BLINDFIRE") then {
        if (_state == "AIMEDFIRE") then {
            // loop serves both states - seamless switch back to sound-directed error
            _gun setVariable ["RECONDO_SAAA_state", "BLINDFIRE"];
            if (RECONDO_SAAA_DEBUG) then {
                diag_log format ["[RECONDO_SAAA] BF | %1: state -> BLINDFIRE (from AIMEDFIRE, lost sight)",
                    typeOf _gun];
            };
        } else {
            private _h = _gun getVariable ["RECONDO_SAAA_bfScript", scriptNull];
            if (isNull _h || {scriptDone _h}) then {
                _gun setVariable ["RECONDO_SAAA_state", "BLINDFIRE"];
                _gun setVariable ["RECONDO_SAAA_bfScript", [_gun] spawn Recondo_fnc_saaaBlindfireLoop];
                if (RECONDO_SAAA_DEBUG) then {
                    systemChat format ["SAAA: %1 -> BLINDFIRE at %2 (%3m, unseen)",
                        typeOf _gun, typeOf _best, round _bestDist];
                    diag_log format ["[RECONDO_SAAA] BF | %1: state -> BLINDFIRE at %2 (%3m)",
                        typeOf _gun, typeOf _best, round _bestDist];
                };
            };
            // else: previous loop still winding down - retry next tick
        };
    };
};

// PREPPED: lay the gun on the sound source. doWatch is re-issued EVERY tick -
// the engine silently drops watch orders (danger FSM, reloads, post-ENGAGING
// steering), and a dropped order left the barrel pointing at a stale bearing.
_gunner doWatch _best;
if (_state != "PREPPED" || {!(_prevTarget isEqualTo _best)}) then {
    _gun setVariable ["RECONDO_SAAA_state", "PREPPED"];
    if (RECONDO_SAAA_DEBUG) then {
        systemChat format ["SAAA: %1 -> PREPPED on %2 (%3m, brg %4)",
            typeOf _gun, typeOf _best, round _bestDist, round (_gun getDir _best)];
    };
};
_gun setVariable ["RECONDO_SAAA_target", _best];
_grp reveal [_best, RECONDO_SAAA_REVEAL_VALUE];
