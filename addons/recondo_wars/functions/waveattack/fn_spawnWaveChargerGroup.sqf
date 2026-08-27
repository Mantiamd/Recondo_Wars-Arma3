/*
    Recondo_fnc_spawnWaveChargerGroup
    Spawns one CHARGER group at a bearing from the wave marker

    Description:
        Second attack tier of the Wave Attack module: same spawn geometry
        as the normal waves (out along a fixed compass bearing, pushed
        further out over water) but built from the charger classname pool
        and configured to sprint straight at the players instead of
        maneuvering:

        - CARELESS / combat mode RED / speed FULL / allowFleeing 0
        - Force walk removed 5 seconds after spawn (past the AI Tweaks
          0.1s EntityCreated apply) via Recondo_fnc_releaseForceWalk,
          which also exempts the group from the force walk sweep
          re-applying it mid-charge
        - LAMBS Danger loaded: the group is handed to lambs_wp_fnc_taskRush,
          their aggressive-attacker loop that re-acquires the closest
          player every cycle and hurls the group at them at full speed,
          firing on the move. A MOVE waypoint to the marker is set first
          as the pre-rush heading.
        - LAMBS not loaded: plain MOVE waypoint to the marker at FULL
          speed, then SAD within 100m.

        Once any living charger closes to 100m of a player, a random
        living charger screams (vn-talks-y pool, loud as the whistles) on
        a jittered ~15s cadence - always on for chargers, on top of the
        optional whistle/radio loops.

        Chargers share the whistle and radio chatter loops with the
        normal waves but are NEVER transferred to a Headless Client:
        taskRush exits on non-local groups, so the charge would die on
        transfer. They stay server-local by design.

    Parameters:
        0: HASHMAP - Module settings
        1: STRING  - Marker name (for debug labels)
        2: ARRAY   - Marker position
        3: NUMBER  - Compass bearing from the marker to spawn at (degrees)
        4: NUMBER  - Charger wave number (1-based)

    Returns:
        GROUP - The spawned group (grpNull on failure)
*/

if (!isServer) exitWith { grpNull };

params ["_settings", "_marker", "_markerPos", "_bearing", "_waveNumber"];

private _instanceId = _settings get "instanceId";
private _attackingSide = _settings get "attackingSide";
private _chargerClassnames = _settings get "chargerClassnames";
private _unitsMin = _settings get "chargerUnitsMin";
private _unitsMax = _settings get "chargerUnitsMax";
private _spawnDistance = _settings get "spawnDistance";
private _triggerRadius = _settings get "triggerRadius";
private _enableWhistles = _settings get "enableWhistles";
private _whistleSounds = _settings get "whistleSounds";
private _enableRadio = _settings getOrDefault ["enableRadio", false];
private _radioSounds = _settings getOrDefault ["radioSounds", []];
private _screamSounds = _settings getOrDefault ["screamSounds", []];
private _debugMarkers = _settings get "debugMarkers";
private _debugLogging = _settings get "debugLogging";

// Walk outward along the fixed bearing until on land; the farthest
// candidate is the force-place fallback so the direction never changes
private _spawnPos = _markerPos getPos [_spawnDistance, _bearing];
{
    private _testPos = _markerPos getPos [_spawnDistance + _x, _bearing];
    _testPos set [2, 0];
    _spawnPos = _testPos;
    if (!surfaceIsWater _testPos) exitWith {};
} forEach [0, 50, 100, 150, 200];

private _group = createGroup [_attackingSide, true];
if (isNull _group) exitWith {
    diag_log format ["[RECONDO_WAVEATK] %1: ERROR - Failed to create charger group at marker %2 bearing %3", _instanceId, _marker, _bearing];
    grpNull
};

private _groupSize = _unitsMin + floor random (_unitsMax - _unitsMin + 1);
private _unitsCreated = 0;

for "_i" from 1 to _groupSize do {
    private _class = selectRandom _chargerClassnames;
    if (isClass (configFile >> "CfgVehicles" >> _class)) then {
        private _unit = _group createUnit [_class, _spawnPos, [], 5, "NONE"];
        if (!isNull _unit) then {
            _unit setUnitPos "UP";
            _unitsCreated = _unitsCreated + 1;
        };
    } else {
        diag_log format ["[RECONDO_WAVEATK] %1: WARNING - Invalid charger classname '%2'", _instanceId, _class];
    };
    sleep 0.1;
};

if (_unitsCreated == 0) exitWith {
    deleteGroup _group;
    diag_log format ["[RECONDO_WAVEATK] %1: ERROR - Failed to create any charger units at marker %2 bearing %3", _instanceId, _marker, _bearing];
    grpNull
};

// Charge posture: heedless, full speed, no retreat
_group setBehaviour "CARELESS";
_group setCombatMode "RED";
_group setSpeedMode "FULL";
_group setFormation "LINE";
_group allowFleeing 0;
_group deleteGroupWhenEmpty true;

