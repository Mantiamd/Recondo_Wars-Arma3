/*
    Recondo_fnc_handleIntelPickup
    Handles intel object interaction at camps
    
    Description:
        Called when a player picks up an intel object from a camp.
        Deletes the intel object, adds item to player inventory,
        and shows confirmation.
    
    Parameters:
        _target - OBJECT - The intel object being picked up
        _player - OBJECT - The player picking up the intel
    
    Returns:
        Nothing
    
    Example:
        [_intelObject, player] call Recondo_fnc_handleIntelPickup;
*/

params [
    ["_target", objNull, [objNull]],
    ["_player", objNull, [objNull]]
];

if (isNull _target || isNull _player) exitWith {};

// Get intel data from object
private _instanceId = _target getVariable ["RECONDO_CAMPS_instanceId", ""];
private _markerId = _target getVariable ["RECONDO_CAMPS_markerId", ""];
private _campName = _target getVariable ["RECONDO_CAMPS_campName", "Intel"];
private _displayName = _target getVariable ["RECONDO_CAMPS_displayName", "Documents"];
private _itemClassname = _target getVariable ["RECONDO_CAMPS_itemClassname", ""];

// Add item to player inventory if specified
if (_itemClassname != "") then {
    // Check if item exists in config
    if (isClass (configFile >> "CfgWeapons" >> _itemClassname) || 
        isClass (configFile >> "CfgMagazines" >> _itemClassname) || 
        isClass (configFile >> "CfgVehicles" >> _itemClassname)) then {
        _player addItem _itemClassname;
    };
};

// Show pickup hint
private _hint = format [
    "<t size='1.2' color='#90EE90'>Intel Retrieved</t><br/><br/><t size='0.9'>%1</t><br/><t size='0.8' color='#888888'>Return to base to turn in.</t>",
    _displayName
];
hint parseText _hint;

// Delete intel object (run on server)
if (isServer) then {
    // Remove from tracking array
    RECONDO_CAMPSRANDOM_INTEL_OBJECTS = RECONDO_CAMPSRANDOM_INTEL_OBJECTS - [_target];
    
    // Delete the object
    deleteVehicle _target;
} else {
    [_target] remoteExec ["deleteVehicle", 2];
};

// Log pickup
diag_log format ["[RECONDO_CAMPS] Player %1 picked up intel '%2' from %3", name _player, _displayName, _markerId];
