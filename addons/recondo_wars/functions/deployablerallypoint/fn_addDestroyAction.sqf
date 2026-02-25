/*
    Recondo_fnc_addDestroyAction
    Add ACE "Destroy Rally Point" action to a rally tent
    
    Description:
        Called via remoteExec on all clients to add the ACE destroy action
        to a rally point object. This action is available to ANY player
        regardless of side, allowing enemies to sabotage rally points.
    
    Parameters:
        0: OBJECT - The rally tent object
    
    Returns:
        Nothing
    
    Execution:
        Client-side (called via remoteExec from server)
*/

params [["_tent", objNull, [objNull]]];

// Only run on clients with interface
if (!hasInterface) exitWith {};

// Validate tent
if (isNull _tent) exitWith {};

// Check if already has destroy action (prevent duplicates)
if (_tent getVariable ["RECONDO_DRP_HAS_DESTROY_ACTION", false]) exitWith {};
_tent setVariable ["RECONDO_DRP_HAS_DESTROY_ACTION", true];

// Create ACE action for manual destruction (available to ANY player)
private _destroyAction = [
    "Recondo_DRP_DestroyRally",
    "<t color='#FF0000'>Destroy Rally Point</t>",
    "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\destroy_ca.paa",
    {
        params ["_target", "_player", "_params"];
        
        // Request server to remove rally
        [_target] remoteExec ["Recondo_fnc_removeRallypoint", 2];
        
        hint "Rally point destroyed!";
    },
    {
        // Condition: Always available (any player can destroy)
        true
    }
] call ace_interact_menu_fnc_createAction;

[_tent, 0, ["ACE_MainActions"], _destroyAction, true] call ace_interact_menu_fnc_addActionToObject;

private _settings = missionNamespace getVariable ["RECONDO_DRP_SETTINGS", nil];
if (!isNil "_settings" && {_settings get "enableDebug"}) then {
    diag_log format ["[RECONDO_DRP] Added ACE destroy action to rally object: %1", _tent];
};
