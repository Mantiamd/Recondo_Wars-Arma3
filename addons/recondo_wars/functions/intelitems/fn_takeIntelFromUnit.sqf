/*
    Recondo_fnc_takeIntelFromUnit
    Server-side: Transfers an intel item from a unit to a player
    
    Description:
        Removes one intel item of the specified type from the unit
        and adds it to the player's inventory. Updates the unit's
        intel inventory tracking variable.
    
    Parameters:
        _unit - OBJECT - The unit to take intel from
        _player - OBJECT - The player receiving the intel
        _displayName - STRING - Display name of the item
        _classname - STRING - Classname of the item
    
    Returns:
        Nothing
    
    Example:
        [_unit, player, "Mobile Phone", "ACE_Cellphone"] remoteExec ["Recondo_fnc_takeIntelFromUnit", 2];
*/

if (!isServer) exitWith {};

params [
    ["_unit", objNull, [objNull]],
    ["_player", objNull, [objNull]],
    ["_displayName", "", [""]],
    ["_classname", "", [""]]
];

if (isNull _unit || isNull _player || _classname == "") exitWith {};

private _debugLogging = if (isNil "RECONDO_INTELITEMS_SETTINGS") then {
    false
} else {
    RECONDO_INTELITEMS_SETTINGS getOrDefault ["debugLogging", false]
};

// Get unit's intel inventory
private _inventory = _unit getVariable ["RECONDO_INTELITEMS_inventory", []];

// Find and remove one item of this type
private _foundIndex = -1;
{
    if ((_x select 1) == _classname) exitWith {
        _foundIndex = _forEachIndex;
    };
} forEach _inventory;

if (_foundIndex == -1) exitWith {
    if (_debugLogging) then {
        diag_log format ["[RECONDO_INTELITEMS] takeIntelFromUnit - Item %1 not found on unit %2", _classname, _unit];
    };
};

// Verify item actually exists in unit's actual inventory (not already manually looted)
if !(_classname in (items _unit + magazines _unit)) exitWith {
    // Item was manually looted - clean up tracking array but don't give duplicate
    _inventory deleteAt _foundIndex;
    _unit setVariable ["RECONDO_INTELITEMS_inventory", _inventory, true];
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_INTELITEMS] takeIntelFromUnit - Item %1 already looted from unit %2, cleaned up tracking", _classname, _unit];
    };
    
    // Notify player
    ["Item already taken."] remoteExec ["hint", _player];
};

// Remove from tracking array
_inventory deleteAt _foundIndex;
_unit setVariable ["RECONDO_INTELITEMS_inventory", _inventory, true];

// Remove item from unit's actual inventory
_unit removeItem _classname;

// Add item to player's inventory - must execute where player is local
[_classname] remoteExec ["Recondo_fnc_addItemToPlayerClient", _player];

// Also add to the Intel system's recognized items if not already there
if (!isNil "RECONDO_INTEL_ITEMS" && {!(_classname in RECONDO_INTEL_ITEMS)}) then {
    RECONDO_INTEL_ITEMS pushBack _classname;
    publicVariable "RECONDO_INTEL_ITEMS";
};

// Notify player
private _message = format ["Acquired: %1", _displayName];
[_message] remoteExec ["hint", _player];

if (_debugLogging) then {
    diag_log format ["[RECONDO_INTELITEMS] Player %1 took '%2' (%3) from unit %4. Remaining intel on unit: %5",
        name _player, _displayName, _classname, _unit, count _inventory];
};
