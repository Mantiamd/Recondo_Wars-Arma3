/*
    Recondo_fnc_addStaboAnchorAction
    Adds ACE interaction to STABO anchor (client-side)
    
    Description:
        Called via remoteExec on all clients to add the "Attach to STABO"
        ACE interaction to the visible anchor object. This ensures the
        action is available on dedicated servers where the anchor is
        created server-side.
        
    Parameters:
        0: STRING - NetId of the visible anchor object
        1: NUMBER - Attach distance (meters)
        2: NUMBER - Maximum attachments allowed
        
    Returns:
        Nothing
        
    Example:
        [netId _visibleAnchor, 5, 4] remoteExec ["Recondo_fnc_addStaboAnchorAction", 0, true];
*/

params [
    ["_anchorNetId", "", [""]],
    ["_attachDistance", 5, [0]],
    ["_maxAttachments", 4, [0]]
];

if (!hasInterface) exitWith {}; // Only run on clients with interface

// Resolve object from netId
private _visibleAnchor = objectFromNetId _anchorNetId;

if (isNull _visibleAnchor) exitWith {
    diag_log format ["[RECONDO_STABO] ERROR: Could not find anchor from netId: %1", _anchorNetId];
};

// Check if action already added
if (_visibleAnchor getVariable ["RECONDO_STABO_ActionAdded", false]) exitWith {};
_visibleAnchor setVariable ["RECONDO_STABO_ActionAdded", true];

diag_log format ["[RECONDO_STABO] Client: Adding ACE action to anchor %1", _visibleAnchor];

// Create the ACE action
private _attachAction = [
    "RECONDO_STABO_Attach",
    "Attach to STABO",
    "\a3\ui_f\data\IGUI\Cfg\Actions\arrow_up_gs.paa",
    {
        params ["_target", "_player", "_params"];
        private _heli = _target getVariable ["RECONDO_STABO_Helicopter", objNull];
        private _helper = _heli getVariable ["RECONDO_STABO_Helper", objNull];
        [_player, _heli, _helper] call Recondo_fnc_attachToStabo;
    },
    {
        params ["_target", "_player", "_params"];
        _params params ["_attachDist", "_maxAttach"];
        
        // Check distance to anchor
        if (_player distance _target > _attachDist) exitWith { false };
        
        // Check if STABO still deployed
        private _heli = _target getVariable ["RECONDO_STABO_Helicopter", objNull];
        if (isNull _heli) exitWith { false };
        if !(_heli getVariable ["RECONDO_STABO_Deployed", false]) exitWith { false };
        
        // Check if player is already attached
        private _attached = _heli getVariable ["RECONDO_STABO_AttachedUnits", []];
        private _alreadyAttached = _attached findIf { (_x select 0) == _player } != -1;
        if (_alreadyAttached) exitWith { false };
        
        // Check if max attachments reached
        if (count _attached >= _maxAttach) exitWith { false };
        
        true
    },
    {},
    [_attachDistance, _maxAttachments]
] call ace_interact_menu_fnc_createAction;

// Add the action to the anchor object
[_visibleAnchor, 0, ["ACE_MainActions"], _attachAction] call ace_interact_menu_fnc_addActionToObject;

diag_log format ["[RECONDO_STABO] Client: ACE action added to anchor %1", _visibleAnchor];
