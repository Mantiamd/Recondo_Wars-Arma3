/*
    Recondo_fnc_moduleOutpostSystem
    Main initialization for Outpost System module

    Description:
        Defines an outpost location with Class 1 supply tracking
        and an optional AI garrison. Supply drains over time and
        is replenished by delivering configurable objects into the
        outpost area. AI units matching garrison classnames are
        automatically tasked to defend the outpost.

    Parameters:
        _logic     - Module logic object
        _units     - Synchronized units (unused)
        _activated - Whether module is activated
*/

params ["_logic", "_units", "_activated"];

if (!isServer) exitWith {};

if (!_activated) exitWith {
    diag_log "[RECONDO_OUTPOST] Module not activated.";
};

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

private _outpostName       = _logic getVariable ["outpostname", "Outpost Alpha"];
private _markerName        = _logic getVariable ["markername", "OUTPOST_1"];
private _outpostRadius     = parseNumber str (_logic getVariable ["outpostradius", 25]);
private _class1Classname   = _logic getVariable ["class1classname", ""];
private _class1Resupply    = parseNumber str (_logic getVariable ["class1resupplyamount", 25]);
private _maxClass1Supply   = parseNumber str (_logic getVariable ["maxclass1supply", 100]);
private _drainAmount       = parseNumber str (_logic getVariable ["drainamount", 1]);
private _drainInterval     = parseNumber str (_logic getVariable ["draininterval", 300]);
private _detectionInterval = parseNumber str (_logic getVariable ["detectioninterval", 30]);
private _enablePersistence = _logic getVariable ["enablepersistence", false];
private _debugLogging      = _logic getVariable ["debuglogging", false];
if (RECONDO_MASTER_DEBUG) then { _debugLogging = true; };

if (_maxClass1Supply < 1) then { _maxClass1Supply = 100; };

// Garrison attributes
private _garrisonClassnamesRaw = _logic getVariable ["garrisonclassnames", ""];
private _maxGarrison           = parseNumber str (_logic getVariable ["maxgarrison", 20]);

private _garrisonClassnames = [];
if (_garrisonClassnamesRaw != "") then {
    {
        private _trimmed = _x trim [" ", 0];
        _trimmed = _trimmed trim [" ", 1];
        if (_trimmed != "") then {
            _garrisonClassnames pushBack _trimmed;
        };
    } forEach (_garrisonClassnamesRaw splitString ",");
};

// Ammo resupply attributes
private _ammoResupplyClassname = _logic getVariable ["ammoresupplyclassname", ""];
private _ammoResupplyInterval  = parseNumber str (_logic getVariable ["ammoresupplyinterval", 300]);
if (_ammoResupplyInterval < 1) then { _ammoResupplyInterval = 300; };

// Class 3 (fuel) attributes
private _class3Classname    = _logic getVariable ["class3classname", ""];
private _class3Resupply     = parseNumber str (_logic getVariable ["class3resupplyamount", 25]);
private _maxClass3Supply    = parseNumber str (_logic getVariable ["maxclass3supply", 100]);
private _class3DrainAmount  = parseNumber str (_logic getVariable ["class3drainamount", 1]);
private _class3DrainInterval = parseNumber str (_logic getVariable ["class3draininterval", 300]);
if (_maxClass3Supply < 1) then { _maxClass3Supply = 100; };

private _class3Enabled = _class3Classname != "";

// Marker visibility (dropdown: 0=WEST, 1=EAST, 2=INDEPENDENT, 3=ALL)
private _markerVisibleSideNum = _logic getVariable ["markervisibleside", 0];
private _sideNames = ["WEST", "EAST", "INDEPENDENT", "ALL"];
private _markerVisibleSide = _sideNames select (_markerVisibleSideNum min 3 max 0);

// Garrison skills - Normal (Class 1 above 0)
private _normalSkills = createHashMapFromArray [
    ["aimingAccuracy", _logic getVariable ["normal_aimingaccuracy", 0.3]],
    ["aimingShake", _logic getVariable ["normal_aimingshake", 0.3]],
    ["aimingSpeed", _logic getVariable ["normal_aimingspeed", 0.3]],
    ["spotDistance", _logic getVariable ["normal_spotdistance", 0.5]],
    ["spotTime", _logic getVariable ["normal_spottime", 0.5]],
    ["courage", _logic getVariable ["normal_courage", 1.0]],
    ["commanding", _logic getVariable ["normal_commanding", 0.5]],
    ["general", _logic getVariable ["normal_general", 0.3]],
    ["reloadSpeed", _logic getVariable ["normal_reloadspeed", 0.5]]
];

