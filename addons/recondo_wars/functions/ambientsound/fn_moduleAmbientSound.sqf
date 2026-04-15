/*
    Recondo_fnc_moduleAmbientSound
    Ambient Sound Triggers Module initialization
    
    Description:
        Creates trigger areas that play 3D positioned sounds when units
        from a configured side enter the area. Simulates wildlife
        being disturbed by player/AI movement.
        
        Supports both default mod sounds and custom mission sounds.
    
    Parameters:
        _logic - OBJECT - The module logic object
        _units - ARRAY - Synced units (not used)
        _activated - BOOL - Whether the module is activated
    
    Returns:
        Nothing
    
    Example:
        Module placed in Eden Editor
*/

params [
    ["_logic", objNull, [objNull]],
    ["_units", [], [[]]],
    ["_activated", true, [true]]
];

if (!isServer) exitWith {};
if (isNull _logic) exitWith {};
if (!_activated) exitWith {};

// Read module attributes
private _markerPrefix = _logic getVariable ["markerprefix", ""];
private _triggerRadius = _logic getVariable ["triggerradius", 50];
private _triggerHeight = _logic getVariable ["triggerheight", 10];
private _triggerSide = _logic getVariable ["triggerside", "WEST"];
private _triggerTarget = _logic getVariable ["triggertarget", 0]; // 0=Players Only, 1=AI Only, 2=Both
private _cooldown = _logic getVariable ["cooldown", 60];
private _delay = _logic getVariable ["delay", 10];
private _soundMode = _logic getVariable ["soundmode", 0]; // 0=Single, 1=Pool
private _soundCategory = _logic getVariable ["soundcategory", "wildlife"];
private _singleSound = _logic getVariable ["singlesound", ""];
private _customSoundsPath = _logic getVariable ["customsoundspath", ""];
private _customSoundsList = _logic getVariable ["customsoundslist", ""];
private _soundDistance = _logic getVariable ["sounddistance", 100];
private _soundVolume = _logic getVariable ["soundvolume", 1];
private _soundOriginDistance = _logic getVariable ["soundorigindistance", 5];
private _soundOriginHeight = _logic getVariable ["soundoriginheight", 4];
private _debugLogging = _logic getVariable ["debuglogging", false];
if (RECONDO_MASTER_DEBUG) then { _debugLogging = true; };

// Validate marker prefix
if (_markerPrefix == "") exitWith {
    diag_log "[RECONDO_AMBIENT] ERROR: No marker prefix specified";
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_AMBIENT] Module initializing with prefix: %1", _markerPrefix];
};

// Build settings hashmap
private _settings = createHashMapFromArray [
    ["markerPrefix", _markerPrefix],
    ["triggerRadius", _triggerRadius],
    ["triggerHeight", _triggerHeight],
    ["triggerSide", _triggerSide],
    ["triggerTarget", _triggerTarget],
    ["cooldown", _cooldown],
    ["delay", _delay],
    ["soundMode", _soundMode],
    ["soundCategory", _soundCategory],
    ["singleSound", _singleSound],
    ["customSoundsPath", _customSoundsPath],
    ["customSoundsList", _customSoundsList],
    ["soundDistance", _soundDistance],
    ["soundVolume", _soundVolume],
    ["soundOriginDistance", _soundOriginDistance],
    ["soundOriginHeight", _soundOriginHeight],
    ["debugLogging", _debugLogging]
];

// Find all markers with the prefix
private _markers = [];
private _markerIndex = 1;

while {true} do {
    private _markerName = format ["%1%2", _markerPrefix, _markerIndex];
    
    if (getMarkerColor _markerName == "") exitWith {
        if (_debugLogging) then {
            diag_log format ["[RECONDO_AMBIENT] Found %1 markers with prefix '%2'", _markerIndex - 1, _markerPrefix];
        };
    };
    
    _markers pushBack _markerName;
    _markerIndex = _markerIndex + 1;
};

if (count _markers == 0) exitWith {
    diag_log format ["[RECONDO_AMBIENT] ERROR: No markers found with prefix '%1'", _markerPrefix];
};

// Create triggers for each marker
{
    [_x, _settings] call Recondo_fnc_createAmbientTrigger;
} forEach _markers;

if (_debugLogging) then {
    diag_log format ["[RECONDO_AMBIENT] Created %1 ambient sound triggers", count _markers];
};

// Store settings globally for reference
if (isNil "RECONDO_AMBIENT_INSTANCES") then {
    RECONDO_AMBIENT_INSTANCES = [];
};
RECONDO_AMBIENT_INSTANCES pushBack _settings;
