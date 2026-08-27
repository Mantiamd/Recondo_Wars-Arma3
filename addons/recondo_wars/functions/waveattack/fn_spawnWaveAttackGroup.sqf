/*
    Recondo_fnc_spawnWaveAttackGroup
    Spawns one attacking group at a bearing from the wave marker

    Description:
        Creates a group of random size (min-max) from the classname pool
        at the configured distance out along a fixed compass bearing from
        the marker. The bearing sells the attack direction, so if the spot
        is in water it is only pushed further out along the same bearing.
        The group moves to the marker, then searches within 100m of it.
        Every group runs a jittered 60-second whistle loop while alive
        so players hear the attacking waves closing in. Server-only.

    Parameters:
        0: HASHMAP - Module settings
        1: STRING  - Marker name (for debug labels)
        2: ARRAY   - Marker position
        3: NUMBER  - Compass bearing from the marker to spawn at (degrees)
        4: NUMBER  - Wave number (1-based)

    Returns:
        GROUP - The spawned group (grpNull on failure)
*/

if (!isServer) exitWith { grpNull };

params ["_settings", "_marker", "_markerPos", "_bearing", "_waveNumber"];

private _instanceId = _settings get "instanceId";
private _attackingSide = _settings get "attackingSide";
private _unitClassnames = _settings get "unitClassnames";
private _unitsMin = _settings get "unitsMin";
private _unitsMax = _settings get "unitsMax";
private _spawnDistance = _settings get "spawnDistance";
private _enableWhistles = _settings get "enableWhistles";
private _whistleSounds = _settings get "whistleSounds";
private _enableRadio = _settings getOrDefault ["enableRadio", false];
private _radioSounds = _settings getOrDefault ["radioSounds", []];
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
    diag_log format ["[RECONDO_WAVEATK] %1: ERROR - Failed to create group at marker %2 bearing %3", _instanceId, _marker, _bearing];
    grpNull
};

private _groupSize = _unitsMin + floor random (_unitsMax - _unitsMin + 1);
private _unitsCreated = 0;

for "_i" from 1 to _groupSize do {
    private _class = selectRandom _unitClassnames;
    if (isClass (configFile >> "CfgVehicles" >> _class)) then {
        private _unit = _group createUnit [_class, _spawnPos, [], 5, "NONE"];
        if (!isNull _unit) then {
            _unit setUnitPos "AUTO";
            _unitsCreated = _unitsCreated + 1;
        };
    } else {
        diag_log format ["[RECONDO_WAVEATK] %1: WARNING - Invalid classname '%2'", _instanceId, _class];
    };
    sleep 0.1;
};

if (_unitsCreated == 0) exitWith {
    deleteGroup _group;
    diag_log format ["[RECONDO_WAVEATK] %1: ERROR - Failed to create any units at marker %2 bearing %3", _instanceId, _marker, _bearing];
    grpNull
};

_group setBehaviour "AWARE";
_group setCombatMode "RED";
_group setSpeedMode "NORMAL";
_group setFormation "WEDGE";
_group deleteGroupWhenEmpty true;

// Move to the marker, then search within 100m of it
private _wpMove = _group addWaypoint [_markerPos, 0];
_wpMove setWaypointType "MOVE";
_wpMove setWaypointCompletionRadius 30;

private _wpSearch = _group addWaypoint [_markerPos, 100];
_wpSearch setWaypointType "SAD";
_wpSearch setWaypointCompletionRadius 100;

// Whistle loop (all waves): jittered interval and random start offset so
// multiple groups never whistle in unison
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

// Radio chatter loop (all waves), independent of the whistles: quiet chatter
// only while the group is within 100m of a player. The timer starts expired,
// so the first close contact chatters immediately, then it settles into a
// jittered ~60s cadence like the whistles
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

// Hand the group to a Headless Client if one is connected. The attack is
// waypoint-driven and the whistle and radio loops only read positions, so all
// keep working across locality.
if (_settings getOrDefault ["enableHC", false]) then {
    [_group, _debugLogging] call Recondo_fnc_transferGroupToHC;
};

if (_debugMarkers) then {
    private _dbg = createMarker [format ["RECONDO_WAVEATK_GRP_%1_%2_%3", _marker, _bearing, time], _spawnPos];
    _dbg setMarkerType "mil_dot";
    _dbg setMarkerColor "ColorRed";
    _dbg setMarkerText format ["WaveAtk W%1 B%2", _waveNumber, _bearing];
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_WAVEATK] %1: Wave %2 group spawned at marker %3 - %4 units, bearing %5, %6m out",
        _instanceId, _waveNumber, _marker, _unitsCreated, _bearing, _spawnDistance];
};

_group
