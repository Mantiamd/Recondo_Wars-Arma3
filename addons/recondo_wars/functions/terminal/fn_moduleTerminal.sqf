/*
    Recondo_fnc_moduleTerminal
    Main initialization for Terminal module
    
    Description:
        Creates an admin terminal on a synced object for viewing
        mission status and managing persistence data.
    
    Parameters:
        _logic - Module logic object
        _units - Synchronized units (unused)
        _activated - Whether module is activated
*/

params ["_logic", "_units", "_activated"];

// Server-only initialization
if (!isServer) exitWith {};

// Validate activation
if (!_activated) exitWith {
    diag_log "[RECONDO_TERMINAL] Module not activated.";
};

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

private _terminalName = _logic getVariable ["terminalname", "Command Terminal"];
private _debugLogging = _logic getVariable ["debuglogging", false];

private _enableRoleAccess = _logic getVariable ["enableroleaccess", false];
private _allowedClassnamesRaw = _logic getVariable ["allowedclassnames", ""];

private _allowedClassnames = [];
if (_enableRoleAccess && _allowedClassnamesRaw != "") then {
    _allowedClassnames = ((_allowedClassnamesRaw splitString (toString [10, 13] + ",")) apply { _x trim [" ", 0] }) select { _x != "" };
};

private _masterDebug = _logic getVariable ["masterdebug", false];
if (_masterDebug) then {
    RECONDO_MASTER_DEBUG = true;
    publicVariable "RECONDO_MASTER_DEBUG";
    _debugLogging = true;
    diag_log "[RECONDO_TERMINAL] Master Debug enabled - all modules will log debug info";
};

// ========================================
// FIND SYNCED OBJECTS
// ========================================

private _syncedObjects = synchronizedObjects _logic;
private _terminalObject = objNull;
private _linkedToPersistence = false;

{
    if (typeOf _x == "Recondo_Module_Persistence") then {
        _linkedToPersistence = true;
    } else {
        // First non-module synced object becomes the terminal
        if (isNull _terminalObject && !(_x isKindOf "Module_F")) then {
            _terminalObject = _x;
        };
    };
} forEach _syncedObjects;

// Validate terminal object
if (isNull _terminalObject) exitWith {
    diag_log "[RECONDO_TERMINAL] ERROR: No object synced to Terminal module. Sync an object in Eden Editor.";
};

if (!_linkedToPersistence) then {
    diag_log "[RECONDO_TERMINAL] WARNING: Not synced to Persistence module. Reset function will not work.";
};

// ========================================
// STORE SETTINGS
// ========================================

RECONDO_TERMINAL_SETTINGS = createHashMapFromArray [
    ["terminalName", _terminalName],
    ["linkedToPersistence", _linkedToPersistence],
    ["enableRoleAccess", _enableRoleAccess],
    ["allowedClassnames", _allowedClassnames],
    ["debugLogging", _debugLogging]
];
publicVariable "RECONDO_TERMINAL_SETTINGS";

RECONDO_TERMINAL_OBJECT = _terminalObject;
publicVariable "RECONDO_TERMINAL_OBJECT";

// ========================================
// ADD ACE ACTIONS
// ========================================

// Broadcast to all clients (with JIP)
[_terminalObject, _terminalName, _linkedToPersistence] remoteExec ["Recondo_fnc_addTerminalActions", 0, true];

// ========================================
// LOG INITIALIZATION
// ========================================

diag_log format ["[RECONDO_TERMINAL] Module initialized. Terminal: %1, Object: %2, Linked to Persistence: %3",
    _terminalName, typeOf _terminalObject, _linkedToPersistence];

if (_debugLogging) then {
    diag_log "[RECONDO_TERMINAL] === Terminal Module Settings ===";
    diag_log format ["[RECONDO_TERMINAL] Terminal Name: %1", _terminalName];
    diag_log format ["[RECONDO_TERMINAL] Terminal Object: %1", _terminalObject];
    diag_log format ["[RECONDO_TERMINAL] Role Access: %1 | Allowed: %2", _enableRoleAccess, _allowedClassnames];
};
