/*
    Recondo_fnc_rpSpendPoints
    Spend Recon Points on an unlock
    
    Description:
        Deducts points from player's balance and records the unlock.
        Called when player unlocks an item in the shop.
        Server-only function.
    
    Parameters:
        _player - OBJECT - The player spending points
        _classname - STRING - The item classname being unlocked
        _cost - NUMBER - The point cost of the item
    
    Returns:
        BOOL - True if successful, false if insufficient points or error
    
    Example:
        [player, "vn_m40a1", 100] call Recondo_fnc_rpSpendPoints;
*/

params [
    ["_player", objNull, [objNull]],
    ["_classname", "", [""]],
    ["_cost", 0, [0]]
];

// Server only
if (!isServer) exitWith { false };

// Validate
if (isNull _player || !isPlayer _player) exitWith {
    diag_log "[RECONDO_RP] ERROR: rpSpendPoints - invalid player";
    false
};

if (_classname == "") exitWith {
    diag_log "[RECONDO_RP] ERROR: rpSpendPoints - empty classname";
    false
};

if (_cost <= 0) exitWith {
    diag_log "[RECONDO_RP] ERROR: rpSpendPoints - invalid cost";
    false
};

// Get player data
private _uid = getPlayerUID _player;
if (_uid == "") exitWith { false };

private _playerData = [_uid] call Recondo_fnc_rpGetPlayerData;
private _currentPoints = _playerData getOrDefault ["points", 0];
private _unlocks = _playerData getOrDefault ["unlocks", []];

// Check if already unlocked
if (_classname in _unlocks) exitWith {
    diag_log format ["[RECONDO_RP] Player %1 already has %2 unlocked", name _player, _classname];
    false
};

// Check if enough points
if (_currentPoints < _cost) exitWith {
    diag_log format ["[RECONDO_RP] Player %1 has insufficient points (%2) for %3 (cost %4)", 
        name _player, _currentPoints, _classname, _cost];
    false
};

// Deduct points and add unlock
_playerData set ["points", _currentPoints - _cost];
_unlocks pushBack _classname;
_playerData set ["unlocks", _unlocks];

// Save updated data
[_uid, _playerData] call Recondo_fnc_rpSetPlayerData;

private _debug = if (isNil "RECONDO_RP_SETTINGS") then { false } else { RECONDO_RP_SETTINGS getOrDefault ["debugLogging", false] };
if (_debug) then {
    diag_log format ["[RECONDO_RP] Player %1 unlocked %2 for %3 RP. Balance: %4", 
        name _player, _classname, _cost, (_currentPoints - _cost)];
};

true
