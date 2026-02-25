/*
    Recondo_fnc_moduleOutpostTele
    Base to Outpost Tele Module - Server-side initialization
    
    Description:
        Reads module attributes, selects outpost markers, spawns compositions,
        and broadcasts configuration to all clients for ACE interactions.
        Supports bidirectional teleportation between base and outposts.
    
    Parameters:
        0: OBJECT - Logic module
        1: ARRAY - Synchronized units/objects (base teleporter objects)
        2: BOOL - Module activated
    
    Returns:
        Nothing
*/

params [["_logic", objNull, [objNull]], ["_units", [], [[]]], ["_activated", true, [true]]];

// Only run on server
if (!isServer) exitWith {};

// Check if module is activated
if (!_activated) exitWith {
    diag_log "[RECONDO_OUTPOSTTELE] Module placed but not activated.";
};

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

// General Settings
private _sideNum = _logic getVariable ["allowedside", 1];
private _actionText = _logic getVariable ["actiontext", "Deploy to %1"];
private _returnText = _logic getVariable ["returntext", "Return to Base"];
private _cooldown = _logic getVariable ["cooldown", 0];

// Outpost Settings
private _markerMode = _logic getVariable ["markermode", 0];
private _markerListRaw = _logic getVariable ["markerlist", ""];
private _markerPrefix = _logic getVariable ["markerprefix", "Outpost_"];
private _randomCount = _logic getVariable ["randomcount", 3];
private _displayNamesRaw = _logic getVariable ["displaynames", ""];
private _outpostRadius = _logic getVariable ["outpostradius", 25];

// Composition Settings
private _enableCompositions = _logic getVariable ["enablecompositions", false];
private _compositionPath = _logic getVariable ["compositionpath", "compositions"];
private _compositionListRaw = _logic getVariable ["compositionlist", ""];
private _useModCompositions = _logic getVariable ["usemodcompositions", false];
private _clearRadius = _logic getVariable ["clearradius", 15];

// Persistence Settings
private _enablePersistence = _logic getVariable ["enablepersistence", true];

// Debug Settings
private _debugLogging = _logic getVariable ["debuglogging", false];
private _debugMarkers = _logic getVariable ["debugmarkers", false];

// ========================================
// PARSE CONFIGURATIONS
// ========================================

// Convert side number to side
private _allowedSide = switch (_sideNum) do {
    case 0: { east };
    case 1: { west };
    case 2: { independent };
    case 3: { civilian };
    case 4: { nil };  // Any side
    default { west };
};

// Parse marker list (comma and newline separated)
private _markerList = ((_markerListRaw splitString (toString [10, 13] + ",")) apply { _x trim [" ", 0] }) select { _x != "" && !(_x select [0, 2] == "//") };

// Parse display names
private _displayNames = ((_displayNamesRaw splitString (toString [10, 13] + ",")) apply { _x trim [" ", 0] }) select { _x != "" && !(_x select [0, 2] == "//") };

// Parse composition list
private _compositionList = ((_compositionListRaw splitString (toString [10, 13] + ",")) apply { _x trim [" ", 0] }) select { _x != "" && !(_x select [0, 2] == "//") };

// ========================================
// GENERATE UNIQUE INSTANCE ID
// ========================================

private _instanceId = format ["outposttele_%1", count RECONDO_OUTPOSTTELE_INSTANCES];

// ========================================
// FIND SYNCED BASE TELEPORTER OBJECTS
// ========================================

private _syncedObjects = synchronizedObjects _logic;
private _baseObjects = _syncedObjects select { !(_x isKindOf "Logic") };

if (count _baseObjects == 0) exitWith {
    diag_log format ["[RECONDO_OUTPOSTTELE] ERROR: No objects synced to module! Sync at least one object to act as base teleporter."];
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_OUTPOSTTELE] Found %1 synced base teleporter objects", count _baseObjects];
};

// ========================================
// STORE SETTINGS
// ========================================

