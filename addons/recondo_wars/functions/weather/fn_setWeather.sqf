/*
    Recondo_fnc_setWeather
    Server-side weather setter
    
    Description:
        Sets the weather to the specified preset.
        Must be executed on the server.
    
    Parameters:
        _preset - STRING - Weather preset name
        _transitionTime - NUMBER - (Optional) Override transition time
    
    Presets:
        "clear" - Clear sunny skies
        "overcast" - Overcast without rain
        "lightrain" - Light rain
        "thunderstorm" - Heavy rain with lightning
        "fog" - Light fog
        "densefog" - Dense fog
    
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [
    ["_preset", "clear", [""]],
    ["_transitionTime", -1, [0]]
];

// Get transition time from settings if not overridden
if (_transitionTime < 0) then {
    _transitionTime = if (isNil "RECONDO_WEATHER_SETTINGS") then {
        30
    } else {
        RECONDO_WEATHER_SETTINGS getOrDefault ["transitionTime", 30]
    };
};

private _debugLogging = if (isNil "RECONDO_WEATHER_SETTINGS") then { false } else {
    RECONDO_WEATHER_SETTINGS getOrDefault ["debugLogging", false]
};

// ========================================
// WEATHER PRESETS
// ========================================

private _overcast = 0;
private _rain = 0;
private _lightning = 0;
private _fog = 0;

switch (toLower _preset) do {
    case "clear": {
        _overcast = 0;
        _rain = 0;
        _lightning = 0;
        _fog = 0;
    };
    
    case "overcast": {
        _overcast = 0.7;
        _rain = 0;
        _lightning = 0;
        _fog = 0;
    };
    
    case "lightrain": {
        _overcast = 0.75;
        _rain = 0.3;
        _lightning = 0;
        _fog = 0;
    };
    
    case "thunderstorm": {
        _overcast = 1;
        _rain = 1;
        _lightning = 1;
        _fog = 0;
    };
    
    case "fog": {
        _overcast = 0.3;
        _rain = 0;
        _lightning = 0;
        _fog = 0.3;
    };
    
    case "densefog": {
        _overcast = 0.5;
        _rain = 0;
        _lightning = 0;
        _fog = 0.7;
    };
    
    default {
        diag_log format ["[RECONDO_WEATHER] WARNING: Unknown weather preset '%1', defaulting to clear", _preset];
        _overcast = 0;
        _rain = 0;
        _lightning = 0;
        _fog = 0;
    };
};

// ========================================
// APPLY WEATHER
// ========================================

_transitionTime setOvercast _overcast;
_transitionTime setRain _rain;
_transitionTime setLightnings _lightning;
_transitionTime setFog [_fog, 0.01, 0];
_transitionTime setWindStr 0;
_transitionTime setWindForce 0;

// Force weather change
forceWeatherChange;

if (_debugLogging) then {
    diag_log format ["[RECONDO_WEATHER] Weather set to '%1' (overcast: %2, rain: %3, lightning: %4, fog: %5) over %6 seconds",
        _preset, _overcast, _rain, _lightning, _fog, _transitionTime];
};
