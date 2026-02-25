/*
    Recondo_fnc_loadSensors
    Load sensor state from persistence
    
    Description:
        Loads saved sensors and recreates them in the world.
        Called during module initialization.
    
    Parameters:
        _debugLogging - BOOL - Enable debug logging
    
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [["_debugLogging", false, [false]]];

private _saveData = ["SENSORS_DEPLOYED"] call Recondo_fnc_getSaveData;
private _idCounter = ["SENSORS_ID_COUNTER"] call Recondo_fnc_getSaveData;

if (!isNil "_idCounter" && {_idCounter isEqualType 0}) then {
    missionNamespace setVariable ["RECONDO_SENSORS_ID_COUNTER", _idCounter, true];
};

if (isNil "_saveData" || {!(_saveData isEqualType [])}) exitWith {
    if (_debugLogging) then {
        diag_log "[RECONDO_SENSORS] No saved sensor data found";
    };
};

if (count _saveData == 0) exitWith {
    if (_debugLogging) then {
        diag_log "[RECONDO_SENSORS] Saved sensor data is empty";
    };
};

private _settings = missionNamespace getVariable ["RECONDO_SENSORS_SETTINGS", nil];
if (isNil "_settings") exitWith {
    diag_log "[RECONDO_SENSORS] ERROR: Settings not found in loadSensors";
};

private _footWorldObject = _settings get "footWorldObject";
private _vehicleWorldObject = _settings get "vehicleWorldObject";
private _notificationSide = _settings get "notificationSide";

private _loadedCount = 0;

{
    _x params ["_type", "_id", "_pos", "_sideStr", "_sensorData", "_lastLog", "_grid"];
    
    private _worldObject = if (_type == "foot") then { _footWorldObject } else { _vehicleWorldObject };
    
    if (_worldObject == "") then { continue };
    
    private _sensor = createVehicle [_worldObject, _pos, [], 0, "CAN_COLLIDE"];
    
    if (isNull _sensor) then {
        diag_log format ["[RECONDO_SENSORS] ERROR: Failed to create sensor object %1 at %2", _worldObject, _pos];
        continue;
    };
    
    private _side = switch (_sideStr) do {
        case "EAST": { east };
        case "WEST": { west };
        case "GUER": { independent };
        default { west };
    };
    
    _sensor setVariable ["RECONDO_SENSOR_ID", _id, true];
    _sensor setVariable ["RECONDO_SENSOR_TYPE", _type, true];
    _sensor setVariable ["RECONDO_SENSOR_DATA", _sensorData, true];
    _sensor setVariable ["RECONDO_SENSOR_LAST_LOG", _lastLog, true];
    _sensor setVariable ["RECONDO_SENSOR_OWNER_SIDE", _side, true];
    _sensor setVariable ["RECONDO_SENSOR_GRID", _grid, true];
    
    [_sensor, _type, _id, _pos, _side, true] call Recondo_fnc_sensorDetectionLoop;
    
    [[_sensor, _side], {
        params ["_sensor", "_ownerSide"];
        
        private _pickUpAction = [
            "RECONDO_PickUpSensor",
            "<t color='#77DD77'>Pick up Sensor</t>",
            "\a3\ui_f\data\igui\cfg\simpletasks\types\interact_ca.paa",
            {
                params ["_target", "_player", "_params"];
                [_target, _player] call Recondo_fnc_pickUpSensor;
            },
            {
                params ["_target", "_player", "_params"];
                (_player distance _target < 3) && (side _player == (_target getVariable ["RECONDO_SENSOR_OWNER_SIDE", west]))
            }
        ] call ace_interact_menu_fnc_createAction;
        
        [_sensor, 0, ["ACE_MainActions"], _pickUpAction] call ace_interact_menu_fnc_addActionToObject;
    }] remoteExec ["call", 0, true];
    
    // Create map marker for loaded sensor (visible to notification side only)
    private _markerName = format ["RECONDO_SENSOR_MARKER_%1", _id];
    private _marker = createMarker [_markerName, _pos];
    _marker setMarkerType "hd_dot";
    _marker setMarkerColor "ColorGreen";
    _marker setMarkerText format ["Sensor ID_%1", _id];
    
    // Hide marker for players not on notification side (JIP compatible)
    [[_markerName, _notificationSide], {
        params ["_markerName", "_notificationSide"];
        if (side player != _notificationSide) then {
            _markerName setMarkerAlphaLocal 0;
        };
    }] remoteExec ["call", 0, true];
    
    _loadedCount = _loadedCount + 1;
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_SENSORS] Loaded %1 sensor ID_%2 at %3 with %4 log entries",
            _type, _id, _grid, count _sensorData];
    };
} forEach _saveData;

// Recalculate counts from actual deployed sensors to ensure accuracy
// This fixes any count corruption from previous buggy versions
private _footCountMap = createHashMap;
private _vehicleCountMap = createHashMap;

{
    _x params ["_sensor", "_type", "_id", "_pos", "_side"];
    private _key = format ["%1_%2", _type, str _side];
    
    if (_type == "foot") then {
        private _current = _footCountMap getOrDefault [_key, 0];
        _footCountMap set [_key, _current + 1];
    } else {
        private _current = _vehicleCountMap getOrDefault [_key, 0];
        _vehicleCountMap set [_key, _current + 1];
    };
} forEach (missionNamespace getVariable ["RECONDO_SENSORS_DEPLOYED", []]);

missionNamespace setVariable ["RECONDO_SENSORS_FOOT_COUNT", _footCountMap, true];
missionNamespace setVariable ["RECONDO_SENSORS_VEHICLE_COUNT", _vehicleCountMap, true];

if (_debugLogging) then {
    diag_log format ["[RECONDO_SENSORS] Recalculated counts from deployed sensors - Foot: %1, Vehicle: %2", _footCountMap, _vehicleCountMap];
};

diag_log format ["[RECONDO_SENSORS] Loaded %1 sensors from persistence", _loadedCount];
