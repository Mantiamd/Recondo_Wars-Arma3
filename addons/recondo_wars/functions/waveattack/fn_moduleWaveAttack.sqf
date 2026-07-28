/*
    Recondo_fnc_moduleWaveAttack
    Main initialization for Wave Attack module

    Description:
        Finds invisible map markers by prefix. When a trigger-side player
        enters the radius around a marker, the marker arms (one time) and
        waves of attacking-side groups spawn at the selected compass
        bearings from the marker, move to it, and search within 100m.
        One group spawns per checked bearing each wave. Waves continue on
        a countdown until the wave cap is reached or no trigger-side
        players remain in the radius. Wave 2+ groups whistle on a jittered
        60-second loop (same sounds as the Trackers system).

    Priority: 5 (feature module — spawns entities, no dependencies)

    Parameters:
        _logic     - Module logic object
        _units     - Synchronized units (unused)
        _activated - Whether module is activated
*/

params ["_logic", "_units", "_activated"];

if (!isServer) exitWith {};

if (!_activated) exitWith {
    diag_log "[RECONDO_WAVEATK] Module not activated.";
};

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

private _debugLogging = _logic getVariable ["debuglogging", false];
if (RECONDO_MASTER_DEBUG) then { _debugLogging = true; };
private _debugMarkers = _logic getVariable ["debugmarkers", false];

private _markerPrefix = _logic getVariable ["markerprefix", "WAVEATK_"];
private _activeMarkerPercent = _logic getVariable ["activemarkerpercent", 100];
private _triggerRadius = _logic getVariable ["triggerradius", 300];
private _triggerSideStr = toUpper (_logic getVariable ["triggerside", "WEST"]);
private _heightLimit = _logic getVariable ["heightlimit", 10];

private _attackingSideNum = _logic getVariable ["attackingside", 0];
private _unitClassnamesRaw = _logic getVariable ["unitclassnames", ""];
private _unitsMin = _logic getVariable ["unitsmin", 2];
private _unitsMax = _logic getVariable ["unitsmax", 4];
private _spawnDistance = _logic getVariable ["spawndistance", 400];

private _bearing0 = _logic getVariable ["bearing0", true];
private _bearing90 = _logic getVariable ["bearing90", true];
private _bearing180 = _logic getVariable ["bearing180", true];
private _bearing270 = _logic getVariable ["bearing270", true];

private _maxWaves = _logic getVariable ["maxwaves", 3];
private _timeBetweenWaves = _logic getVariable ["timebetweenwaves", 120];
private _enableWhistles = _logic getVariable ["enablewhistles", true];
private _enableHC = _logic getVariable ["enablehc", false];

// ========================================
// VALIDATE
// ========================================

private _unitClassnames = [_unitClassnamesRaw] call Recondo_fnc_parseClassnames;
if (count _unitClassnames == 0) exitWith {
    private _msg = "[RECONDO_WAVEATK] ERROR: No unit classnames configured. Module disabled.";
    diag_log _msg;
    _msg remoteExec ["systemChat", 0];
};

private _bearings = [];
if (_bearing0) then { _bearings pushBack 0; };
if (_bearing90) then { _bearings pushBack 90; };
if (_bearing180) then { _bearings pushBack 180; };
if (_bearing270) then { _bearings pushBack 270; };

if (count _bearings == 0) exitWith {
    private _msg = "[RECONDO_WAVEATK] ERROR: No spawn bearings selected. Module disabled.";
    diag_log _msg;
    _msg remoteExec ["systemChat", 0];
};

_unitsMin = _unitsMin max 1;
_unitsMax = _unitsMax max _unitsMin;
_maxWaves = _maxWaves max 1;
_timeBetweenWaves = _timeBetweenWaves max 10;
_triggerRadius = _triggerRadius max 50;
_spawnDistance = _spawnDistance max 100;

private _attackingSide = switch (_attackingSideNum) do {
    case 1: { west };
    case 2: { independent };
    default { east };
};

// ========================================
// FIND MARKERS
// ========================================

private _prefixLen = count _markerPrefix;
private _markers = allMapMarkers select {
    (_x select [0, _prefixLen]) == _markerPrefix
};

if (count _markers == 0) exitWith {
    private _msg = format ["[RECONDO_WAVEATK] ERROR: No markers found with prefix '%1'. Module disabled.", _markerPrefix];
    diag_log _msg;
    _msg remoteExec ["systemChat", 0];
};

