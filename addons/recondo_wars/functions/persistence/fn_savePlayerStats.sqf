/*
    Recondo_fnc_savePlayerStats
    Save player statistics to persistence storage
    
    Description:
        Saves the current RECONDO_PERSISTENCE_PLAYER_STATS hashmap
        to missionProfileNamespace.
    
    Parameters:
        None
        
    Returns:
        NUMBER - Count of players saved
        
    Example:
        private _count = [] call Recondo_fnc_savePlayerStats;
*/

// Only run on server
if (!isServer) exitWith {
    diag_log "[RECONDO_PERSISTENCE] savePlayerStats called on non-server.";
    0
};

private _settings = RECONDO_PERSISTENCE_SETTINGS;
private _debug = _settings get "enableDebug";

// Check if stats exist
if (isNil "RECONDO_PERSISTENCE_PLAYER_STATS") exitWith {
    if (_debug) then {
        diag_log "[RECONDO_PERSISTENCE] No player stats to save.";
    };
    0
};

private _playerStats = RECONDO_PERSISTENCE_PLAYER_STATS;
private _playerCount = count keys _playerStats;

// Save to persistence
["playerstats", _playerStats] call Recondo_fnc_setSaveData;

if (_debug) then {
    diag_log format ["[RECONDO_PERSISTENCE] Saved stats for %1 players", _playerCount];
    
    // Log individual player stats
    {
        private _uid = _x;
        private _stats = _playerStats get _uid;
        private _name = _stats getOrDefault ["name", "Unknown"];
        private _kills = _stats getOrDefault ["kills", 0];
        private _deaths = _stats getOrDefault ["deaths", 0];
        private _disconnects = _stats getOrDefault ["disconnects", 0];
        
        diag_log format ["[RECONDO_PERSISTENCE]   %1: K=%2 D=%3 DC=%4", _name, _kills, _deaths, _disconnects];
    } forEach keys _playerStats;
};

_playerCount
