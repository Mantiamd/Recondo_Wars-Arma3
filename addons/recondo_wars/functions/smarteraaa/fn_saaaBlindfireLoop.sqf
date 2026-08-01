/*
    Recondo_fnc_saaaBlindfireLoop
    Per-gun blind/aimed-fire burst loop (SPAWNED - scheduled, uses sleep)

    Description:
        Runs while the gun's state is BLINDFIRE or AIMEDFIRE; the prep tick
        owns the state, this loop owns the shooting.
        Cycle: solution -> doWatch aim helper -> wait for barrel alignment
        (solution refreshed every 1.5s so the aim point tracks a crossing
        target) -> burst -> pause -> new solution.

        GENERATION GUARD: multiple loops alive for one gun fight over the
        turret (dueling doWatch). Each loop claims a generation number on the
        gun; every condition checks BOTH state and generation, so a newer loop
        instantly invalidates any older one regardless of how it survived.
        AI-restore only runs if the loop still owns the current generation,
        and the pre-blindfire combat mode is stashed ON THE GUN (set once,
        cleared on restore) so an overlap can never corrupt the saved baseline.

        AI ISOLATION: gunner's own fire control stripped while script-firing
        (AUTOTARGET/TARGET off, combat mode BLUE) so the `fire` command is the
        only trigger. Restored by the generation owner on exit.

        AIM HELPER: doWatch with a raw position does not steer static turrets;
        watching an OBJECT works -> invisible helper moved onto each solution
        (visible orange sphere when debug is on), parked at 90% of the
        eye->solution ray.

        RUSHED BURSTS: if alignment times out but the barrel is within 3x
        tolerance the gun fires anyway - a rushed, slightly-off burst beats
        silence.

    Parameters:
        0: _gun - OBJECT - the gun (state must already be BLINDFIRE/AIMEDFIRE)

    Returns:
        Nothing
*/

params [
    ["_gun", objNull, [objNull]]
];

private _log = { diag_log format ["[RECONDO_SAAA] BF | %1", _this] };

private _wpn = (_gun weaponsTurret [0]) param [0, ""];
if (_wpn == "") exitWith {
    format ["%1: ABORT - no weapon on gunner turret", typeOf _gun] call _log;
};
private _gnr0 = gunner _gun;
if (isNull _gnr0) exitWith {
    format ["%1: ABORT - no gunner at loop start", typeOf _gun] call _log;
};

// --- claim the generation: any older loop on this gun is now invalid ---
private _myGen = (_gun getVariable ["RECONDO_SAAA_bfGen", 0]) + 1;
_gun setVariable ["RECONDO_SAAA_bfGen", _myGen];
// Serves BOTH script-fire states: BLINDFIRE (sound-directed) and AIMEDFIRE (visible,
// engine unwilling) - the solution's error model adapts to the current state per burst.
private _active = {
    ((_gun getVariable ["RECONDO_SAAA_state", ""]) in ["BLINDFIRE", "AIMEDFIRE"])
    && {(_gun getVariable ["RECONDO_SAAA_bfGen", 0]) == _myGen}
};

// --- isolate the gunner's own fire control ---
// Baseline combat mode is stashed on the gun exactly once, cleared on restore, so
// overlapping loops can never save BLUE-from-another-loop as the "previous" mode.
private _grp = group _gnr0;
if (isNil {_gun getVariable "RECONDO_SAAA_prevMode"}) then {
    _gun setVariable ["RECONDO_SAAA_prevMode", combatMode _grp];
};
_gnr0 disableAI "AUTOTARGET";
_gnr0 disableAI "TARGET";
_grp setCombatMode "BLUE";

private _helper = createVehicle [
    ["Sign_Sphere10cm_F", "Sign_Sphere100cm_F"] select RECONDO_SAAA_DEBUG,
    [0, 0, 0], [], 0, "CAN_COLLIDE"
];
_gun setVariable ["RECONDO_SAAA_aimHelper", _helper];

format ["%1: loop START gen %2 - wpn %3, someAmmo %4",
    typeOf _gun, _myGen, _wpn, someAmmo _gun] call _log;

