/*
    Recondo_fnc_pickUpSensor
    Pick up a deployed sensor
    
    Description:
        Returns the sensor to the player's inventory.
        Data stays on the sensor (must turn in to read).
    
    Parameters:
        _sensor - OBJECT - The sensor object
        _player - OBJECT - The player picking it up
    
    Returns:
        Nothing
*/

params [
    ["_sensor", objNull, [objNull]],
    ["_player", objNull, [objNull]]
];

if (isNull _sensor || isNull _player) exitWith {
    diag_log "[RECONDO_SENSORS] ERROR: Null sensor or player in pickUpSensor";
};

private _sensorType = _sensor getVariable ["RECONDO_SENSOR_TYPE", "foot"];
private _sensorId = _sensor getVariable ["RECONDO_SENSOR_ID", 0];
private _sensorData = _sensor getVariable ["RECONDO_SENSOR_DATA", []];
private _ownerSide = _sensor getVariable ["RECONDO_SENSOR_OWNER_SIDE", west];
private _sensorGrid = _sensor getVariable ["RECONDO_SENSOR_GRID", "00000000"];

if (side _player != _ownerSide) exitWith {
    hint "This sensor belongs to another side.";
};

private _settings = missionNamespace getVariable ["RECONDO_SENSORS_SETTINGS", nil];
if (isNil "_settings") exitWith {
    diag_log "[RECONDO_SENSORS] ERROR: Settings not found in pickUpSensor";
};

private _inventoryItem = if (_sensorType == "foot") then {
    _settings get "footInventoryItem"
} else {
    _settings get "vehicleInventoryItem"
};

private _isMagazine = isClass (configFile >> "CfgMagazines" >> _inventoryItem);

if !(_player canAdd _inventoryItem) exitWith {
    hint "Not enough space in inventory!";
};

private _sensorName = if (_sensorType == "foot") then { "Foot Sensor" } else { "Vehicle Sensor" };
private _debugLogging = _settings getOrDefault ["debugLogging", false];

[
    5,
    [_sensor, _sensorType, _sensorId, _sensorData, _ownerSide, _sensorGrid, _inventoryItem, _isMagazine, _debugLogging],
    {
        params ["_args"];
        _args params ["_sensor", "_sensorType", "_sensorId", "_sensorData", "_ownerSide", "_sensorGrid", "_inventoryItem", "_isMagazine", "_debugLogging"];
        
        private _player = player;
        
        if (_isMagazine) then {
            _player addMagazine _inventoryItem;
        } else {
            _player addItem _inventoryItem;
        };
        
        if (count _sensorData > 0) then {
            _player setVariable ["RECONDO_SENSOR_CARRIED_DATA", _sensorData, true];
            _player setVariable ["RECONDO_SENSOR_CARRIED_ID", _sensorId, true];
            _player setVariable ["RECONDO_SENSOR_CARRIED_TYPE", _sensorType, true];
            _player setVariable ["RECONDO_SENSOR_CARRIED_GRID", _sensorGrid, true];
            
            hint format ["Sensor ID_%1 retrieved with %2 log entries.\nTurn in at base to submit data.", _sensorId, count _sensorData];
        } else {
            hint format ["Sensor ID_%1 retrieved (no data logged).", _sensorId];
        };
        
        [_sensorId, _sensorType, _ownerSide] remoteExec ["Recondo_fnc_saveSensors", 2];
        
        if (_debugLogging) then {
            diag_log format ["[RECONDO_SENSORS] Player %1 picked up %2 sensor ID_%3 with %4 log entries", 
                name _player, _sensorType, _sensorId, count _sensorData];
        };
    },
    {},
    format ["Retrieving %1...", _sensorName],
    {
        params ["_args"];
        _args params ["_sensor"];
        private _player = player;
        (!isNull _sensor) && (_player distance _sensor < 3) && (_player canAdd (_args select 6))
    },
    ["isnotinside", "isnotswimming"]
] call ace_common_fnc_progressBar;

_player playMoveNow "AinvPknlMstpSnonWnonDnon_medic_1";
