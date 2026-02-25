/*
    Recondo_fnc_getSensorCount
    Get the current count of deployed sensors for a type and side
    
    Description:
        Returns the number of sensors of a given type deployed by a side.
        Can also be called with a delta to update the count.
    
    Parameters:
        _sensorType - STRING - "foot" or "vehicle"
        _side - SIDE - The side to check
        _delta - NUMBER - (Optional) Amount to add/subtract from count
    
    Returns:
        NUMBER - Current count of deployed sensors
*/

params [
    ["_sensorType", "foot", [""]],
    ["_side", west, [west]],
    ["_delta", 0, [0]]
];

private _sideStr = str _side;
private _key = format ["%1_%2", _sensorType, _sideStr];

private _varName = if (_sensorType == "foot") then {
    "RECONDO_SENSORS_FOOT_COUNT"
} else {
    "RECONDO_SENSORS_VEHICLE_COUNT"
};

private _countMap = missionNamespace getVariable [_varName, createHashMap];

private _currentCount = _countMap getOrDefault [_key, 0];

if (_delta != 0 && isServer) then {
    _currentCount = (_currentCount + _delta) max 0;
    _countMap set [_key, _currentCount];
    missionNamespace setVariable [_varName, _countMap, true];
};

_currentCount