private _settings = createHashMapFromArray [
    ["instanceId", _instanceId],
    ["allowedSideNum", _sideNum],  // Store number for serialization (SIDE types don't survive publicVariable)
    ["actionText", _actionText],
    ["returnText", _returnText],
    ["cooldown", _cooldown],
    ["markerMode", _markerMode],
    ["markerPrefix", _markerPrefix],
    ["randomCount", _randomCount],
    ["displayNames", _displayNames],
    ["outpostRadius", _outpostRadius],
    ["enableCompositions", _enableCompositions],
    ["compositionPath", _compositionPath],
    ["compositionList", _compositionList],
    ["useModCompositions", _useModCompositions],
    ["clearRadius", _clearRadius],
    ["enablePersistence", _enablePersistence],
    ["debugLogging", _debugLogging],
    ["debugMarkers", _debugMarkers],
    ["baseObjects", _baseObjects]
];

RECONDO_OUTPOSTTELE_INSTANCES pushBack _settings;

// ========================================
// LOAD PERSISTENCE OR SELECT MARKERS
// ========================================

private _persistenceKey = format ["OUTPOSTTELE_%1", _instanceId];
private _savedMarkers = [];
private _savedCompositionMap = [];

if (_enablePersistence) then {
    _savedMarkers = [_persistenceKey + "_MARKERS"] call Recondo_fnc_getSaveData;
    _savedCompositionMap = [_persistenceKey + "_COMPOSITIONS"] call Recondo_fnc_getSaveData;
    
    if (isNil "_savedMarkers") then { _savedMarkers = [] };
    if (isNil "_savedCompositionMap") then { _savedCompositionMap = [] };
};

private _selectedMarkers = [];
private _compositionMap = [];  // [[markerId, compositionName], ...]

if (count _savedMarkers > 0 && _enablePersistence) then {
    // Use saved state
    _selectedMarkers = _savedMarkers;
    _compositionMap = _savedCompositionMap;
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_OUTPOSTTELE] Loaded %1 saved outpost markers", count _selectedMarkers];
    };
} else {
    // Fresh selection
    if (_markerMode == 0) then {
        // Specific markers mode
        _selectedMarkers = _markerList;
    } else {
        // Random selection mode
        _selectedMarkers = [_markerPrefix, _randomCount, _debugLogging] call Recondo_fnc_selectOutpostMarkers;
    };
    
    // Assign compositions to markers
    if (_enableCompositions && count _compositionList > 0) then {
        {
            private _composition = "";
            if (_forEachIndex < count _compositionList) then {
                _composition = _compositionList select _forEachIndex;
            } else {
                _composition = selectRandom _compositionList;
            };
            _compositionMap pushBack [_x, _composition];
        } forEach _selectedMarkers;
    };
    
    // Save to persistence
    if (_enablePersistence) then {
        [_persistenceKey + "_MARKERS", _selectedMarkers] call Recondo_fnc_setSaveData;
        [_persistenceKey + "_COMPOSITIONS", _compositionMap] call Recondo_fnc_setSaveData;
        saveMissionProfileNamespace;
        
        if (_debugLogging) then {
            diag_log format ["[RECONDO_OUTPOSTTELE] Saved %1 outpost markers to persistence", count _selectedMarkers];
        };
    };
};

// ========================================
// BUILD OUTPOST DATA
// ========================================

private _outpostData = [];

{
    private _markerId = _x;
    private _markerPos = getMarkerPos _markerId;
    
    // Skip invalid markers
    if (_markerPos isEqualTo [0,0,0]) then {
        diag_log format ["[RECONDO_OUTPOSTTELE] WARNING: Invalid marker '%1' - skipping", _markerId];
        continue;
    };
    
    // Get display name (use custom name or marker name)
    private _displayName = _markerId;
    if (_forEachIndex < count _displayNames && {(_displayNames select _forEachIndex) != ""}) then {
        _displayName = _displayNames select _forEachIndex;
    };
    
    // Find composition for this marker
    private _composition = "";
    {
        if ((_x select 0) == _markerId) exitWith {
            _composition = _x select 1;
        };
    } forEach _compositionMap;
    
    private _outpost = createHashMapFromArray [
        ["instanceId", _instanceId],
        ["markerId", _markerId],
        ["displayName", _displayName],
        ["position", _markerPos],
        ["composition", _composition],
        ["hasComposition", _composition != ""]
    ];
    
    _outpostData pushBack _outpost;
    RECONDO_OUTPOSTTELE_OUTPOSTS pushBack _outpost;
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_OUTPOSTTELE] Registered outpost: %1 at %2", _displayName, _markerPos];
    };
} forEach _selectedMarkers;

