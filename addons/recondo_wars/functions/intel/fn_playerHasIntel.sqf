/*
    Recondo_fnc_playerHasIntel
    Checks if a player has any intel items in their inventory
    
    Description:
        Checks the player's inventory for any items (CfgWeapons) or
        magazines (CfgMagazines) that are registered as intel items,
        or items containing "intel" in their classname as a fallback.
    
    Parameters:
        _player - OBJECT - The player to check
    
    Returns:
        BOOL - True if player has at least one intel item
    
    Example:
        [player] call Recondo_fnc_playerHasIntel;
*/

params [["_player", objNull, [objNull]]];

if (isNull _player) exitWith {
    false
};

// Get all items AND magazines in player inventory
private _items = items _player;
private _mags = magazines _player;

// Get configured intel items
private _intelItems = if (isNil "RECONDO_INTEL_ITEMS") then { [] } else { RECONDO_INTEL_ITEMS };

// Check for specific configured intel items
private _hasIntel = false;
if (count _intelItems > 0) then {
    // Check items (CfgWeapons)
    {
        if (_x in _intelItems) exitWith {
            _hasIntel = true;
        };
    } forEach _items;
    
    // Check magazines (CfgMagazines) if not found in items
    if (!_hasIntel) then {
        {
            if (_x in _intelItems) exitWith {
                _hasIntel = true;
            };
        } forEach _mags;
    };
};

// Also check for items/mags with "intel" in classname as fallback
if (!_hasIntel) then {
    {
        if ((toLower _x) find "intel" != -1) exitWith {
            _hasIntel = true;
        };
    } forEach _items;
    
    if (!_hasIntel) then {
        {
            if ((toLower _x) find "intel" != -1) exitWith {
                _hasIntel = true;
            };
        } forEach _mags;
    };
};

_hasIntel
