/*
    Recondo_fnc_recordSensorEvent
    Record a detection event on a sensor
    
    Description:
        Logs detection data to the sensor and optionally sends
        notifications to designated players.
    
    Parameters:
        _sensor - OBJECT - The sensor object
        _sensorType - STRING - "foot" or "vehicle"
        _detectedData - ANY - For foot: count of units. For vehicle: thisList array.
    
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [
    ["_sensor", objNull, [objNull]],
    ["_sensorType", "foot", [""]],
    ["_detectedData", 0, [0, []]]
];

if (isNull _sensor) exitWith {};

private _settings = missionNamespace getVariable ["RECONDO_SENSORS_SETTINGS", nil];
if (isNil "_settings") exitWith {};

private _logFrequency = _settings get "logFrequency";
private _debugLogging = _settings getOrDefault ["debugLogging", false];

private _lastLog = _sensor getVariable ["RECONDO_SENSOR_LAST_LOG", 0];
if (serverTime - _lastLog < _logFrequency) exitWith {};

private _sensorId = _sensor getVariable ["RECONDO_SENSOR_ID", 0];
private _grid = _sensor getVariable ["RECONDO_SENSOR_GRID", "00000000"];
private _sensorData = _sensor getVariable ["RECONDO_SENSOR_DATA", []];

private _timestamp = [dayTime] call BIS_fnc_timeToString;

private _eventText = "";

if (_sensorType == "foot") then {
    _eventText = "Movement detected";
} else {
    private _classification = [_detectedData] call Recondo_fnc_classifyVehicle;
    _eventText = format ["%1 detected", _classification];
};

private _logEntry = [_timestamp, _eventText, _grid];
_sensorData pushBack _logEntry;

_sensor setVariable ["RECONDO_SENSOR_DATA", _sensorData, true];
_sensor setVariable ["RECONDO_SENSOR_LAST_LOG", serverTime, true];

[_sensor, _sensorType, _eventText, _grid] call Recondo_fnc_sendSensorNotification;

[] call Recondo_fnc_saveSensors;

if (_debugLogging) then {
    diag_log format ["[RECONDO_SENSORS] ID_%1 logged: %2 at %3 (%4)", _sensorId, _eventText, _timestamp, _grid];
};