while {
    (call _active)
    && {alive _gun}
    && {!isNull (gunner _gun)}
    && {alive (gunner _gun)}
} do {
    private _tgt = _gun getVariable ["RECONDO_SAAA_target", objNull];
    if (isNull _tgt || {!alive _tgt}) exitWith {
        format ["%1: gen %2 loop exit - target null/dead", typeOf _gun, _myGen] call _log;
    };
    private _gnr = gunner _gun;

    // --- fresh firing solution for this burst (lead centered on the burst window) ---
    private _rounds = RECONDO_SAAA_BURST_MIN + floor random (RECONDO_SAAA_BURST_MAX - RECONDO_SAAA_BURST_MIN + 1);
    private _aim = [_gun, _tgt, (_rounds * RECONDO_SAAA_SHOT_INTERVAL) / 2] call Recondo_fnc_saaaBfSolution;
    private _eye = eyePos _gnr;
    private _ray = _aim vectorDiff _eye;
    _helper setPosASL (_eye vectorAdd (_ray vectorMultiply 0.9));
    _gnr doWatch _helper;
    format ["%1: gen %2 solution - tgt %3 at %4m",
        typeOf _gun, _myGen, typeOf _tgt, round (_gun distance _tgt)] call _log;

    // --- wait for barrel alignment (abort on state/gen change / timeout) ---
    // The solution is refreshed every 1.5s while waiting: a fast-crossing target pulls
    // the required bearing away faster than the turret slews, so chasing a frozen
    // 6-second-old point ends in an ever-growing skip angle. Chasing the LIVE lead
    // point keeps the residual angle small enough to fire.
    private _deadline = time + RECONDO_SAAA_ALIGN_TIMEOUT;
    private _nextRefresh = time + 1.5;
    private _aligned = false;
    private _ang = 180;
    while {
        !_aligned
        && {time < _deadline}
        && {call _active}
    } do {
        sleep 0.2;
        if (time >= _nextRefresh && {alive _tgt}) then {
            _nextRefresh = time + 1.5;
            _aim = [_gun, _tgt, (_rounds * RECONDO_SAAA_SHOT_INTERVAL) / 2] call Recondo_fnc_saaaBfSolution;
            _eye = eyePos _gnr;
            _ray = _aim vectorDiff _eye;
            _helper setPosASL (_eye vectorAdd (_ray vectorMultiply 0.9));
            _gnr doWatch _helper;
        };
        private _wd = _gun weaponDirection _wpn;
        _ang = acos ((_wd vectorCos _ray) max -1 min 1);
        _aligned = _ang <= RECONDO_SAAA_ALIGN_TOL;
    };
    if (!(call _active)) exitWith {
        format ["%1: gen %2 loop exit - state/gen changed during align", typeOf _gun, _myGen] call _log;
    };

    // --- burst (aligned, or rushed if the barrel is at least close) ---
    private _rushed = !_aligned && {_ang <= RECONDO_SAAA_ALIGN_TOL * 3};
    if (_aligned || _rushed) then {
        private _cmds = 0;
        private _shots0 = _gun getVariable ["RECONDO_SAAA_scriptShots", 0];
        _gun setVariable ["RECONDO_SAAA_burstActive", true];
        for "_i" from 1 to _rounds do {
            if (!(call _active) || {!someAmmo _gun}) exitWith {};
            _gun fire _wpn;
            _cmds = _cmds + 1;
            sleep RECONDO_SAAA_SHOT_INTERVAL;
        };
        sleep 0.3;  // let the last round's Fired EH land before dropping the flag
        _gun setVariable ["RECONDO_SAAA_burstActive", false];
        private _actual = (_gun getVariable ["RECONDO_SAAA_scriptShots", 0]) - _shots0;
        private _mode = _gun getVariable ["RECONDO_SAAA_state", "BLINDFIRE"];
        format ["%1: gen %2 %3 burst%4 - %5 cmds, %6 rounds fired (EH), angle %7 deg, tgt %8m",
            typeOf _gun, _myGen, _mode, ["", " RUSHED"] select _rushed, _cmds, _actual,
            _ang toFixed 1, round (_gun distance _tgt)] call _log;
        if (RECONDO_SAAA_DEBUG) then {
            systemChat format ["SAAA: %1 %2 burst %3 rds at %4%5",
                typeOf _gun, _mode, _actual, typeOf _tgt, ["", " (rushed)"] select _rushed];
        };
    } else {
        format ["%1: gen %2 burst SKIPPED - %3 deg off after %4s",
            typeOf _gun, _myGen, round _ang, RECONDO_SAAA_ALIGN_TIMEOUT] call _log;
        if (RECONDO_SAAA_DEBUG) then {
            systemChat format ["SAAA: %1 BLINDFIRE burst SKIPPED - turret %2 deg off",
                typeOf _gun, round _ang];
        };
    };

    // --- pause between bursts, abort early on state/gen change ---
    private _pauseEnd = time + RECONDO_SAAA_PAUSE_MIN + random (RECONDO_SAAA_PAUSE_MAX - RECONDO_SAAA_PAUSE_MIN);
    while {
        time < _pauseEnd
        && {call _active}
    } do { sleep 0.5 };
};

format ["%1: gen %2 loop END - state now '%3'",
    typeOf _gun, _myGen, _gun getVariable ["RECONDO_SAAA_state", ""]] call _log;

deleteVehicle _helper;

// --- restore vanilla fire control ONLY if this loop still owns the gun ---
if ((_gun getVariable ["RECONDO_SAAA_bfGen", 0]) == _myGen) then {
    _gun setVariable ["RECONDO_SAAA_aimHelper", objNull];
    _gun setVariable ["RECONDO_SAAA_burstActive", false];
    if (!isNull _gnr0 && {alive _gnr0}) then {
        _gnr0 enableAI "AUTOTARGET";
        _gnr0 enableAI "TARGET";
    };
    private _prev = _gun getVariable ["RECONDO_SAAA_prevMode", ""];
    if (_prev != "" && {!isNull _grp}) then { _grp setCombatMode _prev };
    _gun setVariable ["RECONDO_SAAA_prevMode", nil];
};
