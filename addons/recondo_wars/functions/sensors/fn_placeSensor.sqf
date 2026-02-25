/*
    Recondo_fnc_placeSensor
    Place a sensor in the world
    
    Description:
        Called when a player places a sensor via ACE interaction.
        Handles both client-initiated (sends to server) and server-side execution.
    
    Parameters:
        _sensorType - STRING - "foot" or "vehicle"
        _pos - ARRAY - Position to place sensor
        _isServerCall - BOOL - (Internal) Whether this is a server-side call from remoteExec
    
    Returns:
        Nothing
*/

params [
    ["_sensorType", "foot", [""]],
    ["_pos", [], [[]]],
    ["_isServerCall", false, [false]]
];

private _settings = missionNamespace getVariable ["RECONDO_SENSORS_SETTINGS", nil];
if (isNil "_settings") exitWith {
    diag_log "[RECONDO_SENSORS] ERROR: Settings not found in placeSensor";
};

private _inventoryItem = if (_sensorType == "foot") then {
    _settings get "footInventoryItem"
} else {
    _settings get "vehicleInventoryItem"
};

if (!_isServerCall) then {
    private _player = player;
    if (count _pos == 0) then { _pos = getPosATL _player; };
    
    if !([_player, _inventoryItem] call BIS_fnc_hasItem) exitWith {
        hint "You don't have the required sensor item.";
    };
    
    private _sensorName = if (_sensorType == "foot") then { "Foot Sensor" } else { "Vehicle Sensor" };
    
    [
        5,
        [_sensorType, _pos, _inventoryItem],
        {
            params ["_args"];
            _args params ["_sensorType", "_pos", "_inventoryItem"];
            
            private _player = player;
            
            private _isMagazine = isClass (configFile >> "CfgMagazines" >> _inventoryItem);
            if (_isMagazine) then {
                _player removeMagazine _inventoryItem;
            } else {
                _player removeItem _inventoryItem;
            };
            
            if (!isServer) then {
                [_sensorType, _pos, true] remoteExecCall ["Recondo_fnc_placeSensor", 2];
            } else {
                [_sensorType, _pos, true] call Recondo_fnc_placeSensor;
            };
        },
        {},
        format ["Deploying %1...", _sensorName],
        {
            private _player = player;
            [_player, _inventoryItem] call BIS_fnc_hasItem
        },
        ["isnotinside", "isnotswimming"]
    ] call ace_common_fnc_progressBar;
    
    _player playMoveNow "AinvPknlMstpSnonWnonDnon_medic_1";
} else {
    if (!isServer) exitWith {
        diag_log "[RECONDO_SENSORS] ERROR: Server call received on non-server";
    };
    
    private _callerOwner = remoteExecutedOwner;
    private _player = objNull;
    
    if (_callerOwner == 0) then {
        _player = player;
    } else {
        {
            if (owner _x == _callerOwner) exitWith {
                _player = _x;
            };
        } forEach allPlayers;
    };
    
    if (isNull _player) exitWith {
        diag_log format ["[RECONDO_SENSORS] ERROR: Could not find player for owner ID %1", _callerOwner];
    };
    
    if (count _pos == 0) then { _pos = getPosATL _player; };
    
    private _worldObject = if (_sensorType == "foot") then {
        _settings get "footWorldObject"
    } else {
        _settings get "vehicleWorldObject"
    };
    
    if (_worldObject == "") exitWith {
        diag_log format ["[RECONDO_SENSORS] ERROR: Missing world object classname for %1 sensor", _sensorType];
    };
    
    private _sensor = createVehicle [_worldObject, _pos, [], 0.5, "CAN_COLLIDE"];
    
    private _currentCounter = missionNamespace getVariable ["RECONDO_SENSORS_ID_COUNTER", 0];
    if (!(_currentCounter isEqualType 0)) then {
        diag_log format ["[RECONDO_SENSORS] WARNING: ID counter was invalid type (%1), resetting to 0", typeName _currentCounter];
        _currentCounter = 0;
    };
    _currentCounter = _currentCounter + 1;
    missionNamespace setVariable ["RECONDO_SENSORS_ID_COUNTER", _currentCounter, true];
    private _sensorId = _currentCounter;
    
    private _ownerSide = side _player;
    
    _sensor setVariable ["RECONDO_SENSOR_ID", _sensorId, true];
    _sensor setVariable ["RECONDO_SENSOR_TYPE", _sensorType, true];
    _sensor setVariable ["RECONDO_SENSOR_DATA", [], true];
    _sensor setVariable ["RECONDO_SENSOR_LAST_LOG", 0, true];
    _sensor setVariable ["RECONDO_SENSOR_OWNER_SIDE", _ownerSide, true];
    
    private _grid = mapGridPosition _pos;
    _sensor setVariable ["RECONDO_SENSOR_GRID", _grid, true];
    
    [_sensor, _sensorType, _sensorId, _pos, _ownerSide] call Recondo_fnc_sensorDetectionLoop;
    
    if (_callerOwner == 0) then {
        hintSilent format ["Sensor ID_%1 deployed at grid %2", _sensorId, _grid];
    } else {
        [format ["Sensor ID_%1 deployed at grid %2", _sensorId, _grid]] remoteExec ["hintSilent", _callerOwner];
    };
    
    [[_sensor, _ownerSide], {
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
    
    private _debugLogging = _settings getOrDefault ["debugLogging", false];
    if (_debugLogging) then {
        diag_log format ["[RECONDO_SENSORS] Player %1 placed %2 sensor ID_%3 at %4", name _player, _sensorType, _sensorId, _grid];
    };
};
