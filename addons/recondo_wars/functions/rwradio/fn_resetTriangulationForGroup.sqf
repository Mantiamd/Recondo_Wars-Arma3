/*
    Recondo_fnc_resetTriangulationForGroup
    Resets triangulation data for a leader's group.

    Description:
        Clears cumulative triangulation time and marker state for the given
        leader's group, and immediately deletes active triangulation markers.
        If RW Radio persistence is enabled, the cleared group-time map is saved.

    Parameters:
        0: OBJECT - Group leader unit

    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params ["_leader"];
if (isNull _leader) exitWith {};
if (isNil "RECONDO_RWR_SETTINGS" || {isNil "RECONDO_RWR_GROUP_TIMES"} || {isNil "RECONDO_RWR_GROUP_MARKERS"}) exitWith {};

private _groupId = groupId group _leader;
if (_groupId == "") exitWith {};

private _debug = RECONDO_RWR_SETTINGS get "enableDebug";

// Remove active markers for this group.
private _existingMarkers = RECONDO_RWR_GROUP_MARKERS getOrDefault [_groupId, []];
{
    deleteMarker _x;
} forEach _existingMarkers;
RECONDO_RWR_GROUP_MARKERS set [_groupId, []];
RECONDO_RWR_GROUP_MARKERS set [_groupId + "_count", 0];

// Clear cumulative triangulation time.
RECONDO_RWR_GROUP_TIMES set [_groupId, 0];
publicVariable "RECONDO_RWR_GROUP_TIMES";

// Persist immediately if enabled so the reset survives restart/load.
if ((RECONDO_RWR_SETTINGS get "enablePersistence") && {!isNil "RECONDO_PERSISTENCE_SETTINGS"}) then {
    ["RWR_GroupTimes", RECONDO_RWR_GROUP_TIMES] call Recondo_fnc_setSaveData;
    call Recondo_fnc_queueSave;
};

if (_debug) then {
    diag_log format ["[RECONDO_RWR] Triangulation reset for group %1 (leader: %2)", _groupId, name _leader];
};
