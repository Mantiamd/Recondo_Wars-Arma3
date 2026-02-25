/*
    Recondo_fnc_initConvoyBehavior
    Initializes convoy behavior systems
    
    Description:
        Sets up path following, speed control, and driver monitoring
        for a convoy.
    
    Parameters:
        0: OBJECT - Leader vehicle
        1: ARRAY - All vehicles in convoy
        2: HASHMAP - Settings from module
        
    Returns:
        Nothing
*/

params [
    ["_leaderVeh", objNull, [objNull]],
    ["_vehicles", [], [[]]],
    ["_settings", nil, [createHashMap]]
];

if (isNull _leaderVeh || count _vehicles == 0 || isNil "_settings") exitWith {
    diag_log "[RECONDO_CONVOY] ERROR: Invalid parameters for initConvoyBehavior";
};

private _debugLogging = _settings get "debugLogging";

if (_debugLogging) then {
    diag_log format ["[RECONDO_CONVOY] Initializing behavior for convoy with %1 vehicles", count _vehicles];
};

// Initialize path array on leader
_leaderVeh setVariable ["RECONDO_CONVOY_Path", [getPosATL _leaderVeh], true];

// Start path creator for leader (records breadcrumb trail)
[_leaderVeh, _vehicles, _settings] spawn Recondo_fnc_convoyPathCreator;

// Start lead speed control (adjusts leader speed based on convoy state)
[_leaderVeh, _vehicles, _settings] spawn Recondo_fnc_convoyLeadSpeedControl;

// Start link speed control (each follower adjusts to vehicle ahead)
[_leaderVeh, _vehicles, _settings] spawn Recondo_fnc_convoyLinkSpeedControl;

// Start driver monitor for each vehicle (handles driver death)
{
    [_x, _leaderVeh, _settings] spawn Recondo_fnc_convoyDriverMonitor;
} forEach _vehicles;

if (_debugLogging) then {
    diag_log "[RECONDO_CONVOY] Convoy behavior systems initialized";
};
