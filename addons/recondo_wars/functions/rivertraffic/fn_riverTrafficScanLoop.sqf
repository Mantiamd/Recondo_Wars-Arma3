/*
    Recondo_fnc_riverTrafficScanLoop
    Server-side scan tick for the River Traffic module.

    Description:
        Runs once per second on the server. Despawns boats with no players in
        range, then for each module instance (throttled by its scan interval)
        finds qualifying players, builds candidate river spawn points, and rolls
        each enabled boat type's spawn chance under the global boat cap.

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
// DESPAWN PASS (global, every tick)
// ========================================

if (count RECONDO_RIVERTRAFFIC_BOATS > 0) then {
    private _survivors = [];
    {
        private _rec = _x;
        private _boat = _rec get "boat";
        if (isNull _boat || {!alive _boat} || {{alive _x} count (crew _boat) == 0}) then {
            { deleteVehicle _x } forEach (crew _boat);
            if (!isNull _boat) then { deleteVehicle _boat };
            private _g = _rec get "group";
            if (!isNull _g) then { deleteGroup _g };
            continue;
        };
        private _dd = _rec get "despawnDist";
        private _bpos = getPos _boat;
        if (_allP findIf {(_x distance2D _bpos) <= _dd} < 0) then {
            { deleteVehicle _x } forEach (crew _boat);
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

private _rivers = RECONDO_RIVERTRAFFIC_RIVERS;

// ========================================
// PER-INSTANCE SPAWN PASS
// ========================================

{
    private _settings = _x;

    private _last = _settings get "lastScan";
    private _interval = _settings get "scanInterval";
    if (_now - _last < _interval) then { continue };
    _settings set ["lastScan", _now];

    private _maxBoats = _settings get "maxBoats";
    if (count RECONDO_RIVERTRAFFIC_BOATS >= _maxBoats) then { continue };

    private _center = _settings get "center";
    private _radius = _settings get "moduleRadius";
    private _hLimit = _settings get "heightLimit";

    // Qualifying players: inside zone, below height limit, not in an aircraft.
    private _qual = _allP select {
        (_x distance2D _center) <= _radius
        && {((getPosATL _x) select 2) <= _hLimit}
        && {private _v = vehicle _x; (_v == _x) || {!(_v isKindOf "Air")}}
    };
    if (_qual isEqualTo []) then { continue };

    private _actDist = _settings get "activationDistance";
    private _minAway = _settings get "minSpawnAway";

    // Build candidate spawn points along the rivers.
    private _candidates = [];
    for "_ri" from 0 to (count _rivers - 1) do {
        private _positions = (_rivers select _ri) select 1;
        {
            private _p = _x;
            private _pi = _forEachIndex;
            if ((_p distance2D _center) <= _radius
                && {(_qual findIf {(_x distance2D _p) <= _actDist}) >= 0}
                && {(_allP findIf {(_x distance2D _p) < _minAway}) < 0}
            ) then {
                _candidates pushBack [_ri, _pi, _p];
            };
        } forEach _positions;
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
        if (count RECONDO_RIVERTRAFFIC_BOATS >= _maxBoats) exitWith {};
        if (_chance <= 0 || {count _classes == 0}) then { continue };
        if (random 100 > _chance) then { continue };

        private _cand = selectRandom _candidates;
        [_cand, _classes, _crew, _sideType, _settings] call Recondo_fnc_spawnRiverBoat;
    } forEach _attempts;

} forEach RECONDO_RIVERTRAFFIC_INSTANCES;
