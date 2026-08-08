/*
    Recondo_fnc_initNPCDialogClient
    Adds the "Talk to" ACE action to NPC Dialog units on the local client

    Description:
        Called on every client (JIP-safe remoteExec) after an NPC Dialog
        module instance registers its units. Waits for the broadcast unit
        list, then adds a per-object ACE action to each unit that does not
        have one yet. Safe to run multiple times (one call can arrive per
        module instance) - already-processed units are skipped via a local
        marker variable.

    Parameters:
        None

    Returns:
        Nothing
*/

if (!hasInterface) exitWith {};

[{
    !isNil "RECONDO_NPCDIALOG_UNITS"
}, {
    private _added = 0;
    {
        if (!isNull _x && {!(_x getVariable ["RECONDO_NPCDIALOG_ACTION_ADDED", false])}) then {
            _x setVariable ["RECONDO_NPCDIALOG_ACTION_ADDED", true];   // local marker, not broadcast

            private _action = [
                "Recondo_NPCDialog_Talk",
                "Talk to",
                "\a3\ui_f\data\igui\cfg\simpletasks\types\talk_ca.paa",
                {
                    params ["_target", "_player"];
                    [_target, _player] call Recondo_fnc_npcDialogTalk;
                },
                {
                    params ["_target"];
                    alive _target
                }
            ] call ace_interact_menu_fnc_createAction;

            [_x, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;
            _added = _added + 1;
        };
    } forEach RECONDO_NPCDIALOG_UNITS;

    if (_added > 0) then {
        diag_log format ["[RECONDO_NPCDIALOG] Client: Talk to action added to %1 unit(s)", _added];
    };
}, []] call CBA_fnc_waitUntilAndExecute;
