/*
    Recondo_fnc_rpHasUnlocked
    Check if player has unlocked an item
    
    Description:
        Returns whether a player has the specified item unlocked.
        Can be called on any machine (reads from publicVariable).
    
    Parameters:
        _player - OBJECT - The player to check
        _classname - STRING - The item classname to check
    
    Returns:
        BOOL - True if unlocked, false otherwise
    
    Example:
        if ([player, "vn_m40a1"] call Recondo_fnc_rpHasUnlocked) then {...};
*/

params [
    ["_player", objNull, [objNull]],
    ["_classname", "", [""]]
];

// Validate
if (isNull _player || !isPlayer _player) exitWith { false };
if (_classname == "") exitWith { false };

// Check if system is initialized
if (isNil "RECONDO_RP_PLAYER_DATA") exitWith { false };

// Get player data
private _uid = getPlayerUID _player;
if (_uid == "") exitWith { false };

private _playerData = RECONDO_RP_PLAYER_DATA getOrDefault [_uid, createHashMap];
private _unlocks = _playerData getOrDefault ["unlocks", []];

(_classname in _unlocks)
