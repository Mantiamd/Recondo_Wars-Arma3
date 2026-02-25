/*
    Recondo_fnc_addWeatherControlClient
    Client-side ACE weather control action setup
    
    Description:
        Adds ACE interaction menu to the specified object
        with weather and time control options.
    
    Parameters:
        _object - OBJECT - The object to add interactions to
        _adminOnly - BOOL - Whether only admins can use weather control
        _enableTimeControl - BOOL - Whether time control is enabled
    
    Returns:
        Nothing
*/

if (!hasInterface) exitWith {};

params [
    ["_netId", "", [""]],
    ["_adminOnly", true, [false]],
    ["_enableTimeControl", true, [false]]
];

// Resolve object from netId
private _object = objectFromNetId _netId;

if (isNull _object) exitWith {
    diag_log format ["[RECONDO_WEATHER] ERROR: Could not find object from netId: %1", _netId];
};

// Check if already added
if (_object getVariable ["RECONDO_WEATHER_actionsAdded", false]) exitWith {};
_object setVariable ["RECONDO_WEATHER_actionsAdded", true];

// Admin check condition
private _adminCondition = if (_adminOnly) then {
    "admin owner player > 0"
} else {
    "true"
};

// ========================================
// CREATE MAIN WEATHER CONTROL MENU
// ========================================

private _mainAction = [
    "Recondo_WeatherControl",
    "Weather Control",
    "",
    {},
    {
        // DEBUG: Temporarily disabled admin check for testing
        true
    },
    {},
    [_adminOnly],
    [0, 0, 0],
    3
] call ace_interact_menu_fnc_createAction;

[_object, 0, ["ACE_MainActions"], _mainAction] call ace_interact_menu_fnc_addActionToObject;

// ========================================
// CREATE WEATHER PRESET ACTIONS
// ========================================

// Clear Sunny
private _clearAction = [
    "Recondo_Weather_Clear",
    "Clear Sunny",
    "",
    {
        ["clear"] remoteExec ["Recondo_fnc_setWeather", 2];
    },
    {true},
    {},
    [],
    [0, 0, 0],
    2
] call ace_interact_menu_fnc_createAction;

[_object, 0, ["ACE_MainActions", "Recondo_WeatherControl"], _clearAction] call ace_interact_menu_fnc_addActionToObject;

// Overcast
private _overcastAction = [
    "Recondo_Weather_Overcast",
    "Overcast",
    "",
    {
        ["overcast"] remoteExec ["Recondo_fnc_setWeather", 2];
    },
    {true},
    {},
    [],
    [0, 0, 0],
    2
] call ace_interact_menu_fnc_createAction;

[_object, 0, ["ACE_MainActions", "Recondo_WeatherControl"], _overcastAction] call ace_interact_menu_fnc_addActionToObject;

// Light Rain
private _lightRainAction = [
    "Recondo_Weather_LightRain",
    "Light Rain",
    "",
    {
        ["lightrain"] remoteExec ["Recondo_fnc_setWeather", 2];
    },
    {true},
    {},
    [],
    [0, 0, 0],
    2
] call ace_interact_menu_fnc_createAction;

[_object, 0, ["ACE_MainActions", "Recondo_WeatherControl"], _lightRainAction] call ace_interact_menu_fnc_addActionToObject;

// Thunderstorm
private _thunderstormAction = [
    "Recondo_Weather_Thunderstorm",
    "Thunderstorm",
    "",
    {
        ["thunderstorm"] remoteExec ["Recondo_fnc_setWeather", 2];
    },
    {true},
    {},
    [],
    [0, 0, 0],
    2
] call ace_interact_menu_fnc_createAction;

[_object, 0, ["ACE_MainActions", "Recondo_WeatherControl"], _thunderstormAction] call ace_interact_menu_fnc_addActionToObject;

// Fog
private _fogAction = [
    "Recondo_Weather_Fog",
    "Fog",
    "",
    {
        ["fog"] remoteExec ["Recondo_fnc_setWeather", 2];
    },
    {true},
    {},
    [],
    [0, 0, 0],
    2
] call ace_interact_menu_fnc_createAction;

[_object, 0, ["ACE_MainActions", "Recondo_WeatherControl"], _fogAction] call ace_interact_menu_fnc_addActionToObject;

// Dense Fog
private _denseFogAction = [
    "Recondo_Weather_DenseFog",
    "Dense Fog",
    "",
    {
        ["densefog"] remoteExec ["Recondo_fnc_setWeather", 2];
    },
    {true},
    {},
    [],
    [0, 0, 0],
    2
] call ace_interact_menu_fnc_createAction;

[_object, 0, ["ACE_MainActions", "Recondo_WeatherControl"], _denseFogAction] call ace_interact_menu_fnc_addActionToObject;

