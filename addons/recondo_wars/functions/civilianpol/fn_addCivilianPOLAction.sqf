/*
    Recondo_fnc_addCivilianPOLAction
    Add ACE interaction action to POL civilians
    
    Description:
        Client-side function that adds an ACE action to interact with
        POL civilians. When interacted with, civilian responds and may
        give documents.
    
    Parameters:
        None (runs on all clients)
    
    Returns:
        Nothing
*/

if (!hasInterface) exitWith {};

// Wait for settings to be available
[{!isNil "RECONDO_CIVPOL_SETTINGS"}, {
    
    // Skip if already added
    if (!isNil "RECONDO_CIVPOL_ACTIONS_ADDED") exitWith {};
    RECONDO_CIVPOL_ACTIONS_ADDED = true;
    
    private _debugLogging = RECONDO_CIVPOL_SETTINGS getOrDefault ["debugLogging", false];
    
    // ========================================
    // CREATE ACE ACTION
    // ========================================
    
    private _talkAction = [
        "Recondo_CivPOL_Talk",
        "Talk to Civilian",
        "\a3\ui_f\data\IGUI\Cfg\Actions\talk_ca.paa",
        // Statement - what happens when action is used
        {
            params ["_target", "_player"];
            [_target, _player] call Recondo_fnc_civilianPOLInteract;
        },
        // Condition - when action is available
        {
            params ["_target", "_player"];
            
            // Check if this is a POL civilian
            private _markerName = _target getVariable ["RECONDO_CIVPOL_VillageMarker", ""];
            private _isAlive = alive _target;
            private _isFleeing = _target getVariable ["RECONDO_CIVPOL_Fleeing", false];
            
            (_markerName != "") && _isAlive && !_isFleeing
        },
        {},     // Insert children
        [],     // Action params
        [0, 0, 0.5], // Position offset
        4       // Distance
    ] call ace_interact_menu_fnc_createAction;
    
    // Add to CAManBase class so it appears on all units
    ["CAManBase", 0, ["ACE_MainActions"], _talkAction] call ace_interact_menu_fnc_addActionToClass;
    
    if (_debugLogging) then {
        diag_log "[RECONDO_CIVPOL] ACE interaction action added to CAManBase";
    };
    
}] call CBA_fnc_waitUntilAndExecute;
