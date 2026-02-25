/*
    Recondo_fnc_handlePOWTurnIn
    Server-side handler for POW turn-in
    
    Description:
        Called on server when a player turns in a POW.
        Triggers an intel reveal with the configured POW intel value.
        Leaves the POW unit as-is (does not delete).
    
    Parameters:
        _pow - OBJECT - The POW unit being turned in
        _player - OBJECT - The player turning in the POW
    
    Returns:
        BOOL - True if turn-in was successful
*/

if (!isServer) exitWith { false };

params [
    ["_pow", objNull, [objNull]],
    ["_player", objNull, [objNull]]
];

// Validate parameters
if (isNull _pow || isNull _player) exitWith {
    diag_log "[RECONDO_INTELITEMS] ERROR: Invalid parameters in handlePOWTurnIn";
    false
};

// Check if already turned in
if (_pow getVariable ["RECONDO_POW_TurnedIn", false]) exitWith {
    diag_log format ["[RECONDO_INTELITEMS] POW %1 already turned in", _pow];
    false
};

// Get settings
private _settings = if (isNil "RECONDO_INTELITEMS_SETTINGS") then { 
    createHashMap 
} else { 
    RECONDO_INTELITEMS_SETTINGS 
};

private _intelValue = _settings getOrDefault ["powIntelValue", 0.3];
private _debugLogging = _settings getOrDefault ["debugLogging", false];

// Mark as turned in
_pow setVariable ["RECONDO_POW_TurnedIn", true, true];

// Get POW info for notification
private _powName = name _pow;
private _powType = typeOf _pow;

if (_debugLogging) then {
    diag_log format ["[RECONDO_INTELITEMS] Processing POW turn-in: %1 (%2) by player %3", _powName, _powType, name _player];
};

// Trigger intel reveal using the POW intel value as weight
// The Intel system's reveal function handles weighted random selection
private _playerGroup = group _player;
private _groupId = str _playerGroup;

// Check if Intel system is available
if (isNil "RECONDO_INTEL_TARGETS" || {count RECONDO_INTEL_TARGETS == 0}) then {
    // No intel targets registered, just notify
    private _msg = format ["Prisoner %1 turned in. No actionable intelligence obtained.", _powName];
    [_msg] remoteExec ["hint", _player];
    
    if (_debugLogging) then {
        diag_log "[RECONDO_INTELITEMS] No intel targets available for POW turn-in";
    };
} else {
    // Attempt to reveal intel using weighted random
    // Use the POW intel value to modify the chance
    private _revealed = false;
    
    // Roll against the intel value (lower value = less likely to reveal)
    if (random 1 <= _intelValue) then {
        // Try to reveal a random target
        _revealed = [_playerGroup] call Recondo_fnc_revealRandomTarget;
    };
    
    if (_revealed) then {
        // Success message handled by revealRandomTarget
        if (_debugLogging) then {
            diag_log format ["[RECONDO_INTELITEMS] POW turn-in revealed intel for group %1", _groupId];
        };
    } else {
        // No reveal this time
        private _msg = format ["Prisoner %1 turned in. No actionable intelligence obtained.", _powName];
        [_msg] remoteExec ["hint", _player];
        
        if (_debugLogging) then {
            diag_log "[RECONDO_INTELITEMS] POW turn-in did not reveal intel (random roll or no targets)";
        };
    };
};

// Notify all players
private _notifyMsg = format ["%1 turned in a prisoner.", name _player];
[_notifyMsg] remoteExec ["systemChat", 0];

// Award Recon Points for POW turn-in
if (!isNil "RECONDO_RP_SETTINGS") then {
    ["pow", _player] call Recondo_fnc_rpAwardPoints;
};

diag_log format ["[RECONDO_INTELITEMS] POW turn-in complete: %1 by %2", _powName, name _player];

true
