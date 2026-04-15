/*
    Recondo_fnc_moduleCiviliansWorking
    Main initialization for Civilians Working Fields module
    
    Description:
        Creates a proximity trigger that spawns civilians who work in fields.
        Civilians kneel, perform working animations, then move to new spots.
        They flee in panic if gunfire is detected nearby.
    
    Parameters:
        _logic - Module logic object
        _units - Synchronized units (unused)
        _activated - Whether module is activated
*/

params ["_logic", "_units", "_activated"];

// Server-only initialization
if (!isServer) exitWith {};

// Validate activation
if (!_activated) exitWith {
    diag_log "[RECONDO_CIVWORKING] Module not activated.";
};

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

private _civilianCount = _logic getVariable ["civiliancount", 5];
private _unitClassnamesRaw = _logic getVariable ["unitclassnames", "vn_c_men_01"];
private _spawnDistance = _logic getVariable ["spawndistance", 500];
private _despawnDistance = _logic getVariable ["despawndistance", 600];
private _triggerSide = _logic getVariable ["triggerside", "WEST"];

private _workDurationMin = _logic getVariable ["workdurationmin", 15];
private _workDurationMax = _logic getVariable ["workdurationmax", 60];
private _moveDistanceMin = _logic getVariable ["movedistancemin", 5];
private _moveDistanceMax = _logic getVariable ["movedistancemax", 20];
private _animationsRaw = _logic getVariable ["animations", "AinvPknlMstpSnonWnonDnon_medic_1,AinvPknlMstpSnonWnonDnon_medic0,AinvPknlMstpSlayWnonDnon_medic,Acts_carFixingWheel"];
private _fleeOnGunfire = _logic getVariable ["fleeongunfire", true];
private _gunfireDetectRadius = _logic getVariable ["gunfiredetectradius", 100];

private _propsCount = _logic getVariable ["propscount", 4];
private _propsClassnamesRaw = _logic getVariable ["propsclassnames", "Land_WoodenCart_F,Land_Sacks_goods_F,Land_Sack_F,Land_Basket_F"];

private _debugLogging = _logic getVariable ["debuglogging", false];
if (RECONDO_MASTER_DEBUG) then { _debugLogging = true; };
private _debugMarkers = _logic getVariable ["debugmarkers", false];

// ========================================
// GET MODULE AREA
// ========================================

private _modulePos = getPos _logic;
private _moduleDir = getDir _logic;

// Get area dimensions from module (canSetArea = 1)
private _areaSize = _logic getVariable ["objectArea", [50, 50, 0, false, -1]];
_areaSize params ["_areaX", "_areaY", "_areaDir", "_isRectangle", "_areaHeight"];

// Use module direction if area direction is 0
if (_areaDir == 0) then {
    _areaDir = _moduleDir;
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_CIVWORKING] Area size: %1 x %2, Dir: %3", _areaX, _areaY, _areaDir];
};

// ========================================
// PARSE STRING INPUTS
// ========================================

private _unitClassnames = [_unitClassnamesRaw] call Recondo_fnc_parseClassnames;
private _animations = [_animationsRaw] call Recondo_fnc_parseClassnames;
private _propsClassnames = [_propsClassnamesRaw] call Recondo_fnc_parseClassnames;

// Validate classnames
if (count _unitClassnames == 0) then {
    _unitClassnames = ["C_man_1"];
    diag_log "[RECONDO_CIVWORKING] WARNING: No unit classnames specified, using default C_man_1";
};

// Validate animations
if (count _animations == 0) then {
    _animations = [
        "AinvPknlMstpSnonWnonDnon_medic_1",
        "AinvPknlMstpSnonWnonDnon_medic0",
        "AinvPknlMstpSlayWnonDnon_medic",
        "Acts_carFixingWheel"
    ];
    diag_log "[RECONDO_CIVWORKING] WARNING: No animations specified, using defaults";
};

