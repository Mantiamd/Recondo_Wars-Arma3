/*
    Recondo_fnc_limitPainSounds
    Disables player pain/moan sounds completely
    
    Description:
        Permanently disables ACE Medical pain/groaning sounds by setting
        the sound timeout to an extremely high value.
    
    Parameters:
        None (uses global RECONDO_PLAYEROPTIONS_SETTINGS)
        
    Returns:
        Nothing
*/

if (!hasInterface) exitWith {};

private _settings = RECONDO_PLAYEROPTIONS_SETTINGS;
private _debug = _settings get "enableDebug";

[{CBA_missionTime > 0}, {
    params ["_debug"];
    player setVariable ["ace_medical_feedback_soundTimeoutmoan", 1e10];
    
    if (_debug) then {
        diag_log "[RECONDO_PLAYEROPTIONS] Pain sounds disabled";
    };
}, [_debug]] call CBA_fnc_waitUntilAndExecute;
