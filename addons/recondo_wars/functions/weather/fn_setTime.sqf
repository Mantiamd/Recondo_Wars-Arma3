/*
    Recondo_fnc_setTime
    Server-side time setter
    
    Description:
        Sets the time of day based on a preset name.
        Runs on server only.
    
    Parameters:
        _preset - STRING - Time preset name (dawn, morning, noon, afternoon, dusk, night, midnight)
    
    Returns:
        Nothing
    
    Example:
        ["noon"] call Recondo_fnc_setTime;
*/

if (!isServer) exitWith {};

params [["_preset", "", [""]]];

// Get target hour based on preset
private _targetHour = switch (toLower _preset) do {
    case "dawn": { 5 };
    case "morning": { 8 };
    case "noon": { 12 };
    case "afternoon": { 15 };
    case "dusk": { 19 };
    case "night": { 22 };
    case "midnight": { 0 };
    default { -1 };
};

if (_targetHour == -1) exitWith {
    diag_log format ["[RECONDO_WEATHER] ERROR: Unknown time preset: %1", _preset];
};

// Get current date and set new hour
private _date = date;
_date set [3, _targetHour];
_date set [4, 0]; // Reset minutes to 0

// Apply the time change
setDate _date;

// Debug logging
private _debugLogging = if (isNil "RECONDO_WEATHER_SETTINGS") then { false } else {
    RECONDO_WEATHER_SETTINGS getOrDefault ["debugLogging", false]
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_WEATHER] Time set to %1 (%2:00)", _preset, _targetHour];
};
