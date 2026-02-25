/*
    Recondo_fnc_loadPlayerStats
    Load player statistics from persistence storage
    
    Description:
        Retrieves saved player statistics from missionProfileNamespace
        and restores them to RECONDO_PERSISTENCE_PLAYER_STATS.
    
    Parameters:
        None
        
    Returns:
        NUMBER - Count of players loaded
        
    Example:
        private _count = [] call Recondo_fnc_loadPlayerStats;
*/

// Only run on server
if (!isServer) exitWith {
    diag_log "[RECONDO_PERSISTENCE] loadPlayerStats called on non-server.";
    0
};

private _settings = RECONDO_PERSISTENCE_SETTINGS;
private _debug = _settings get "enableDebug";

// Get saved player stats
private _savedStats = ["playerstats", createHashMap] call Recondo_fnc_getSaveData;

// Check if we got valid data
if (_savedStats isEqualType []) then {
    // Convert old array format to hashmap if necessary
    _savedStats = createHashMap;
};

private _playerCount = count keys _savedStats;

if (_playerCount == 0) then {
    if (_debug) then {
        diag_log "[RECONDO_PERSISTENCE] No player stats to load. Starting fresh.";
    };
    
    // Initialize empty hashmap
    RECONDO_PERSISTENCE_PLAYER_STATS = createHashMap;
} else {
    // Restore stats
    RECONDO_PERSISTENCE_PLAYER_STATS = _savedStats;
    
    if (_debug) then {
        diag_log format ["[RECONDO_PERSISTENCE] Loaded stats for %1 players", _playerCount];
        
        // Log individual player stats
        {
            private _uid = _x;
            private _stats = _savedStats get _uid;
            private _name = _stats getOrDefault ["name", "Unknown"];
            private _kills = _stats getOrDefault ["kills", 0];
            private _deaths = _stats getOrDefault ["deaths", 0];
            private _disconnects = _stats getOrDefault ["disconnects", 0];
            
            diag_log format ["[RECONDO_PERSISTENCE]   %1: K=%2 D=%3 DC=%4", _name, _kills, _deaths, _disconnects];
        } forEach keys _savedStats;
    };
};

// Broadcast to all clients
publicVariable "RECONDO_PERSISTENCE_PLAYER_STATS";

_playerCount
