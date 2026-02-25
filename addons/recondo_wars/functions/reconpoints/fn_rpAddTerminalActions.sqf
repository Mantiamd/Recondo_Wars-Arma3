/*
    Recondo_fnc_rpAddTerminalActions
    Add ACE actions to unlock terminal (server-side wrapper)
    
    Description:
        Wrapper function that broadcasts terminal action setup to all clients.
        Called from server when module initializes.
    
    Parameters:
        _object - OBJECT - The terminal object
        _terminalName - STRING - Display name for the terminal
    
    Returns:
        Nothing
    
    Example:
        [_terminal, "Unlock Terminal"] call Recondo_fnc_rpAddTerminalActions;
*/

params [
    ["_object", objNull, [objNull]],
    ["_terminalName", "Unlock Terminal", [""]]
];

// Validate
if (isNull _object) exitWith {
    diag_log "[RECONDO_RP] ERROR: rpAddTerminalActions - null object";
};

// Store terminal name on object for client access
_object setVariable ["RECONDO_RP_TERMINAL_NAME", _terminalName, true];

// Execute client setup on all machines with JIP
[_object] remoteExec ["Recondo_fnc_rpAddTerminalActionsClient", 0, true];
