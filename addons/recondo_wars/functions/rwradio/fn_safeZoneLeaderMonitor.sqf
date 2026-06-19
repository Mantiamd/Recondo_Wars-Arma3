/*
    Recondo_fnc_safeZoneLeaderMonitor
    Watches NO_RADIO zones for leader entry.

    Description:
        Server-side monitor that checks player leaders once per tick.
        On transition from outside -> inside a NO_RADIO marker, it immediately
        resets that group's triangulation data and removes triangulation markers.
        This only triggers when the group leader enters the safe zone.

    Parameters (CBA PFH):
        _args   - unused
        _handle - PFH handle

    Returns:
        Nothing
*/

if (!isServer) exitWith {};
if (isNil "RECONDO_RWR_SETTINGS") exitWith {};
if !(RECONDO_RWR_SETTINGS get "enableTriangulation") exitWith {};

params ["_args", "_handle"];
private _debug = RECONDO_RWR_SETTINGS get "enableDebug";

if (isNil "RECONDO_RWR_SAFEZONE_LEADER_STATE") then {
    RECONDO_RWR_SAFEZONE_LEADER_STATE = createHashMap;
};

private _seenGroups = [];

{
    if (!alive _x) then { continue };

    private _grp = group _x;
    if (leader _grp != _x) then { continue };

    private _groupId = groupId _grp;
    if (_groupId == "") then { continue };
    _seenGroups pushBackUnique _groupId;

    private _inSafeZone = [_x] call Recondo_fnc_isInSafeZone;
    private _wasInSafeZone = RECONDO_RWR_SAFEZONE_LEADER_STATE getOrDefault [_groupId, false];

    if (_inSafeZone && {!_wasInSafeZone}) then {
        [_x] call Recondo_fnc_resetTriangulationForGroup;
        if (_debug) then {
            private _triggerMarker = "<unknown>";
            private _noCountPrefix = RECONDO_RWR_SETTINGS get "noCountPrefix";
            private _noCountRadius = RECONDO_RWR_SETTINGS get "noCountRadius";
            private _leaderPos = getPos _x;
            {
                if (toUpper _x find toUpper _noCountPrefix >= 0) then {
                    if (_leaderPos distance (getMarkerPos _x) <= _noCountRadius) exitWith {
                        _triggerMarker = _x;
                    };
                };
            } forEach allMapMarkers;

            diag_log format [
                "[RECONDO_RWR] Leader %1 entered NO_RADIO marker %2 - triangulation reset for group %3",
                name _x,
                _triggerMarker,
                _groupId
            ];
        };
        RECONDO_RWR_SAFEZONE_LEADER_STATE set [_groupId, true];
        continue;
    };

    if (!_inSafeZone && {_wasInSafeZone}) then {
        RECONDO_RWR_SAFEZONE_LEADER_STATE set [_groupId, false];
    };
} forEach allPlayers;

// Cleanup for groups no longer represented by a player leader.
{
    if !(_x in _seenGroups) then {
        RECONDO_RWR_SAFEZONE_LEADER_STATE deleteAt _x;
    };
} forEach keys RECONDO_RWR_SAFEZONE_LEADER_STATE;
