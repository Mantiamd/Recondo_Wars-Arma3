/*
    Recondo_fnc_moduleVillageUprising
    Main initialization for Village Uprising module

    Description:
        Creates detection triggers at invisible map markers. When the
        configured trigger side enters the radius, civilians spawn and
        wander. When any OPFOR in the area detects the trigger side
        (knowsAbout), civilians rally, arm up, and attack.
        Each village site triggers independently.

    Priority: 5 (feature module)

    Parameters:
        _logic     - Module logic object
        _units     - Synchronized units (unused)
        _activated - Whether module is activated
*/

params ["_logic", "_units", "_activated"];

if (!isServer) exitWith {};

if (!_activated) exitWith {
    diag_log "[RECONDO_UPRISING] Module not activated.";
};

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

private _markerPrefix = _logic getVariable ["markerprefix", "UPRISING_"];
private _rallyPrefix = _logic getVariable ["rallyprefix", "RALLY_"];
private _civsPerSite = _logic getVariable ["civspersite", 5];
private _spawnRadius = _logic getVariable ["spawnradius", 50];

private _civClassnamesRaw = _logic getVariable ["civclassnames", ""];
private _civClassnames = ((_civClassnamesRaw splitString (toString [10, 13] + ",")) apply { _x trim [" ", 0] }) select { _x != "" };

if (count _civClassnames == 0) exitWith {
    private _msg = "[RECONDO_UPRISING] ERROR: No civilian classnames configured.";
    diag_log _msg;
    _msg remoteExec ["systemChat", 0];
};

private _triggerSideStr = _logic getVariable ["triggerside", "WEST"];
private _spawnDistance = _logic getVariable ["spawndistance", 300];
private _detectionRadius = _logic getVariable ["detectionradius", 200];

private _combatSideStr = _logic getVariable ["combatside", "EAST"];
private _weaponClassname = _logic getVariable ["weaponclassname", "arifle_AKS_F"];
private _magazineClassname = _logic getVariable ["magazineclassname", "30Rnd_545x39_Mag_Green_F"];
private _magazineCount = _logic getVariable ["magazinecount", 5];
private _armingDelay = _logic getVariable ["armingdelay", 3];
private _uprisingPercent = _logic getVariable ["uprisingpercent", 50];

private _debugLogging = _logic getVariable ["debuglogging", false];
if (RECONDO_MASTER_DEBUG) then { _debugLogging = true; };
private _debugMarkers = _logic getVariable ["debugmarkers", false];

// ========================================
// CONVERT SIDES
// ========================================

private _triggerSide = switch (toUpper _triggerSideStr) do {
    case "EAST": { "EAST" };
    case "WEST": { "WEST" };
    case "GUER": { "GUER" };
    case "ANY":  { "ANY" };
    default      { "WEST" };
};

private _combatSide = switch (toUpper _combatSideStr) do {
    case "EAST":  { east };
    case "WEST":  { west };
    case "GUER":  { independent };
    default       { east };
};

// ========================================
// STORE SETTINGS
// ========================================

private _instanceId = format ["uprising_%1_%2", _markerPrefix, count (missionNamespace getVariable ["RECONDO_UPRISING_INSTANCES", []])];

private _settings = createHashMapFromArray [
    ["instanceId", _instanceId],
    ["markerPrefix", _markerPrefix],
    ["rallyPrefix", _rallyPrefix],
    ["civsPerSite", _civsPerSite],
    ["spawnRadius", _spawnRadius],
    ["civClassnames", _civClassnames],
    ["triggerSide", _triggerSide],
    ["spawnDistance", _spawnDistance],
    ["detectionRadius", _detectionRadius],
    ["combatSide", _combatSide],
    ["weaponClassname", _weaponClassname],
    ["magazineClassname", _magazineClassname],
    ["magazineCount", _magazineCount],
    ["armingDelay", _armingDelay],
    ["uprisingPercent", _uprisingPercent],
    ["debugLogging", _debugLogging],
    ["debugMarkers", _debugMarkers]
];

if (isNil "RECONDO_UPRISING_INSTANCES") then {
    RECONDO_UPRISING_INSTANCES = [];
};
RECONDO_UPRISING_INSTANCES pushBack _settings;

// ========================================
// FIND MARKERS
// ========================================

private _prefixLen = count _markerPrefix;
private _allMarkers = allMapMarkers select {
    (_x select [0, _prefixLen]) == _markerPrefix
};

if (count _allMarkers == 0) exitWith {
    private _msg = format ["[RECONDO_UPRISING] ERROR: No markers found with prefix '%1'", _markerPrefix];
    diag_log _msg;
    _msg remoteExec ["systemChat", 0];
};

