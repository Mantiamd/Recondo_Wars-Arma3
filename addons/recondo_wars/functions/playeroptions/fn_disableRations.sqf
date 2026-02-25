/*
    Recondo_fnc_disableRations
    Disables ACE Field Rations for specified unit classnames
    
    Description:
        Checks if player's unit classname is in the exempt list.
        If so, disables ACE hunger/thirst effects for that player
        using ACE's official status modifier API.
    
    Parameters:
        None (uses global RECONDO_PLAYEROPTIONS_SETTINGS)
        
    Returns:
        Nothing
*/

if (!hasInterface) exitWith {};

private _settings = RECONDO_PLAYEROPTIONS_SETTINGS;
private _debug = _settings get "enableDebug";

private _exemptUnits = _settings get "rationsExemptUnitsArray";

// Validate configuration
if (count _exemptUnits == 0) exitWith {
    if (_debug) then {
        diag_log "[RECONDO_PLAYEROPTIONS] Rations exemption disabled - no units configured";
    };
};

// Convert exempt units to lowercase for case-insensitive comparison
private _exemptUnitsLower = _exemptUnits apply { toLower _x };

// Function to check if player should be exempt from rations (case-insensitive)
RECONDO_PO_fnc_shouldExemptRations = {
    private _unitClass = toLower (typeOf player);
    private _exemptUnits = (RECONDO_PLAYEROPTIONS_SETTINGS get "rationsExemptUnitsArray") apply { toLower _x };
    _unitClass in _exemptUnits
};

// Function to disable rations for player using ACE's official API
RECONDO_PO_fnc_disableRationsForPlayer = {
    // Check if ACE Field Rations status modifier function exists
    if (isNil "ace_field_rations_fnc_addStatusModifier") exitWith {
        if (RECONDO_PLAYEROPTIONS_SETTINGS get "enableDebug") then {
            diag_log "[RECONDO_PLAYEROPTIONS] ACE Field Rations not loaded or API not available - skipping rations exemption";
        };
    };
    
    // Create unique variable name for this player
    private _varName = format ["RECONDO_rations_immune_%1", getPlayerUID player];
    missionNamespace setVariable [_varName, player];
    
    // Add status modifier for hunger (type 2)
    // Returning -10 completely negates any hunger gain
    [2, compile format ["
        if (_this == (missionNamespace getVariable ['%1', objNull])) then {
            -10
        } else {
            0
        };
    ", _varName]] call ace_field_rations_fnc_addStatusModifier;
    
    // Add status modifier for thirst (type 3)
    // Returning -10 completely negates any thirst gain
    [3, compile format ["
        if (_this == (missionNamespace getVariable ['%1', objNull])) then {
            -10
        } else {
            0
        };
    ", _varName]] call ace_field_rations_fnc_addStatusModifier;
    
    if (RECONDO_PLAYEROPTIONS_SETTINGS get "enableDebug") then {
        diag_log format ["[RECONDO_PLAYEROPTIONS] ACE Rations disabled for player %1 (%2) using status modifiers", name player, typeOf player];
    };
};

// Wait for player initialization
[{!isNull player && {alive player}}, {
    params ["_debug", "_exemptUnitsLower"];
    
    // Check and apply exemption
    if (call RECONDO_PO_fnc_shouldExemptRations) then {
        // Delay to ensure ACE is fully initialized
        [{
            call RECONDO_PO_fnc_disableRationsForPlayer;
        }, [], 3] call CBA_fnc_waitAndExecute;
        
        // Re-apply on respawn (status modifiers may need to be re-added)
        player addEventHandler ["Respawn", {
            if (call RECONDO_PO_fnc_shouldExemptRations) then {
                [{
                    call RECONDO_PO_fnc_disableRationsForPlayer;
                }, [], 2] call CBA_fnc_waitAndExecute;
            };
        }];
        
        if (_debug) then {
            diag_log format ["[RECONDO_PLAYEROPTIONS] Player %1 (%2) matched exempt list - rations will be disabled", name player, typeOf player];
        };
    } else {
        if (_debug) then {
            diag_log format ["[RECONDO_PLAYEROPTIONS] Player %1 (%2) not in exempt list: %3", name player, toLower (typeOf player), _exemptUnitsLower];
        };
    };
    
}, [_debug, _exemptUnitsLower]] call CBA_fnc_waitUntilAndExecute;

if (_debug) then {
    diag_log format ["[RECONDO_PLAYEROPTIONS] Rations exemption initialized. Exempt units (lowercase): %1", _exemptUnitsLower];
};
