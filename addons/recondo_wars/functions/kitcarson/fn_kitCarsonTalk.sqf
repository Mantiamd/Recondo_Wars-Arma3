/*
    Recondo_fnc_kitCarsonTalk
    Client-side entry point for talking to a Kit Carson informant

    Description:
        ACE action callback, runs on the interacting player's client.
        Handles everything that can be answered locally without touching
        the intel transaction:

        - Translator restriction: players whose classname is not on the
          allowed list get the refusal line and the informant stays quiet.
        - Depleted fast path: an informant already used this mission
          answers with the depleted line (the server re-checks anyway, so
          a stale flag can't double-reveal).

        Everything else - item check, consumption, one-time claim, intel
        reveal - is a server transaction (fn_kitCarsonProcess), so two
        players hammering the action can't race each other.

        While talking, the NPC stops and faces the player; both commands
        run where the AI is local. A watcher releases the NPC when the
        player walks away (>20m) or either party dies.

    Parameters:
        0: OBJECT - Informant NPC
        1: OBJECT - Interacting player

    Returns:
        Nothing
*/

if (!hasInterface) exitWith {};

params [["_npc", objNull, [objNull]], ["_player", objNull, [objNull]]];

if (isNull _npc || {!alive _npc}) exitWith {};

private _cfg = _npc getVariable ["RECONDO_KITCARSON_CFG", []];
if (_cfg isEqualTo []) exitWith {
    [toUpper name _npc, "They do not respond.", 2, 5, "", 3] call Recondo_fnc_showIntelCard;
};
_cfg params ["", "", "", "", "_depletedLine", "_allowedClassnames", "_refusalLine"];

// Stop and face the player while talking - runs where the NPC is local
[_npc, 0] remoteExec ["forceSpeed", _npc];
[_npc, _player] remoteExec ["doWatch", _npc];

// One release watcher per NPC per client (same pattern as NPC Dialog)
if !(_npc getVariable ["RECONDO_KITCARSON_WATCHING", false]) then {
    _npc setVariable ["RECONDO_KITCARSON_WATCHING", true];

    [{
        params ["_args", "_pfhId"];
        _args params ["_npc", "_player"];

        if (isNull _npc || {!alive _npc} || {isNull _player} || {!alive _player} || {_player distance _npc > 20}) then {
            if (!isNull _npc && {alive _npc}) then {
                [_npc, -1] remoteExec ["forceSpeed", _npc];   // -1 removes the speed limit
                [_npc, objNull] remoteExec ["doWatch", _npc];
            };
            if (!isNull _npc) then {
                _npc setVariable ["RECONDO_KITCARSON_WATCHING", false];
            };
            [_pfhId] call CBA_fnc_removePerFrameHandler;
        };
    }, 5, [_npc, _player]] call CBA_fnc_addPerFrameHandler;
};

// Translator restriction - answered locally, case-insensitive classname match
if (_allowedClassnames isNotEqualTo [] && {
    private _playerClass = toLower typeOf _player;
    (_allowedClassnames findIf { (toLower _x) == _playerClass }) == -1
}) exitWith {
    [toUpper name _npc, _refusalLine, 2, 8, "", 3] call Recondo_fnc_showIntelCard;
};

// Depleted fast path saves a server round-trip; the server re-checks
if (_npc getVariable ["RECONDO_KITCARSON_USED", false]) exitWith {
    [toUpper name _npc, _depletedLine, 2, 8, "", 3] call Recondo_fnc_showIntelCard;
};

[_npc, _player] remoteExec ["Recondo_fnc_kitCarsonProcess", 2];
