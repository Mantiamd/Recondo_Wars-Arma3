/*
    Recondo_fnc_hcSweepLoop
    Periodic sweep that (re)transfers HC-eligible groups to a Headless Client

    Description:
        Every 30 seconds, finds groups tagged RECONDO_HC_ELIGIBLE (set by
        Recondo_fnc_transferGroupToHC) that are currently owned by the
        server and hands them to a connected HC. This covers two cases:
        - An HC connects after eligible groups were already spawned.
        - An HC disconnects, dumping its groups back on the server; they
          are re-transferred when an HC (re)connects.
        Started lazily by the first transfer request; self-guarding so
        only one instance runs. Idles cheaply while no HC is connected.
        Server-only.

    Parameters:
        None

    Returns:
        Nothing
*/

if (!isServer) exitWith {};

if (RECONDO_HC_SWEEP_RUNNING) exitWith {};
RECONDO_HC_SWEEP_RUNNING = true;

diag_log "[RECONDO_HC] Sweep loop started (30 second interval)";

[{
    if ((call Recondo_fnc_getHeadlessClients) isEqualTo []) exitWith {};

    // Eligible groups that fell back to (or never left) the server
    private _pending = allGroups select {
        local _x &&
        {_x getVariable ["RECONDO_HC_ELIGIBLE", false]} &&
        {(units _x) isNotEqualTo []}
    };

    if (_pending isEqualTo []) exitWith {};

    private _moved = 0;
    {
        if ([_x] call Recondo_fnc_transferGroupToHC) then {
            _moved = _moved + 1;
        };
    } forEach _pending;

    if (_moved > 0) then {
        diag_log format ["[RECONDO_HC] Sweep transferred %1 group(s) to Headless Client", _moved];
    };
}, 30, []] call CBA_fnc_addPerFrameHandler;