// Garrison skills - Low Morale (Class 1 at 0)
private _lowMoraleSkills = createHashMapFromArray [
    ["aimingAccuracy", _logic getVariable ["lowmorale_aimingaccuracy", 0.1]],
    ["aimingShake", _logic getVariable ["lowmorale_aimingshake", 0.6]],
    ["aimingSpeed", _logic getVariable ["lowmorale_aimingspeed", 0.1]],
    ["spotDistance", _logic getVariable ["lowmorale_spotdistance", 0.2]],
    ["spotTime", _logic getVariable ["lowmorale_spottime", 0.2]],
    ["courage", _logic getVariable ["lowmorale_courage", 0.3]],
    ["commanding", _logic getVariable ["lowmorale_commanding", 0.2]],
    ["general", _logic getVariable ["lowmorale_general", 0.1]],
    ["reloadSpeed", _logic getVariable ["lowmorale_reloadspeed", 0.2]]
];

// ========================================
// VALIDATE MARKER
// ========================================

private _markerPos = getMarkerPos _markerName;
if (_markerPos isEqualTo [0, 0, 0]) exitWith {
    diag_log format ["[RECONDO_OUTPOST] ERROR: Marker '%1' not found. Module disabled.", _markerName];
};

if (_class1Classname == "") then {
    diag_log format ["[RECONDO_OUTPOST] WARNING: No Class 1 object classname configured for '%1'. Resupply will not function.", _outpostName];
};

// ========================================
// GENERATE INSTANCE ID
// ========================================

private _instanceId = format ["outpost_%1_%2", _outpostName, count RECONDO_OUTPOST_INSTANCES];

// ========================================
// STORE SETTINGS
// ========================================

private _settings = createHashMapFromArray [
    ["instanceId", _instanceId],
    ["outpostName", _outpostName],
    ["markerName", _markerName],
    ["markerPos", _markerPos],
    ["outpostRadius", _outpostRadius],
    ["class1Classname", _class1Classname],
    ["class1Resupply", _class1Resupply],
    ["maxClass1Supply", _maxClass1Supply],
    ["drainAmount", _drainAmount],
    ["drainInterval", _drainInterval],
    ["detectionInterval", _detectionInterval],
    ["enablePersistence", _enablePersistence],
    ["debugLogging", _debugLogging],
    ["class1Supply", 0],
    ["garrisonClassnames", _garrisonClassnames],
    ["maxGarrison", _maxGarrison],
    ["garrisonUnits", []],
    ["garrisonedGroups", []],
    ["garrisonCount", 0],
    ["ammoResupplyClassname", _ammoResupplyClassname],
    ["ammoResupplyInterval", _ammoResupplyInterval],
    ["class3Classname", _class3Classname],
    ["class3Resupply", _class3Resupply],
    ["maxClass3Supply", _maxClass3Supply],
    ["class3DrainAmount", _class3DrainAmount],
    ["class3DrainInterval", _class3DrainInterval],
    ["class3Supply", _maxClass3Supply],
    ["class3Enabled", _class3Enabled],
    ["markerVisibleSide", _markerVisibleSide],
    ["normalSkills", _normalSkills],
    ["lowMoraleSkills", _lowMoraleSkills],
    ["currentMoraleState", "normal"]
];

// ========================================
// LOAD PERSISTENCE DATA
// ========================================

if (_enablePersistence) then {
    private _persistenceKey = format ["OUTPOST_%1", _outpostName];
    private _savedSupply = [_persistenceKey + "_CLASS1"] call Recondo_fnc_getSaveData;

    if (!isNil "_savedSupply" && {_savedSupply isEqualType 0}) then {
        _settings set ["class1Supply", _savedSupply min _maxClass1Supply max 0];
        if (_debugLogging) then {
            diag_log format ["[RECONDO_OUTPOST] Loaded persisted supply for '%1': %2", _outpostName, _savedSupply];
        };
    };

    if (_class3Enabled) then {
        private _savedFuel = [_persistenceKey + "_CLASS3"] call Recondo_fnc_getSaveData;
        if (!isNil "_savedFuel" && {_savedFuel isEqualType 0}) then {
            _settings set ["class3Supply", _savedFuel min _maxClass3Supply max 0];
            if (_debugLogging) then {
                diag_log format ["[RECONDO_OUTPOST] Loaded persisted fuel for '%1': %2", _outpostName, _savedFuel];
            };
        };
    };

    private _savedGarrison = [_persistenceKey + "_GARRISON"] call Recondo_fnc_getSaveData;
    if (!isNil "_savedGarrison" && {_savedGarrison isEqualType 0} && {_savedGarrison > 0} && {count _garrisonClassnames > 0}) then {
        private _toSpawn = (_savedGarrison max 0) min _maxGarrison;
        if (_debugLogging) then {
            diag_log format ["[RECONDO_OUTPOST] Spawning %1 persisted garrison units for '%2'.", _toSpawn, _outpostName];
        };

        private _spawnedUnits = [];
        private _spawnedGroups = [];
        private _side = west;

        for "_i" from 1 to _toSpawn do {
            private _classname = selectRandom _garrisonClassnames;
            private _grp = createGroup [_side, true];
            private _unit = _grp createUnit [_classname, _markerPos, [], _outpostRadius * 0.5, "NONE"];
            _unit setVariable ["RECONDO_OUTPOST_GARRISONED", _instanceId];
            _spawnedUnits pushBack _unit;

            if !(_grp in _spawnedGroups) then {
                _spawnedGroups pushBack _grp;
            };
        };

        {
            [_x, _markerPos, _outpostRadius] call lambs_wp_fnc_taskGarrison;
        } forEach _spawnedGroups;

        _settings set ["garrisonUnits", _spawnedUnits];
        _settings set ["garrisonedGroups", _spawnedGroups];
        _settings set ["garrisonCount", count _spawnedUnits];

        private _initSupply = _settings get "class1Supply";
        private _skillSet = if (_initSupply > 0) then { _normalSkills } else { _lowMoraleSkills };
        private _skillState = if (_initSupply > 0) then { "normal" } else { "lowMorale" };
        {
            private _unit = _x;
            if (alive _unit) then {
                { _unit setSkill [_x, _y]; } forEach _skillSet;
            };
        } forEach _spawnedUnits;
        _settings set ["currentMoraleState", _skillState];

        diag_log format ["[RECONDO_OUTPOST] '%1' restored %2 garrison units in %3 groups from persistence. Morale: %4",
            _outpostName, count _spawnedUnits, count _spawnedGroups, _skillState];
    };
};

