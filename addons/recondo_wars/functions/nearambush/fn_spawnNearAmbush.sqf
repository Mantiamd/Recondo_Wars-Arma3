/*
    Recondo_fnc_spawnNearAmbush
    Spawns an OPFOR ambush line against a BLUFOR player group

    Description:
        Called by the module watch loop when a BLUFOR player on foot enters
        an armed ambush site. Picks one of two spawn geometries at random,
        based on the triggering player's direction of travel:

        FRONT    - Line across the path, 50m ahead of the player, facing
                   back down the path. Springs when a player closes to 25m.
        PARALLEL - Line alongside the path, 35m off to a random side and
                   centered 50m ahead. Springs when the players walk abreast
                   of the line center (perpendicular crossing).

        The group spawns at the module's staging marker (a mission-maker
        placed marker in a far corner of the map), goes prone there while
        nobody can see it, and 2 seconds later teleports into the ambush
        line already flat - players never see the stand-to-prone
        transition. setPos preserves the animation state.

        When Automatic Rifleman Classnames is set on the module, one random
        slot in the line is guaranteed to be one of those classnames; on
        spring he fires the overhead suppression (see fn_springNearAmbush).

        The line holds fire (combat mode GREEN) with PATH disabled so
        nobody wanders out of position. Early contact - an ambusher taking
        a hit, or gunfire from a non-OPFOR shooter landing near the line -
        springs the ambush immediately, as does any player closing to 15m
        of an ambusher. Contact handlers and the spring monitor only arm
        after the teleport, so nothing can spring while the squad is still
        staged.

        If the players leave the area before the ambush springs, the group
        is deleted and the site re-armed. Sprung or wiped sites are spent.

        Server-only; called on the server where the watch loop runs.
        No line-of-sight checks on the spawn positions by design.

    Parameters:
        0: STRING - Ambush site marker name
        1: ARRAY  - Ambush site marker position
        2: OBJECT - Triggering BLUFOR player

    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [["_markerName", "", [""]], ["_markerPos", [0,0,0], [[]]], ["_targetPlayer", objNull, [objNull]]];

if (isNull _targetPlayer) exitWith {};

private _settings = RECONDO_NEARAMBUSH_SETTINGS;
private _unitClassnames = _settings get "unitClassnames";
private _autoRifleClassnames = _settings get "autoRifleClassnames";
private _minGroupSize = _settings get "minGroupSize";
private _maxGroupSize = _settings get "maxGroupSize";
private _unitSpacing = _settings get "unitSpacing";
private _debugMarkers = _settings get "debugMarkers";
private _debugLogging = _settings get "debugLogging";

// ========================================
// GEOMETRY
// ========================================

// Direction of travel from velocity; falls back to facing when standing still
private _vel = velocity _targetPlayer;
private _travelDir = if (sqrt ((_vel select 0)^2 + (_vel select 1)^2) > 0.5) then {
    (_vel select 0) atan2 (_vel select 1)
} else {
    getDir _targetPlayer
};

private _playerPos = getPos _targetPlayer;
private _mode = selectRandom ["FRONT", "PARALLEL"];

private _center = [];
private _lineDir = 0;   // Axis the line is laid along
private _faceDir = 0;   // Direction the ambushers face

if (_mode == "FRONT") then {
    _center = _playerPos getPos [_settings get "frontDistance", _travelDir];
    _lineDir = _travelDir + 90;
    _faceDir = _travelDir + 180;
} else {
    private _side = selectRandom [90, -90];
    _center = (_playerPos getPos [_settings get "parallelAhead", _travelDir]) getPos [_settings get "parallelOffset", _travelDir + _side];
    _lineDir = _travelDir;
    _faceDir = _travelDir - _side;
};

// ========================================
// SPAWN GROUP AT STAGING MARKER
// ========================================

private _stagingPos = _settings get "stagingPos";
private _groupSize = _minGroupSize + floor random (_maxGroupSize - _minGroupSize + 1);
private _group = createGroup [east, true];

// LAMBS Danger takes over groups in COMBAT behaviour and issues its own
// stance/movement orders, standing the ambushers up. Keep it off the group
// until the post-spring hold ends (fn_springNearAmbush re-enables it)
_group setVariable ["lambs_danger_disableGroupAI", true, true];

// Units spawn scattered around the staging marker (so squads from
// simultaneously triggered sites don't spawn inside each other), go prone
// out of sight, and are teleported into the line below. _placements pairs
// each unit with its final line position.
private _placements = [];

// When automatic rifleman classnames are configured, one random slot in the
// line is guaranteed to be one - he fires the overhead suppression on spring
private _autoSlot = -1;
if (_autoRifleClassnames isNotEqualTo []) then {
    _autoSlot = floor random _groupSize;
};

for "_i" from 0 to (_groupSize - 1) do {
    // Center the line on _center: offsets run from -(n-1)/2 to +(n-1)/2
    private _offset = (_i - (_groupSize - 1) / 2) * _unitSpacing;
    private _linePos = _center getPos [_offset, _lineDir];

    private _classname = if (_i == _autoSlot) then {
        selectRandom _autoRifleClassnames
    } else {
        selectRandom _unitClassnames
    };

    private _spawnPos = _stagingPos getPos [3 + random 10, random 360];
    private _unit = _group createUnit [_classname, _spawnPos, [], 0, "NONE"];
    _unit setPos _spawnPos;
    _unit setUnitPos "DOWN";
    _unit disableAI "PATH";
    _unit setVariable ["lambs_danger_disableAI", true, true];

    if (_i == _autoSlot) then {
        _group setVariable ["RECONDO_NEARAMBUSH_autoRifle", _unit];
    };

    _placements pushBack [_unit, _linePos];
};

_group setBehaviour "COMBAT";
_group setCombatMode "GREEN";
_group setFormation "LINE";
_group allowFleeing 0;

// State for the monitor and the spring function
_group setVariable ["RECONDO_NEARAMBUSH_mode", _mode];
_group setVariable ["RECONDO_NEARAMBUSH_center", _center];
_group setVariable ["RECONDO_NEARAMBUSH_travelDir", _travelDir];
_group setVariable ["RECONDO_NEARAMBUSH_marker", _markerName];

if (_debugMarkers) then {
    private _dbgName = "RECONDO_NEARAMBUSH_DBG_" + _markerName;
    _dbgName setMarkerColor "ColorOrange";
    _dbgName setMarkerText format ["Ambush (waiting, %1)", _mode];

    private _line = createMarker ["RECONDO_NEARAMBUSH_LINE_" + _markerName, _center];
    _line setMarkerType "mil_triangle";
    _line setMarkerColor "ColorOrange";
    _line setMarkerDir _faceDir;
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_NEARAMBUSH] Spawned %1 ambush of %2 units at site %3 (center %4, facing %5)",
        _mode, _groupSize, _markerName, _center apply {round _x}, round _faceDir];
};

// ========================================
// STAGE, TELEPORT IN, THEN MONITOR
// ========================================

[_group, _markerName, _markerPos, _placements, _faceDir] spawn {
    params ["_group", "_markerName", "_markerPos", "_placements", "_faceDir"];

    private _settings = RECONDO_NEARAMBUSH_SETTINGS;
    private _springDistance = _settings get "springDistance";
    private _proximitySpring = _settings get "proximitySpring";
    private _rearmRadius = _settings get "rearmRadius";
    private _debugLogging = _settings get "debugLogging";

    // Let the go-prone transition finish out of sight at the staging marker
    sleep 2;

    // Teleport into the ambush line already flat - setPos/setDir preserve the
    // prone animation state - and only now arm the early-contact handlers, so
    // gunfire near the staging area can never spring an unplaced ambush
    {
        _x params ["_unit", "_linePos"];
        if (!alive _unit) then { continue };

        _unit setPos _linePos;
        _unit setDir _faceDir;
        _unit setUnitPos "DOWN";

        // Early contact: taking a hit springs the ambush immediately
        // (signal and volley together - no free seconds for the shooters)
        _unit addEventHandler ["Hit", {
            params ["_unit"];
            [group _unit, true] call Recondo_fnc_springNearAmbush;
        }];

        // Early contact: non-OPFOR gunfire landing near the line springs it
        _unit addEventHandler ["FiredNear", {
            params ["_unit", "_firer"];
            if (side _firer != east) then {
                [group _unit, true] call Recondo_fnc_springNearAmbush;
            };
        }];
    } forEach _placements;

    private _mode = _group getVariable "RECONDO_NEARAMBUSH_mode";
    private _center = _group getVariable "RECONDO_NEARAMBUSH_center";
    private _travelDir = _group getVariable "RECONDO_NEARAMBUSH_travelDir";
    private _dirVec = [sin _travelDir, cos _travelDir];
    private _spawnTime = time;

    while {true} do {
        sleep 1;

        // Sprung by the monitor below or by an event handler - done here
        if (_group getVariable ["RECONDO_NEARAMBUSH_sprung", false]) exitWith {};

        // Wiped before springing - site is spent
        private _aliveUnits = (units _group) select { alive _x };
        if (_aliveUnits isEqualTo []) exitWith {
            if (_debugLogging) then {
                diag_log format ["[RECONDO_NEARAMBUSH] Ambush at site %1 wiped before springing - site spent", _markerName];
            };
            deleteMarker ("RECONDO_NEARAMBUSH_LINE_" + _markerName);
            deleteMarker ("RECONDO_NEARAMBUSH_DBG_" + _markerName);
            deleteGroup _group;
        };

        private _bluforPlayers = allPlayers select { alive _x && {side _x == west} };

        private _spring = false;

        // FRONT: player closes on the line
        if (_mode == "FRONT") then {
            _spring = _bluforPlayers findIf { _x distance2D _center < _springDistance } > -1;
        } else {
            // PARALLEL: player walks abreast of the line center (crosses the
            // perpendicular through it, measured along the travel direction)
            _spring = _bluforPlayers findIf {
                private _rel = (getPos _x) vectorDiff _center;
                private _along = ((_rel select 0) * (_dirVec select 0)) + ((_rel select 1) * (_dirVec select 1));
                (_x distance2D _center < 60) && {_along >= 0}
            } > -1;
        };

        // Failsafe both modes: player walks into an ambusher
        if (!_spring) then {
            _spring = _bluforPlayers findIf {
                private _player = _x;
                _aliveUnits findIf { _x distance2D _player < _proximitySpring } > -1
            } > -1;
        };

        if (_spring) exitWith {
            [_group] call Recondo_fnc_springNearAmbush;
        };

        // Players left before the ambush sprang - despawn and re-arm the site
        if (time - _spawnTime > 60 && {_bluforPlayers findIf { _x distance2D _markerPos < _rearmRadius } == -1}) exitWith {
            { deleteVehicle _x } forEach units _group;
            deleteGroup _group;

            RECONDO_NEARAMBUSH_ACTIVE pushBack [_markerName, _markerPos];

            deleteMarker ("RECONDO_NEARAMBUSH_LINE_" + _markerName);
            if (_settings get "debugMarkers") then {
                private _dbgName = "RECONDO_NEARAMBUSH_DBG_" + _markerName;
                _dbgName setMarkerColor "ColorGreen";
                _dbgName setMarkerText "Ambush (armed)";
            };

            if (_debugLogging) then {
                diag_log format ["[RECONDO_NEARAMBUSH] Players left site %1 - ambush despawned, site re-armed", _markerName];
            };
        };
    };
};
