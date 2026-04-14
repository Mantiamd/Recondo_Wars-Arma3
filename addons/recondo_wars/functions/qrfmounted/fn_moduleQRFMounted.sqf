/*
    Recondo_fnc_moduleQRFMounted
    Main initialization for QRF Mounted module

    Description:
        When the QRF Side detects the Target Side (knowsAbout threshold),
        spawns a vehicle-mounted QRF group at the nearest road ~1000m away.
        Vehicles move towards the detected target. Cargo passengers dismount
        at a configurable distance and engage on foot while drivers/gunners
        remain mounted. One-time trigger per module instance.

    Priority: 5 (Feature module)

    Parameters:
        _logic - Module logic object
        _units - Synchronized units (unused)
        _activated - Whether module is activated
*/

params ["_logic", "_units", "_activated"];

if (!isServer) exitWith {};

if (!_activated) exitWith {
    diag_log "[RECONDO_QRF] Module not activated.";
};

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

private _qrfSideNum = _logic getVariable ["qrfside", 0];
private _targetSideNum = _logic getVariable ["targetside", 1];
private _detectionThreshold = _logic getVariable ["detectionthreshold", 1.5];
private _triggerRadius = _logic getVariable ["triggerradius", 500];
private _heightLimit = _logic getVariable ["heightlimit", 20];

private _vehicleClassnamesRaw = _logic getVariable ["vehicleclassnames", ""];
private _unitClassnamesRaw = _logic getVariable ["unitclassnames", ""];
private _crewClassnameRaw = _logic getVariable ["crewclassname", ""];
private _fillCargo = _logic getVariable ["fillcargo", true];
private _minVehicles = _logic getVariable ["minvehicles", 1];
private _maxVehicles = _logic getVariable ["maxvehicles", 2];

private _spawnDistance = _logic getVariable ["spawndistance", 1000];
private _safetyDistance = _logic getVariable ["safetydistance", 300];
private _dismountDistance = _logic getVariable ["dismountdistance", 200];

private _debugMarkers = _logic getVariable ["debugmarkers", false];
private _debugLogging = _logic getVariable ["debuglogging", false];

// ========================================
// PARSE AND VALIDATE
// ========================================

private _vehicleClassnames = [_vehicleClassnamesRaw] call Recondo_fnc_parseClassnames;
private _unitClassnames = [_unitClassnamesRaw] call Recondo_fnc_parseClassnames;
private _crewClassname = [_crewClassnameRaw] call Recondo_fnc_parseClassnames;

if (count _vehicleClassnames == 0) exitWith {
    diag_log "[RECONDO_QRF] ERROR: No vehicle classnames specified. Module disabled.";
};

if (count _unitClassnames == 0) exitWith {
    diag_log "[RECONDO_QRF] ERROR: No unit classnames specified. Module disabled.";
};

_minVehicles = _minVehicles max 1;
_maxVehicles = _maxVehicles max _minVehicles;

private _qrfSide = switch (_qrfSideNum) do {
    case 0: { east };
    case 1: { west };
    case 2: { independent };
    default { east };
};

private _targetSide = switch (_targetSideNum) do {
    case 0: { east };
    case 1: { west };
    case 2: { independent };
    default { west };
};

private _moduleId = format ["QRF_%1_%2", getPos _logic, diag_tickTime];

// ========================================
// STORE SETTINGS
// ========================================

private _moduleSettings = createHashMapFromArray [
    ["moduleId", _moduleId],
    ["modulePos", getPos _logic],
    ["qrfSide", _qrfSide],
    ["targetSide", _targetSide],
    ["detectionThreshold", _detectionThreshold],
    ["triggerRadius", _triggerRadius],
    ["heightLimit", _heightLimit],
    ["vehicleClassnames", _vehicleClassnames],
    ["unitClassnames", _unitClassnames],
    ["crewClassname", _crewClassname],
    ["fillCargo", _fillCargo],
    ["minVehicles", _minVehicles],
    ["maxVehicles", _maxVehicles],
    ["spawnDistance", _spawnDistance],
    ["safetyDistance", _safetyDistance],
    ["dismountDistance", _dismountDistance],
    ["debugMarkers", _debugMarkers],
    ["debugLogging", _debugLogging],
    ["triggered", false]
];

RECONDO_QRF_INSTANCES pushBack _moduleSettings;

// ========================================
// START DETECTION LOOP
// ========================================

[_moduleSettings] call Recondo_fnc_qrfDetectionLoop;

// ========================================
// LOG
// ========================================

if (_debugLogging) then {
    diag_log format ["[RECONDO_QRF] Module %1 settings:", _moduleId];
    diag_log format ["[RECONDO_QRF]   QRF side: %1, Target side: %2", _qrfSide, _targetSide];
    diag_log format ["[RECONDO_QRF]   Trigger radius: %1m, Detection threshold: %2", _triggerRadius, _detectionThreshold];
    diag_log format ["[RECONDO_QRF]   Spawn distance: %1m, Safety: %2m, Dismount: %3m", _spawnDistance, _safetyDistance, _dismountDistance];
    diag_log format ["[RECONDO_QRF]   Vehicle pool: %1, Count: %2-%3, Units: %4", _vehicleClassnames, _minVehicles, _maxVehicles, _unitClassnames];
};

diag_log format ["[RECONDO_QRF] Module initialized at %1. Trigger radius: %2m", getPos _logic, _triggerRadius];
