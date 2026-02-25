/*
    Recondo_fnc_rpLoadData
    Load Recon Points data from persistence
    
    Description:
        Loads all saved player RP data using the Persistence module.
        Called during module initialization.
        Server-only function.
    
    Parameters:
        None
    
    Returns:
        Nothing (sets RECONDO_RP_PLAYER_DATA global)
    
    Example:
        [] call Recondo_fnc_rpLoadData;
*/

// Server only
if (!isServer) exitWith {};

// Ensure persistence system exists
if (isNil "Recondo_fnc_getSaveData") exitWith {
    diag_log "[RECONDO_RP] WARNING: Persistence system not available, starting with fresh RP data.";
};

// Load from persistence
private _saveArray = ["reconpoints_data", []] call Recondo_fnc_getSaveData;

// If no saved data, exit
if (count _saveArray == 0) exitWith {
    diag_log "[RECONDO_RP] No saved RP data found, starting fresh.";
};

// Initialize hashmap
RECONDO_RP_PLAYER_DATA = createHashMap;

{
    _x params ["_uid", "_points", "_totalEarned", "_unlocks"];
    
    private _playerData = createHashMapFromArray [
        ["points", _points],
        ["totalEarned", _totalEarned],
        ["unlocks", _unlocks],
        ["lastSeen", systemTimeUTC]
    ];
    
    RECONDO_RP_PLAYER_DATA set [_uid, _playerData];
    
} forEach _saveArray;

private _debug = if (isNil "RECONDO_RP_SETTINGS") then { false } else { RECONDO_RP_SETTINGS getOrDefault ["debugLogging", false] };
if (_debug) then {
    diag_log format ["[RECONDO_RP] Loaded RP data for %1 players", count _saveArray];
};
