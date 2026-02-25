/*
    Recondo_fnc_rpUnlockItem
    Unlock item from the shop dialog
    
    Description:
        Called when player clicks the Unlock button in the shop.
        Sends unlock request to server.
        Client-side function.
    
    Parameters:
        None (reads from dialog)
    
    Returns:
        Nothing
    
    Example:
        [] call Recondo_fnc_rpUnlockItem;
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

// Find item data to get cost
private _items = RECONDO_RP_ITEMS getOrDefault [_catId, []];
private _itemData = [];

{
    _x params ["_cls", "_name", "_cost"];
    if (_cls == _classname) exitWith {
        _itemData = _x;
    };
} forEach _items;

if (count _itemData == 0) exitWith {
    hint "Error: Item data not found.";
};

_itemData params ["_cls", "_name", "_cost"];

// Check if already unlocked locally
private _uid = getPlayerUID player;
private _playerData = RECONDO_RP_PLAYER_DATA getOrDefault [_uid, createHashMap];
private _unlocks = _playerData getOrDefault ["unlocks", []];

if (_classname in _unlocks) exitWith {
    hint "Item already unlocked.";
};

// Check if can afford locally
private _points = _playerData getOrDefault ["points", 0];
if (_points < _cost) exitWith {
    hint format ["Not enough RP! Need %1, have %2.", _cost, _points];
};

// Send unlock request to server
[player, _classname, _cost] remoteExec ["Recondo_fnc_rpSpendPoints", 2];

// Optimistic UI update - assume success
hint format ["Unlocking %1...", _name];

// Refresh dialog after small delay to allow server response
[{
    // Force category refresh by clearing cached cat
    private _display = findDisplay 58200;
    if (isNull _display) exitWith {};
    
    private _itemsList = _display displayCtrl 58211;
    _itemsList setVariable ["RECONDO_RP_CURRENT_CAT", ""];
    
    [] call Recondo_fnc_rpRefreshUnlockShop;
}, [], 0.5] call CBA_fnc_waitAndExecute;
