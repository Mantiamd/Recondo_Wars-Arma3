/*
    Recondo_fnc_spawnRWTrackerTeam
    Spawns a Trackers-module tracker team as part of a reinforcement wave

    Description:
        Spawns a tracker team 150m from the target group in a random
        direction when Wave 1 of a reinforcement party spawns. The team
        is created through the Trackers module (Recondo_fnc_createTrackerGroup),
        so its side, classnames, group size, dog chance, movement speed,
        signal shots, give-up rules and group cap all come from the
        Trackers module placed in the mission - this function only picks
        the spawn position.

        Position selection re-rolls the bearing (up to 8 tries) when the
        candidate spot is in water or within 100m of a target-side unit
        outside the tracked group; if every try fails, the candidate
        furthest from any such unit is used.

        Requires the Trackers module: exits with an RPT warning when it
        is not initialized.

    Parameters:
        0: HASHMAP - Reinforcement Waves module settings
        1: GROUP - Target group being tracked

    Returns:
        GROUP - The tracker group, or grpNull if not spawned
*/

if (!isServer) exitWith { grpNull };

params ["_moduleSettings", "_targetGroup"];

private _moduleId = _moduleSettings get "moduleId";
private _debugLogging = _moduleSettings get "debugLogging";

if (isNil "RECONDO_TRACKERS_SETTINGS") exitWith {
    diag_log format ["[RECONDO_RW] Module %1: Spawn Tracker Team enabled but no Trackers module is placed - skipping tracker team", _moduleId];
    grpNull
};

private _aliveTargets = units _targetGroup select { alive _x };
if (_aliveTargets isEqualTo []) exitWith { grpNull };

// Anchor on the centroid of the target group (same anchor side groups use)
private _anchor = [0, 0, 0];
{ _anchor = _anchor vectorAdd (getPos _x); } forEach _aliveTargets;
_anchor = _anchor vectorMultiply (1 / count _aliveTargets);

private _targetSide = _moduleSettings get "targetSide";
private _spawnDistance = 150;
private _safetyRadius = 100;

// Other target-side units (players from other groups etc.) the team must
// not spawn on top of - the tracked group itself is inside 150m by design
private _otherTargets = allUnits select {
    side _x == _targetSide && {alive _x} && {group _x != _targetGroup}
};

private _spawnPos = [];
private _bestPos = [];
private _bestClearance = -1;

for "_i" from 1 to 8 do {
    private _candidate = _anchor getPos [_spawnDistance, random 360];
    if (!surfaceIsWater _candidate) then {
        private _clearance = 1e6;
        { _clearance = _clearance min (_x distance2D _candidate); } forEach _otherTargets;

        if (_clearance > _bestClearance) then {
            _bestClearance = _clearance;
            _bestPos = _candidate;
        };
    };
    if (_bestClearance >= _safetyRadius) exitWith { _spawnPos = _bestPos; };
};

// All rolls landed near other BLUFOR (or in water): take the clearest spot
if (_spawnPos isEqualTo []) then {
    _spawnPos = if (_bestPos isEqualTo []) then { _anchor getPos [_spawnDistance, random 360] } else { _bestPos };
};

private _trackerGroup = [_spawnPos, _targetGroup, ""] call Recondo_fnc_createTrackerGroup;

if (_debugLogging) then {
    if (isNull _trackerGroup) then {
        diag_log format ["[RECONDO_RW] Module %1: Tracker team not created (Trackers module refused - see its log)", _moduleId];
    } else {
        diag_log format ["[RECONDO_RW] Module %1: Tracker team %2 spawned at %3 (clearance %4m)", _moduleId, _trackerGroup, _spawnPos, round _bestClearance];
    };
};

_trackerGroup
