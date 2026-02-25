/*
    Recondo_fnc_openRallyMenu
    Open rally point selection menu
    
    Description:
        Called when player uses the ACE action on the base teleporter object.
        If only one rally exists, teleports directly.
        If multiple rallies exist, shows a selection menu with distances.
    
    Parameters:
        0: OBJECT - Player requesting the menu
    
    Returns:
        Nothing
    
    Execution:
        Client only
*/

params [["_player", objNull, [objNull]]];

if (isNull _player) exitWith {};
if (!hasInterface) exitWith {};

private _settings = RECONDO_DRP_SETTINGS;
if (isNil "_settings") exitWith {
    hint "Rally point system not initialized!";
};

private _enableDebug = _settings get "enableDebug";

// ========================================
// GET RALLIES FOR PLAYER'S SIDE
// ========================================

private _rallies = missionNamespace getVariable ["RECONDO_DRP_RALLIES", []];

if (_rallies isEqualTo []) exitWith {
    hint "No rally points deployed.";
};

private _playerSideNum = switch (side _player) do {
    case east: { 0 };
    case west: { 1 };
    case independent: { 2 };
    case civilian: { 3 };
    default { -1 };
};

// Get module's allowed side
private _allowedSideNum = _settings get "allowedSideNum";

// Filter rallies based on side
private _sideRallies = [];

if (_allowedSideNum == 4) then {
    // Any side mode - show rallies matching player's side
    _sideRallies = _rallies select { (_x get "sideNum") == _playerSideNum };
} else {
    // Restricted mode - show all rallies if player is allowed side
    if (_playerSideNum == _allowedSideNum) then {
        _sideRallies = _rallies select { (_x get "sideNum") == _allowedSideNum };
    };
};

if (_sideRallies isEqualTo []) exitWith {
    hint "No rally points deployed for your side.";
};

// ========================================
// SINGLE RALLY - TELEPORT DIRECTLY
// ========================================

if (count _sideRallies == 1) exitWith {
    private _rallyData = _sideRallies select 0;
    [_player, _rallyData] call Recondo_fnc_teleportToRally;
};

// ========================================
// MULTIPLE RALLIES - SHOW SELECTION MENU
// ========================================

// Clear any existing rally selection actions
private _existingActionIds = _player getVariable ["RECONDO_DRP_MENU_ACTION_IDS", []];
{
    _player removeAction _x;
} forEach _existingActionIds;

private _actionIds = [];

// Add action for each rally
{
    private _rallyData = _x;
    private _idx = _forEachIndex + 1;
    private _pos = _rallyData get "position";
    private _markerName = _rallyData get "markerName";
    
    // Calculate distance
    private _dist = round (_player distance2D _pos);
    
    // Get marker text for display
    private _displayText = format ["Rally %1 (%2m)", _idx, _dist];
    
    private _actionId = _player addAction [
        format ["<t color='#00FF00'>%1</t>", _displayText],
        {
            params ["_target", "_caller", "_actionId", "_args"];
            _args params ["_rallyData"];
            
            // Teleport to this rally
            [_caller, _rallyData] call Recondo_fnc_teleportToRally;
            
            // Clear all menu actions
            private _actionIds = _caller getVariable ["RECONDO_DRP_MENU_ACTION_IDS", []];
            {
                _caller removeAction _x;
            } forEach _actionIds;
            _caller setVariable ["RECONDO_DRP_MENU_ACTION_IDS", []];
        },
        [_rallyData],
        100 - _forEachIndex,  // Priority (first rally at top)
        false,
        true,
        "",
        "true",
        5
    ];
    
    _actionIds pushBack _actionId;
    
} forEach _sideRallies;

// Add cancel action
private _cancelId = _player addAction [
    "<t color='#FF0000'>Cancel Selection</t>",
    {
        params ["_target", "_caller", "_actionId", "_args"];
        
        // Clear all menu actions
        private _actionIds = _caller getVariable ["RECONDO_DRP_MENU_ACTION_IDS", []];
        {
            _caller removeAction _x;
        } forEach _actionIds;
        _caller setVariable ["RECONDO_DRP_MENU_ACTION_IDS", []];
    },
    [],
    0,
    false,
    true,
    "",
    "true",
    5
];
_actionIds pushBack _cancelId;

// Store action IDs for cleanup
_player setVariable ["RECONDO_DRP_MENU_ACTION_IDS", _actionIds];

// Auto-close menu after 30 seconds
[{
    params ["_player"];
    private _actionIds = _player getVariable ["RECONDO_DRP_MENU_ACTION_IDS", []];
    {
        _player removeAction _x;
    } forEach _actionIds;
    _player setVariable ["RECONDO_DRP_MENU_ACTION_IDS", []];
}, [_player], 30] call CBA_fnc_waitAndExecute;

if (_enableDebug) then {
    diag_log format ["[RECONDO_DRP] Opened rally menu with %1 options", count _sideRallies];
};
