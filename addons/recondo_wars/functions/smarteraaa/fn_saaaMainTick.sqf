/*
    Recondo_fnc_saaaMainTick
    Main loop tick (server-side, called by CBA PFH from the module init)

    Description:
        Checks the enable toggle live, rescans guns periodically, builds the
        audible aircraft list once, and runs every managed gun's state machine.

    Parameters:
        None

    Returns:
        Nothing
*/

// Live disable: release every steered gun and go dormant
if (!RECONDO_SAAA_ENABLED) exitWith {
    {
        if ((_x getVariable ["RECONDO_SAAA_state", "IDLE"]) != "IDLE") then {
            private _g = gunner _x;
            if (!isNull _g && {alive _g}) then { _g doWatch objNull };
            _x setVariable ["RECONDO_SAAA_state", "IDLE"];
            _x setVariable ["RECONDO_SAAA_target", objNull];
        };
    } forEach RECONDO_SAAA_GUNS;
};

RECONDO_SAAA_SCAN_COUNTER = RECONDO_SAAA_SCAN_COUNTER + 1;
if (RECONDO_SAAA_SCAN_COUNTER >= RECONDO_SAAA_SCAN_EVERY) then {
    RECONDO_SAAA_SCAN_COUNTER = 0;
    call Recondo_fnc_saaaScanGuns;
};

private _airList = call Recondo_fnc_saaaGetAudibleAir;

{
    [_x, _airList] call Recondo_fnc_saaaPrepTick;
} forEach RECONDO_SAAA_GUNS;

if (RECONDO_SAAA_DEBUG) then {
    call Recondo_fnc_saaaDebugDraw;
} else {
    // debug turned off mid-mission -> clear stale markers once
    if (!(RECONDO_SAAA_DBG_MARKERS isEqualTo [])) then {
        { deleteMarkerLocal _x } forEach RECONDO_SAAA_DBG_MARKERS;
        RECONDO_SAAA_DBG_MARKERS = [];
    };
};