// ========================================
// PAIR VILLAGE AND RALLY MARKERS
// ========================================

private _sites = [];
{
    private _villageMarker = _x;
    private _numberStr = _villageMarker select [_prefixLen];
    private _rallyMarker = _rallyPrefix + _numberStr;

    if (getMarkerPos _rallyMarker isEqualTo [0,0,0]) then {
        diag_log format ["[RECONDO_UPRISING] WARNING: No rally marker '%1' for village '%2'. Civilians will arm in place.", _rallyMarker, _villageMarker];
    };

    _sites pushBack [_villageMarker, _rallyMarker];

    if (_debugLogging) then {
        diag_log format ["[RECONDO_UPRISING] Paired: %1 -> %2", _villageMarker, _rallyMarker];
    };
} forEach _allMarkers;

// ========================================
// CREATE TRIGGERS PER SITE (no civilian spawn yet)
// ========================================

{
    _x params ["_villageMarker", "_rallyMarker"];
    private _villagePos = getMarkerPos _villageMarker;

    private _trigger = createTrigger ["EmptyDetector", _villagePos, true];
    _trigger setTriggerArea [_spawnDistance, _spawnDistance, 0, false];
    _trigger setTriggerActivation [_triggerSide, "PRESENT", false];
    _trigger setTriggerStatements [
        "this",
        format [
            "[thisTrigger, thisList, ""%1"", ""%2""] call Recondo_fnc_triggerUprising;",
            _villageMarker, _rallyMarker
        ],
        ""
    ];

    _trigger setVariable ["RECONDO_UPRISING_settings", _settings];
    _trigger setVariable ["RECONDO_UPRISING_triggered", false];

    // Debug markers
    if (_debugMarkers) then {
        private _spawnDbg = createMarker [format ["RECONDO_UPRISING_SPAWN_%1", _villageMarker], _villagePos];
        _spawnDbg setMarkerShape "ELLIPSE";
        _spawnDbg setMarkerBrush "Border";
        _spawnDbg setMarkerColor "ColorGreen";
        _spawnDbg setMarkerSize [_spawnDistance, _spawnDistance];

        private _dbgMarker = createMarker [format ["RECONDO_UPRISING_DBG_%1", _villageMarker], _villagePos];
        _dbgMarker setMarkerShape "ELLIPSE";
        _dbgMarker setMarkerBrush "Border";
        _dbgMarker setMarkerColor "ColorYellow";
        _dbgMarker setMarkerSize [_detectionRadius, _detectionRadius];

        private _iconMarker = createMarker [format ["RECONDO_UPRISING_ICON_%1", _villageMarker], _villagePos];
        _iconMarker setMarkerType "mil_warning";
        _iconMarker setMarkerColor "ColorYellow";
        _iconMarker setMarkerText format ["Uprising: %1", _villageMarker];

        private _rallyPos = getMarkerPos _rallyMarker;
        if !(_rallyPos isEqualTo [0,0,0]) then {
            private _rallyDbg = createMarker [format ["RECONDO_UPRISING_RALLY_%1", _rallyMarker], _rallyPos];
            _rallyDbg setMarkerType "mil_flag";
            _rallyDbg setMarkerColor "ColorRed";
            _rallyDbg setMarkerText format ["Rally: %1", _rallyMarker];
        };
    };

    if (_debugLogging) then {
        diag_log format ["[RECONDO_UPRISING] Site %1: spawn distance %2m, detection radius %3m", _villageMarker, _spawnDistance, _detectionRadius];
    };
} forEach _sites;

// ========================================
// LOG INITIALIZATION
// ========================================

diag_log format ["[RECONDO_UPRISING] Module initialized: %1 sites, %2 civs/site, Spawn: %3m, Detection: %4 %5m",
    count _sites, _civsPerSite, _spawnDistance, _triggerSide, _detectionRadius];

if (_debugLogging) then {
    diag_log "[RECONDO_UPRISING] === Village Uprising Settings ===";
    diag_log format ["[RECONDO_UPRISING] Village Prefix: %1 | Rally Prefix: %2", _markerPrefix, _rallyPrefix];
    diag_log format ["[RECONDO_UPRISING] Classnames: %1", _civClassnames];
    diag_log format ["[RECONDO_UPRISING] Weapon: %1 | Mag: %2 x%3", _weaponClassname, _magazineClassname, _magazineCount];
    diag_log format ["[RECONDO_UPRISING] Combat Side: %1 | Arming Delay: %2s", _combatSideStr, _armingDelay];
};
