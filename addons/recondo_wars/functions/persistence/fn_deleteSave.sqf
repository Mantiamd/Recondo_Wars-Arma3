/*
    Recondo_fnc_deleteSave
    Delete all persistence data for current campaign
    
    Description:
        Clears all saved data from missionProfileNamespace for the current
        campaign ID. Use with caution - this cannot be undone.
    
    Parameters:
        0: BOOL - Confirm deletion (must be true to proceed)
        
    Returns:
        BOOL - True if deletion successful
        
    Example:
        [true] call Recondo_fnc_deleteSave;
*/

params [["_confirm", false, [true]]];

// Only run on server
if (!isServer) exitWith {
    diag_log "[RECONDO_PERSISTENCE] deleteSave called on non-server.";
    false
};

// Require confirmation
if (!_confirm) exitWith {
    diag_log "[RECONDO_PERSISTENCE] deleteSave: Confirmation required. Pass true to confirm deletion.";
    false
};

// Check if persistence is initialized
if (isNil "RECONDO_PERSISTENCE_SETTINGS") exitWith {
    diag_log "[RECONDO_PERSISTENCE] deleteSave: Persistence not initialized.";
    false
};

private _settings = RECONDO_PERSISTENCE_SETTINGS;
private _campaignID = _settings get "campaignID";
private _debug = _settings get "enableDebug";

diag_log format ["[RECONDO_PERSISTENCE] Deleting all save data for campaign: %1", _campaignID];

// List of data types to delete
private _dataTypes = [
    "metadata",
    "markers",
    "playerstats"
];

// Delete each data type
{
    private _tag = [_x] call Recondo_fnc_getSaveTag;
    missionProfileNamespace setVariable [_tag, nil];
    
    if (_debug) then {
        diag_log format ["[RECONDO_PERSISTENCE] Deleted: %1", _tag];
    };
} forEach _dataTypes;

// Commit changes
saveMissionProfileNamespace;

// Clear runtime data
RECONDO_PERSISTENCE_PLAYER_STATS = createHashMap;
publicVariable "RECONDO_PERSISTENCE_PLAYER_STATS";

diag_log format ["[RECONDO_PERSISTENCE] All save data deleted for campaign: %1", _campaignID];

// Notify players
format ["Save data deleted for campaign: %1", _campaignID] remoteExec ["systemChat", 0, false];

true
