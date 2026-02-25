/*
    Recondo_fnc_setBatteryLevel
    Set battery level for a specific radio
    
    Description:
        Sets the battery level in seconds for a radio ID.
        Server-side only, broadcasts to all clients.
    
    Parameters:
        0: STRING - Radio ID
        1: NUMBER - New battery level in seconds
        
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params ["_radioId", "_level"];

if (isNil "RECONDO_RWR_BATTERY_LEVELS") then {
    RECONDO_RWR_BATTERY_LEVELS = createHashMap;
};

// Clamp to valid range
private _batteryCapacity = RECONDO_RWR_SETTINGS getOrDefault ["batteryCapacity", 360];
_level = _level max 0 min _batteryCapacity;

// Store level
RECONDO_RWR_BATTERY_LEVELS set [_radioId, _level];

// Broadcast to all clients
publicVariable "RECONDO_RWR_BATTERY_LEVELS";

if (RECONDO_RWR_SETTINGS getOrDefault ["enableDebug", false]) then {
    diag_log format ["[RECONDO_RWR] Set battery level - Radio: %1, Level: %2s", _radioId, _level toFixed 1];
};
