/*
    Recondo_fnc_getBatteryLevel
    Get battery level for a specific radio
    
    Description:
        Returns the current battery level in seconds for a radio ID.
        If radio has no stored level, returns full capacity.
    
    Parameters:
        0: STRING - Radio ID
        
    Returns:
        NUMBER - Remaining battery in seconds
*/

params ["_radioId"];

if (isNil "RECONDO_RWR_SETTINGS") exitWith { 360 };
if (isNil "RECONDO_RWR_BATTERY_LEVELS") exitWith { 360 };

private _batteryCapacity = RECONDO_RWR_SETTINGS get "batteryCapacity";

// Return stored level or full capacity if not set
RECONDO_RWR_BATTERY_LEVELS getOrDefault [_radioId, _batteryCapacity]
