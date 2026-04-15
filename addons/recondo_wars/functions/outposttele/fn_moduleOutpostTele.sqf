/*
    Recondo_fnc_moduleOutpostTele
    Base to Outpost Tele Module - Server-side initialization
    
    Description:
        Reads module attributes, selects outpost markers, spawns compositions,
        and broadcasts configuration to all clients for ACE interactions.
        Supports bidirectional teleportation between base and outposts.
        Supports destroyable outposts — if a key object in the composition
        is destroyed, the outpost is permanently disabled on next mission restart.
    
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

// Destruction Settings
private _destroyableClassname = _logic getVariable ["destroyableclassname", ""];
_destroyableClassname = _destroyableClassname trim [" ", 0];

// Persistence Settings
private _enablePersistence = _logic getVariable ["enablepersistence", true];

// Debug Settings
private _debugLogging = _logic getVariable ["debuglogging", false];
if (RECONDO_MASTER_DEBUG) then { _debugLogging = true; };
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
    ["allowedSideNum", _sideNum],
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
    ["destroyableClassname", _destroyableClassname],
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
private _savedDestroyedMarkers = [];

if (_enablePersistence) then {
    _savedMarkers = [_persistenceKey + "_MARKERS"] call Recondo_fnc_getSaveData;
    _savedCompositionMap = [_persistenceKey + "_COMPOSITIONS"] call Recondo_fnc_getSaveData;
    _savedDestroyedMarkers = [_persistenceKey + "_DESTROYED"] call Recondo_fnc_getSaveData;
    
    if (isNil "_savedMarkers") then { _savedMarkers = [] };
    if (isNil "_savedCompositionMap") then { _savedCompositionMap = [] };
    if (isNil "_savedDestroyedMarkers") then { _savedDestroyedMarkers = [] };
};

private _selectedMarkers = [];
private _compositionMap = [];

if (count _savedMarkers > 0 && _enablePersistence) then {
    _selectedMarkers = _savedMarkers;
    _compositionMap = _savedCompositionMap;
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_OUTPOSTTELE] Loaded %1 saved outpost markers", count _selectedMarkers];
    };
} else {
    if (_markerMode == 0) then {
        _selectedMarkers = _markerList;
    } else {
        _selectedMarkers = [_markerPrefix, _randomCount, _debugLogging] call Recondo_fnc_selectOutpostMarkers;
    };
    
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
// FILTER OUT DESTROYED OUTPOSTS
// ========================================

private _activeMarkers = [];

if (count _savedDestroyedMarkers > 0) then {
    {
        if (_x in _savedDestroyedMarkers) then {
            if (_debugLogging) then {
                diag_log format ["[RECONDO_OUTPOSTTELE] Skipping destroyed outpost marker: %1", _x];
            };
        } else {
            _activeMarkers pushBack _x;
        };
    } forEach _selectedMarkers;
    
    diag_log format ["[RECONDO_OUTPOSTTELE] Filtered %1 destroyed outposts. %2 active remain.", count _savedDestroyedMarkers, count _activeMarkers];
} else {
    _activeMarkers = +_selectedMarkers;
};

// ========================================
// BUILD OUTPOST DATA
// ========================================

private _outpostData = [];

{
    private _markerId = _x;
    private _markerPos = getMarkerPos _markerId;
    
    if (_markerPos isEqualTo [0,0,0]) then {
        diag_log format ["[RECONDO_OUTPOSTTELE] WARNING: Invalid marker '%1' - skipping", _markerId];
        continue;
    };
    
    // Find the original index in _selectedMarkers for display name matching
    private _originalIndex = _selectedMarkers find _markerId;
    
    private _displayName = _markerId;
    if (_originalIndex >= 0 && {_originalIndex < count _displayNames} && {(_displayNames select _originalIndex) != ""}) then {
        _displayName = _displayNames select _originalIndex;
    };
    
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
        ["hasComposition", _composition != ""],
        ["destroyed", false]
    ];
    
    _outpostData pushBack _outpost;
    RECONDO_OUTPOSTTELE_OUTPOSTS pushBack _outpost;
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_OUTPOSTTELE] Registered outpost: %1 at %2", _displayName, _markerPos];
    };
} forEach _activeMarkers;

// ========================================
// REGISTER BASE OBJECTS
// ========================================

{
    private _baseData = createHashMapFromArray [
        ["instanceId", _instanceId],
        ["netId", netId _x],
        ["position", getPosATL _x]
    ];
    
    RECONDO_OUTPOSTTELE_BASE_OBJECTS pushBack _baseData;
    
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
        
        // Only spawn compositions for active (non-destroyed) markers
        if (!(_markerId in _activeMarkers)) then { continue };
        
        if (_composition != "") then {
            [_settings, _markerId, _composition] call Recondo_fnc_spawnOutpostComposition;
        };
    } forEach _compositionMap;
};

// ========================================
// CREATE DEBUG MARKERS
// ========================================

if (_debugMarkers) then {
    {
        private _markerId = _x get "markerId";
        private _displayName = _x get "displayName";
        private _pos = _x get "position";
        
        private _debugMarker = createMarker [format ["RECONDO_OUTPOST_DEBUG_%1", _markerId], _pos];
        _debugMarker setMarkerShape "ICON";
        _debugMarker setMarkerType "mil_flag";
        _debugMarker setMarkerColor "ColorBlue";
        _debugMarker setMarkerText format ["Outpost: %1", _displayName];
        
        private _radiusMarker = createMarker [format ["RECONDO_OUTPOST_RADIUS_%1", _markerId], _pos];
        _radiusMarker setMarkerShape "ELLIPSE";
        _radiusMarker setMarkerSize [_outpostRadius, _outpostRadius];
        _radiusMarker setMarkerBrush "Border";
        _radiusMarker setMarkerColor "ColorBlue";
    } forEach _outpostData;
    
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

diag_log format ["[RECONDO_OUTPOSTTELE] Initialized: %1 outposts (%2 destroyed/filtered), %3 base teleporters", 
    count _outpostData, count _savedDestroyedMarkers, count _baseObjects];

if (_debugLogging) then {
    diag_log "[RECONDO_OUTPOSTTELE] === Module Settings ===";
    diag_log format ["[RECONDO_OUTPOSTTELE] Instance ID: %1", _instanceId];
    diag_log format ["[RECONDO_OUTPOSTTELE] Allowed Side: %1", _allowedSide];
    diag_log format ["[RECONDO_OUTPOSTTELE] Marker Mode: %1", if (_markerMode == 0) then { "Specific" } else { "Random" }];
    diag_log format ["[RECONDO_OUTPOSTTELE] Selected Markers: %1", _selectedMarkers];
    diag_log format ["[RECONDO_OUTPOSTTELE] Active Markers: %1", _activeMarkers];
    diag_log format ["[RECONDO_OUTPOSTTELE] Destroyed Markers: %1", _savedDestroyedMarkers];
    diag_log format ["[RECONDO_OUTPOSTTELE] Destroyable Classname: %1", if (_destroyableClassname != "") then { _destroyableClassname } else { "NONE (destruction disabled)" }];
    diag_log format ["[RECONDO_OUTPOSTTELE] Compositions Enabled: %1", _enableCompositions];
    diag_log format ["[RECONDO_OUTPOSTTELE] Outpost Radius: %1m", _outpostRadius];
    diag_log format ["[RECONDO_OUTPOSTTELE] Cooldown: %1s", _cooldown];
};
