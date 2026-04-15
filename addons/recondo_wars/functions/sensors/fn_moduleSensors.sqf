/*
    Recondo_fnc_moduleSensors
    Main initialization for Sensors module
    
    Description:
        Enables deployable reconnaissance sensors for monitoring enemy movement.
        Players can place foot traffic and vehicle sensors that detect and log
        enemy activity. Data persists across sessions and can be turned in at
        Intel objects for Intel Board display.
    
    Parameters:
        _logic - Module logic object
        _units - Synchronized units (unused)
        _activated - Whether module is activated
*/

params ["_logic", "_units", "_activated"];

if (!isServer) exitWith {};

if (!_activated) exitWith {
    diag_log "[RECONDO_SENSORS] Module not activated.";
};

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

private _objectiveName = _logic getVariable ["objectivename", "Sensor Network"];

private _enableFootSensor = _logic getVariable ["enablefootsensor", true];
private _footInventoryItem = _logic getVariable ["footinventoryitem", "colsog_inv_sensor"];
private _footWorldObject = _logic getVariable ["footworldobject", "colsog_thing_sensor"];
private _footDetectionRadius = _logic getVariable ["footdetectionradius", 50];
private _footMaxSensors = _logic getVariable ["footmaxsensors", 5];

private _enableVehicleSensor = _logic getVariable ["enablevehiclesensor", true];
private _vehicleInventoryItem = _logic getVariable ["vehicleinventoryitem", "colsog_inv_handsid_sensor"];
private _vehicleWorldObject = _logic getVariable ["vehicleworldobject", "colsog_thing_handsid_sensor"];
private _vehicleDetectionRadius = _logic getVariable ["vehicledetectionradius", 100];
private _vehicleMaxSensors = _logic getVariable ["vehiclemaxsensors", 5];

private _detectionSideNum = _logic getVariable ["detectionside", 0];
private _detectionInterval = _logic getVariable ["detectioninterval", 5];
private _logFrequency = _logic getVariable ["logfrequency", 30];

private _notificationSideNum = _logic getVariable ["notificationside", 1];
private _notificationClassnamesRaw = _logic getVariable ["notificationclassnames", ""];
private _notificationFrequency = _logic getVariable ["notificationfrequency", 30];

private _debugLogging = _logic getVariable ["debuglogging", false];
if (RECONDO_MASTER_DEBUG) then { _debugLogging = true; };
private _debugMarkers = _logic getVariable ["debugmarkers", false];

// ========================================
// VALIDATE SETTINGS
// ========================================

if (_enableFootSensor && (_footInventoryItem == "" || _footWorldObject == "")) then {
    diag_log "[RECONDO_SENSORS] WARNING: Foot sensor enabled but inventory item or world object classname is empty.";
    _enableFootSensor = false;
};

if (_enableVehicleSensor && (_vehicleInventoryItem == "" || _vehicleWorldObject == "")) then {
    diag_log "[RECONDO_SENSORS] WARNING: Vehicle sensor enabled but inventory item or world object classname is empty.";
    _enableVehicleSensor = false;
};

if (!_enableFootSensor && !_enableVehicleSensor) exitWith {
    diag_log "[RECONDO_SENSORS] ERROR: No sensors enabled or configured. Module will not function.";
};

// ========================================
// PARSE CONFIGURATIONS
// ========================================

private _notificationClassnames = if (_notificationClassnamesRaw != "") then {
    [_notificationClassnamesRaw] call Recondo_fnc_parseClassnames
} else { [] };

private _detectionSide = switch (_detectionSideNum) do {
    case 0: { east };
    case 1: { west };
    case 2: { independent };
    default { east };
};

private _notificationSide = switch (_notificationSideNum) do {
    case 0: { east };
    case 1: { west };
    case 2: { independent };
    default { west };
};

// ========================================
// INITIALIZE GLOBAL VARIABLES
// ========================================

if (isNil {missionNamespace getVariable "RECONDO_SENSORS_DEPLOYED"}) then {
    missionNamespace setVariable ["RECONDO_SENSORS_DEPLOYED", [], true];
};

if (isNil {missionNamespace getVariable "RECONDO_SENSORS_FOOT_COUNT"}) then {
    missionNamespace setVariable ["RECONDO_SENSORS_FOOT_COUNT", createHashMap, true];
};

