/*
    Recondo_fnc_initPlayerLimitations
    Client-side initialization for Player Limitations
    
    Description:
        Waits for settings to be available from server, then starts
        the periodic inventory check loop for affected players.
    
    Parameters:
        None (uses global RECONDO_PLAYERLIMITS_SETTINGS)
        
    Returns:
        Nothing
*/

if (!hasInterface) exitWith {};

// Wait for settings to be broadcast from server
[{
    !isNil "RECONDO_PLAYERLIMITS_SETTINGS"
}, {
    // Exit if settings never arrived
    if (isNil "RECONDO_PLAYERLIMITS_SETTINGS") exitWith {
        diag_log "[RECONDO_PLAYERLIMITS] No Player Limitations module placed.";
    };
    
    private _settings = RECONDO_PLAYERLIMITS_SETTINGS;
    private _debug = _settings get "enableDebug";
    private _limitations = _settings get "limitations";
    
    // Exit if no limitations configured
    if (count _limitations == 0) exitWith {
        if (_debug) then {
            diag_log "[RECONDO_PLAYERLIMITS] No item limitations configured. Client init skipped.";
        };
    };
    
    // Convert side number to side type for comparison
    private _sideNum = _settings get "allowedSideNum";
    private _allowedSide = switch (_sideNum) do {
        case 0: { east };
        case 1: { west };
        case 2: { independent };
        case 3: { civilian };
        default { sideUnknown }; // 4 = Any side
    };
    
    // Wait for player to be initialized
    [{!isNull player}, {
        params ["_settings", "_allowedSide", "_debug"];
        
        private _checkInterval = _settings get "checkInterval";
        
        // Check if player is on the affected side (or any side if sideUnknown)
        private _playerSide = side player;
        private _isAffected = (_allowedSide == sideUnknown) || (_playerSide == _allowedSide);
        
        if (!_isAffected) exitWith {
            if (_debug) then {
                diag_log format ["[RECONDO_PLAYERLIMITS] Player side (%1) not affected. Side filter: %2", _playerSide, _allowedSide];
            };
        };
        
        if (_debug) then {
            diag_log format ["[RECONDO_PLAYERLIMITS] Player side (%1) is affected. Starting periodic check every %2 seconds.", _playerSide, _checkInterval];
        };
        
        // Start the periodic check handler
        RECONDO_PLAYERLIMITS_HANDLER = [{
            [] call Recondo_fnc_checkPlayerInventory;
        }, _checkInterval, []] call CBA_fnc_addPerFrameHandler;
        
    }, [_settings, _allowedSide, _debug]] call CBA_fnc_waitUntilAndExecute;
    
}, [], 30] call CBA_fnc_waitUntilAndExecute;
