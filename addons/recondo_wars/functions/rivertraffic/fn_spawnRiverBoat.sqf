/*
    Recondo_fnc_spawnRiverBoat
    Spawns a single river boat and registers it with the movement engine.

    Description:
        Server-side. Creates a boat at a river path point, crews it for the
        requested side, applies per-side behavior, hands steering to the custom
        engine (driver AI movement disabled, gunner AI left enabled), and pushes
        a tracking record onto RECONDO_RIVERTRAFFIC_BOATS.

    Parameters:
        0: _cand      - [riverIndex, startIndex, position, direction(+1/-1)]
        1: _classes   - boat classname pool
        2: _crew      - crew classname pool ([] = use createVehicleCrew)
        3: _sideType  - "CIV" | "OPFOR" | "BLUFOR"
        4: _settings  - instance settings hashmap
*/

params ["_cand", "_classes", "_crew", "_sideType", "_settings"];
_cand params ["_ri", "_pi", "_pos", ["_dir", 1]];

private _debug = _settings get "debugLogging";
private _rivers = _settings get "rivers";
private _river = _rivers select _ri;
private _riverName = _river select 0;
private _positions = _river select 1;

// Marker riverId prefix "big" allows the side's larger boat classes.
private _isBig = (_riverName find "big") == 0;

// On big rivers, add the side's big-boat pool to the normal pool.
if (_isBig) then {
    private _bigPool = switch (_sideType) do {
        case "OPFOR":  { _settings get "opforBig" };
        case "BLUFOR": { _settings get "bluforBig" };
        default        { _settings get "civBig" };
    };
    if (count _bigPool > 0) then { _classes = _classes + _bigPool; };
};

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

// Face the next path point in the travel direction.
private _nextIdx = ((_pi + _dir) max 0) min ((count _positions) - 1);
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

// --- CONTACT REACTION SETUP (CIV / OPFOR) ---
// Being hit or shot at near the boat flags it; the movement engine then reacts
// (SOG AI style): armed OPFOR boats accelerate and keep fighting from the boat,
// unarmed OPFOR boats beach and dump their crew to fight on foot, and civilian
// boats just flee at speed. The shooter is revealed so gunners engage sooner.
if (_sideType in ["CIV", "OPFOR"]) then {
    _boat setVariable ["RECONDO_RT_CONTACT", false];
    // Hit EH args: [target, causer, damage, instigator]; instigator is the shooter.
    _boat addEventHandler ["Hit", {
        params ["_target", "_causer", "_dmg", "_instigator"];
        private _b = vehicle _target;
        if !(_b getVariable ["RECONDO_RT_CONTACT", false]) then {
            _b setVariable ["RECONDO_RT_CONTACT", true];
            if (!isNull _instigator) then { (group driver _b) reveal [_instigator, 4]; };
        };
    }];
    {
        _x addEventHandler ["Hit", {
            params ["_target", "_causer", "_dmg", "_instigator"];
            private _b = vehicle _target;
            if !(_b getVariable ["RECONDO_RT_CONTACT", false]) then {
                _b setVariable ["RECONDO_RT_CONTACT", true];
                if (!isNull _instigator) then { (group driver _b) reveal [_instigator, 4]; };
            };
        }];
        // FiredNear args: [unit, firer, distance, ...]; firer is the shooter.
        _x addEventHandler ["FiredNear", {
            params ["_unit", "_firer"];
            private _b = vehicle _unit;
            if !(_b getVariable ["RECONDO_RT_CONTACT", false]) then {
                _b setVariable ["RECONDO_RT_CONTACT", true];
                if (!isNull _firer) then { (group driver _b) reveal [_firer, 4]; };
            };
        }];
    } forEach units _grp;
};

// --- OPTIONAL HEADGEAR OVERRIDE (CIV / OPFOR) ---
// Replace every crew member's headgear with a random entry from the side's
// list. Applies to all seats and to auto-created crew (crew _boat covers both).
private _hgEnable = switch (_sideType) do {
    case "CIV":   { _settings get "civHeadgearEnable" };
    case "OPFOR": { _settings get "opforHeadgearEnable" };
    default        { false };
};
if (_hgEnable) then {
    private _hgList = switch (_sideType) do {
        case "CIV":   { _settings get "civHeadgear" };
        case "OPFOR": { _settings get "opforHeadgear" };
        default        { [] };
    };
    if (count _hgList > 0) then {
        {
            removeHeadgear _x;
            _x addHeadgear (selectRandom _hgList);
        } forEach (crew _boat);
    };
};

// Hand steering to the custom engine: disable driver movement AI only.
private _drv = driver _boat;
_drv disableAI "PATH";
_drv disableAI "MOVE";

// Engine AI won't throttle with MOVE disabled, so force the engine on for the
// running sound/propeller. Boat is server-local, so this broadcasts to clients.
_boat engineOn true;

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
_record set ["dir", _dir];
// Contact-reaction state machine: CRUISE -> FLEE / BEACHING -> DISEMBARKED.
_record set ["state", "CRUISE"];
// Armed boats fight from the water; unarmed ones beach and disembark on contact.
_record set ["armed", (weapons _boat) isNotEqualTo []];
_record set ["disembarked", []];
RECONDO_RIVERTRAFFIC_BOATS pushBack _record;

if (_debug) then {
    diag_log format [
        "[RECONDO_RIVERTRAFFIC] Spawned %1 boat '%2' on river '%3' at %4. Active boats: %5",
        _sideType, _class, _riverName, mapGridPosition _pos, count RECONDO_RIVERTRAFFIC_BOATS
    ];
};
