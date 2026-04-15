/*
    Recondo_fnc_moduleHanoiHannah
    Main initialization for Hanoi Hannah Loudspeakers module

    Description:
        Spawns loudspeakers at a configurable percentage of invisible map markers.
        Speakers broadcast sound on a cooldown loop. Players can disable speakers
        via ACE interaction ("Rip Out Wires") which awards Recon Points.
        Requires the Hanoi Hannah mod (Steam Workshop #3696734884).

    Priority: 5 (feature module, depends on persistence + recon points)

    Parameters:
        _logic     - Module logic object
        _units     - Synchronized units (unused)
        _activated - Whether module is activated
*/

params ["_logic", "_units", "_activated"];

if (!isServer) exitWith {};

if (!_activated) exitWith {
    diag_log "[RECONDO_HANNAH] Module not activated.";
};

// ========================================
// CHECK DEPENDENCY
// ========================================

if !(isClass (configFile >> "CfgPatches" >> "hannah_loudspeakers")) then {
    private _msg = "[RECONDO_HANNAH] ERROR: Hanoi Hannah mod not loaded. This module requires the Hanoi Hannah Loudspeakers mod (Steam Workshop #3696734884).";
    diag_log _msg;
    _msg remoteExec ["systemChat", 0];
    // Continue anyway - the speaker classname is vanilla Arma 3, only the sound class depends on the mod
};

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

private _markerPrefix = _logic getVariable ["markerprefix", "HANNAH_"];
private _spawnPercentage = _logic getVariable ["spawnpercentage", 0.5];

private _volume = _logic getVariable ["volume", 1];
private _distance = _logic getVariable ["distance", 300];
private _cooldown = _logic getVariable ["cooldown", 120];
private _randomDelay = _logic getVariable ["randomdelay", 30];

private _useCustomSound = _logic getVariable ["usecustomsound", false];
private _customSoundPath = _logic getVariable ["customsoundpath", ""];

private _disableOriginal = _logic getVariable ["disableoriginal", true];
private _enablePersistence = _logic getVariable ["enablepersistence", false];
private _reconPointsAward = _logic getVariable ["reconpointsaward", 10];

private _debugLogging = _logic getVariable ["debuglogging", false];
if (RECONDO_MASTER_DEBUG) then { _debugLogging = true; };
private _debugMarkers = _logic getVariable ["debugmarkers", false];

// ========================================
// DISABLE ORIGINAL HANOI HANNAH
// ========================================

if (_disableOriginal) then {
    missionNamespace setVariable ["hannah_enabled", false];
    if (_debugLogging) then {
        diag_log "[RECONDO_HANNAH] Disabled original Hanoi Hannah broadcasts.";
    };
};

// ========================================
// STORE SETTINGS
// ========================================

private _instanceId = format ["hannah_%1_%2", _markerPrefix, diag_tickTime];

private _settings = createHashMapFromArray [
    ["instanceId", _instanceId],
    ["markerPrefix", _markerPrefix],
    ["spawnPercentage", _spawnPercentage],
    ["volume", _volume],
    ["distance", _distance],
    ["cooldown", _cooldown],
    ["randomDelay", _randomDelay],
    ["useCustomSound", _useCustomSound],
    ["customSoundPath", _customSoundPath],
    ["disableOriginal", _disableOriginal],
    ["enablePersistence", _enablePersistence],
    ["reconPointsAward", _reconPointsAward],
    ["debugLogging", _debugLogging],
    ["debugMarkers", _debugMarkers]
];

if (isNil "RECONDO_HANNAH_SETTINGS") then {
    RECONDO_HANNAH_SETTINGS = _settings;
};
if (isNil "RECONDO_HANNAH_SPEAKERS") then {
    RECONDO_HANNAH_SPEAKERS = [];
};
if (isNil "RECONDO_HANNAH_DISABLED") then {
    RECONDO_HANNAH_DISABLED = [];
};

// ========================================
// FIND MARKERS
// ========================================

private _prefixLength = count _markerPrefix;
private _allMarkers = allMapMarkers select {
    (_x select [0, _prefixLength]) == _markerPrefix
};

