/*
    Recondo_fnc_addItemToPlayerClient
    Client-side: Adds an item to the local player's inventory
    
    Description:
        Simple client-side function to add an item to the player's inventory.
        Called via remoteExec from server after validating intel pickup.
        This exists as a dedicated function because addItem must run
        where the player object is local (on their client machine).
    
    Parameters:
        _classname - STRING - The classname of the item to add
    
    Returns:
        Nothing
    
    Example:
        ["ACE_Cellphone"] remoteExec ["Recondo_fnc_addItemToPlayerClient", _player];
*/

if (!hasInterface) exitWith {};

params [["_classname", "", [""]]];

if (_classname == "") exitWith {};

// Add the item to the local player's inventory
player addItem _classname;
