/*
    Recondo_fnc_turnInSensorData
    Turn in sensor data at Intel turn-in object
    
    Description:
        Processes sensor data turn-in. Removes the sensor item,
        adds data to Intel Board, and notifies the player.
        Called from ACE action on Intel turn-in objects.
    
    Parameters:
        _player - OBJECT - The player turning in sensor data
    
    Returns:
        BOOL - True if turn-in was successful
*/

params [["_player", objNull, [objNull]]];

if (isNull _player) exitWith { false };

private _sensorData = _player getVariable ["RECONDO_SENSOR_CARRIED_DATA", []];
private _sensorId = _player getVariable ["RECONDO_SENSOR_CARRIED_ID", 0];
private _sensorType = _player getVariable ["RECONDO_SENSOR_CARRIED_TYPE", "foot"];
private _sensorGrid = _player getVariable ["RECONDO_SENSOR_CARRIED_GRID", "00000000"];

if (count _sensorData == 0) exitWith {
    ["NO SENSOR DATA", "You have no sensor data to turn in.", 2, 5, "", 3] remoteExec ["Recondo_fnc_showIntelCard", _player];
    false
};

private _settings = missionNamespace getVariable ["RECONDO_SENSORS_SETTINGS", nil];
if (isNil "_settings") exitWith { 
    diag_log "[RECONDO_SENSORS] ERROR: Settings not found in turnInSensorData";
    false 
};

private _inventoryItem = if (_sensorType == "foot") then {
    _settings get "footInventoryItem"
} else {
    _settings get "vehicleInventoryItem"
};

_player removeItem _inventoryItem;

_player setVariable ["RECONDO_SENSOR_CARRIED_DATA", nil, true];
_player setVariable ["RECONDO_SENSOR_CARRIED_ID", nil, true];
_player setVariable ["RECONDO_SENSOR_CARRIED_TYPE", nil, true];
_player setVariable ["RECONDO_SENSOR_CARRIED_GRID", nil, true];

private _objectiveName = _settings get "objectiveName";
private _debugLogging = _settings getOrDefault ["debugLogging", false];

private _formattedLog = format ["SENSOR LOG - ID_%1 (Grid: %2)<br/>", _sensorId, _sensorGrid];
_formattedLog = _formattedLog + "─────────────────────────────────────<br/>";

{
    _x params ["_timestamp", "_eventText", "_eventGrid"];
    _formattedLog = _formattedLog + format ["%1 - %2<br/>", _timestamp, _eventText];
} forEach _sensorData;

private _intelLog = missionNamespace getVariable ["RECONDO_INTEL_LOG", []];

private _dateArray = date;
private _dateString = format ["%1-%2-%3 %4:%5", 
    _dateArray select 0,
    if ((_dateArray select 1) < 10) then { format ["0%1", _dateArray select 1] } else { str (_dateArray select 1) },
    if ((_dateArray select 2) < 10) then { format ["0%1", _dateArray select 2] } else { str (_dateArray select 2) },
    if ((_dateArray select 3) < 10) then { format ["0%1", _dateArray select 3] } else { str (_dateArray select 3) },
    if ((_dateArray select 4) < 10) then { format ["0%1", _dateArray select 4] } else { str (_dateArray select 4) }
];

private _logEntry = createHashMapFromArray [
    ["timestamp", _dateString],
    ["message", format ["Sensor ID_%1 (%2) - %3 entries at grid %4", _sensorId, toUpper _sensorType, count _sensorData, _sensorGrid]],
    ["targetType", "sensor"],
    ["targetName", format ["Sensor ID_%1", _sensorId]],
    ["grid", _sensorGrid],
    ["source", "sensor"],
    ["fullLog", _formattedLog]
];

_intelLog pushBack _logEntry;
missionNamespace setVariable ["RECONDO_INTEL_LOG", _intelLog];
// Broadcast only the new entry; clients append locally via event handler
RECONDO_INTEL_LOG_LATEST = _logEntry;
publicVariable "RECONDO_INTEL_LOG_LATEST";

["SENSOR_LOG"] call Recondo_fnc_setSaveData;

private _cardTitle = "SENSOR DATA RECEIVED";
private _cardBody = format ["ID_%1 (%2 sensor) - %3 log entries<br/>Grid: %4<br/><br/>Data added to Intel Board.", 
    _sensorId, toUpper _sensorType, count _sensorData, _sensorGrid];

[_cardTitle, _cardBody, 2, 5, "", 3] remoteExec ["Recondo_fnc_showIntelCard", _player];

if (_debugLogging) then {
    diag_log format ["[RECONDO_SENSORS] Player %1 turned in %2 sensor ID_%3 with %4 entries", 
        name _player, _sensorType, _sensorId, count _sensorData];
};

true
