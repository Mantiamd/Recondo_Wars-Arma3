/*
    Recondo_fnc_getActiveRWPartyCount
    Count active reinforcement parties across all RW modules

    Description:
        Counts distinct party IDs among reinforcement groups that still
        have living members. Used to enforce the global concurrent-party
        cap (RECONDO_RW_MAX_ACTIVE_PARTIES) so overlapping modules cannot
        pile unlimited spawns onto the server.

    Parameters:
        None

    Returns:
        NUMBER - Count of active parties
*/

private _activeParties = [];

{
    if (!isNull _x && {({alive _x} count units _x) > 0}) then {
        private _partyId = _x getVariable ["RECONDO_RW_partyId", ""];
        if (_partyId != "" && {!(_partyId in _activeParties)}) then {
            _activeParties pushBack _partyId;
        };
    };
} forEach RECONDO_RW_ACTIVE_GROUPS;

count _activeParties
