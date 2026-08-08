/*
    Recondo_fnc_moduleNPCDialog
    Main initialization for NPC Dialog module

    Description:
        Gives synced AI units an ACE "Talk to" interaction. Each interaction
        shows the interacting player the next line of the module-defined
        dialog on an intel card; the NPC stops and faces the player while
        talking. Multi-instance: place one module per NPC, or sync several
        NPCs to one module to share the same dialog.

        Dedicated-server flow: the server tags each synced unit with the
        dialog lines (public, JIP-safe), registers it in a broadcast list,
        and clients add the ACE action locally. NPC movement commands run
        where the unit is local via remoteExec to the unit.

    Priority: 10 (UI/presentation - no dependencies)

    Parameters:
        _logic     - Module logic object
        _units     - Synchronized units
        _activated - Whether module is activated
*/

params ["_logic", "_units", "_activated"];

if (!isServer) exitWith {};

if (!_activated) exitWith {
    diag_log "[RECONDO_NPCDIALOG] Module not activated.";
};

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

private _dialogLinesRaw = _logic getVariable ["dialoglines", ""];
private _debugLogging = _logic getVariable ["debuglogging", false];
if (RECONDO_MASTER_DEBUG) then { _debugLogging = true; };

// One line per row; lines may contain commas, so split on newlines only
private _dialogLines = ((_dialogLinesRaw splitString (toString [10, 13])) apply { _x trim [" ", 0] }) select { _x != "" };

// ========================================
// VALIDATE
// ========================================

if (_dialogLines isEqualTo []) exitWith {
    diag_log "[RECONDO_NPCDIALOG] ERROR: No dialog lines configured. Module disabled.";
};

private _npcs = (synchronizedObjects _logic) select { _x isKindOf "CAManBase" && {alive _x} };

if (_npcs isEqualTo []) exitWith {
    diag_log "[RECONDO_NPCDIALOG] ERROR: No living AI units synced to module. Sync at least one unit in Eden.";
};

// ========================================
// TAG NPCS AND BROADCAST
// ========================================

{
    _x setVariable ["RECONDO_NPCDIALOG_LINES", _dialogLines, true];
} forEach _npcs;

if (isNil "RECONDO_NPCDIALOG_UNITS") then { RECONDO_NPCDIALOG_UNITS = []; };
RECONDO_NPCDIALOG_UNITS append _npcs;
publicVariable "RECONDO_NPCDIALOG_UNITS";

// ========================================
// MAIN LOGIC
// ========================================

// Add the ACE action on every client (JIP-safe via static id)
[] remoteExec ["Recondo_fnc_initNPCDialogClient", 0, "RECONDO_NPCDIALOG_CLIENTINIT"];

if (_debugLogging) then {
    diag_log format ["[RECONDO_NPCDIALOG] NPCs: %1 | First line: %2", _npcs apply { typeOf _x }, _dialogLines select 0];
};

// ========================================
// FINAL LOG
// ========================================

diag_log format ["[RECONDO_NPCDIALOG] Module initialized. NPCs: %1, dialog lines: %2", count _npcs, count _dialogLines];
