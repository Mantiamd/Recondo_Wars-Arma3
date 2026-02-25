/*
    Recondo_fnc_initSensorActions
    Initialize ACE self-interaction menu actions for sensors (client-side)
    
    Description:
        Adds ACE self-interaction actions for placing foot and vehicle sensors.
        Only adds actions if the respective sensor type is enabled.
*/

if (!hasInterface) exitWith {};

private _settings = missionNamespace getVariable ["RECONDO_SENSORS_SETTINGS", nil];
if (isNil "_settings") exitWith {
    [{!isNil {missionNamespace getVariable "RECONDO_SENSORS_SETTINGS"}}, {
        [] call Recondo_fnc_initSensorActions;
    }, []] call CBA_fnc_waitUntilAndExecute;
};

private _enableFootSensor = _settings get "enableFootSensor";
private _enableVehicleSensor = _settings get "enableVehicleSensor";
private _footInventoryItem = _settings get "footInventoryItem";
private _vehicleInventoryItem = _settings get "vehicleInventoryItem";
private _notificationSide = _settings get "notificationSide";

if (_enableFootSensor) then {
    private _footSensorAction = [
        "RECONDO_PlaceFootSensor",
        "Place Foot Sensor",
        "\a3\ui_f\data\igui\cfg\simpletasks\types\listen_ca.paa",
        {
            ["foot"] call Recondo_fnc_placeSensor;
        },
        {
            private _settings = missionNamespace getVariable ["RECONDO_SENSORS_SETTINGS", nil];
            if (isNil "_settings") exitWith { false };
            
            private _footInventoryItem = _settings get "footInventoryItem";
            private _notificationSide = _settings get "notificationSide";
            private _footMaxSensors = _settings get "footMaxSensors";
            
            private _hasItem = [player, _footInventoryItem] call BIS_fnc_hasItem;
            private _isNotInVehicle = isNull objectParent player;
            private _correctSide = side player == _notificationSide;
            private _currentCount = ["foot", _notificationSide] call Recondo_fnc_getSensorCount;
            private _underLimit = _currentCount < _footMaxSensors;
            
            _hasItem && _isNotInVehicle && _correctSide && _underLimit
        }
    ] call ace_interact_menu_fnc_createAction;
    
    ["Man", 1, ["ACE_SelfActions", "ACE_Equipment"], _footSensorAction, true] call ace_interact_menu_fnc_addActionToClass;
};

if (_enableVehicleSensor) then {
    private _vehicleSensorAction = [
        "RECONDO_PlaceVehicleSensor",
        "Place Vehicle Sensor",
        "x\zen\addons\attributes\ui\engine_on_ca.paa",
        {
            ["vehicle"] call Recondo_fnc_placeSensor;
        },
        {
            private _settings = missionNamespace getVariable ["RECONDO_SENSORS_SETTINGS", nil];
            if (isNil "_settings") exitWith { false };
            
            private _vehicleInventoryItem = _settings get "vehicleInventoryItem";
            private _notificationSide = _settings get "notificationSide";
            private _vehicleMaxSensors = _settings get "vehicleMaxSensors";
            
            private _hasItem = [player, _vehicleInventoryItem] call BIS_fnc_hasItem;
            private _isNotInVehicle = isNull objectParent player;
            private _correctSide = side player == _notificationSide;
            private _currentCount = ["vehicle", _notificationSide] call Recondo_fnc_getSensorCount;
            private _underLimit = _currentCount < _vehicleMaxSensors;
            
            _hasItem && _isNotInVehicle && _correctSide && _underLimit
        }
    ] call ace_interact_menu_fnc_createAction;
    
    ["Man", 1, ["ACE_SelfActions", "ACE_Equipment"], _vehicleSensorAction, true] call ace_interact_menu_fnc_addActionToClass;
};

private _debugLogging = _settings getOrDefault ["debugLogging", false];
if (_debugLogging) then {
    diag_log format ["[RECONDO_SENSORS] Client actions initialized - Foot: %1, Vehicle: %2", _enableFootSensor, _enableVehicleSensor];
};
