/*
    Recondo_fnc_saveRallypoints
    Save rally points to persistence
    
    Description:
        Saves current rally points to missionProfileNamespace for persistence
        across mission restarts. Uses the Persistence module's save system.
    
    Parameters:
        None
    
    Returns:
        Nothing
    
    Execution:
        Server only
*/

if (!isServer) exitWith {};

private _settings = RECONDO_DRP_SETTINGS;
if (isNil "_settings") exitWith {
    diag_log "[RECONDO_DRP] ERROR: Cannot save - settings not initialized!";
};

private _enablePersistence = _settings get "enablePersistence";
if (!_enablePersistence) exitWith {};

private _enableDebug = _settings get "enableDebug";

// ========================================
// PREPARE DATA FOR SAVING
// ========================================

private _rallies = missionNamespace getVariable ["RECONDO_DRP_RALLIES", []];

// Convert to saveable format (remove object references, keep only serializable data)
private _saveData = [];

{
    private _rallyData = _x;
    
    private _saveEntry = createHashMapFromArray [
        ["sideNum", _rallyData get "sideNum"],
        ["position", _rallyData get "position"],
        ["createTime", _rallyData get "createTime"],
        ["deployerUID", _rallyData get "deployerUID"],
        ["markerType", _settings get "markerType"],
        ["markerColor", _settings get "markerColor"],
        ["markerText", _settings get "markerText"]
    ];
    
    _saveData pushBack _saveEntry;
} forEach _rallies;

// ========================================
// SAVE USING PERSISTENCE SYSTEM
// ========================================

// Check if Persistence module is available
if (isNil "RECONDO_PERSISTENCE_SETTINGS") then {
    // Persistence module not placed - save directly
    private _saveTag = "RECONDO_DRP_RALLIES";
    missionProfileNamespace setVariable [_saveTag, _saveData];
    saveMissionProfileNamespace;
    
    if (_enableDebug) then {
        diag_log format ["[RECONDO_DRP] Saved %1 rally points directly (no Persistence module)", count _saveData];
    };
} else {
    // Use Persistence module's save system
    ["DRP_RALLIES", _saveData] call Recondo_fnc_setSaveData;
    
    if (_enableDebug) then {
        diag_log format ["[RECONDO_DRP] Saved %1 rally points via Persistence module", count _saveData];
    };
};
