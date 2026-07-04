/*
    Recondo_fnc_updatePsychWarfareReadout
    Publishes a per-side demoralization readout for client UI (intel board)

    Description:
        The PsyWar skill state lives only on the server, so the client-side
        intel board can't read it directly. This resolves the demoralization
        tier, picks the user-authored sentence for it, and maintains a small
        broadcast array. It only re-broadcasts when the tier/message changes,
        avoiding network spam from per-spawn re-applies.

        Tiers: 0 = dormant (no reduction), 1 = rattled (reduction below floor),
               2 = broken (reduction at the floor).

        Readout entry format: [sideNum, tier, messageText]

    Parameters:
        0: NUMBER - Target side number (0=OPFOR,1=BLUFOR,2=IND,3=CIV)
        1: NUMBER - Current skill factor (1.0 = no reduction)
        2: NUMBER - Floor factor (lowest the factor can reach)
        3: ARRAY  - Tier sentences [dormant, rattled, broken]
*/

params [["_sideNum", -1, [0]], ["_factor", 1, [0]], ["_floorFactor", 0, [0]], ["_readings", [], [[]]]];

if (_sideNum < 0) exitWith {};
if (isNil "RECONDO_PSYWAR_READOUT") then { RECONDO_PSYWAR_READOUT = []; };

private _tier = 1;
if (_factor >= 1) then {
    _tier = 0;
} else {
    if (_factor <= (_floorFactor + 0.0001)) then { _tier = 2; };
};

private _message = "";
if (_tier < count _readings) then { _message = _readings select _tier; };

private _newEntry = [_sideNum, _tier, _message];

private _idx = -1;
{
    if ((_x select 0) == _sideNum) exitWith { _idx = _forEachIndex; };
} forEach RECONDO_PSYWAR_READOUT;

private _changed = false;
if (_idx == -1) then {
    RECONDO_PSYWAR_READOUT pushBack _newEntry;
    _changed = true;
} else {
    if (!((RECONDO_PSYWAR_READOUT select _idx) isEqualTo _newEntry)) then {
        RECONDO_PSYWAR_READOUT set [_idx, _newEntry];
        _changed = true;
    };
};

if (_changed) then {
    publicVariable "RECONDO_PSYWAR_READOUT";
};