// Pre-rush heading; with LAMBS this is just the direction they run until
// taskRush picks its first target
private _wpMove = _group addWaypoint [_markerPos, 0];
_wpMove setWaypointType "MOVE";
_wpMove setWaypointCompletionRadius 30;

private _wpSearch = _group addWaypoint [_markerPos, 100];
_wpSearch setWaypointType "SAD";
_wpSearch setWaypointCompletionRadius 100;

// Force walk off, delayed past the AI Tweaks 0.1s EntityCreated apply.
// releaseForceWalk clears the RECONDO_FORCEWALK tag, so the sweep loop
// never re-walks a charger mid-charge
[{
    params ["_group"];
    { [_x] call Recondo_fnc_releaseForceWalk; } forEach units _group;
}, [_group], 5] call CBA_fnc_waitAndExecute;

// LAMBS Danger charging system: taskRush tracks the closest player within
// the radius and re-issues the charge every cycle. Group is server-local
// (chargers skip HC transfer), so the local-group requirement holds
if (!isNil "lambs_wp_fnc_taskRush") then {
    private _rushRadius = (_spawnDistance + _triggerRadius + 200) max 500;
    [_group, _rushRadius] spawn lambs_wp_fnc_taskRush;

    if (_debugLogging) then {
        diag_log format ["[RECONDO_WAVEATK] %1: Charger group handed to LAMBS taskRush (radius %2m)", _instanceId, _rushRadius];
    };
};

// Whistle loop, same as the normal waves
if (_enableWhistles) then {
    [_group, _whistleSounds] spawn {
        params ["_group", "_whistleSounds"];

        private _interval = (60 + (random 20) - 10) max 30;
        sleep (random _interval);

        while {!isNull _group && {(units _group findIf { alive _x }) != -1}} do {
            private _leader = leader _group;
            if (!isNull _leader && {alive _leader}) then {
                private _nearbyPlayers = allPlayers select { _x distance _leader < 350 };
                if (count _nearbyPlayers > 0) then {
                    [_leader, _whistleSounds] remoteExec ["RECONDO_WAVEATK_fnc_playSound", _nearbyPlayers];
                };
            };
            sleep _interval;
        };
    };
};

// Charge screams - the chargers' signature sound, always on. Once any
// living charger is within 100m of a player, a random living charger
// screams on a jittered ~15s cadence (timer starts expired, so the first
// close contact screams immediately). Random shooter each time so the
// screaming comes from different points of the charging line
if (_screamSounds isNotEqualTo []) then {
    [_group, _screamSounds] spawn {
        params ["_group", "_screamSounds"];

        // Random initial offset so charger groups from the same wave don't
        // all scream on the same tick when they cross the 100m gate together
        private _lastScreamTime = time - (random 30);

        while {!isNull _group && {(units _group findIf { alive _x }) != -1}} do {
            private _interval = (15 + (random 10) - 5) max 5;

            if (time - _lastScreamTime >= _interval) then {
                private _aliveUnits = (units _group) select { alive _x };
                private _inRange = _aliveUnits findIf {
                    private _unit = _x;
                    (allPlayers findIf { alive _x && {_x distance2D _unit <= 100} }) != -1
                } != -1;

                if (_inRange) then {
                    private _screamer = selectRandom _aliveUnits;
                    [_screamer, _screamSounds] remoteExec ["RECONDO_WAVEATK_fnc_playScreamSound", 0];
                    _lastScreamTime = time;
                };
            };

            sleep 2;
        };
    };
};

// Radio chatter loop, same as the normal waves
if (_enableRadio && {_radioSounds isNotEqualTo []}) then {
    [_group, _radioSounds] spawn {
        params ["_group", "_radioSounds"];

        private _interval = (60 + (random 20) - 10) max 30;
        // Random initial offset so groups spawned in the same wave don't
        // all clear the 100m gate in the same tick and chatter in unison
        private _lastRadioTime = time - (random _interval);

        while {!isNull _group && {(units _group findIf { alive _x }) != -1}} do {
            private _leader = leader _group;
            if (!isNull _leader && {alive _leader} && {time - _lastRadioTime >= _interval}
                && {allPlayers findIf { alive _x && {_x distance2D _leader <= 100} } >= 0}) then {
                [_leader, _radioSounds] remoteExec ["RECONDO_WAVEATK_fnc_playRadioSound", 0];
                _lastRadioTime = time;
            };
            sleep 3;
        };
    };
};

// NO Headless Client transfer for chargers - taskRush runs where the group
// is local and would go inert on transfer

if (_debugMarkers) then {
    private _dbg = createMarker [format ["RECONDO_WAVEATK_CHG_%1_%2_%3", _marker, _bearing, time], _spawnPos];
    _dbg setMarkerType "mil_dot";
    _dbg setMarkerColor "ColorOrange";
    _dbg setMarkerText format ["WaveAtk CHARGE W%1 B%2", _waveNumber, _bearing];
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_WAVEATK] %1: Charger wave %2 group spawned at marker %3 - %4 units, bearing %5, %6m out",
        _instanceId, _waveNumber, _marker, _unitsCreated, _bearing, _spawnDistance];
};

_group
