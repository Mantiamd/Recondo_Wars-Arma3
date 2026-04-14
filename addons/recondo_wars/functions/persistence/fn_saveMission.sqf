/*
    Recondo_fnc_saveMission
    Orchestrate saving all mission data
    
    Description:
        Coordinates saving of all enabled data types (markers, player stats, etc.)
        and writes to missionProfileNamespace.
        Should only be called on the server.
    
    Parameters:
        0: BOOL - Show notification to players (default: true)
        
    Returns:
        BOOL - True if save successful
        
    Example:
        [] call Recondo_fnc_saveMission;
        [false] call Recondo_fnc_saveMission; // Silent save
*/

params [["_notify", true, [true]]];

// Only run on server
if (!isServer) exitWith {
    diag_log "[RECONDO_PERSISTENCE] saveMission called on non-server.";
    false
};

// Check if persistence is initialized
if (isNil "RECONDO_PERSISTENCE_SETTINGS") exitWith {
    diag_log "[RECONDO_PERSISTENCE] saveMission: Persistence not initialized.";
    false
};

// Prevent concurrent saves
if (!isNil "RECONDO_PERSISTENCE_SAVING" && {RECONDO_PERSISTENCE_SAVING}) exitWith {
    diag_log "[RECONDO_PERSISTENCE] saveMission: Save already in progress.";
    false
};

RECONDO_PERSISTENCE_SAVING = true;

private _settings = RECONDO_PERSISTENCE_SETTINGS;
private _debug = _settings get "enableDebug";
private _startTime = diag_tickTime;

if (_debug) then {
    diag_log "[RECONDO_PERSISTENCE] Starting mission save...";
};

// Save metadata
private _metadata = createHashMapFromArray [
    ["version", "1.0.0"],
    ["saveTime", systemTimeUTC],
    ["campaignID", _settings get "campaignID"],
    ["missionName", missionName],
    ["worldName", worldName]
];
["metadata", _metadata] call Recondo_fnc_setSaveData;

// Save markers if enabled
if (_settings get "saveMarkers") then {
    [] call Recondo_fnc_saveMarkers;
};

// Save player stats if enabled
if (_settings get "savePlayerStats") then {
    [] call Recondo_fnc_savePlayerStats;
};

// Save Civilian POL data if module is active
if (!isNil "RECONDO_CIVPOL_PERSISTENCE_ENABLED" && {RECONDO_CIVPOL_PERSISTENCE_ENABLED}) then {
    [] call Recondo_fnc_saveCivilianPOL;
};

// Save Player Persistence data if module is active
if (RECONDO_PLAYER_PERSISTENCE_ENABLED) then {
    [] call Recondo_fnc_savePlayers;
};

// Save Vehicle Persistence data if module has registered vehicles
if (count RECONDO_VEHICLE_PERSISTENCE_UNITS > 0) then {
    [] call Recondo_fnc_saveVehicles;
};

// Save Inventory Persistence data if module has registered containers
if (count RECONDO_INVENTORY_PERSISTENCE_CONTAINERS > 0) then {
    [] call Recondo_fnc_saveInventories;
};

// Commit to disk
saveMissionProfileNamespace;

private _elapsed = diag_tickTime - _startTime;

// Notify players
if (_notify) then {
    "Mission data saved." remoteExec ["systemChat", 0, false];
};

// Log completion
diag_log format ["[RECONDO_PERSISTENCE] Mission saved in %1 ms.", round (_elapsed * 1000)];

RECONDO_PERSISTENCE_SAVING = false;

true
