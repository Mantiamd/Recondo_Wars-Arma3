/*
    Recondo_fnc_despawnRWGroup
    Deletes a reinforcement group in place and cleans up its tracking

    Description:
        Removes a reinforcement group where it stands (used when the group
        gives up a cold trail). Cleans up the group's tracker dog and its
        bullet magnet first (deleteVehicle does not fire the dog's Killed
        handler), deletes all remaining units, removes the group from the
        per-module and global active-group lists, then deletes the group.
        Server-only.

    Parameters:
        0: GROUP - The reinforcement group to remove
        1: HASHMAP - Module settings (for the per-module active list)

    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params ["_group", "_moduleSettings"];

if (isNull _group) exitWith {};

// Clean up the group's tracker dog bullet magnet before deleting the units
private _dog = _group getVariable ["RECONDO_RW_dog", objNull];
if (!isNull _dog) then {
    private _bulletMagnet = _dog getVariable ["RECONDO_RW_bulletMagnet", objNull];
    if (!isNull _bulletMagnet) then { deleteVehicle _bulletMagnet; };
};

// Delete all remaining units (the dog is a member of the group and is included)
{ deleteVehicle _x; } forEach units _group;

// Remove from the per-module active list
if (!isNil "_moduleSettings") then {
    private _activeGroups = _moduleSettings get "activeGroups";
    if (!isNil "_activeGroups") then {
        _moduleSettings set ["activeGroups", _activeGroups - [_group]];
    };
};

// Remove from the global active list
RECONDO_RW_ACTIVE_GROUPS = RECONDO_RW_ACTIVE_GROUPS - [_group];

// Delete the now-empty group (safety net; groups auto-delete when empty)
deleteGroup _group;
