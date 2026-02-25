/*
    Recondo_fnc_sensorDetectionLoop
    Initialize detection for a deployed sensor (server-side)
    
    Description:
        Creates a trigger around the sensor that detects enemy units.
        Foot sensors detect infantry, vehicle sensors detect vehicles.
    
    Parameters:
        _sensor - OBJECT - The sensor object
        _sensorType - STRING - "foot" or "vehicle"
        _sensorId - NUMBER - Unique sensor ID
        _pos - ARRAY - Position of the sensor
        _ownerSide - SIDE - Side that deployed the sensor
        _isLoading - BOOL - (Optional) If true, skip count increment (loading from persistence)
    
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [
    ["_sensor", objNull, [objNull]],
    ["_sensorType", "foot", [""]],
    ["_sensorId", 0, [0]],
    ["_pos", [0,0,0], [[]]],
    ["_ownerSide", west, [west]],
    ["_isLoading", false, [false]]
];

if (isNull _sensor) exitWith {
    diag_log "[RECONDO_SENSORS] ERROR: Null sensor in sensorDetectionLoop";
};

private _settings = missionNamespace getVariable ["RECONDO_SENSORS_SETTINGS", nil];
if (isNil "_settings") exitWith {
    diag_log "[RECONDO_SENSORS] ERROR: Settings not found in sensorDetectionLoop";
};

private _detectionRadius = if (_sensorType == "foot") then {
    _settings get "footDetectionRadius"
} else {
    _settings get "vehicleDetectionRadius"
};

private _detectionSide = _settings get "detectionSide";
private _detectionInterval = _settings get "detectionInterval";
private _debugLogging = _settings getOrDefault ["debugLogging", false];
private _debugMarkers = _settings getOrDefault ["debugMarkers", false];

private _grid = mapGridPosition _pos;
_sensor setVariable ["RECONDO_SENSOR_GRID", _grid, true];

private _detectionSideStr = switch (_detectionSide) do {
    case east: { "EAST" };
    case west: { "WEST" };
    case independent: { "GUER" };
    default { "EAST" };
};

private _trigger = createTrigger ["EmptyDetector", _pos];
_trigger setTriggerArea [_detectionRadius, _detectionRadius, 0, false];
_trigger setTriggerInterval _detectionInterval;
_trigger setTriggerActivation [_detectionSideStr, "PRESENT", true];

_trigger setVariable ["RECONDO_SENSOR_OBJECT", _sensor, true];
_trigger setVariable ["RECONDO_SENSOR_TYPE", _sensorType, true];
_trigger setVariable ["RECONDO_SENSOR_ID", _sensorId, true];

_sensor setVariable ["RECONDO_SENSOR_TRIGGER", _trigger, true];

if (_sensorType == "foot") then {
    _trigger setTriggerStatements [
        "this && {vehicle _x == _x} count thisList > 0",
        "[thisTrigger getVariable 'RECONDO_SENSOR_OBJECT', 'foot', {vehicle _x == _x} count thisList] call Recondo_fnc_recordSensorEvent;",
        ""
    ];
} else {
    _trigger setTriggerStatements [
        "this && {vehicle _x != _x} count thisList > 0",
        "[thisTrigger getVariable 'RECONDO_SENSOR_OBJECT', 'vehicle', thisList] call Recondo_fnc_recordSensorEvent;",
        ""
    ];
};

private _deployed = missionNamespace getVariable ["RECONDO_SENSORS_DEPLOYED", []];
_deployed pushBack [_sensor, _sensorType, _sensorId, _pos, _ownerSide];
missionNamespace setVariable ["RECONDO_SENSORS_DEPLOYED", _deployed, true];

if (!_isLoading) then {
    [_sensorType, _ownerSide, 1] call Recondo_fnc_getSensorCount;
    [] call Recondo_fnc_saveSensors;
};

if (_debugMarkers) then {
    private _marker = createMarker [format ["RECONDO_SENSOR_%1", _sensorId], _pos];
    _marker setMarkerShape "ELLIPSE";
    _marker setMarkerSize [_detectionRadius, _detectionRadius];
    _marker setMarkerColor (if (_sensorType == "foot") then { "ColorGreen" } else { "ColorBlue" });
    _marker setMarkerAlpha 0.3;
    _marker setMarkerBrush "SolidBorder";
    
    private _iconMarker = createMarker [format ["RECONDO_SENSOR_ICON_%1", _sensorId], _pos];
    _iconMarker setMarkerType "mil_dot";
    _iconMarker setMarkerColor (if (_sensorType == "foot") then { "ColorGreen" } else { "ColorBlue" });
    _iconMarker setMarkerText format ["ID_%1 (%2)", _sensorId, toUpper _sensorType];
    
    _sensor setVariable ["RECONDO_SENSOR_MARKERS", [_marker, _iconMarker], true];
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_SENSORS] Detection initialized for %1 sensor ID_%2 at %3, radius: %4m",
        _sensorType, _sensorId, _grid, _detectionRadius];
};
