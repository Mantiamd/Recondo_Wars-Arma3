/*
    Recondo_fnc_loadPlayers
    Load player positions and loadouts from persistence

    Description:
        On mission start, polls for connecting players and restores
        their saved data after the configured delay.
        JIP players are handled by the PlayerConnected event handler
        in fn_modulePlayerPersistence.
*/

if (!isServer) exitWith {};

private _savedData = ["PLAYER_PERSIST_DATA", []] call Recondo_fnc_getSaveData;

if (count _savedData == 0) exitWith {
    diag_log "[RECONDO_PLAYERPERSIST] No saved player data found.";
};

private _debug = RECONDO_PLAYER_PERSISTENCE_DEBUG;
private _delay = RECONDO_PLAYER_PERSISTENCE_DELAY;

RECONDO_PLAYER_PERSISTENCE_RESTORED = createHashMap;

[{
    params ["_args", "_idPFH"];
    _args params ["_savedData", "_debug", "_delay"];

    private _allRestored = true;

    {
        private _savedEntry = _x;
        private _uid = _savedEntry get "uid";

        if (_uid in RECONDO_PLAYER_PERSISTENCE_RESTORED) then { continue };

        _allRestored = false;

        private _player = objNull;
        {
            if (getPlayerUID _x == _uid) exitWith {
                _player = _x;
            };
        } forEach allPlayers;

        if (isNull _player) then { continue };
        if !(_player getVariable ["RECONDO_IsPlayerTracked", false]) then { continue };

        RECONDO_PLAYER_PERSISTENCE_RESTORED set [_uid, true];

        [{
            params ["_player", "_savedEntry", "_debug"];

            if (isNull _player || !alive _player) exitWith {};

            private _savedPos = _savedEntry get "pos";
            private _savedDir = _savedEntry getOrDefault ["dir", 0];
            private _savedLoadout = _savedEntry getOrDefault ["loadout", []];
            private _owner = owner _player;

            if (count _savedPos >= 2) then {
                [_player, _savedPos] remoteExec ["setPosASL", _owner];
                [_player, _savedDir] remoteExec ["setDir", _owner];
            };

            if (count _savedLoadout > 0) then {
                [_player, _savedLoadout] remoteExec ["setUnitLoadout", _owner];
            };

            if (_debug) then {
                diag_log format ["[RECONDO_PLAYERPERSIST] Restored player %1 (UID: %2): pos=%3",
                    name _player, getPlayerUID _player, _savedPos];
            };

        }, [_player, _savedEntry, _debug], _delay] call CBA_fnc_waitAndExecute;

    } forEach _savedData;

    if (_allRestored || time > 120) then {
        [_idPFH] call CBA_fnc_removePerFrameHandler;
        RECONDO_PLAYER_PERSISTENCE_RESTORED = nil;
        diag_log format ["[RECONDO_PLAYERPERSIST] Player data load complete. %1 entries.", count _savedData];
    };

}, 5, [_savedData, _debug, _delay]] call CBA_fnc_addPerFrameHandler;
