/*
    Recondo_fnc_rpTakeItem
    Take an unlocked item from the shop
    
    Description:
        Called when player clicks the Take button in the shop.
        Adds the item to player's inventory if they have room.
        Client-side function.
    
    Parameters:
        None (reads from dialog)
    
    Returns:
        Nothing
    
    Example:
        [] call Recondo_fnc_rpTakeItem;
*/

if (!hasInterface) exitWith {};

private _display = findDisplay 58200;
if (isNull _display) exitWith {};

// Get selected item
private _categoryList = _display displayCtrl 58210;
private _itemsList = _display displayCtrl 58211;

private _selCat = lbCurSel _categoryList;
private _selItem = lbCurSel _itemsList;

if (_selCat < 0 || _selItem < 0) exitWith {
    hint "No item selected.";
};

private _catId = _categoryList lbData _selCat;
private _classname = _itemsList lbData _selItem;

// Check if player has this unlocked
private _uid = getPlayerUID player;
private _playerData = RECONDO_RP_PLAYER_DATA getOrDefault [_uid, createHashMap];
private _unlocks = _playerData getOrDefault ["unlocks", []];

if !(_classname in _unlocks) exitWith {
    hint "Item not unlocked!";
};

// Find item data for display name
private _items = RECONDO_RP_ITEMS getOrDefault [_catId, []];
private _displayName = _classname;

{
    _x params ["_cls", "_name", "_cost"];
    if (_cls == _classname) exitWith {
        _displayName = _name;
    };
} forEach _items;

// Add item based on category
private _success = false;

switch (_catId) do {
    case "PRIMARY";
    case "SECONDARY";
    case "HANDGUN": {
        // Weapons - addWeapon handles slot assignment
        player addWeapon _classname;
        _success = true;
    };
    
    case "UNIFORM": {
        // Uniforms - must swap
        private _oldItems = uniformItems player;
        
        player forceAddUniform _classname;
        
        // Try to restore old items
        {
            player addItemToUniform _x;
        } forEach _oldItems;
        
        _success = true;
    };
    
    case "VEST": {
        // Vests - must swap
        private _oldItems = vestItems player;
        
        player addVest _classname;
        
        // Try to restore old items
        {
            player addItemToVest _x;
        } forEach _oldItems;
        
        _success = true;
    };
    
    case "BACKPACK": {
        // Backpacks - must swap
        private _oldItems = backpackItems player;
        
        removeBackpack player;
        player addBackpack _classname;
        
        // Try to restore old items
        {
            player addItemToBackpack _x;
        } forEach _oldItems;
        
        _success = true;
    };
    
    case "HEADGEAR": {
        removeHeadgear player;
        player addHeadgear _classname;
        _success = true;
    };
    
    case "GOGGLES": {
        removeGoggles player;
        player addGoggles _classname;
        _success = true;
    };
    
    case "ATTACH": {
        // Attachments - add to inventory
        if (player canAdd _classname) then {
            player addItem _classname;
            _success = true;
        } else {
            hint "No room for attachment!";
        };
    };
    
    case "MAGS": {
        // Magazines - add to inventory
        if (player canAdd _classname) then {
            player addMagazine _classname;
            _success = true;
        } else {
            hint "No room for magazine!";
        };
    };
    
    case "ITEMS": {
        // Generic items
        if (player canAdd _classname) then {
            player addItem _classname;
            _success = true;
        } else {
            hint "No room for item!";
        };
    };
    
    default {
        // Fallback - try generic add
        if (player canAdd _classname) then {
            player addItem _classname;
            _success = true;
        } else {
            hint "Cannot add item!";
        };
    };
};

if (_success) then {
    hint format ["Added: %1", _displayName];
};
