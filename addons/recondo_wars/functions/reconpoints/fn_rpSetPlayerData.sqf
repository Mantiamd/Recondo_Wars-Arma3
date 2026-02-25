/*
    Recondo_fnc_rpSetPlayerData
    Update player data for Recon Points system
    
    Description:
        Updates the player's data in the global hashmap and broadcasts
        the change to all clients. Also triggers persistence save.
        Should be called on server only.
    
    Parameters:
        _uid - STRING - Player UID
        _data - HASHMAP - Player data hashmap
    
    Returns:
        BOOL - True if successful
    
    Example:
        [getPlayerUID player, _playerData] call Recondo_fnc_rpSetPlayerData;
*/

params [["_uid", "", [""]], ["_data", createHashMap, [createHashMap]]];

// Validate inputs
if (_uid == "") exitWith {
    diag_log "[RECONDO_RP] ERROR: rpSetPlayerData called with empty UID";
    false
};

// Ensure player data hashmap exists
if (isNil "RECONDO_RP_PLAYER_DATA") then {
    RECONDO_RP_PLAYER_DATA = createHashMap;
};

// Update the data
RECONDO_RP_PLAYER_DATA set [_uid, _data];

// Broadcast to all clients
publicVariable "RECONDO_RP_PLAYER_DATA";

// Save to persistence (debounced via queue)
[] call Recondo_fnc_rpSaveData;

private _debug = if (isNil "RECONDO_RP_SETTINGS") then { false } else { RECONDO_RP_SETTINGS getOrDefault ["debugLogging", false] };
if (_debug) then {
    private _points = _data getOrDefault ["points", 0];
    private _unlockCount = count (_data getOrDefault ["unlocks", []]);
    diag_log format ["[RECONDO_RP] Updated player data for %1: %2 RP, %3 unlocks", _uid, _points, _unlockCount];
};

true
