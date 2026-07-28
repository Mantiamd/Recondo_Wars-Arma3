/*
    Recondo_fnc_spawnSurvHunters
    Spawns a hunter group on a triangulated transmitter

    Description:
        Spawns a hunter group a set distance from the triangulated position
        in a random direction. If another target-side unit is within 100m of
        the candidate point (or it is in water), another random direction is
        rolled; after several attempts the last candidate is used. The group
        moves to the triangulated position, then follows the transmitter's
        footprints (see Recondo_fnc_survHunterBehavior). Must be spawned,
        not called (contains sleeps). Server-only.

    Parameters:
        0: OBJECT - The triangulated transmitter
        1: ARRAY - Triangulated position (transmitter position at trigger)

    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params ["_targetUnit", "_triangulatedPos"];

private _settings = RECONDO_SURV_SETTINGS;
private _hunterClassnames = _settings get "hunterClassnames";
private _hunterSide = _settings get "hunterSide";
private _targetSide = _settings get "targetSide";
private _spawnDistance = _settings get "spawnDistance";
private _hunterMinSize = _settings get "hunterMinSize";
private _hunterMaxSize = _settings get "hunterMaxSize";
private _debugMarkers = _settings get "debugMarkers";
private _debug = _settings get "debugLogging";

// Stable ID for this hunt - footprints and hunters are keyed to it.
// A respawned player is a new object, so a fresh triangulation starts a new hunt.
private _targetId = netId _targetUnit;

// ========================================
// PICK SPAWN POSITION
// ========================================

// Random direction at spawnDistance; reroll if another target-side unit is
// within 100m of the point or it lands in water. The transmitter itself is
// spawnDistance away so it never blocks its own hunters.
private _targetSideUnits = allUnits select { alive _x && side group _x == _targetSide };

private _spawnPos = _triangulatedPos getPos [_spawnDistance, random 360];
for "_i" from 1 to 12 do {
    private _testPos = _triangulatedPos getPos [_spawnDistance, random 360];
    _testPos set [2, 0];
    _spawnPos = _testPos;

    private _blocked = (_targetSideUnits findIf { _x distance _testPos < 100 }) != -1;
    if (!_blocked && {!surfaceIsWater _testPos}) exitWith {};
};

// ========================================
// CREATE HUNTER GROUP
// ========================================

private _hunterGroup = createGroup [_hunterSide, true];
if (isNull _hunterGroup) exitWith {
    diag_log "[RECONDO_SURV] ERROR: Failed to create hunter group";
};

_hunterGroup setVariable ["RECONDO_SURV_targetId", _targetId];
_hunterGroup setVariable ["RECONDO_SURV_targetUnit", _targetUnit];
_hunterGroup setVariable ["RECONDO_SURV_triangulatedPos", _triangulatedPos];

// Group size within configured bounds
private _groupSize = _hunterMinSize + floor random ((_hunterMaxSize - _hunterMinSize) + 1);

// Brief pause between creations spreads the engine load
private _unitsCreated = 0;
for "_i" from 1 to _groupSize do {
    private _class = selectRandom _hunterClassnames;
    if (isClass (configFile >> "CfgVehicles" >> _class)) then {
        private _unit = _hunterGroup createUnit [_class, _spawnPos, [], 0, "NONE"];
        if (!isNull _unit) then {
            _unit disableAI "AUTOCOMBAT";
            _unit setUnitPos "UP";
            _unitsCreated = _unitsCreated + 1;
        };
    };
    sleep 0.1;
};

if (_unitsCreated == 0) exitWith {
    deleteGroup _hunterGroup;
    diag_log "[RECONDO_SURV] ERROR: Failed to create any hunter units";
};

_hunterGroup setFormation "FILE";
_hunterGroup setBehaviour "AWARE";
_hunterGroup setCombatMode "RED";
_hunterGroup setSpeedMode "NORMAL";

RECONDO_SURV_ACTIVE_GROUPS pushBack _hunterGroup;

// Register the transmitter with the footprint producer
RECONDO_SURV_TRACKED set [_targetId, [_targetUnit, getPos _targetUnit]];

// Debug markers
if (_debugMarkers) then {
    private _spawnMarker = createMarker [format ["RECONDO_SURV_spawn_%1_%2", _targetId, time], _spawnPos];
    _spawnMarker setMarkerType "mil_dot";
    _spawnMarker setMarkerColor "ColorRed";
    _spawnMarker setMarkerText "SURV_Hunters";

    private _triangMarker = createMarker [format ["RECONDO_SURV_triang_%1_%2", _targetId, time], _triangulatedPos];
    _triangMarker setMarkerType "mil_objective";
    _triangMarker setMarkerColor "ColorOrange";
    _triangMarker setMarkerText "SURV_Triangulated";
};

// Start behavior: move to triangulated position, then follow footprints
[_hunterGroup, _targetId, _triangulatedPos] spawn Recondo_fnc_survHunterBehavior;

if (_debug) then {
    diag_log format ["[RECONDO_SURV] Hunter group spawned - %1 units at %2, hunting %3 (triangulated at %4)",
        _unitsCreated, _spawnPos, name _targetUnit, _triangulatedPos];
};
