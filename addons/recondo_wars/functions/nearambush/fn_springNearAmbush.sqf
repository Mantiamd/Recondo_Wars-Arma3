/*
    Recondo_fnc_springNearAmbush
    Springs a waiting Near Ambush group

    Description:
        Signals, then moves the ambushers from prone/hold-fire to
        crouch/open-fire and reveals nearby BLUFOR players so the volley
        starts immediately instead of waiting on AI spotting.

        The signal depends on time of day (sunOrMoon):
        - Day:   a random whistle (same sound pool as Reinforcement Waves)
                 from the ambush line, 1 second before the line engages.
        - Night: a trip flare (module attribute, default
                 ACE_FlareTripMineRed) popped at the feet of the ambushed
                 group's leader, 3 seconds before the line engages - as if
                 he just walked into it.
        On early contact (a player hits an ambusher or lands rounds near
        the line first) the signal plays and the line engages at the same
        moment - players who already opened fire get no free seconds.

        If the group carries a designated automatic rifleman (module
        attribute Automatic Rifleman Classnames), he opens the engagement
        with 5 seconds of full auto at an invisible aim point fixed 3m
        above the head of the ambushed group's leader - grazing fire over
        the kill zone - then joins the fight with the rest of the line.

        PATH stays disabled and the stance stays locked to crouch for the
        opening minute so the volley comes from the line, then movement,
        stance, and LAMBS group AI (disabled since spawn so it cannot
        override the staged stances) are all released so survivors can
        maneuver.

        Idempotent - the monitor loop and the per-unit event handlers can
        all call this; only the first call acts. The engage sequence runs
        in a spawned thread because the event handlers call this from
        unscheduled context where sleep is not allowed.

        Ambushers are pulled out of the AI Tweaks dynamic force walk system
        so springing units are never stuck at walking pace.

        Server-only; ambush groups are server-local. The whistle is
        broadcast to clients with remoteExec (playSound3D is local-effect)
        and the trip flare is a server-side createMine + setDamage (global
        effects), so both work on a dedicated server.

    Parameters:
        0: GROUP - Ambush group to spring
        1: BOOL  - True for early contact: engage immediately with the
                   signal instead of after the signal delay (default false)

    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [["_group", grpNull, [grpNull]], ["_immediate", false, [false]]];

if (isNull _group) exitWith {};
if (_group getVariable ["RECONDO_NEARAMBUSH_sprung", false]) exitWith {};
_group setVariable ["RECONDO_NEARAMBUSH_sprung", true];

private _settings = RECONDO_NEARAMBUSH_SETTINGS;
private _debugLogging = _settings get "debugLogging";
private _markerName = _group getVariable ["RECONDO_NEARAMBUSH_marker", ""];
private _center = _group getVariable ["RECONDO_NEARAMBUSH_center", getPos (leader _group)];

private _aliveUnits = (units _group) select { alive _x };
if (_aliveUnits isEqualTo []) exitWith {};

// Site is spent - update debug markers (no sleeps here, safe in unscheduled context)
if (_settings get "debugMarkers") then {
    private _dbgName = "RECONDO_NEARAMBUSH_DBG_" + _markerName;
    _dbgName setMarkerColor "ColorRed";
    _dbgName setMarkerText "Ambush (sprung)";
    ("RECONDO_NEARAMBUSH_LINE_" + _markerName) setMarkerColor "ColorRed";
};

[_group, _aliveUnits, _center, _immediate, _markerName, _debugLogging] spawn {
    params ["_group", "_aliveUnits", "_center", "_immediate", "_markerName", "_debugLogging"];

    // ========================================
    // SIGNAL: DAY WHISTLE / NIGHT FLARE
    // ========================================

    private _signalSource = _aliveUnits select 0;
    private _isDay = sunOrMoon >= 0.5;
    private _delay = 0;

    if (_isDay) then {
        // Same whistle pool as Reinforcement Waves / Trackers. playSound3D is
        // local-effect, so broadcast. remoteExec needs the command's array
        // argument wrapped in an outer array, otherwise it reads 7 arguments
        // and rejects the call
        private _whistle = selectRandom ["enemy_whistle_2", "enemy_whistle_3", "enemy_whistle_4", "enemy_whistling_2", "enemy_whistling_3", "enemy_whistling_4"];
        private _soundPath = "\recondo_wars\sounds\trackers\" + _whistle + ".ogg";
        [[_soundPath, _signalSource, false, getPosASL _signalSource, 5, 1, 300]] remoteExec ["playSound3D", 0];
        _delay = 1;
    } else {
        // Trip flare popped right at the feet of the ambushed group's
        // leader, as if he just walked into it. setDamage 1 detonates the
        // mine and launches the flare; server-side createMine/setDamage are
        // global effects, so all clients see it
        private _tripFlareClass = RECONDO_NEARAMBUSH_SETTINGS get "tripFlareClassname";
        private _players = allPlayers select { alive _x && {side _x == west} };
        private _flarePos = _center;
        if (_players isNotEqualTo []) then {
            _players = [_players, [], { _x distance2D _center }, "ASCEND"] call BIS_fnc_sortBy;
            private _anchor = leader group (_players select 0);
            if (isNull _anchor || {!alive _anchor}) then { _anchor = _players select 0; };
            _flarePos = getPos _anchor;
        };
        private _mine = createMine [_tripFlareClass, _flarePos, [], 0];
        _mine setDamage 1;
        _delay = 3;
    };

    // Early contact engages with the signal; a planned spring gives the
    // signal a moment to register before the volley
    if (!_immediate) then { sleep _delay; };

    // ========================================
    // ENGAGE
    // ========================================

    _group setCombatMode "RED";
    _group setBehaviour "COMBAT";

    {
        if (alive _x) then {
            _x setUnitPos "MIDDLE";
            [_x] call Recondo_fnc_releaseForceWalk;
        };
    } forEach _aliveUnits;

    // Hand the group its targets - the players are within a few dozen meters
    // and the whole point of an ambush is the instant volley
    {
        _group reveal [_x, 4];
    } forEach (allPlayers select { alive _x && {side _x == west} && {_x distance2D _center < 300} });

    // ========================================
    // OVERHEAD SUPPRESSIVE FIRE
    // ========================================

    // The designated automatic rifleman (spawned only when the module's
    // Automatic Rifleman Classnames attribute is set) opens the ambush with
    // grazing fire: full auto at an invisible aim point fixed 3m above the
    // head of the ambushed group's leader, then joins the fight. Runs in its
    // own thread so it doesn't hold up the 60-second line release below.
    private _autoRifle = _group getVariable ["RECONDO_NEARAMBUSH_autoRifle", objNull];
    if (!isNull _autoRifle && {alive _autoRifle}) then {
        [_autoRifle, _center, _markerName, _debugLogging] spawn {
            params ["_shooter", "_center", "_markerName", "_debugLogging"];

            private _settings = RECONDO_NEARAMBUSH_SETTINGS;
            private _height = _settings get "suppressHeight";
            private _duration = _settings get "suppressDuration";

            // Aim above the leader of the nearest player's group; if that
            // leader is somehow gone, the nearest player himself
            private _players = allPlayers select { alive _x && {side _x == west} && {_x distance2D _center < 300} };
            if (_players isEqualTo []) exitWith {};
            _players = [_players, [], { _x distance2D _center }, "ASCEND"] call BIS_fnc_sortBy;
            private _anchor = leader group (_players select 0);
            if (isNull _anchor || {!alive _anchor}) then { _anchor = _players select 0; };

            // Fixed aim point by design - the burst cracks over where the
            // group was when the ambush sprang, it does not track anyone.
            // Empty helipad: inherently invisible, and the target type SOG's
            // own proven air-shoot sequence aims at
            private _aimPos = getPosATL _anchor;
            private _helper = createVehicle ["Land_HelipadEmpty_F", _aimPos, [], 0, "CAN_COLLIDE"];
            _helper setPosATL [_aimPos select 0, _aimPos select 1, (_aimPos select 2) + _height];

            // SOG's working recipe (fn_tracker_stalker_airshoot): FSM off so
            // the danger FSM can't yank the aim onto the revealed players,
            // AUTOTARGET off so target selection can't either. doSuppressiveFire
            // is outvoted by known close-range enemies, so force the rounds out
            _shooter disableAI "FSM";
            _shooter disableAI "AUTOTARGET";
            _shooter reveal _helper;
            _shooter doWatch _helper;
            _shooter doTarget _helper;

            if (_debugLogging) then {
                diag_log format ["[RECONDO_NEARAMBUSH] Site %1: %2 suppressing over %3 for %4s",
                    _markerName, typeOf _shooter, name _anchor, _duration];
            };

            // forceWeaponFire issued before the aim settles is silently
            // dropped, so wait for actual muzzle alignment first
            private _weapon = primaryWeapon _shooter;
            private _timeout = diag_tickTime + 2;
            waitUntil {
                sleep 0.1;
                !alive _shooter
                || {diag_tickTime > _timeout}
                || {vectorMagnitude (((eyePos _shooter) vectorFromTo (getPosASL _helper)) vectorCrossProduct (_shooter weaponDirection _weapon)) < 0.4}
            };

            // On a FullAuto-only weapon (RPD) each forced call fires a real
            // automatic burst; calls landing mid-recoil are dropped, so keep
            // re-issuing for the duration
            private _muzzle = (weaponState _shooter) select 1;
            private _modes = getArray (configFile >> "CfgWeapons" >> _weapon >> "modes");
            private _mode = "FullAuto";
            if !("FullAuto" in _modes) then {
                _mode = if (_modes isNotEqualTo [] && {(_modes select 0) != "this"}) then { _modes select 0 } else { _muzzle };
            };

            private _endTime = time + _duration;
            while {time < _endTime && {alive _shooter}} do {
                _shooter forceWeaponFire [_muzzle, _mode];
                sleep 0.4;
            };

            deleteVehicle _helper;
            if (alive _shooter) then {
                _shooter enableAI "FSM";
                _shooter enableAI "AUTOTARGET";
                _shooter doWatch objNull;
                _shooter doTarget objNull;
            };
        };
    };

    if (_debugLogging) then {
        diag_log format ["[RECONDO_NEARAMBUSH] Ambush at site %1 SPRUNG (%2 units, %3, %4)",
            _markerName, count _aliveUnits,
            ["night flare", "day whistle"] select _isDay,
            ["signaled", "early contact"] select _immediate];
    };

    // Hold the line for the opening engagement (locked to crouch), then free
    // the survivors to fight - movement, stance, and LAMBS group AI are all
    // released together so its combat behavior takes the fight from here
    sleep 60;
    _group setVariable ["lambs_danger_disableGroupAI", nil, true];
    {
        if (alive _x) then {
            _x enableAI "PATH";
            _x setUnitPos "AUTO";
            _x setVariable ["lambs_danger_disableAI", nil, true];
        };
    } forEach units _group;
};