// ========================================
// REGISTER BASE OBJECTS
// ========================================

{
    private _baseData = createHashMapFromArray [
        ["instanceId", _instanceId],
        ["netId", netId _x],  // Store netId instead of object reference
        ["position", getPosATL _x]
    ];
    
    RECONDO_OUTPOSTTELE_BASE_OBJECTS pushBack _baseData;
    
    // Store instance ID on object for client reference
    _x setVariable ["RECONDO_OUTPOSTTELE_INSTANCE", _instanceId, true];
    _x setVariable ["RECONDO_OUTPOSTTELE_SETTINGS", _settings, true];
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_OUTPOSTTELE] Registered base teleporter: %1 at %2 (netId: %3)", typeOf _x, getPosATL _x, netId _x];
    };
} forEach _baseObjects;

// ========================================
// SPAWN COMPOSITIONS
// ========================================

if (_enableCompositions && count _compositionMap > 0) then {
    {
        _x params ["_markerId", "_composition"];
        
        if (_composition != "") then {
            [_settings, _markerId, _composition] call Recondo_fnc_spawnOutpostComposition;
        };
    } forEach _compositionMap;
};

// ========================================
// CREATE DEBUG MARKERS
// ========================================

if (_debugMarkers) then {
    // Mark outposts
    {
        private _markerId = _x get "markerId";
        private _displayName = _x get "displayName";
        private _pos = _x get "position";
        
        private _debugMarker = createMarker [format ["RECONDO_OUTPOST_DEBUG_%1", _markerId], _pos];
        _debugMarker setMarkerShape "ICON";
        _debugMarker setMarkerType "mil_flag";
        _debugMarker setMarkerColor "ColorBlue";
        _debugMarker setMarkerText format ["Outpost: %1", _displayName];
        
        // Draw radius
        private _radiusMarker = createMarker [format ["RECONDO_OUTPOST_RADIUS_%1", _markerId], _pos];
        _radiusMarker setMarkerShape "ELLIPSE";
        _radiusMarker setMarkerSize [_outpostRadius, _outpostRadius];
        _radiusMarker setMarkerBrush "Border";
        _radiusMarker setMarkerColor "ColorBlue";
    } forEach _outpostData;
    
    // Mark base teleporters
    {
        private _pos = getPosATL _x;
        private _debugMarker = createMarker [format ["RECONDO_BASE_DEBUG_%1", _forEachIndex], _pos];
        _debugMarker setMarkerShape "ICON";
        _debugMarker setMarkerType "mil_start";
        _debugMarker setMarkerColor "ColorGreen";
        _debugMarker setMarkerText "Base Teleporter";
    } forEach _baseObjects;
};

// ========================================
// BROADCAST TO CLIENTS
// ========================================

publicVariable "RECONDO_OUTPOSTTELE_INSTANCES";
publicVariable "RECONDO_OUTPOSTTELE_OUTPOSTS";
publicVariable "RECONDO_OUTPOSTTELE_BASE_OBJECTS";

// ========================================
// LOG INITIALIZATION
// ========================================

diag_log format ["[RECONDO_OUTPOSTTELE] Initialized: %1 outposts, %2 base teleporters", count _outpostData, count _baseObjects];

if (_debugLogging) then {
    diag_log "[RECONDO_OUTPOSTTELE] === Module Settings ===";
    diag_log format ["[RECONDO_OUTPOSTTELE] Instance ID: %1", _instanceId];
    diag_log format ["[RECONDO_OUTPOSTTELE] Allowed Side: %1", _allowedSide];
    diag_log format ["[RECONDO_OUTPOSTTELE] Marker Mode: %1", if (_markerMode == 0) then { "Specific" } else { "Random" }];
    diag_log format ["[RECONDO_OUTPOSTTELE] Selected Markers: %1", _selectedMarkers];
    diag_log format ["[RECONDO_OUTPOSTTELE] Compositions Enabled: %1", _enableCompositions];
    diag_log format ["[RECONDO_OUTPOSTTELE] Outpost Radius: %1m", _outpostRadius];
    diag_log format ["[RECONDO_OUTPOSTTELE] Cooldown: %1s", _cooldown];
};
