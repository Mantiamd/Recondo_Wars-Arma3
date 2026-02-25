/*
    Recondo_fnc_sendSensorNotification
    Send Intel Card notification to designated players
    
    Description:
        Sends an Intel Card popup to players matching the notification
        classnames when a sensor detects activity.
    
    Parameters:
        _sensor - OBJECT - The sensor object
        _sensorType - STRING - "foot" or "vehicle"
        _eventText - STRING - Description of the event
        _grid - STRING - 8-digit grid reference
    
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [
    ["_sensor", objNull, [objNull]],
    ["_sensorType", "foot", [""]],
    ["_eventText", "", [""]],
    ["_grid", "00000000", [""]]
];

private _settings = missionNamespace getVariable ["RECONDO_SENSORS_SETTINGS", nil];
if (isNil "_settings") exitWith {};

private _notificationFrequency = _settings get "notificationFrequency";

private _lastNotification = missionNamespace getVariable ["RECONDO_SENSORS_LAST_NOTIFICATION", 0];

if (serverTime - _lastNotification < _notificationFrequency) exitWith {};

missionNamespace setVariable ["RECONDO_SENSORS_LAST_NOTIFICATION", serverTime];

private _notificationSide = _settings get "notificationSide";
private _notificationClassnames = _settings get "notificationClassnames";
private _debugLogging = _settings getOrDefault ["debugLogging", false];

private _sensorId = _sensor getVariable ["RECONDO_SENSOR_ID", 0];

private _recipients = [];

{
    if (side _x == _notificationSide && isPlayer _x) then {
        if (count _notificationClassnames == 0) then {
            _recipients pushBack _x;
        } else {
            private _unitClassname = typeOf _x;
            if (_unitClassname in _notificationClassnames) then {
                _recipients pushBack _x;
            };
        };
    };
} forEach allPlayers;

if (count _recipients == 0) exitWith {
    if (_debugLogging) then {
        diag_log format ["[RECONDO_SENSORS] No notification recipients found for side %1", _notificationSide];
    };
};

private _title = "SENSOR ALERT";
private _body = format ["%1 at grid %2", _eventText, _grid];

{
    ["SENSOR ALERT", _body, 2, 5, "", 3] remoteExec ["Recondo_fnc_showIntelCard", _x];
} forEach _recipients;

if (_debugLogging) then {
    diag_log format ["[RECONDO_SENSORS] Sent notification to %1 players: %2", count _recipients, _body];
};
