/*
    Recondo_fnc_rpRefreshUnlockShop
    Refresh the unlock shop item list and info panel
    
    Description:
        Updates the items list based on selected category,
        and updates the info panel based on selected item.
        Called when category or item selection changes.
        Client-side function.
    
    Parameters:
        None
    
    Returns:
        Nothing
    
    Example:
        [] call Recondo_fnc_rpRefreshUnlockShop;
*/

if (!hasInterface) exitWith {};

private _display = findDisplay 58200;
if (isNull _display) exitWith {};

// Get controls
private _categoryList = _display displayCtrl 58210;
private _itemsList = _display displayCtrl 58211;
private _balanceText = _display displayCtrl 58202;
private _infoName = _display displayCtrl 58220;
private _infoClass = _display displayCtrl 58221;
private _infoCost = _display displayCtrl 58222;
private _infoStatus = _display displayCtrl 58223;
private _unlockBtn = _display displayCtrl 58230;
private _takeBtn = _display displayCtrl 58231;

// Get player data
private _uid = getPlayerUID player;
private _playerData = if (isNil "RECONDO_RP_PLAYER_DATA") then { createHashMap } else {
    RECONDO_RP_PLAYER_DATA getOrDefault [_uid, createHashMap]
};
private _points = _playerData getOrDefault ["points", 0];
private _unlocks = _playerData getOrDefault ["unlocks", []];

// Update balance
_balanceText ctrlSetText format ["Balance: %1 RP", _points];

// Get selected category
private _selCat = lbCurSel _categoryList;
if (_selCat < 0) exitWith {
    lbClear _itemsList;
    _infoName ctrlSetText "";
    _infoClass ctrlSetText "";
    _infoCost ctrlSetText "";
    _infoStatus ctrlSetText "";
    _unlockBtn ctrlEnable false;
    _takeBtn ctrlEnable false;
};

private _catId = _categoryList lbData _selCat;
private _items = RECONDO_RP_ITEMS getOrDefault [_catId, []];

// Check if we need to repopulate items (category changed)
private _currentCat = _itemsList getVariable ["RECONDO_RP_CURRENT_CAT", ""];
if (_currentCat != _catId) then {
    // Category changed, repopulate items
    lbClear _itemsList;
    
    {
        _x params ["_classname", "_displayName", "_cost"];
        
        private _isUnlocked = _classname in _unlocks;
        private _canAfford = _points >= _cost;
        
        // Format display text with status
        private _text = if (_isUnlocked) then {
            format ["[✓] %1", _displayName]
        } else {
            format ["%1 (%2 RP)", _displayName, _cost]
        };
        
        private _idx = _itemsList lbAdd _text;
        _itemsList lbSetData [_idx, _classname];
        
        // Color based on status
        if (_isUnlocked) then {
            _itemsList lbSetColor [_idx, [0.5, 1, 0.5, 1]];  // Green for unlocked
        } else {
            if (_canAfford) then {
                _itemsList lbSetColor [_idx, [1, 1, 1, 1]];  // White for affordable
            } else {
                _itemsList lbSetColor [_idx, [0.6, 0.4, 0.4, 1]];  // Dim red for unaffordable
            };
        };
        
    } forEach _items;
    
    _itemsList setVariable ["RECONDO_RP_CURRENT_CAT", _catId];
    
    // Select first item if available
    if (lbSize _itemsList > 0) then {
        _itemsList lbSetCurSel 0;
    };
};

// Update info panel based on selected item
private _selItem = lbCurSel _itemsList;
if (_selItem < 0) exitWith {
    _infoName ctrlSetText "";
    _infoClass ctrlSetText "";
    _infoCost ctrlSetText "";
    _infoStatus ctrlSetText "";
    _unlockBtn ctrlEnable false;
    _takeBtn ctrlEnable false;
};

private _classname = _itemsList lbData _selItem;

// Find item data
private _itemData = [];
{
    _x params ["_cls", "_name", "_cost"];
    if (_cls == _classname) exitWith {
        _itemData = _x;
    };
} forEach _items;

if (count _itemData == 0) exitWith {
    _infoName ctrlSetText "Unknown item";
    _infoClass ctrlSetText "";
    _infoCost ctrlSetText "";
    _infoStatus ctrlSetText "";
    _unlockBtn ctrlEnable false;
    _takeBtn ctrlEnable false;
};

_itemData params ["_cls", "_name", "_cost"];
private _isUnlocked = _cls in _unlocks;
private _canAfford = _points >= _cost;

// Update info panel
_infoName ctrlSetText _name;
_infoClass ctrlSetText format ["(%1)", _cls];
_infoCost ctrlSetText format ["%1 RP", _cost];

// Update status and buttons
if (_isUnlocked) then {
    _infoStatus ctrlSetText "UNLOCKED";
    _infoStatus ctrlSetTextColor [0.5, 1, 0.5, 1];
    _unlockBtn ctrlEnable false;
    _takeBtn ctrlEnable true;
} else {
    if (_canAfford) then {
        _infoStatus ctrlSetText "Available";
        _infoStatus ctrlSetTextColor [1, 1, 0.5, 1];
        _unlockBtn ctrlEnable true;
    } else {
        _infoStatus ctrlSetText format ["Need %1 more RP", _cost - _points];
        _infoStatus ctrlSetTextColor [1, 0.4, 0.4, 1];
        _unlockBtn ctrlEnable false;
    };
    _takeBtn ctrlEnable false;
};
