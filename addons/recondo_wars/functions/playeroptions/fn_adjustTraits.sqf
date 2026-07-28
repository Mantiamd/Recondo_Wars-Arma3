/*
    Recondo_fnc_adjustTraits
    Adjusts player traits (camouflage and audible coefficients)
    
    Description:
        Sets player camouflageCoef and audibleCoef traits.
        These affect how easily AI can detect the player.
        Uses the default coefficients unless the player's unit classname
        is listed in the trait override list (e.g., pilot slots), in which
        case the override coefficients are applied instead.
        Runs on clients with interface.
    
    Parameters:
        None (uses global RECONDO_PLAYEROPTIONS_SETTINGS)
        
    Returns:
        Nothing
*/

if (!hasInterface) exitWith {};

// Selects the trait pool per unit so respawning into a different slot picks the right pool
Recondo_fnc_applyPlayerTraits = {
    params ["_unit"];
    
    private _settings = RECONDO_PLAYEROPTIONS_SETTINGS;
    private _debug = _settings get "enableDebug";
    
    private _camouflageCoef = _settings get "camouflageCoef";
    private _audibleCoef = _settings get "audibleCoef";
    private _overrideClassnames = _settings getOrDefault ["traitOverrideClassnamesArray", []];
    private _isOverride = (toLower typeOf _unit) in _overrideClassnames;
    
    if (_isOverride) then {
        _camouflageCoef = _settings get "overrideCamouflageCoef";
        _audibleCoef = _settings get "overrideAudibleCoef";
    };
    
    _unit setUnitTrait ["camouflageCoef", _camouflageCoef];
    _unit setUnitTrait ["audibleCoef", _audibleCoef];
    
    if (_debug) then {
        diag_log format ["[RECONDO_PLAYEROPTIONS] Player traits set (%1 pool, unit: %2) - Camo: %3, Audible: %4", ["default", "override"] select _isOverride, typeOf _unit, _camouflageCoef, _audibleCoef];
    };
};

// Wait for player to exist
[{!isNull player && {alive player}}, {
    [player] call Recondo_fnc_applyPlayerTraits;
    
    // Re-apply on respawn
    player addEventHandler ["Respawn", {
        params ["_unit"];
        
        private _settings = RECONDO_PLAYEROPTIONS_SETTINGS;
        if (!isNil "_settings" && {_settings get "enableTraits"}) then {
            [_unit] call Recondo_fnc_applyPlayerTraits;
        };
    }];
    
}, []] call CBA_fnc_waitUntilAndExecute;
