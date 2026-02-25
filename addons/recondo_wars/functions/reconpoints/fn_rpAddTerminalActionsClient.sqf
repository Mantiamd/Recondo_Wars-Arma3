/*
    Recondo_fnc_rpAddTerminalActionsClient
    Add ACE actions to unlock terminal (client-side)
    
    Description:
        Creates ACE interact actions on terminal objects for players
        to access the unlock shop.
        Client-side function, called via remoteExec from server.
    
    Parameters:
        _object - OBJECT - The terminal object
    
    Returns:
        Nothing
    
    Example:
        [_terminal] call Recondo_fnc_rpAddTerminalActionsClient;
*/

params [["_object", objNull, [objNull]]];

// Only run on clients with interface
if (!hasInterface) exitWith {};

// Validate
if (isNull _object) exitWith {};

// Check if ACE is available
if (isNil "ace_interact_menu_fnc_addActionToObject") exitWith {
    diag_log "[RECONDO_RP] WARNING: ACE Interact Menu not available, falling back to addAction";
    
    // Fallback to vanilla addAction
    private _terminalName = _object getVariable ["RECONDO_RP_TERMINAL_NAME", "Unlock Terminal"];
    
    _object addAction [
        format ["<t color='#FFFF00'>%1</t>", _terminalName],
        {
            params ["_target", "_caller"];
            [] call Recondo_fnc_rpOpenUnlockShop;
        },
        nil,
        6,
        true,
        true,
        "",
        "alive _target && _this distance _target < 3"
    ];
};

// Get terminal name
private _terminalName = _object getVariable ["RECONDO_RP_TERMINAL_NAME", "Unlock Terminal"];

// Create main ACE action for unlock shop
private _mainAction = [
    "RECONDO_RP_Terminal",
    _terminalName,
    "\a3\ui_f\data\igui\cfg\simpleTasks\types\rifle_ca.paa",
    {
        // Show RP balance hint on hover
        true
    },
    {
        // Condition: player is alive and system initialized
        alive player && !isNil "RECONDO_RP_SETTINGS"
    },
    {},
    [],
    [0, 0, 0],
    3
] call ace_interact_menu_fnc_createAction;

// Add sub-action: Open Shop
private _shopAction = [
    "RECONDO_RP_OpenShop",
    "Browse Unlocks",
    "\a3\ui_f\data\igui\cfg\simpleTasks\types\box_ca.paa",
    {
        [] call Recondo_fnc_rpOpenUnlockShop;
    },
    {
        alive player
    }
] call ace_interact_menu_fnc_createAction;

// Add sub-action: Check Balance
private _balanceAction = [
    "RECONDO_RP_Balance",
    "Check Balance",
    "\a3\ui_f\data\igui\cfg\actions\arrow_up_gs.paa",
    {
        private _uid = getPlayerUID player;
        if (_uid == "") exitWith { hint "Error: No player UID"; };
        
        private _playerData = RECONDO_RP_PLAYER_DATA getOrDefault [_uid, createHashMap];
        private _points = _playerData getOrDefault ["points", 0];
        private _totalEarned = _playerData getOrDefault ["totalEarned", 0];
        private _unlockCount = count (_playerData getOrDefault ["unlocks", []]);
        
        hint parseText format [
            "<t size='1.3' color='#FFFF00'>Recon Points</t><br/><br/>" +
            "<t size='1.1'>Balance: <t color='#7FFF7F'>%1 RP</t></t><br/>" +
            "<t size='0.9' color='#AAAAAA'>Total Earned: %2 RP</t><br/>" +
            "<t size='0.9' color='#AAAAAA'>Items Unlocked: %3</t>",
            _points, _totalEarned, _unlockCount
        ];
    },
    {
        alive player && !isNil "RECONDO_RP_PLAYER_DATA"
    }
] call ace_interact_menu_fnc_createAction;

// Add actions to object
[_object, 0, ["ACE_MainActions"], _mainAction] call ace_interact_menu_fnc_addActionToObject;
[_object, 0, ["ACE_MainActions", "RECONDO_RP_Terminal"], _shopAction] call ace_interact_menu_fnc_addActionToObject;
[_object, 0, ["ACE_MainActions", "RECONDO_RP_Terminal"], _balanceAction] call ace_interact_menu_fnc_addActionToObject;
