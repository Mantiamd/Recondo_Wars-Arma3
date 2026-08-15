/*
    Recondo_fnc_initKitCarsonClient
    Adds the informant ACE action to Kit Carson units on the local client

    Description:
        Called on every client (JIP-safe remoteExec) after a Kit Carson
        module instance registers its units. Waits for the broadcast unit
        list, then adds a per-object ACE action (text from the informant's
        config) to each unit that does not have one yet. Safe to run
        multiple times - already-processed units are skipped via a local
        marker variable.

    Parameters:
        None

    Returns:
        Nothing
*/

if (!hasInterface) exitWith {};

[{
    !isNil "RECONDO_KITCARSON_UNITS"
}, {
    private _added = 0;
    {
        if (!isNull _x && {!(_x getVariable ["RECONDO_KITCARSON_ACTION_ADDED", false])}) then {
            _x setVariable ["RECONDO_KITCARSON_ACTION_ADDED", true];   // local marker, not broadcast

            private _cfg = _x getVariable ["RECONDO_KITCARSON_CFG", []];
            private _actionText = if (_cfg isNotEqualTo []) then { _cfg select 0 } else { "Ask about enemy activity" };

            private _action = [
                "Recondo_KitCarson_Ask",
                _actionText,
                "\a3\ui_f\data\igui\cfg\simpletasks\types\intel_ca.paa",
                {
                    params ["_target", "_player"];
                    [_target, _player] call Recondo_fnc_kitCarsonTalk;
                },
                {
                    params ["_target"];
                    alive _target
                }
            ] call ace_interact_menu_fnc_createAction;

            [_x, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;
            _added = _added + 1;
        };
    } forEach RECONDO_KITCARSON_UNITS;

    if (_added > 0) then {
        diag_log format ["[RECONDO_KITCARSON] Client: informant action added to %1 unit(s)", _added];
    };
}, []] call CBA_fnc_waitUntilAndExecute;