// Validate props classnames
if (count _propsClassnames == 0 && _propsCount > 0) then {
    _propsClassnames = ["Land_WoodenCart_F", "Land_Sacks_goods_F", "Land_Sack_F", "Land_Basket_F"];
    diag_log "[RECONDO_CIVWORKING] WARNING: No props classnames specified, using defaults";
};

// ========================================
// GENERATE INSTANCE ID
// ========================================

// Initialize global tracking if needed
if (isNil "RECONDO_CIVWORKING_INSTANCES") then {
    RECONDO_CIVWORKING_INSTANCES = [];
};

private _instanceId = format ["civworking_%1", count RECONDO_CIVWORKING_INSTANCES];

// ========================================
// STORE SETTINGS
// ========================================

private _settings = createHashMapFromArray [
    ["instanceId", _instanceId],
    ["modulePos", _modulePos],
    ["areaX", _areaX],
    ["areaY", _areaY],
    ["areaDir", _areaDir],
    ["civilianCount", _civilianCount],
    ["unitClassnames", _unitClassnames],
    ["spawnDistance", _spawnDistance],
    ["despawnDistance", _despawnDistance],
    ["triggerSide", _triggerSide],
    ["workDurationMin", _workDurationMin],
    ["workDurationMax", _workDurationMax],
    ["moveDistanceMin", _moveDistanceMin],
    ["moveDistanceMax", _moveDistanceMax],
    ["animations", _animations],
    ["fleeOnGunfire", _fleeOnGunfire],
    ["gunfireDetectRadius", _gunfireDetectRadius],
    ["propsCount", _propsCount],
    ["propsClassnames", _propsClassnames],
    ["debugLogging", _debugLogging],
    ["debugMarkers", _debugMarkers]
];

RECONDO_CIVWORKING_INSTANCES pushBack _settings;

// ========================================
// CREATE DEBUG MARKERS
// ========================================

if (_debugMarkers) then {
    // Area marker
    private _areaMarker = createMarker [format ["RECONDO_CIVWORK_AREA_%1", _instanceId], _modulePos];
    _areaMarker setMarkerShape "RECTANGLE";
    _areaMarker setMarkerSize [_areaX, _areaY];
    _areaMarker setMarkerDir _areaDir;
    _areaMarker setMarkerColor "ColorGreen";
    _areaMarker setMarkerBrush "Border";
    _areaMarker setMarkerAlpha 0.5;
    
    // Center marker
    private _centerMarker = createMarker [format ["RECONDO_CIVWORK_CENTER_%1", _instanceId], _modulePos];
    _centerMarker setMarkerShape "ICON";
    _centerMarker setMarkerType "mil_dot";
    _centerMarker setMarkerColor "ColorGreen";
    _centerMarker setMarkerText format ["Field %1", _instanceId];
};

// ========================================
// CREATE PROXIMITY TRIGGER
// ========================================

[_settings] call Recondo_fnc_createFieldTrigger;

// ========================================
// LOG INITIALIZATION
// ========================================

diag_log format ["[RECONDO_CIVWORKING] '%1' initialized: %2 civilians, Area: %3x%4m, Spawn: %5m, Despawn: %6m",
    _instanceId, _civilianCount, _areaX * 2, _areaY * 2, _spawnDistance, _despawnDistance];

if (_debugLogging) then {
    diag_log "[RECONDO_CIVWORKING] === Settings ===";
    diag_log format ["[RECONDO_CIVWORKING] Position: %1", _modulePos];
    diag_log format ["[RECONDO_CIVWORKING] Unit Classnames: %1", _unitClassnames];
    diag_log format ["[RECONDO_CIVWORKING] Animations: %1", _animations];
    diag_log format ["[RECONDO_CIVWORKING] Work Duration: %1-%2s", _workDurationMin, _workDurationMax];
    diag_log format ["[RECONDO_CIVWORKING] Move Distance: %1-%2m", _moveDistanceMin, _moveDistanceMax];
    diag_log format ["[RECONDO_CIVWORKING] Flee on Gunfire: %1, Radius: %2m", _fleeOnGunfire, _gunfireDetectRadius];
};
