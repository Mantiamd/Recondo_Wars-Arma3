/*
    Recondo_fnc_rpGetPlayerData
    Get or create player data for Recon Points system
    
    Description:
        Retrieves player data from the global hashmap. If the player
        doesn't exist yet, creates a new entry with default values.
        Should be called on server only.
    
    Parameters:
        _uid - STRING - Player UID
    
    Returns:
        HASHMAP - Player data with keys: points, totalEarned, unlocks, lastSeen
    
    Example:
        private _data = [getPlayerUID player] call Recondo_fnc_rpGetPlayerData;
*/

params [["_uid", "", [""]]];

// Validate UID
if (_uid == "") exitWith {
    diag_log "[RECONDO_RP] ERROR: rpGetPlayerData called with empty UID";
    createHashMap
};

// Ensure player data hashmap exists
if (isNil "RECONDO_RP_PLAYER_DATA") then {
    RECONDO_RP_PLAYER_DATA = createHashMap;
};

// Get existing data or create new
private _playerData = RECONDO_RP_PLAYER_DATA getOrDefault [_uid, nil];

if (isNil "_playerData") then {
    // Create new player entry
    _playerData = createHashMapFromArray [
        ["points", 0],
        ["totalEarned", 0],
        ["unlocks", []],
        ["lastSeen", systemTimeUTC]
    ];
    
    RECONDO_RP_PLAYER_DATA set [_uid, _playerData];
    
    private _debug = if (isNil "RECONDO_RP_SETTINGS") then { false } else { RECONDO_RP_SETTINGS getOrDefault ["debugLogging", false] };
    if (_debug) then {
        diag_log format ["[RECONDO_RP] Created new player data for UID: %1", _uid];
    };
} else {
    // Update last seen
    _playerData set ["lastSeen", systemTimeUTC];
};

_playerData