// ========================================
// REGISTER INSTANCE
// ========================================

RECONDO_OUTPOST_INSTANCES pushBack _settings;
publicVariable "RECONDO_OUTPOST_INSTANCES";

// ========================================
// CREATE MAP MARKER
// ========================================

private _displayMarker = format ["RECONDO_OUTPOST_DISPLAY_%1", _instanceId];
createMarker [_displayMarker, _markerPos];
_displayMarker setMarkerShape "ICON";
_displayMarker setMarkerType "mil_flag";
_displayMarker setMarkerColor "ColorBLUFOR";

private _supply = _settings get "class1Supply";
private _fuel = _settings get "class3Supply";
private _initGarrisonCount = _settings get "garrisonCount";

private _markerText = "";
if (_class3Enabled && {_fuel <= 0}) then {
    _markerText = format ["%1 - Comms lost, no fuel for generators", _outpostName];
} else {
    _markerText = format ["%1 - Class 1: %2/%3", _outpostName, _supply, _maxClass1Supply];
    if (_class3Enabled) then {
        private _fuelPct = (_fuel / _maxClass3Supply) * 100;
        private _fuelStatus = "GREEN";
        if (_fuelPct < 35) then { _fuelStatus = "RED"; } else { if (_fuelPct < 75) then { _fuelStatus = "AMBER"; }; };
        _markerText = format ["%1 | Class 3: %2", _markerText, _fuelStatus];
    };
    if (count _garrisonClassnames > 0) then {
        _markerText = format ["%1 | Garrison: %2/%3", _markerText, _initGarrisonCount, _maxGarrison];
        if (_ammoResupplyClassname != "") then {
            _markerText = format ["%1 | Class 5: GREEN", _markerText];
        };
    };
};
_displayMarker setMarkerText _markerText;

_settings set ["displayMarker", _displayMarker];

_markerName setMarkerAlpha 0;

// ========================================
// MARKER SIDE VISIBILITY
// ========================================

if (_markerVisibleSide != "ALL") then {
    private _sideEnum = switch (_markerVisibleSide) do {
        case "WEST": { west };
        case "EAST": { east };
        case "GUER": { independent };
        default { west };
    };
    _settings set ["markerVisibleSideEnum", _sideEnum];
    _settings set ["markerVisibleSideRestricted", true];

    private _markerNameForVis = _displayMarker;
    private _visCode = compile format [
        "if (hasInterface) then { if (side player isEqualTo %1) then { '%2' setMarkerAlphaLocal 1; } else { '%2' setMarkerAlphaLocal 0; }; };",
        _markerVisibleSide,
        _markerNameForVis
    ];
    _visCode remoteExec ["call", 0, true];
} else {
    _settings set ["markerVisibleSideRestricted", false];
};

// ========================================
// QRF HELICOPTER SETUP
// ========================================

private _qrfTeamSize = parseNumber str (_logic getVariable ["qrfteamsize", 4]);
if (_qrfTeamSize < 1) then { _qrfTeamSize = 4; };

private _syncedObjects = synchronizedObjects _logic;
private _qrfHelicopters = _syncedObjects select { _x isKindOf "Helicopter" };

