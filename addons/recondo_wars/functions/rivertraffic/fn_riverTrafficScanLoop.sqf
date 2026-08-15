/*
    Recondo_fnc_riverTrafficScanLoop
    Server-side scan tick for the River Traffic module.

    Description:
        Runs once per second on the server. Cleans up derelict boats (wrecks,
        dead-crew hulls, beached-and-abandoned boats) once no player is near,
        then for each module instance (throttled by its scan interval) finds
        qualifying players, builds candidate river spawn points, and rolls
        each enabled boat type's spawn chance under the global boat cap.
        Live boats are never distance-despawned: once spawned they complete
        their route and are retired at the far end by the movement engine.

    Parameters (CBA PFH):
        _args   - unused
        _handle - PFH handle
*/

params ["_args", "_handle"];

if (isNil "RECONDO_RIVERTRAFFIC_INSTANCES") exitWith {};
if (isNil "RECONDO_RIVERTRAFFIC_BOATS") then { RECONDO_RIVERTRAFFIC_BOATS = []; };

private _now = time;

// All real players (exclude headless clients), alive only.
private _hc = entities "HeadlessClient_F";
private _allP = allPlayers select { alive _x && {!(_x in _hc)} };

// ========================================
// DERELICT CLEANUP PASS (global, every tick)
// ========================================

if (count RECONDO_RIVERTRAFFIC_BOATS > 0) then {
    private _survivors = [];
    {
        private _rec = _x;
        private _boat = _rec get "boat";
        // Boat object already gone (deleted elsewhere): clean up any disembarked
        // crew and drop the record.
        if (isNull _boat) then {
            { if (!isNull _x) then { deleteVehicle _x } } forEach (_rec getOrDefault ["disembarked", []]);
            private _g = _rec get "group";
            if (!isNull _g) then { deleteGroup _g };
            continue;
        };
        // Live boats always complete their route (the movement engine retires
        // them at the far end), regardless of where players are.
        if (alive _boat && {{alive _x} count (crew _boat) > 0}) then {
            _survivors pushBack _rec;
            continue;
        };
        // Derelicts - wrecks, dead-crew hulls, and beached boats whose crew
        // disembarked to fight on foot - can never finish a route. They are
        // removed by distance, but only once no player is nearby, so
        // wrecks/corpses persist for players in the area.
        private _dd = _rec get "despawnDist";
        // Reference points: the boat plus any disembarked crew now fighting on
        // foot, so we never delete a squad still engaging nearby players.
        private _refs = [getPos _boat];
        {
            if (!isNull _x && {alive _x}) then { _refs pushBack (getPos _x); };
        } forEach (_rec getOrDefault ["disembarked", []]);

        private _keep = (_refs findIf {
            private _p = _x;
            (_allP findIf {(_x distance2D _p) <= _dd}) >= 0
        }) >= 0;

        if (!_keep) then {
            { deleteVehicle _x } forEach (crew _boat);
            { if (!isNull _x) then { deleteVehicle _x } } forEach (_rec getOrDefault ["disembarked", []]);
            deleteVehicle _boat;
            private _g = _rec get "group";
            if (!isNull _g) then { deleteGroup _g };
        } else {
            _survivors pushBack _rec;
        };
    } forEach RECONDO_RIVERTRAFFIC_BOATS;
    RECONDO_RIVERTRAFFIC_BOATS = _survivors;
};

if (_allP isEqualTo []) exitWith {};

// ========================================
// PER-INSTANCE SPAWN PASS
// ========================================

