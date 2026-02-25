/*
    Recondo_fnc_addTerminalActions
    Server-side: Broadcasts terminal action setup to clients
    
    Description:
        Initiates the client-side ACE action creation via remoteExec.
    
    Parameters:
        _terminalObject - OBJECT - The terminal object
        _terminalName - STRING - Display name for the terminal
        _linkedToPersistence - BOOL - Whether linked to Persistence module
*/

params [
    ["_terminalObject", objNull, [objNull]],
    ["_terminalName", "Command Terminal", [""]],
    ["_linkedToPersistence", false, [false]]
];

if (isNull _terminalObject) exitWith {};

// Call client-side function
[_terminalObject, _terminalName, _linkedToPersistence] call Recondo_fnc_addTerminalActionsClient;