{
    private _helo = _x;
    _helo setVariable ["RECONDO_OUTPOST_QRF_SETTINGS", createHashMapFromArray [
        ["garrisonClassnames", _garrisonClassnames],
        ["qrfTeamSize", _qrfTeamSize],
        ["outpostName", _outpostName],
        ["debugLogging", _debugLogging]
    ], true];

    _helo setVariable ["RECONDO_OUTPOST_QRF_LOADED", false, true];

    [_helo, [
        "<t color='#00FF00'>Load QRF Team</t>",
        {
            params ["_target", "_caller", "_actionId", "_args"];
            [_target] remoteExec ["Recondo_fnc_outpostQRFLoad", 2];
        },
        nil,
        6,
        false,
        true,
        "",
        "alive _target && {_this in [driver _target, _target turretUnit [0]]} && {!(_target getVariable ['RECONDO_OUTPOST_QRF_LOADED', false])}"
    ]] remoteExec ["addAction", 0, true];

    [_helo, [
        "<t color='#FF8C00'>Dismount QRF Team</t>",
        {
            params ["_target", "_caller", "_actionId", "_args"];
            [_target] remoteExec ["Recondo_fnc_outpostQRFDismount", 2];
        },
        nil,
        6,
        false,
        true,
        "",
        "alive _target && {_this in [driver _target, _target turretUnit [0]]} && {_target getVariable ['RECONDO_OUTPOST_QRF_LOADED', false]}"
    ]] remoteExec ["addAction", 0, true];

    if (_debugLogging) then {
        diag_log format ["[RECONDO_OUTPOST] '%1' QRF helicopter '%2' (%3) configured. Team size: %4",
            _outpostName, _helo, typeOf _helo, _qrfTeamSize];
    };
} forEach _qrfHelicopters;

if (count _qrfHelicopters > 0) then {
    diag_log format ["[RECONDO_OUTPOST] '%1' QRF enabled on %2 helicopter(s). Team size: %3",
        _outpostName, count _qrfHelicopters, _qrfTeamSize];
};

// ========================================
// START SUPPLY LOOP
// ========================================

[_settings] spawn Recondo_fnc_outpostSupplyLoop;

// ========================================
// LOG
// ========================================

diag_log format ["[RECONDO_OUTPOST] '%1' initialized at %2, Radius: %3m, Class 1: %4/%5, Drain: %6 every %7s, Persistence: %8, Marker Side: %9",
    _outpostName, _markerPos, _outpostRadius, _supply, _maxClass1Supply, _drainAmount, _drainInterval, _enablePersistence, _markerVisibleSide];

if (_class3Enabled) then {
    diag_log format ["[RECONDO_OUTPOST] '%1' Class 3 (Fuel) enabled. Object: %2, Resupply: +%3, Max: %4, Drain: %5 every %6s, Current: %7",
        _outpostName, _class3Classname, _class3Resupply, _maxClass3Supply, _class3DrainAmount, _class3DrainInterval, _fuel];
};

if (count _garrisonClassnames > 0) then {
    diag_log format ["[RECONDO_OUTPOST] '%1' Garrison enabled. Max: %2, Classnames: %3", _outpostName, _maxGarrison, _garrisonClassnames];
    if (_ammoResupplyClassname != "") then {
        diag_log format ["[RECONDO_OUTPOST] '%1' Ammo Resupply enabled. Crate: %2, Interval: %3s", _outpostName, _ammoResupplyClassname, _ammoResupplyInterval];
    };
};

if (_debugLogging) then {
    diag_log "[RECONDO_OUTPOST] === Outpost System Settings ===";
    diag_log format ["[RECONDO_OUTPOST] Instance ID: %1", _instanceId];
    diag_log format ["[RECONDO_OUTPOST] Marker: %1 at %2", _markerName, _markerPos];
    diag_log format ["[RECONDO_OUTPOST] Radius: %1m", _outpostRadius];
    diag_log format ["[RECONDO_OUTPOST] Class 1 Object: %1 | Resupply: +%2 per object | Max: %3", _class1Classname, _class1Resupply, _maxClass1Supply];
    diag_log format ["[RECONDO_OUTPOST] Drain: %1 every %2s | Detection: every %3s", _drainAmount, _drainInterval, _detectionInterval];
    if (count _garrisonClassnames > 0) then {
        diag_log format ["[RECONDO_OUTPOST] Garrison Classnames: %1 | Max: %2", _garrisonClassnames, _maxGarrison];
        diag_log format ["[RECONDO_OUTPOST] Ammo Resupply Object: %1 | Interval: %2s", _ammoResupplyClassname, _ammoResupplyInterval];
        diag_log format ["[RECONDO_OUTPOST] Normal Skills: %1", _normalSkills];
        diag_log format ["[RECONDO_OUTPOST] Low Morale Skills: %1", _lowMoraleSkills];
    };
};
