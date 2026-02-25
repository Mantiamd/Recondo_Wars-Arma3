/*
    Recondo_fnc_moduleWeather
    Main initialization for Weather Control module
    
    Description:
        Sets default weather and time on mission start. Adds ACE weather 
        and time control interactions to synchronized objects for admin access.
    
    Parameters:
        _logic - Module logic object
        _units - Synchronized units (unused)
        _activated - Whether module is activated
*/

params ["_logic", "_units", "_activated"];

// Validate activation
if (!_activated) exitWith {
    diag_log "[RECONDO_WEATHER] Module not activated.";
};

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

private _defaultWeather = _logic getVariable ["defaultweather", "clear"];
private _transitionTime = _logic getVariable ["transitiontime", 30];
private _adminOnly = _logic getVariable ["adminonly", true];
private _enableTimeControl = _logic getVariable ["enabletimecontrol", true];
private _defaultTimeNum = _logic getVariable ["defaulttime", 0];
private _debugLogging = _logic getVariable ["debuglogging", false];

// Convert default time number to preset name
private _defaultTime = switch (_defaultTimeNum) do {
    case 1: { "dawn" };
    case 2: { "morning" };
    case 3: { "noon" };
    case 4: { "afternoon" };
    case 5: { "dusk" };
    case 6: { "night" };
    case 7: { "midnight" };
    default { "" }; // 0 = No Change
};

// ========================================
// STORE SETTINGS GLOBALLY
// ========================================

RECONDO_WEATHER_SETTINGS = createHashMapFromArray [
    ["defaultWeather", _defaultWeather],
    ["transitionTime", _transitionTime],
    ["adminOnly", _adminOnly],
    ["enableTimeControl", _enableTimeControl],
    ["defaultTime", _defaultTime],
    ["debugLogging", _debugLogging]
];
publicVariable "RECONDO_WEATHER_SETTINGS";

// ========================================
// SET DEFAULT WEATHER AND TIME (SERVER ONLY)
// ========================================

if (isServer) then {
    // Small delay to ensure mission is fully loaded
    [{
        params ["_weather", "_time", "_defaultTime", "_debug"];
        
        // Set default weather
        [_weather, _time] call Recondo_fnc_setWeather;
        
        if (_debug) then {
            diag_log format ["[RECONDO_WEATHER] Default weather set to: %1", _weather];
        };
        
        // Set default time (if configured)
        if (_defaultTime != "") then {
            [_defaultTime] call Recondo_fnc_setTime;
            
            if (_debug) then {
                diag_log format ["[RECONDO_WEATHER] Default time set to: %1", _defaultTime];
            };
        };
    }, [_defaultWeather, _transitionTime, _defaultTime, _debugLogging], 3] call CBA_fnc_waitAndExecute;
};

// ========================================
// ADD ACE INTERACTIONS TO SYNCED OBJECTS
// ========================================

private _syncedObjects = synchronizedObjects _logic;

if (count _syncedObjects == 0) then {
    diag_log "[RECONDO_WEATHER] No objects synced to module. Weather control interactions not added.";
} else {
    // Server broadcasts to all clients
    if (isServer) then {
        {
            private _object = _x;
            private _netId = netId _object;
            
            // Broadcast ACE action setup to all clients (with JIP)
            [_netId, _adminOnly, _enableTimeControl] remoteExec ["Recondo_fnc_addWeatherControlClient", 0, true];
            
            if (_debugLogging) then {
                diag_log format ["[RECONDO_WEATHER] Broadcasting weather control to object: %1 (netId: %2, Time: %3)", _object, _netId, _enableTimeControl];
            };
        } forEach _syncedObjects;
    };
    
    diag_log format ["[RECONDO_WEATHER] Weather control added to %1 synced objects", count _syncedObjects];
};

// ========================================
// LOG INITIALIZATION
// ========================================

diag_log format ["[RECONDO_WEATHER] Module initialized. Default Weather: %1, Default Time: %2, Transition: %3s, Admin Only: %4, Time Control: %5",
    _defaultWeather, if (_defaultTime == "") then { "No Change" } else { _defaultTime }, _transitionTime, _adminOnly, _enableTimeControl];
