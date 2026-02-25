/*
    Recondo_fnc_rpAwardPoints
    Award Recon Points to player(s) for objective completion
    
    Description:
        Awards points to a player or group based on objective type.
        Called from objective completion handlers.
        Server-only function.
    
    Parameters:
        _type - STRING - Reward type: "hvt", "hostage", "intel", "wiretap", "destroy", "pow", "kill", "custom"
        _recipient - OBJECT or GROUP - Player or group to receive points
        _customAmount - NUMBER - (Optional) Custom point amount if type is "custom"
        _notifyMsg - STRING - (Optional) Custom notification message
    
    Returns:
        NUMBER - Total points awarded (0 if system not active)
    
    Examples:
        ["hvt", group player] call Recondo_fnc_rpAwardPoints;
        ["intel", player] call Recondo_fnc_rpAwardPoints;
        ["custom", player, 50, "Bonus objective completed!"] call Recondo_fnc_rpAwardPoints;
*/

params [
    ["_type", "", [""]],
    ["_recipient", objNull, [objNull, grpNull]],
    ["_customAmount", 0, [0]],
    ["_notifyMsg", "", [""]]
];

// Server only
if (!isServer) exitWith { 0 };

// Validate settings exist
if (isNil "RECONDO_RP_SETTINGS") exitWith {
    diag_log "[RECONDO_RP] WARNING: rpAwardPoints called but system not initialized";
    0
};

// Determine point amount
private _rewards = RECONDO_RP_SETTINGS get "rewards";
private _amount = 0;

if (_type == "custom") then {
    _amount = _customAmount;
} else {
    _amount = _rewards getOrDefault [toLower _type, 0];
};

if (_amount <= 0) exitWith {
    diag_log format ["[RECONDO_RP] WARNING: Zero or negative amount for reward type '%1'", _type];
    0
};

// Get list of players to award
private _players = [];

if (_recipient isEqualType grpNull) then {
    // Award to all players in group
    {
        if (isPlayer _x && alive _x) then {
            _players pushBack _x;
        };
    } forEach units _recipient;
} else {
    // Award to single player
    if (isPlayer _recipient && alive _recipient) then {
        _players pushBack _recipient;
    };
};

if (count _players == 0) exitWith {
    diag_log "[RECONDO_RP] WARNING: No valid players to award points to";
    0
};

// Award points to each player
private _totalAwarded = 0;
private _debug = RECONDO_RP_SETTINGS getOrDefault ["debugLogging", false];

{
    private _player = _x;
    private _uid = getPlayerUID _player;
    
    if (_uid == "") then { continue; };
    
    // Get player data
    private _playerData = [_uid] call Recondo_fnc_rpGetPlayerData;
    
    // Update points
    private _currentPoints = _playerData getOrDefault ["points", 0];
    private _totalEarned = _playerData getOrDefault ["totalEarned", 0];
    
    _playerData set ["points", _currentPoints + _amount];
    _playerData set ["totalEarned", _totalEarned + _amount];
    
    // Save updated data
    [_uid, _playerData] call Recondo_fnc_rpSetPlayerData;
    
    _totalAwarded = _totalAwarded + _amount;
    
    // Send notification to player
    private _msg = if (_notifyMsg != "") then { 
        _notifyMsg 
    } else { 
        format ["+%1 Recon Points (%2)", _amount, _type] 
    };
    
    [_msg, _amount] remoteExec ["Recondo_fnc_rpShowNotification", _player];
    
    if (_debug) then {
        diag_log format ["[RECONDO_RP] Awarded %1 RP to %2 (%3). Total: %4", 
            _amount, name _player, _type, (_currentPoints + _amount)];
    };
    
} forEach _players;

_totalAwarded
