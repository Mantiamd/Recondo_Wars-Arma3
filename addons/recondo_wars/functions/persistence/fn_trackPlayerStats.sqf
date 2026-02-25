/*
    Recondo_fnc_trackPlayerStats
    Initialize player statistics tracking
    
    Description:
        Sets up event handlers to track player kills, deaths, and disconnects.
        Runs on server only. Stats are stored in RECONDO_PERSISTENCE_PLAYER_STATS hashmap.
    
    Parameters:
        None
        
    Returns:
        Nothing
        
    Example:
        [] call Recondo_fnc_trackPlayerStats;
*/

// Only run on server
if (!isServer) exitWith {
    diag_log "[RECONDO_PERSISTENCE] trackPlayerStats called on non-server.";
};

// Check if already tracking
if (!isNil "RECONDO_PERSISTENCE_TRACKING_ACTIVE") exitWith {
    diag_log "[RECONDO_PERSISTENCE] Player stat tracking already active.";
};

RECONDO_PERSISTENCE_TRACKING_ACTIVE = true;

private _settings = RECONDO_PERSISTENCE_SETTINGS;
private _debug = _settings get "enableDebug";
private _trackAI = _settings get "trackAIKills";
private _trackPvP = _settings get "trackPlayerKills";

// Initialize player stats hashmap if not loaded from save
if (isNil "RECONDO_PERSISTENCE_PLAYER_STATS") then {
    RECONDO_PERSISTENCE_PLAYER_STATS = createHashMap;
};
publicVariable "RECONDO_PERSISTENCE_PLAYER_STATS";

// Helper function to get or create player stats entry
RECONDO_fnc_getPlayerStats = {
    params ["_uid", ["_name", "Unknown"]];
    
    if (_uid == "") exitWith { createHashMap };
    
    private _stats = RECONDO_PERSISTENCE_PLAYER_STATS getOrDefault [_uid, createHashMap];
    
    // Initialize if new player
    if (count keys _stats == 0) then {
        _stats = createHashMapFromArray [
            ["name", _name],
            ["kills", 0],
            ["aiKills", 0],
            ["playerKills", 0],
            ["deaths", 0],
            ["disconnects", 0],
            ["firstSeen", systemTimeUTC],
            ["lastSeen", systemTimeUTC]
        ];
        RECONDO_PERSISTENCE_PLAYER_STATS set [_uid, _stats];
    } else {
        // Update name and last seen
        _stats set ["name", _name];
        _stats set ["lastSeen", systemTimeUTC];
    };
    
    _stats
};

// Track kills via MPKilled event handler
addMissionEventHandler ["EntityKilled", {
    params ["_killed", "_killer", "_instigator"];
    
    private _settings = RECONDO_PERSISTENCE_SETTINGS;
    if (isNil "_settings") exitWith {};
    
    private _trackAI = _settings get "trackAIKills";
    private _trackPvP = _settings get "trackPlayerKills";
    private _debug = _settings get "enableDebug";
    
    // Determine actual killer (instigator takes priority)
    private _actualKiller = if (!isNull _instigator) then { _instigator } else { _killer };
    
    // Skip if killer is null or same as killed (suicide)
    if (isNull _actualKiller || {_actualKiller == _killed}) exitWith {};
    
    // Only track if killer is a player
    if (!isPlayer _actualKiller) exitWith {};
    
    private _killerUID = getPlayerUID _actualKiller;
    private _killerName = name _actualKiller;
    
    if (_killerUID == "") exitWith {};
    
    // Check if killed was AI or player
    private _killedWasPlayer = isPlayer _killed;
    private _killedWasAI = _killed isKindOf "CAManBase" && {!_killedWasPlayer};
    
    // Get killer's stats
    private _killerStats = [_killerUID, _killerName] call RECONDO_fnc_getPlayerStats;
    
    // Update kill counts
    if (_killedWasAI && _trackAI) then {
        private _aiKills = _killerStats getOrDefault ["aiKills", 0];
        private _totalKills = _killerStats getOrDefault ["kills", 0];
        _killerStats set ["aiKills", _aiKills + 1];
        _killerStats set ["kills", _totalKills + 1];
        
        if (_debug) then {
            diag_log format ["[RECONDO_PERSISTENCE] %1 killed AI. Total: %2 AI kills", _killerName, _aiKills + 1];
        };
    };
    
    if (_killedWasPlayer && _trackPvP) then {
        private _pvpKills = _killerStats getOrDefault ["playerKills", 0];
        private _totalKills = _killerStats getOrDefault ["kills", 0];
        _killerStats set ["playerKills", _pvpKills + 1];
        _killerStats set ["kills", _totalKills + 1];
        
        if (_debug) then {
            diag_log format ["[RECONDO_PERSISTENCE] %1 killed player %2. Total: %3 PvP kills", _killerName, name _killed, _pvpKills + 1];
        };
    };
    
    // Track death for the killed player
    if (_killedWasPlayer) then {
        private _killedUID = getPlayerUID _killed;
        private _killedName = name _killed;
        
        if (_killedUID != "") then {
            private _killedStats = [_killedUID, _killedName] call RECONDO_fnc_getPlayerStats;
            private _deaths = _killedStats getOrDefault ["deaths", 0];
            _killedStats set ["deaths", _deaths + 1];
            
            if (_debug) then {
                diag_log format ["[RECONDO_PERSISTENCE] %1 died. Total deaths: %2", _killedName, _deaths + 1];
            };
        };
    };
    
    // Update public variable
    publicVariable "RECONDO_PERSISTENCE_PLAYER_STATS";
}];

// Track disconnects
addMissionEventHandler ["HandleDisconnect", {
    params ["_unit", "_id", "_uid", "_name"];
    
    private _settings = RECONDO_PERSISTENCE_SETTINGS;
    if (isNil "_settings") exitWith { false };
    
    private _debug = _settings get "enableDebug";
    
    if (_uid == "") exitWith { false };
    
    private _playerStats = [_uid, _name] call RECONDO_fnc_getPlayerStats;
    private _disconnects = _playerStats getOrDefault ["disconnects", 0];
    _playerStats set ["disconnects", _disconnects + 1];
    _playerStats set ["lastSeen", systemTimeUTC];
    
    if (_debug) then {
        diag_log format ["[RECONDO_PERSISTENCE] %1 disconnected. Total disconnects: %2", _name, _disconnects + 1];
    };
    
    publicVariable "RECONDO_PERSISTENCE_PLAYER_STATS";
    
    false // Don't prevent default disconnect handling
}];

// Track player connections to update firstSeen/lastSeen
addMissionEventHandler ["PlayerConnected", {
    params ["_id", "_uid", "_name", "_jip", "_owner", "_idstr"];
    
    if (_uid == "") exitWith {};
    
    private _settings = RECONDO_PERSISTENCE_SETTINGS;
    if (isNil "_settings") exitWith {};
    
    // Create or update player entry
    [_uid, _name] call RECONDO_fnc_getPlayerStats;
    
    publicVariable "RECONDO_PERSISTENCE_PLAYER_STATS";
}];

if (_debug) then {
    diag_log format ["[RECONDO_PERSISTENCE] Player stat tracking initialized. Track AI: %1, Track PvP: %2", _trackAI, _trackPvP];
};