if (count _allMarkers == 0) exitWith {
    private _msg = format ["[RECONDO_HANNAH] ERROR: No markers found with prefix '%1'", _markerPrefix];
    diag_log _msg;
    _msg remoteExec ["systemChat", 0];
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_HANNAH] Found %1 markers with prefix '%2'", count _allMarkers, _markerPrefix];
};

// ========================================
// SELECT MARKERS BASED ON PERCENTAGE
// ========================================

private _numToSelect = round ((count _allMarkers) * _spawnPercentage);
_numToSelect = _numToSelect max 1;

private _selectedMarkers = [];
private _availableMarkers = +_allMarkers;

while {count _selectedMarkers < _numToSelect && count _availableMarkers > 0} do {
    private _randomMarker = selectRandom _availableMarkers;
    _availableMarkers = _availableMarkers - [_randomMarker];
    _selectedMarkers pushBack _randomMarker;
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_HANNAH] Selected %1 of %2 markers (%3%%): %4",
        count _selectedMarkers, count _allMarkers, round(_spawnPercentage * 100), _selectedMarkers];
};

// ========================================
// LOAD PERSISTENCE DATA
// ========================================

private _persistenceKey = format ["HANNAH_%1", _markerPrefix];
private _savedDisabled = [];

if (_enablePersistence && {!isNil "RECONDO_PERSISTENCE_SETTINGS"}) then {
    _savedDisabled = [_persistenceKey + "_DISABLED"] call Recondo_fnc_getSaveData;
    if (isNil "_savedDisabled") then { _savedDisabled = [] };

    {
        if (!(_x in RECONDO_HANNAH_DISABLED)) then {
            RECONDO_HANNAH_DISABLED pushBack _x;
        };
    } forEach _savedDisabled;

    if (_debugLogging) then {
        diag_log format ["[RECONDO_HANNAH] Loaded %1 disabled speakers from persistence", count _savedDisabled];
    };
};

// ========================================
// SPAWN SPEAKERS
// ========================================

{
    private _markerId = _x;

    if (_markerId in RECONDO_HANNAH_DISABLED) then {
        if (_debugLogging) then {
            diag_log format ["[RECONDO_HANNAH] Skipping disabled speaker: %1", _markerId];
        };
        continue;
    };

    private _markerPos = getMarkerPos _markerId;
    [_settings, _markerId, _markerPos] call Recondo_fnc_spawnHannahSpeaker;

    if (_debugMarkers) then {
        private _dbgMarker = createMarker [format ["RECONDO_HANNAH_DBG_%1", _markerId], _markerPos];
        _dbgMarker setMarkerType "mil_dot";
        _dbgMarker setMarkerColor "ColorBlue";
        _dbgMarker setMarkerText format ["Hannah: %1", _markerId];
    };
} forEach _selectedMarkers;

// ========================================
// SAVE INITIAL STATE
// ========================================

if (_enablePersistence && {!isNil "RECONDO_PERSISTENCE_SETTINGS"}) then {
    [_persistenceKey + "_SELECTED", _selectedMarkers] call Recondo_fnc_setSaveData;
    [_persistenceKey + "_DISABLED", RECONDO_HANNAH_DISABLED] call Recondo_fnc_setSaveData;
    saveMissionProfileNamespace;
};

// ========================================
// LOG INITIALIZATION
// ========================================

private _activeCount = count _selectedMarkers - count (_savedDisabled select { _x in _selectedMarkers });

diag_log format ["[RECONDO_HANNAH] Module initialized: %1 active speakers, %2 disabled, %3 total selected, Persistence: %4",
    _activeCount, count _savedDisabled, count _selectedMarkers, _enablePersistence];

if (_debugLogging) then {
    diag_log "[RECONDO_HANNAH] === Hanoi Hannah Settings ===";
    diag_log format ["[RECONDO_HANNAH] Volume: %1 | Distance: %2m | Cooldown: %3s", _volume, _distance, _cooldown];
    diag_log format ["[RECONDO_HANNAH] Custom Sound: %1 | Path: %2", _useCustomSound, _customSoundPath];
    diag_log format ["[RECONDO_HANNAH] Recon Points Award: %1", _reconPointsAward];
    diag_log format ["[RECONDO_HANNAH] Disable Original: %1", _disableOriginal];
};
