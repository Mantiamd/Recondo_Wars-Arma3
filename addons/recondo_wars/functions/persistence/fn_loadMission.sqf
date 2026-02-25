/*
    Recondo_fnc_loadMission
    Orchestrate loading all mission data
    
    Description:
        Coordinates loading of all enabled data types (markers, player stats, etc.)
        from missionProfileNamespace.
        Should only be called on the server.
    
    Parameters:
        None
        
    Returns:
        BOOL - True if load successful, false if no save data found
        
    Example:
        [] call Recondo_fnc_loadMission;
*/

// Only run on server
if (!isServer) exitWith {
    diag_log "[RECONDO_PERSISTENCE] loadMission called on non-server.";
    false
};

// Check if persistence is initialized
if (isNil "RECONDO_PERSISTENCE_SETTINGS") exitWith {
    diag_log "[RECONDO_PERSISTENCE] loadMission: Persistence not initialized.";
    false
};

private _settings = RECONDO_PERSISTENCE_SETTINGS;
private _debug = _settings get "enableDebug";
private _startTime = diag_tickTime;

if (_debug) then {
    diag_log "[RECONDO_PERSISTENCE] Starting mission load...";
};

// Check for existing save data
private _metadata = ["metadata", createHashMap] call Recondo_fnc_getSaveData;

if (count keys _metadata == 0) exitWith {
    diag_log "[RECONDO_PERSISTENCE] No existing save data found. Starting fresh.";
    
    // Initialize empty player stats hashmap
    if (_settings get "savePlayerStats") then {
        RECONDO_PERSISTENCE_PLAYER_STATS = createHashMap;
        publicVariable "RECONDO_PERSISTENCE_PLAYER_STATS";
    };
    
    false
};

// Log save info
private _saveTime = _metadata getOrDefault ["saveTime", []];
private _savedCampaign = _metadata getOrDefault ["campaignID", "unknown"];
private _savedVersion = _metadata getOrDefault ["version", "unknown"];

diag_log format ["[RECONDO_PERSISTENCE] Loading save: Campaign=%1, Version=%2", _savedCampaign, _savedVersion];

if (count _saveTime > 0) then {
    diag_log format ["[RECONDO_PERSISTENCE] Save date: %1-%2-%3 %4:%5:%6 UTC", 
        _saveTime select 0, _saveTime select 1, _saveTime select 2,
        _saveTime select 3, _saveTime select 4, _saveTime select 5];
};

// Load markers if enabled
if (_settings get "saveMarkers") then {
    [] call Recondo_fnc_loadMarkers;
};

// Load player stats if enabled
if (_settings get "savePlayerStats") then {
    [] call Recondo_fnc_loadPlayerStats;
};

private _elapsed = diag_tickTime - _startTime;

// Log completion
diag_log format ["[RECONDO_PERSISTENCE] Mission loaded in %1 ms.", round (_elapsed * 1000)];

// Notify players
"Mission data loaded from save." remoteExec ["systemChat", 0, false];

true