if (isNil {missionNamespace getVariable "RECONDO_SENSORS_VEHICLE_COUNT"}) then {
    missionNamespace setVariable ["RECONDO_SENSORS_VEHICLE_COUNT", createHashMap, true];
};

private _existingCounter = missionNamespace getVariable ["RECONDO_SENSORS_ID_COUNTER", nil];
if (isNil "_existingCounter" || {!(_existingCounter isEqualType 0)}) then {
    missionNamespace setVariable ["RECONDO_SENSORS_ID_COUNTER", 0, true];
};

if (isNil {missionNamespace getVariable "RECONDO_SENSORS_LAST_NOTIFICATION"}) then {
    missionNamespace setVariable ["RECONDO_SENSORS_LAST_NOTIFICATION", 0];
};

// ========================================
// STORE SETTINGS
// ========================================

private _settingsMap = createHashMapFromArray [
    ["objectiveName", _objectiveName],
    ["enableFootSensor", _enableFootSensor],
    ["footInventoryItem", _footInventoryItem],
    ["footWorldObject", _footWorldObject],
    ["footDetectionRadius", _footDetectionRadius],
    ["footMaxSensors", _footMaxSensors],
    ["enableVehicleSensor", _enableVehicleSensor],
    ["vehicleInventoryItem", _vehicleInventoryItem],
    ["vehicleWorldObject", _vehicleWorldObject],
    ["vehicleDetectionRadius", _vehicleDetectionRadius],
    ["vehicleMaxSensors", _vehicleMaxSensors],
    ["detectionSide", _detectionSide],
    ["detectionInterval", _detectionInterval],
    ["logFrequency", _logFrequency],
    ["notificationSide", _notificationSide],
    ["notificationClassnames", _notificationClassnames],
    ["notificationFrequency", _notificationFrequency],
    ["debugLogging", _debugLogging],
    ["debugMarkers", _debugMarkers]
];
missionNamespace setVariable ["RECONDO_SENSORS_SETTINGS", _settingsMap, true];

// ========================================
// LOAD PERSISTENCE DATA
// ========================================

[_debugLogging] call Recondo_fnc_loadSensors;

// ========================================
// INITIALIZE CLIENT ACTIONS
// ========================================

[] remoteExec ["Recondo_fnc_initSensorActions", 0, true];

// ========================================
// CHECK SYNC TO INTEL MODULE
// ========================================

private _linkedToIntel = false;
{
    if (typeOf _x == "Recondo_Module_Intel") exitWith {
        _linkedToIntel = true;
    };
} forEach (synchronizedObjects _logic);

if (!_linkedToIntel) then {
    diag_log "[RECONDO_SENSORS] WARNING: Not synced to Intel module. Turn-in feature will not work.";
};

_settingsMap set ["linkedToIntel", _linkedToIntel];
missionNamespace setVariable ["RECONDO_SENSORS_SETTINGS", _settingsMap, true];

// ========================================
// LOG INITIALIZATION
// ========================================

diag_log format ["[RECONDO_SENSORS] Module initialized - Foot: %1, Vehicle: %2, Detection: %3, Notify: %4",
    _enableFootSensor, _enableVehicleSensor, _detectionSide, _notificationSide];

if (_debugLogging) then {
    diag_log "[RECONDO_SENSORS] === Sensors Module Settings ===";
    diag_log format ["[RECONDO_SENSORS] Intel Board Category: %1", _objectiveName];
    diag_log format ["[RECONDO_SENSORS] Foot Sensor - Item: %1, Object: %2, Radius: %3m, Max: %4",
        _footInventoryItem, _footWorldObject, _footDetectionRadius, _footMaxSensors];
    diag_log format ["[RECONDO_SENSORS] Vehicle Sensor - Item: %1, Object: %2, Radius: %3m, Max: %4",
        _vehicleInventoryItem, _vehicleWorldObject, _vehicleDetectionRadius, _vehicleMaxSensors];
    diag_log format ["[RECONDO_SENSORS] Detection Side: %1, Interval: %2s, Log Freq: %3s",
        _detectionSide, _detectionInterval, _logFrequency];
    diag_log format ["[RECONDO_SENSORS] Notification Side: %1, Classnames: %2, Freq: %3s",
        _notificationSide, _notificationClassnames, _notificationFrequency];
    diag_log format ["[RECONDO_SENSORS] Linked to Intel: %1", _linkedToIntel];
};
