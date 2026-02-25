/*
    Recondo_fnc_checkPlayerInventory
    Periodic inventory check and enforcement
    
    Description:
        Checks the player's inventory against configured limitations.
        Removes excess items silently if count exceeds the limit.
        Runs on client for the local player only.
    
    Parameters:
        None (uses global RECONDO_PLAYERLIMITS_SETTINGS)
        
    Returns:
        Nothing
*/

if (!hasInterface) exitWith {};
if (isNull player) exitWith {};

private _settings = RECONDO_PLAYERLIMITS_SETTINGS;
if (isNil "_settings") exitWith {};

private _debug = _settings get "enableDebug";
private _limitations = _settings get "limitations";

if (count _limitations == 0) exitWith {};

// Get all items in player's inventory (uniform, vest, backpack)
// Note: Container items already include magazines/grenades stored within them
private _allItems = [];

// Items in uniform (includes magazines/grenades)
private _uniformItems = uniformItems player;
_allItems append _uniformItems;

// Items in vest (includes magazines/grenades)
private _vestItems = vestItems player;
_allItems append _vestItems;

// Items in backpack (includes magazines/grenades)
private _backpackItems = backpackItems player;
_allItems append _backpackItems;

// Build a count map of all items
private _itemCounts = createHashMap;
{
    private _item = _x;
    private _currentCount = _itemCounts getOrDefault [_item, 0];
    _itemCounts set [_item, _currentCount + 1];
} forEach _allItems;

// Check each limitation
{
    _x params ["_pattern", "_maxLimit"];
    
    // Find all items that match this pattern
    private _matchingItems = [];
    {
        private _itemClass = _x;
        if ([_itemClass, _pattern] call Recondo_fnc_matchesPattern) then {
            _matchingItems pushBackUnique _itemClass;
        };
    } forEach (keys _itemCounts);
    
    // Calculate total count of matching items
    private _totalCount = 0;
    {
        _totalCount = _totalCount + (_itemCounts get _x);
    } forEach _matchingItems;
    
    // Check if over limit
    if (_totalCount > _maxLimit) then {
        private _toRemove = _totalCount - _maxLimit;
        
        if (_debug) then {
            diag_log format ["[RECONDO_PLAYERLIMITS] Over limit for pattern '%1': %2/%3. Removing %4 item(s).", _pattern, _totalCount, _maxLimit, _toRemove];
        };
        
        // Remove excess items (silently)
        private _removed = 0;
        
        scopeName "itemLoop";
        
        {
            private _itemClass = _x;
            
            // Keep removing while we haven't hit our target
            while {_removed < _toRemove} do {
                // Get current count before removal attempt
                private _countBefore = (
                    ({_x == _itemClass} count (magazines player)) +
                    ({_x == _itemClass} count (uniformItems player)) +
                    ({_x == _itemClass} count (vestItems player)) +
                    ({_x == _itemClass} count (backpackItems player))
                );
                
                // Nothing left to remove of this type
                if (_countBefore == 0) exitWith {};
                
                // Determine if it's a magazine or item and remove appropriately
                private _isMagazine = _itemClass in (magazines player);
                
                if (_isMagazine) then {
                    // Grenades, ammo, etc. are magazines
                    player removeMagazine _itemClass;
                } else {
                    // Regular items - try specific containers first
                    if (_itemClass in (uniformItems player)) then {
                        player removeItemFromUniform _itemClass;
                    } else {
                        if (_itemClass in (vestItems player)) then {
                            player removeItemFromVest _itemClass;
                        } else {
                            if (_itemClass in (backpackItems player)) then {
                                player removeItemFromBackpack _itemClass;
                            } else {
                                // Fallback
                                player removeItem _itemClass;
                            };
                        };
                    };
                };
                
                // Verify removal actually happened
                private _countAfter = (
                    ({_x == _itemClass} count (magazines player)) +
                    ({_x == _itemClass} count (uniformItems player)) +
                    ({_x == _itemClass} count (vestItems player)) +
                    ({_x == _itemClass} count (backpackItems player))
                );
                
                if (_countAfter < _countBefore) then {
                    _removed = _removed + 1;
                    
                    if (_debug) then {
                        diag_log format ["[RECONDO_PLAYERLIMITS] Removed 1x %1 (total removed: %2/%3)", _itemClass, _removed, _toRemove];
                    };
                } else {
                    // Removal failed - exit to prevent infinite loop
                    if (_debug) then {
                        diag_log format ["[RECONDO_PLAYERLIMITS] WARNING: Could not remove %1 from inventory", _itemClass];
                    };
                    breakTo "itemLoop";
                };
            };
            
            if (_removed >= _toRemove) then { breakTo "itemLoop" };
            
        } forEach _matchingItems;
        
        if (_debug) then {
            diag_log format ["[RECONDO_PLAYERLIMITS] Enforcement complete. Removed %1 item(s) matching '%2'.", _removed, _pattern];
        };
    };
} forEach _limitations;
