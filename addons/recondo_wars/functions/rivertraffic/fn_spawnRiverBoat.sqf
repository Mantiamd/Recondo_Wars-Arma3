/*
    Recondo_fnc_spawnRiverBoat
    Spawns a single river boat and registers it with the movement engine.

    Description:
        Server-side. Creates a boat at a river path point, crews it for the
        requested side, applies per-side behavior, hands steering to the custom
        engine (driver AI movement disabled, gunner AI left enabled), and pushes
        a tracking record onto RECONDO_RIVERTRAFFIC_BOATS.

    Parameters:
        0: _cand      - [riverIndex, pointIndex, position]
        1: _classes   - boat classname pool
        2: _crew      - crew classname pool ([] = use createVehicleCrew)
        3: _sideType  - "CIV" | "OPFOR" | "BLUFOR"
        4: _settings  - instance settings hashmap
*/

params ["_cand", "_classes", "_crew", "_sideType", "_settings"];
_cand params ["_ri", "_pi", "_pos"];

private _debug = _settings get "debugLogging";
private _positions = (RECONDO_RIVERTRAFFIC_RIVERS select _ri) select 1;
private _class = selectRandom _classes;

private _side = switch (_sideType) do {
    case "OPFOR":  { east };
    case "BLUFOR": { west };
    default        { civilian };
};

// --- CREATE BOAT ON THE WATER ---
private _spawnPos = [_pos select 0, _pos select 1, 0];
private _boat = createVehicle [_class, _spawnPos, [], 0, "CAN_COLLIDE"];
if (isNull _boat) exitWith {
    if (_debug) then { diag_log format ["[RECONDO_RIVERTRAFFIC] Failed to create boat '%1'.", _class]; };
};
_boat setPosASL [_pos select 0, _pos select 1, 0];

// Face the next path point.
private _nextIdx = (_pi + 1) min ((count _positions) - 1);
private _nextPos = _positions select _nextIdx;
_boat setDir (_pos getDir _nextPos);

// --- CREW THE BOAT ---
private _grp = grpNull;
if (count _crew > 0) then {
    _grp = createGroup [_side, true];

    private _driver = _grp createUnit [selectRandom _crew, _spawnPos, [], 0, "NONE"];
    _driver moveInDriver _boat;

    private _gunner = _grp createUnit [selectRandom _crew, _spawnPos, [], 0, "NONE"];
    _gunner moveInGunner _boat;
    if (isNull objectParent _gunner) then { _gunner moveInAny _boat };
    if (isNull objectParent _gunner) then { deleteVehicle _gunner };
} else {
    createVehicleCrew _boat;
    _grp = group (driver _boat);
};

if (isNull (driver _boat)) exitWith {
    // Could not crew the boat; clean up.
    { deleteVehicle _x } forEach crew _boat;
    deleteVehicle _boat;
    if (!isNull _grp) then { deleteGroup _grp };
    if (_debug) then { diag_log format ["[RECONDO_RIVERTRAFFIC] Boat '%1' had no driver; aborted.", _class]; };
};

// --- PER-SIDE BEHAVIOR ---
switch (_sideType) do {
    case "CIV": {
        { _x setCaptive true } forEach units _grp;
        _grp setBehaviour "CARELESS";
        _grp setCombatMode "BLUE";
        _grp setSpeedMode "NORMAL";

        // Flee trigger: any hit flags the boat so the engine speeds it up.
        _boat setVariable ["RECONDO_RT_FLEE", false];
        _boat addEventHandler ["Hit", { (_this select 0) setVariable ["RECONDO_RT_FLEE", true]; }];
        {
            _x addEventHandler ["Hit", { (vehicle (_this select 0)) setVariable ["RECONDO_RT_FLEE", true]; }];
        } forEach units _grp;
    };
    case "OPFOR": {
        _grp setBehaviour "AWARE";
        _grp setCombatMode "RED";
        _grp setSpeedMode "NORMAL";
    };
    case "BLUFOR": {
        _grp setBehaviour "SAFE";
        _grp setCombatMode "BLUE";
        _grp setSpeedMode "NORMAL";
    };
};

// Hand steering to the custom engine: disable driver movement AI only.
private _drv = driver _boat;
_drv disableAI "PATH";
_drv disableAI "MOVE";

// --- REGISTER WITH MOVEMENT ENGINE ---
private _record = createHashMap;
_record set ["boat", _boat];
_record set ["group", _grp];
_record set ["positions", _positions];
_record set ["index", _nextIdx];
_record set ["speed", _settings get "boatSpeed"];
_record set ["sideType", _sideType];
_record set ["despawnDist", _settings get "despawnDistance"];
_record set ["arrival", 14];
_record set ["fleeing", false];
RECONDO_RIVERTRAFFIC_BOATS pushBack _record;

if (_debug) then {
    diag_log format [
        "[RECONDO_RIVERTRAFFIC] Spawned %1 boat '%2' on river '%3' at %4. Active boats: %5",
        _sideType, _class, (RECONDO_RIVERTRAFFIC_RIVERS select _ri) select 0, mapGridPosition _pos, count RECONDO_RIVERTRAFFIC_BOATS
    ];
};
