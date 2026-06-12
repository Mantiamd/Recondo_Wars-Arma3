/*
    Recondo_fnc_queueSave
    Debounced saveMissionProfileNamespace

    Description:
        Queues a disk write with a 5-second delay. If called again within
        that window, the request is absorbed. At most one disk write per
        5-second window regardless of how many modules request saves.

        For critical paths (manual save, delete save), call
        saveMissionProfileNamespace directly instead.

    Parameters:
        None

    Returns:
        Nothing
*/

if (!isServer) exitWith {};

if (!isNil "RECONDO_SAVE_QUEUED") exitWith {};
RECONDO_SAVE_QUEUED = true;

[{
    saveMissionProfileNamespace;
    RECONDO_SAVE_QUEUED = nil;
}, [], 5] call CBA_fnc_waitAndExecute;