// Randomly select the configured percentage of markers to be active this
// mission (minimum 1) so hot zones differ between playthroughs
_activeMarkerPercent = (_activeMarkerPercent max 1) min 100;
private _activeCount = (round (count _markers * _activeMarkerPercent / 100)) max 1;
private _activeMarkers = [];
private _markerPool = +_markers;
for "_i" from 1 to _activeCount do {
    private _pick = selectRandom _markerPool;
    _activeMarkers pushBack _pick;
    _markerPool = _markerPool - [_pick];
};

// ========================================
// STORE SETTINGS
// ========================================

private _instanceId = format ["waveatk_%1_%2", _markerPrefix, count (missionNamespace getVariable ["RECONDO_WAVEATK_INSTANCES", []])];

private _settings = createHashMapFromArray [
    ["instanceId", _instanceId],
    ["markerPrefix", _markerPrefix],
    ["triggerRadius", _triggerRadius],
    ["triggerSideStr", _triggerSideStr],
    ["heightLimit", _heightLimit],
    ["attackingSide", _attackingSide],
    ["unitClassnames", _unitClassnames],
    ["unitsMin", _unitsMin],
    ["unitsMax", _unitsMax],
    ["spawnDistance", _spawnDistance],
    ["bearings", _bearings],
    ["maxWaves", _maxWaves],
    ["timeBetweenWaves", _timeBetweenWaves],
    ["enableWhistles", _enableWhistles],
    ["enableHC", _enableHC],
    ["whistleSounds", ["enemy_whistle_2", "enemy_whistle_3", "enemy_whistle_4", "enemy_whistling_2", "enemy_whistling_3", "enemy_whistling_4"]],
    ["pendingMarkers", _activeMarkers],
    ["debugLogging", _debugLogging],
    ["debugMarkers", _debugMarkers]
];

if (isNil "RECONDO_WAVEATK_INSTANCES") then {
    RECONDO_WAVEATK_INSTANCES = [];
};
RECONDO_WAVEATK_INSTANCES pushBack _settings;

// ========================================
// CLIENT SOUND FUNCTION (JIP-safe via publicVariable)
// ========================================

if (isNil "RECONDO_WAVEATK_fnc_playSound") then {
    RECONDO_WAVEATK_fnc_playSound = compileFinal "
        if (!hasInterface) exitWith {};
        params ['_unit', '_sounds'];
        if (_sounds isEqualTo []) exitWith {};
        if (player distance _unit > 300) exitWith {};
        private _sound = selectRandom _sounds;
        private _soundPath = '\recondo_wars\sounds\trackers\' + _sound + '.ogg';
        playSound3D [_soundPath, _unit, false, getPosASL _unit, 5, 1, 300];
    ";
    publicVariable "RECONDO_WAVEATK_fnc_playSound";
};

// ========================================
// DEBUG MARKERS
// ========================================

if (_debugMarkers) then {
    {
        private _pos = getMarkerPos _x;
        private _dbg = createMarker [format ["RECONDO_WAVEATK_DBG_%1", _x], _pos];
        _dbg setMarkerShape "ELLIPSE";
        _dbg setMarkerBrush "Border";
        _dbg setMarkerColor "ColorRed";
        _dbg setMarkerSize [_triggerRadius, _triggerRadius];

        private _icon = createMarker [format ["RECONDO_WAVEATK_ICON_%1", _x], _pos];
        _icon setMarkerType "mil_warning";
        _icon setMarkerColor "ColorRed";
        _icon setMarkerText format ["WaveAtk: %1", _x];
    } forEach _activeMarkers;
};

// ========================================
// START WATCHER
// ========================================

[_settings] spawn Recondo_fnc_waveAttackWatcher;

// ========================================
// FINAL LOG
// ========================================

diag_log format ["[RECONDO_WAVEATK] Module initialized: %1/%2 markers active (prefix '%3', %4%5), trigger %6 within %7m, %8 waves of %9-%10 units from bearings %11, %12s between waves",
    count _activeMarkers, count _markers, _markerPrefix, _activeMarkerPercent, "%", _triggerSideStr, _triggerRadius, _maxWaves, _unitsMin, _unitsMax, _bearings, _timeBetweenWaves];

if (_debugLogging) then {
    diag_log format ["[RECONDO_WAVEATK] Active markers: %1", _activeMarkers];
};