// ========================================
// CREATE TIME CONTROL SUBMENU (if enabled)
// ========================================

if (_enableTimeControl) then {
    // Time Control submenu
    private _timeAction = [
        "Recondo_TimeControl",
        "Time Control",
        "",
        {},
        {true},
        {},
        [],
        [0, 0, 0],
        2
    ] call ace_interact_menu_fnc_createAction;
    
    [_object, 0, ["ACE_MainActions", "Recondo_WeatherControl"], _timeAction] call ace_interact_menu_fnc_addActionToObject;
    
    // Dawn (05:00)
    private _dawnAction = [
        "Recondo_Time_Dawn",
        "Dawn (05:00)",
        "",
        {
            ["dawn"] remoteExec ["Recondo_fnc_setTime", 2];
        },
        {true},
        {},
        [],
        [0, 0, 0],
        2
    ] call ace_interact_menu_fnc_createAction;
    
    [_object, 0, ["ACE_MainActions", "Recondo_WeatherControl", "Recondo_TimeControl"], _dawnAction] call ace_interact_menu_fnc_addActionToObject;
    
    // Morning (08:00)
    private _morningAction = [
        "Recondo_Time_Morning",
        "Morning (08:00)",
        "",
        {
            ["morning"] remoteExec ["Recondo_fnc_setTime", 2];
        },
        {true},
        {},
        [],
        [0, 0, 0],
        2
    ] call ace_interact_menu_fnc_createAction;
    
    [_object, 0, ["ACE_MainActions", "Recondo_WeatherControl", "Recondo_TimeControl"], _morningAction] call ace_interact_menu_fnc_addActionToObject;
    
    // Noon (12:00)
    private _noonAction = [
        "Recondo_Time_Noon",
        "Noon (12:00)",
        "",
        {
            ["noon"] remoteExec ["Recondo_fnc_setTime", 2];
        },
        {true},
        {},
        [],
        [0, 0, 0],
        2
    ] call ace_interact_menu_fnc_createAction;
    
    [_object, 0, ["ACE_MainActions", "Recondo_WeatherControl", "Recondo_TimeControl"], _noonAction] call ace_interact_menu_fnc_addActionToObject;
    
    // Afternoon (15:00)
    private _afternoonAction = [
        "Recondo_Time_Afternoon",
        "Afternoon (15:00)",
        "",
        {
            ["afternoon"] remoteExec ["Recondo_fnc_setTime", 2];
        },
        {true},
        {},
        [],
        [0, 0, 0],
        2
    ] call ace_interact_menu_fnc_createAction;
    
    [_object, 0, ["ACE_MainActions", "Recondo_WeatherControl", "Recondo_TimeControl"], _afternoonAction] call ace_interact_menu_fnc_addActionToObject;
    
    // Dusk (19:00)
    private _duskAction = [
        "Recondo_Time_Dusk",
        "Dusk (19:00)",
        "",
        {
            ["dusk"] remoteExec ["Recondo_fnc_setTime", 2];
        },
        {true},
        {},
        [],
        [0, 0, 0],
        2
    ] call ace_interact_menu_fnc_createAction;
    
    [_object, 0, ["ACE_MainActions", "Recondo_WeatherControl", "Recondo_TimeControl"], _duskAction] call ace_interact_menu_fnc_addActionToObject;
    
    // Night (22:00)
    private _nightAction = [
        "Recondo_Time_Night",
        "Night (22:00)",
        "",
        {
            ["night"] remoteExec ["Recondo_fnc_setTime", 2];
        },
        {true},
        {},
        [],
        [0, 0, 0],
        2
    ] call ace_interact_menu_fnc_createAction;
    
    [_object, 0, ["ACE_MainActions", "Recondo_WeatherControl", "Recondo_TimeControl"], _nightAction] call ace_interact_menu_fnc_addActionToObject;
    
    // Midnight (00:00)
    private _midnightAction = [
        "Recondo_Time_Midnight",
        "Midnight (00:00)",
        "",
        {
            ["midnight"] remoteExec ["Recondo_fnc_setTime", 2];
        },
        {true},
        {},
        [],
        [0, 0, 0],
        2
    ] call ace_interact_menu_fnc_createAction;
    
    [_object, 0, ["ACE_MainActions", "Recondo_WeatherControl", "Recondo_TimeControl"], _midnightAction] call ace_interact_menu_fnc_addActionToObject;
};

// Debug logging
private _debugLogging = if (isNil "RECONDO_WEATHER_SETTINGS") then { false } else {
    RECONDO_WEATHER_SETTINGS getOrDefault ["debugLogging", false]
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_WEATHER] Client: Added weather control ACE actions to object: %1 (Time control: %2)", _object, _enableTimeControl];
};
