/*
    Recondo_fnc_saveSensors
    Save sensor state to persistence
    
    Description:
        Saves all deployed sensors and their data to the persistence system.
        Called when sensors are placed, pick up, or record events.
    
    Parameters:
        _removedSensorId - NUMBER - (Optional) ID of sensor being removed (use -1 for none)
        _removedType - STRING - (Optional) Type of removed sensor
        _removedSide - SIDE - (Optional) Side of removed sensor
    
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [
    ["_removedSensorId", -1, [0]],
    ["_removedType", "", [""]],
    ["_removedSide", sideUnknown, [west]]
];

private _settings = missionNamespace getVariable ["RECONDO_SENSORS_SETTINGS", nil];
private _debugLogging = if (isNil "_settings") then { false } else {
    _settings getOrDefault ["debugLogging", false]
};

private _deployed = missionNamespace getVariable ["RECONDO_SENSORS_DEPLOYED", []];

if (_removedSensorId > 0 && _removedType != "" && _removedSide != sideUnknown) then {
    private _newDeployed = [];
    private _sensorToDelete = objNull;
    {
        _x params ["_sensor", "_type", "_id", "_pos", "_side"];
        if (_id != _removedSensorId) then {
            _newDeployed pushBack _x;
        } else {
            _sensorToDelete = _sensor;
        };
    } forEach _deployed;
    
    _deployed = _newDeployed;
    missionNamespace setVariable ["RECONDO_SENSORS_DEPLOYED", _deployed, true];
    
    if (!isNull _sensorToDelete) then {
        private _trigger = _sensorToDelete getVariable ["RECONDO_SENSOR_TRIGGER", objNull];
        if (!isNull _trigger) then {
            deleteVehicle _trigger;
        };
        deleteVehicle _sensorToDelete;
    };
    
    [_removedType, _removedSide, -1] call Recondo_fnc_getSensorCount;
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_SENSORS] Removed sensor ID_%1 from deployed list, decremented %2 count for %3", 
            _removedSensorId, _removedType, _removedSide];
    };
};

private _saveData = [];

{
    _x params ["_sensor", "_type", "_id", "_pos", "_side"];
    
    if (!isNull _sensor) then {
        private _sensorData = _sensor getVariable ["RECONDO_SENSOR_DATA", []];
        private _lastLog = _sensor getVariable ["RECONDO_SENSOR_LAST_LOG", 0];
        private _grid = _sensor getVariable ["RECONDO_SENSOR_GRID", "00000000"];
        
        _saveData pushBack [
            _type,
            _id,
            _pos,
            str _side,
            _sensorData,
            _lastLog,
            _grid
        ];
    };
} forEach _deployed;

["SENSORS_DEPLOYED", _saveData] call Recondo_fnc_setSaveData;

private _idCounter = missionNamespace getVariable ["RECONDO_SENSORS_ID_COUNTER", 0];
["SENSORS_ID_COUNTER", _idCounter] call Recondo_fnc_setSaveData;

private _footCountMap = missionNamespace getVariable ["RECONDO_SENSORS_FOOT_COUNT", createHashMap];
private _footCounts = [];
{
    _footCounts pushBack [_x, _footCountMap get _x];
} forEach (keys _footCountMap);
["SENSORS_FOOT_COUNT", _footCounts] call Recondo_fnc_setSaveData;

private _vehicleCountMap = missionNamespace getVariable ["RECONDO_SENSORS_VEHICLE_COUNT", createHashMap];
private _vehicleCounts = [];
{
    _vehicleCounts pushBack [_x, _vehicleCountMap get _x];
} forEach (keys _vehicleCountMap);
["SENSORS_VEHICLE_COUNT", _vehicleCounts] call Recondo_fnc_setSaveData;

saveMissionProfileNamespace;

if (_debugLogging) then {
    diag_log format ["[RECONDO_SENSORS] Saved %1 sensors to persistence (written to disk)", count _saveData];
};
