/*
    Recondo_fnc_trackerSignalShot
    Makes a tracker group member fire signal shots into the air

    Description:
        Thin wrapper around SOG PF's own tracker air shoot function
        (vn_ms_fnc_tracker_stalker_airShoot): the shooter aims at an
        invisible sky target and discharges up to 4 rounds with
        forceWeaponFire. Real gunfire - nearby players hear it naturally,
        no sound broadcast needed.

        The wrapper adds what SOG's FSM provides in their system:
        - Per-group cooldown and no-signaling-in-combat check
        - Leader-preferred shooter selection
        - A pause flag so the tracker behavior loop issues no move orders
          mid-sequence (their FSM waits in a dedicated state; our loop
          checks the flag - see fn_trackerBehavior). The same flag keeps
          the AI Tweaks force walk release handlers from treating the
          signal shots as combat (see fn_applyForceWalkLocal).
        - The group is raised out of SAFE for the sequence - in SAFE the
          weapon safety swallows forced fire - and restored afterwards.

        Server-side; tracker AI is local to the server.

    Parameters:
        0: GROUP - Tracker group

    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [["_group", grpNull, [grpNull]]];

if (isNull _group) exitWith {};

// SOG PF is a hard dependency of this mod, but guard anyway
if (isNil "vn_ms_fnc_tracker_stalker_airShoot") exitWith {
    diag_log "[RECONDO_TRACKERS] WARNING: vn_ms_fnc_tracker_stalker_airShoot not found - signal shot skipped";
};

private _settings = RECONDO_TRACKERS_SETTINGS;
private _debugLogging = _settings get "debugLogging";

// Per-group cooldown against double-firing from stacked triggers
if (time - (_group getVariable ["RECONDO_TRACKERS_lastSignalShot", -999]) < 30) exitWith {};

// No signaling while fighting
private _leader = leader _group;
if (isNull _leader || {!alive _leader} || {behaviour _leader == "COMBAT"} || {!isNull (_leader findNearestEnemy _leader)}) exitWith {
    if (_debugLogging) then {
        diag_log format ["[RECONDO_TRACKERS] Signal shot skipped for %1 - group in combat", _group];
    };
};

// Human shooters only - tracker dogs have no primary weapon. The group
// leader takes the shot when he can, so the signal reads as a command
private _shooters = (units _group) select { alive _x && {primaryWeapon _x != ""} };
if (_shooters isEqualTo []) exitWith {};
private _shooter = if (_leader in _shooters) then { _leader } else { selectRandom _shooters };

_group setVariable ["RECONDO_TRACKERS_lastSignalShot", time];

// Holds the behavior loop's move orders and marks the gunfire as staged
// for the force walk release handlers
_group setVariable ["RECONDO_TRACKERS_signalShotActive", true];

[_shooter, _group, _debugLogging] spawn {
    params ["_shooter", "_group", "_debugLogging"];

    // Out of SAFE for the sequence, restored afterwards
    private _groupBehaviour = behaviour leader _group;
    _group setBehaviour "AWARE";

    private _muzzle = (weaponState _shooter) select 1;

    // SOG's sequence issues 4 forceWeaponFire calls, but follow-up calls
    // landing mid recoil/re-aim cycle are dropped - each run reliably
    // produces the first round only (bob: 3/4, tracker units: 1/4).
    // Re-running the sequence until ~4 rounds are out turns that into
    // deliberate spaced single shots, which is the signal cadence we
    // want anyway. Each run takes ~3-5s; worst case fits inside the
    // behavior loop's 25s hold.
    private _totalRounds = 0;
    for "_attempt" from 1 to 4 do {
        if (_totalRounds >= 4 || {!alive _shooter}) exitWith {};

        private _before = _shooter ammo _muzzle;
        if (_before == 0) exitWith {};

        private _handle = [_shooter] call vn_ms_fnc_tracker_stalker_airShoot;

        // Cap each wait so a hung script can't park the group forever
        private _cap = diag_tickTime + 8;
        waitUntil {
            sleep 0.5;
            scriptDone _handle || {diag_tickTime > _cap}
        };

        _totalRounds = _totalRounds + (_before - (_shooter ammo _muzzle));
        sleep 0.5;
    };

    _group setBehaviour _groupBehaviour;
    _group setVariable ["RECONDO_TRACKERS_signalShotActive", false];

    if (_debugLogging) then {
        diag_log format ["[RECONDO_TRACKERS] Signal shots: %1 rounds fired by %2 (%3)",
            _totalRounds, _shooter, _group];
    };
};
