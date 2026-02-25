/*
    Recondo_fnc_spawnFieldCivilians
    Spawns civilians within the field area
    
    Description:
        Creates civilians at random positions within the defined area.
        Starts their working behavior loop.
    
    Parameters:
        _trigger - OBJECT - The spawn trigger
        _settings - HASHMAP - Module settings
    
    Returns:
        Nothing
*/

params [
    ["_trigger", objNull, [objNull]],
    ["_settings", createHashMap, [createHashMap]]
];

if (isNull _trigger) exitWith {};

private _instanceId = _settings get "instanceId";
private _modulePos = _settings get "modulePos";
private _areaX = _settings get "areaX";
private _areaY = _settings get "areaY";
private _areaDir = _settings get "areaDir";
private _civilianCount = _settings get "civilianCount";
private _unitClassnames = _settings get "unitClassnames";
private _propsCount = _settings get "propsCount";
private _propsClassnames = _settings get "propsClassnames";
private _debugLogging = _settings get "debugLogging";
private _debugMarkers = _settings get "debugMarkers";

private _civilians = [];
private _behaviorHandles = [];

// Create civilian group
private _group = createGroup [civilian, true];

// Function to get random position within rotated rectangle
private _fnc_getRandomPosInArea = {
    params ["_center", "_sizeX", "_sizeY", "_dir"];
    
    // Random offset within rectangle (before rotation)
    private _offsetX = -_sizeX + random (_sizeX * 2);
    private _offsetY = -_sizeY + random (_sizeY * 2);
    
    // Rotate offset by area direction
    private _dirRad = _dir * (pi / 180);
    private _rotatedX = _offsetX * cos(_dirRad) - _offsetY * sin(_dirRad);
    private _rotatedY = _offsetX * sin(_dirRad) + _offsetY * cos(_dirRad);
    
    // Final position
    [(_center select 0) + _rotatedX, (_center select 1) + _rotatedY, 0]
};

// Spawn civilians
for "_i" from 1 to _civilianCount do {
    // Random classname
    private _classname = selectRandom _unitClassnames;
    
    // Random position in area
    private _spawnPos = [_modulePos, _areaX, _areaY, _areaDir] call _fnc_getRandomPosInArea;
    
    // Find safe position on ground
    private _safePos = _spawnPos findEmptyPosition [0, 10, "C_man_1"];
    if (count _safePos == 0) then { _safePos = _spawnPos };
    
    // Create civilian
    private _civilian = _group createUnit [_classname, _safePos, [], 0, "NONE"];
    
    if (isNull _civilian) then {
        if (_debugLogging) then {
            diag_log format ["[RECONDO_CIVWORKING] %1: Failed to spawn civilian %2 (%3)", _instanceId, _i, _classname];
        };
        continue;
    };
    
    // Configure civilian
    _civilian setVariable ["RECONDO_CIVWORKING_InstanceId", _instanceId];
    _civilian setVariable ["RECONDO_CIVWORKING_Settings", _settings];
    _civilian setVariable ["RECONDO_CIVWORKING_Fleeing", false];
    
    // Disable combat AI
    _civilian disableAI "AUTOTARGET";
    _civilian disableAI "TARGET";
    _civilian disableAI "AUTOCOMBAT";
    _civilian disableAI "SUPPRESSION";
    
    // Remove weapons
    removeAllWeapons _civilian;
    
    // Set civilian behavior
    _civilian setBehaviour "CARELESS";
    _civilian setSpeedMode "LIMITED";
    _civilian setCombatMode "BLUE";
    
    // Note: Dynamic simulation will be registered after all civilians are spawned
    
    // Create debug marker
    if (_debugMarkers) then {
        private _marker = createMarker [format ["RECONDO_CIVWORK_UNIT_%1_%2", _instanceId, _i], getPos _civilian];
        _marker setMarkerShape "ICON";
        _marker setMarkerType "mil_dot";
        _marker setMarkerColor "ColorYellow";
        _marker setMarkerText format ["Civ %1", _i];
        
        // Update marker position in a loop
        [_civilian, _marker] spawn {
            params ["_civ", "_mkr"];
            while {alive _civ && {markerColor _mkr != ""}} do {
                _mkr setMarkerPos (getPos _civ);
                sleep 2;
            };
            deleteMarker _mkr;
        };
    };
    
    _civilians pushBack _civilian;
    
    // Start behavior loop
    private _handle = [_civilian, _settings] spawn Recondo_fnc_civilianFieldBehavior;
    _behaviorHandles pushBack _handle;
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_CIVWORKING] %1: Spawned civilian %2 (%3) at %4", _instanceId, _i, _classname, _safePos];
    };
};

// ========================================
// SPAWN PROPS IN WORK AREA
// ========================================

private _spawnedProps = [];

if (_propsCount > 0 && count _propsClassnames > 0) then {
    for "_i" from 1 to _propsCount do {
        // Random classname
        private _propClass = selectRandom _propsClassnames;
        
        // Random position in area (reuse the same function used for civilians)
        private _propPos = [_modulePos, _areaX, _areaY, _areaDir] call _fnc_getRandomPosInArea;
        
        // Random direction
        private _propDir = random 360;
        
        // Create as simple object for better performance
        private _prop = createSimpleObject [_propClass, [0,0,0], true];
        _prop setDir _propDir;
        _prop setPosATL _propPos;
        
        _spawnedProps pushBack _prop;
        
        if (_debugLogging) then {
            diag_log format ["[RECONDO_CIVWORKING] %1: Spawned prop %2 (%3) at %4", _instanceId, _i, _propClass, _propPos];
        };
    };
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_CIVWORKING] %1: Spawned %2 props", _instanceId, count _spawnedProps];
    };
};

// Store civilians and props on trigger
_trigger setVariable ["RECONDO_CIVWORKING_Civilians", _civilians];
_trigger setVariable ["RECONDO_CIVWORKING_BehaviorHandles", _behaviorHandles];
_trigger setVariable ["RECONDO_CIVWORKING_Props", _spawnedProps];

if (_debugLogging) then {
    diag_log format ["[RECONDO_CIVWORKING] %1: Spawned %2 civilians, %3 props", _instanceId, count _civilians, count _spawnedProps];
};
