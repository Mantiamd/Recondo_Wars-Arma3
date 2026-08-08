/*
    Recondo_fnc_npcDialogTalk
    Shows the next dialog line of an NPC to the local player

    Description:
        ACE action callback, runs on the interacting player's client.
        Progress through the dialog is stored as a LOCAL (non-broadcast)
        variable on the NPC, so every player hears the conversation from
        the beginning independently of other players.

        While talking, the NPC stops and faces the player - both commands
        are remoteExec'd to the unit so they run where the AI is local
        (server or Headless Client). A watcher releases the NPC when the
        player walks away (>20m) or dies, or the NPC dies.

    Parameters:
        0: OBJECT - NPC being talked to
        1: OBJECT - Interacting player

    Returns:
        Nothing
*/

if (!hasInterface) exitWith {};

params [["_npc", objNull, [objNull]], ["_player", objNull, [objNull]]];

if (isNull _npc || {!alive _npc}) exitWith {};

private _lines = _npc getVariable ["RECONDO_NPCDIALOG_LINES", []];
if (_lines isEqualTo []) exitWith {
    [toUpper name _npc, "They do not respond.", 2, 5, "", 3] call Recondo_fnc_showIntelCard;
};

private _idx = _npc getVariable ["RECONDO_NPCDIALOG_IDX", 0];

if (_idx >= count _lines) exitWith {
    [toUpper name _npc, "They have nothing more to say.", 2, 5, "", 3] call Recondo_fnc_showIntelCard;
};

// Stop and face the player while talking - runs where the NPC is local
[_npc, 0] remoteExec ["forceSpeed", _npc];
[_npc, _player] remoteExec ["doWatch", _npc];

[toUpper name _npc, _lines select _idx, 2, 10, "", 1] call Recondo_fnc_showIntelCard;

// Local progress marker: each player advances their own copy of the dialog
_npc setVariable ["RECONDO_NPCDIALOG_IDX", _idx + 1];

// One release watcher per NPC per client
if !(_npc getVariable ["RECONDO_NPCDIALOG_WATCHING", false]) then {
    _npc setVariable ["RECONDO_NPCDIALOG_WATCHING", true];

    [{
        params ["_args", "_pfhId"];
        _args params ["_npc", "_player"];

        if (isNull _npc || {!alive _npc} || {isNull _player} || {!alive _player} || {_player distance _npc > 20}) then {
            if (!isNull _npc && {alive _npc}) then {
                [_npc, -1] remoteExec ["forceSpeed", _npc];   // -1 removes the speed limit
                [_npc, objNull] remoteExec ["doWatch", _npc];
            };
            if (!isNull _npc) then {
                _npc setVariable ["RECONDO_NPCDIALOG_WATCHING", false];
            };
            [_pfhId] call CBA_fnc_removePerFrameHandler;
        };
    }, 5, [_npc, _player]] call CBA_fnc_addPerFrameHandler;
};
