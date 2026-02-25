/*
    Recondo_fnc_adjustTraits
    Adjusts player traits (camouflage and audible coefficients)
    
    Description:
        Sets player camouflageCoef and audibleCoef traits.
        These affect how easily AI can detect the player.
        Runs on clients with interface.
    
    Parameters:
        None (uses global RECONDO_PLAYEROPTIONS_SETTINGS)
        
    Returns:
        Nothing
*/

if (!hasInterface) exitWith {};

private _settings = RECONDO_PLAYEROPTIONS_SETTINGS;
private _debug = _settings get "enableDebug";

private _camouflageCoef = _settings get "camouflageCoef";
private _audibleCoef = _settings get "audibleCoef";

// Wait for player to exist
[{!isNull player && {alive player}}, {
    params ["_camouflageCoef", "_audibleCoef", "_debug"];
    
    player setUnitTrait ["camouflageCoef", _camouflageCoef];
    player setUnitTrait ["audibleCoef", _audibleCoef];
    
    if (_debug) then {
        diag_log format ["[RECONDO_PLAYEROPTIONS] Player traits set - Camo: %1, Audible: %2", _camouflageCoef, _audibleCoef];
    };
    
    // Re-apply on respawn
    player addEventHandler ["Respawn", {
        params ["_unit"];
        
        private _settings = RECONDO_PLAYEROPTIONS_SETTINGS;
        if (!isNil "_settings" && {_settings get "enableTraits"}) then {
            _unit setUnitTrait ["camouflageCoef", _settings get "camouflageCoef"];
            _unit setUnitTrait ["audibleCoef", _settings get "audibleCoef"];
            
            if (_settings get "enableDebug") then {
                diag_log "[RECONDO_PLAYEROPTIONS] Player traits re-applied after respawn";
            };
        };
    }];
    
}, [_camouflageCoef, _audibleCoef, _debug]] call CBA_fnc_waitUntilAndExecute;