{
    private _settings = _x;

    // Each instance carries its own prefix-scoped river set.
    private _rivers = _settings get "rivers";

    private _last = _settings get "lastScan";
    private _interval = _settings get "scanInterval";
    if (_now - _last < _interval) then { continue };
    _settings set ["lastScan", _now];

    private _maxBoats = _settings get "maxBoats";
    // Only live, crewed boats count toward the cap so kills/wrecks left drifting
    // in the area don't block new spawns.
    private _activeBoats = {
        private _b = _x get "boat";
        !isNull _b && {alive _b} && {{alive _x} count (crew _b) > 0}
    } count RECONDO_RIVERTRAFFIC_BOATS;
    if (_activeBoats >= _maxBoats) then { continue };

    private _center = _settings get "center";
    private _radius = _settings get "moduleRadius";
    private _hLimit = _settings get "heightLimit";
    private _actDist = _settings get "activationDistance";
    private _minAway = _settings get "minSpawnAway";

    // Activation is measured from the module's placement position: a boat may
    // spawn only while a valid player (below the height limit, not in an
    // aircraft) is within Activation Distance of the module.
    private _triggered = _allP findIf {
        (_x distance2D _center) <= _actDist
        && {((getPosATL _x) select 2) <= _hLimit}
        && {private _v = vehicle _x; (_v == _x) || {!(_v isKindOf "Air")}}
    } >= 0;
    if (!_triggered) then { continue };

    // Boats now launch from a river end and run straight through to the other
    // end. For each river that passes through this module's zone, pick a random
    // end (50/50): low end -> travel ascending, high end -> travel descending.
    private _candidates = [];
    for "_ri" from 0 to (count _rivers - 1) do {
        private _positions = (_rivers select _ri) select 1;
        // Only drive rivers that actually pass through this module's zone.
        if ((_positions findIf {(_x distance2D _center) <= _radius}) < 0) then { continue };

        private _lastIdx = (count _positions) - 1;
        private _startLow = (random 1) < 0.5;
        private _startIdx = if (_startLow) then { 0 } else { _lastIdx };
        private _dir = if (_startLow) then { 1 } else { -1 };
        private _sp = _positions select _startIdx;

        // Don't pop a boat in on top of a player standing at that end.
        if ((_allP findIf {(_x distance2D _sp) < _minAway}) < 0) then {
            _candidates pushBack [_ri, _startIdx, _sp, _dir];
        };
    };

    if (_candidates isEqualTo []) then { continue };

    // Roll each enabled boat type. Stops once the global cap is reached.
    private _attempts = [
        ["CIV",    _settings get "civClasses",    _settings get "civCrew",    _settings get "civChance"],
        ["OPFOR",  _settings get "opforClasses",  _settings get "opforCrew",  _settings get "opforChance"],
        ["BLUFOR", _settings get "bluforClasses", _settings get "bluforCrew", _settings get "bluforChance"]
    ];

    {
        _x params ["_sideType", "_classes", "_crew", "_chance"];
        // Recount live, crewed boats each attempt so the cap tracks the active
        // fleet (spawns add one; kills/wrecks are excluded).
        private _activeNow = {
            private _b = _x get "boat";
            !isNull _b && {alive _b} && {{alive _x} count (crew _b) > 0}
        } count RECONDO_RIVERTRAFFIC_BOATS;
        if (_activeNow >= _maxBoats) exitWith {};
        if (_chance <= 0 || {count _classes == 0}) then { continue };
        if (random 100 > _chance) then { continue };

        private _cand = selectRandom _candidates;

        // Clear this river's banks once, the first time we spawn on it. Keyed by
        // prefix + riverId so different module instances never collide by index.
        if (_settings get "clearObstacles") then {
            private _rIdx = _cand select 0;
            private _cleanKey = format ["%1|%2", _settings get "markerPrefix", (_rivers select _rIdx) select 0];
            if (!(_cleanKey in RECONDO_RIVERTRAFFIC_CLEANED)) then {
                RECONDO_RIVERTRAFFIC_CLEANED pushBack _cleanKey;
                [(_rivers select _rIdx) select 1, _settings get "clearRadius"] call Recondo_fnc_riverTrafficClearObstacles;
            };
        };

        [_cand, _classes, _crew, _sideType, _settings] call Recondo_fnc_spawnRiverBoat;
    } forEach _attempts;

} forEach RECONDO_RIVERTRAFFIC_INSTANCES;
