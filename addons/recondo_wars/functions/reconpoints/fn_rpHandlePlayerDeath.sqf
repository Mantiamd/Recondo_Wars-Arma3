/*
    Recondo_fnc_rpHandlePlayerDeath
    Handle player death for point penalty
    
    Description:
        Called when a player dies to apply the death penalty.
        Can either reset points to 0 or subtract a fixed amount.
        Optionally resets unlocks as well.
        Server-only function.
    
    Parameters:
        _player - OBJECT - The player who died
    
    Returns:
        Nothing
    
    Example:
        [player] call Recondo_fnc_rpHandlePlayerDeath;
*/

params [["_player", objNull, [objNull]]];

// Server only
if (!isServer) exitWith {};

// Validate
if (isNull _player || !isPlayer _player) exitWith {};

// Check settings
if (isNil "RECONDO_RP_SETTINGS") exitWith {};

private _settings = RECONDO_RP_SETTINGS;
private _penaltyEnabled = _settings getOrDefault ["deathPenaltyEnabled", false];

if (!_penaltyEnabled) exitWith {};

// Get player UID
private _uid = getPlayerUID _player;
if (_uid == "") exitWith {};

// Get player data
private _playerData = [_uid] call Recondo_fnc_rpGetPlayerData;
private _currentPoints = _playerData getOrDefault ["points", 0];

// Skip if no points to lose
if (_currentPoints <= 0) exitWith {};

// Apply penalty
private _penaltyType = _settings getOrDefault ["deathPenaltyType", 0];
private _resetUnlocks = _settings getOrDefault ["deathResetUnlocks", false];
private _debug = _settings getOrDefault ["debugLogging", false];

private _newPoints = 0;
private _lostPoints = 0;

if (_penaltyType == 0) then {
    // Type 0: Reset to 0
    _lostPoints = _currentPoints;
    _newPoints = 0;
} else {
    // Type 1: Subtract amount
    private _subtractAmount = _settings getOrDefault ["deathSubtractAmount", 25];
    _lostPoints = _currentPoints min _subtractAmount;  // Can't lose more than you have
    _newPoints = (_currentPoints - _subtractAmount) max 0;
};

_playerData set ["points", _newPoints];

// Reset unlocks if configured
if (_resetUnlocks) then {
    _playerData set ["unlocks", []];
};

// Save updated data
[_uid, _playerData] call Recondo_fnc_rpSetPlayerData;

// Notify player about the penalty
private _msg = if (_penaltyType == 0) then {
    format ["Death Penalty: Lost all %1 Recon Points!", _lostPoints]
} else {
    format ["Death Penalty: -%1 Recon Points", _lostPoints]
};

if (_resetUnlocks) then {
    _msg = _msg + " All unlocks reset!";
};

[_msg, -_lostPoints] remoteExec ["Recondo_fnc_rpShowNotification", _player];

if (_debug) then {
    diag_log format ["[RECONDO_RP] Death penalty applied to %1: lost %2 RP (now %3), unlocks reset: %4",
        name _player, _lostPoints, _newPoints, _resetUnlocks];
};
