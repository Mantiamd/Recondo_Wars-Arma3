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

// Route the reveal through the standard intel turn-in flow with the "pow" source.
// processTurnIn handles weighted selection, the interrogation intel card, and the intel log.
// Guard against the Intel module being absent so we never call into a nil target list.
if (isNil "RECONDO_INTEL_TARGETS") then {
    private _msg = format ["Prisoner %1 turned in. No actionable intelligence obtained.", _powName];
    [_msg] remoteExec ["hint", _player];
    
    if (_debugLogging) then {
        diag_log "[RECONDO_INTELITEMS] No intel system available for POW turn-in";
    };
} else {
    // Configured POW intel value gates the chance of yielding actionable intel
    if (random 1 <= _intelValue) then {
        [_player, "pow"] call Recondo_fnc_processTurnIn;
    } else {
        private _msg = format ["Prisoner %1 turned in. No actionable intelligence obtained.", _powName];
        [_msg] remoteExec ["hint", _player];
        
        if (_debugLogging) then {
            diag_log "[RECONDO_INTELITEMS] POW turn-in did not yield intel (random roll)";
        };
    };
};

// Award Recon Points for POW turn-in. Silent - completion is surfaced via
// the Intel Board / revealed intel rather than a mission-wide broadcast.
if (!isNil "RECONDO_RP_SETTINGS") then {
    ["pow", _player, 0, "", true] call Recondo_fnc_rpAwardPoints;
};

diag_log format ["[RECONDO_INTELITEMS] POW turn-in complete: %1 by %2", _powName, name _player];

true
