/*
    Recondo_fnc_rpOpenUnlockShop
    Open the Recon Points unlock shop dialog
    
    Description:
        Opens the unlock shop dialog and populates it with
        categories and items.
        Client-side function.
    
    Parameters:
        None
    
    Returns:
        Nothing
    
    Example:
        [] call Recondo_fnc_rpOpenUnlockShop;
*/

if (!hasInterface) exitWith {};

// Check if system is initialized
if (isNil "RECONDO_RP_ITEMS") exitWith {
    hint "Recon Points system not initialized.";
};

// Create dialog
createDialog "RscReconPointsShop";

// Small delay for dialog to fully create
[{
    private _display = findDisplay 58200;
    if (isNull _display) exitWith {};
    
    // Get controls
    private _categoryList = _display displayCtrl 58210;
    private _balanceText = _display displayCtrl 58202;
    private _statsText = _display displayCtrl 58250;
    
    // Populate categories
    private _categories = [
        ["PRIMARY", "Primary Weapons"],
        ["SECONDARY", "Secondary Weapons"],
        ["HANDGUN", "Handguns"],
        ["ATTACH", "Attachments"],
        ["MAGS", "Magazines"],
        ["UNIFORM", "Uniforms"],
        ["VEST", "Vests"],
        ["BACKPACK", "Backpacks"],
        ["HEADGEAR", "Headgear"],
        ["GOGGLES", "Facewear"],
        ["ITEMS", "Items"]
    ];
    
    {
        _x params ["_catId", "_catName"];
        
        // Only add category if it has items
        private _items = RECONDO_RP_ITEMS getOrDefault [_catId, []];
        if (count _items > 0) then {
            private _idx = _categoryList lbAdd format ["%1 (%2)", _catName, count _items];
            _categoryList lbSetData [_idx, _catId];
        };
    } forEach _categories;
    
    // Select first category
    if (lbSize _categoryList > 0) then {
        _categoryList lbSetCurSel 0;
    };
    
    // Update balance display
    private _uid = getPlayerUID player;
    private _playerData = if (isNil "RECONDO_RP_PLAYER_DATA") then { createHashMap } else {
        RECONDO_RP_PLAYER_DATA getOrDefault [_uid, createHashMap]
    };
    
    private _points = _playerData getOrDefault ["points", 0];
    private _totalEarned = _playerData getOrDefault ["totalEarned", 0];
    private _unlockCount = count (_playerData getOrDefault ["unlocks", []]);
    
    _balanceText ctrlSetText format ["Balance: %1 RP", _points];
    _statsText ctrlSetText format ["Total Earned: %1 RP | Items Unlocked: %2", _totalEarned, _unlockCount];
    
    // Refresh items list
    [] call Recondo_fnc_rpRefreshUnlockShop;
    
}, [], 0.1] call CBA_fnc_waitAndExecute;
