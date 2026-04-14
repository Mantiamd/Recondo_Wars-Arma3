/*
    Recondo_fnc_savePlayers
    Save tracked player positions and loadouts to persistence

    Description:
        Iterates allPlayers, saves position/direction/loadout for
        units tagged with RECONDO_IsPlayerTracked.
        Preserves entries for offline players so disconnect saves
        are not overwritten.
*/

if (!isServer) exitWith {};
if (!RECONDO_PLAYER_PERSISTENCE_ENABLED) exitWith {};

private _existingData = ["PLAYER_PERSIST_DATA", []] call Recondo_fnc_getSaveData;

{
    private _unit = _x;

    if !(_unit getVariable ["RECONDO_IsPlayerTracked", false]) then { continue };
    if (isNull _unit || !alive _unit) then { continue };

    private _uid = getPlayerUID _unit;
    if (_uid == "") then { continue };

    private _entry = createHashMapFromArray [
        ["uid", _uid],
        ["name", name _unit],
        ["pos", getPosASL _unit],
        ["dir", getDir _unit],
        ["loadout", getUnitLoadout _unit]
    ];

    private _replaced = false;
    {
        if ((_x get "uid") == _uid) exitWith {
            _existingData set [_forEachIndex, _entry];
            _replaced = true;
        };
    } forEach _existingData;

    if (!_replaced) then {
        _existingData pushBack _entry;
    };
} forEach allPlayers;

["PLAYER_PERSIST_DATA", _existingData] call Recondo_fnc_setSaveData;

if (RECONDO_PLAYER_PERSISTENCE_DEBUG) then {
    diag_log format ["[RECONDO_PLAYERPERSIST] Saved %1 player entries", count _existingData];
};
