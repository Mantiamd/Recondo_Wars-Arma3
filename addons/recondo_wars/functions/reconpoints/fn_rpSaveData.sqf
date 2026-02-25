/*
    Recondo_fnc_rpSaveData
    Save Recon Points data to persistence
    
    Description:
        Saves all player RP data using the Persistence module.
        Called automatically when player data changes.
        Server-only function.
    
    Parameters:
        None
    
    Returns:
        Nothing
    
    Example:
        [] call Recondo_fnc_rpSaveData;
*/

// Server only
if (!isServer) exitWith {};

// Ensure persistence system exists
if (isNil "Recondo_fnc_setSaveData") exitWith {
    diag_log "[RECONDO_RP] WARNING: Persistence system not available, RP data not saved.";
};

// Ensure we have data to save
if (isNil "RECONDO_RP_PLAYER_DATA") exitWith {};

// Convert hashmap to array for storage
private _saveArray = [];

{
    private _uid = _x;
    private _data = _y;
    
    // Extract only the essential data (not lastSeen which is transient)
    private _saveData = [
        _uid,
        _data getOrDefault ["points", 0],
        _data getOrDefault ["totalEarned", 0],
        _data getOrDefault ["unlocks", []]
    ];
    
    _saveArray pushBack _saveData;
    
} forEach RECONDO_RP_PLAYER_DATA;

// Save using persistence system
["reconpoints_data", _saveArray] call Recondo_fnc_setSaveData;

private _debug = if (isNil "RECONDO_RP_SETTINGS") then { false } else { RECONDO_RP_SETTINGS getOrDefault ["debugLogging", false] };
if (_debug) then {
    diag_log format ["[RECONDO_RP] Saved RP data for %1 players", count _saveArray];
};
