/*
    Recondo_fnc_addTakeIntelActionClient
    Client-side: Adds ACE interactions to take intel from a unit
    
    Description:
        Creates ACE interactions on a unit for taking intel items.
        Called via remoteExec from server.
    
    Parameters:
        _unit - OBJECT - The unit to add actions to
        _intelItems - ARRAY - Array of [displayName, classname] for each item
        _takeActionText - STRING - Format string for action text
    
    Returns:
        Nothing
*/

if (!hasInterface) exitWith {};

params [
    ["_unit", objNull, [objNull]],
    ["_intelItems", [], [[]]],
    ["_takeActionText", "Take %1", [""]]
];

if (isNull _unit || count _intelItems == 0) exitWith {};

// Check if actions already added
if (_unit getVariable ["RECONDO_INTELITEMS_actionsAdded", false]) exitWith {};

// Create a parent action for intel items
private _parentAction = [
    "Recondo_IntelItems_Parent",
    "Search for Intel",
    "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\search_ca.paa",
    {},
    {
        // Show if unit has intel items
        params ["_target", "_player", "_params"];
        private _inventory = _target getVariable ["RECONDO_INTELITEMS_inventory", []];
        count _inventory > 0
    },
    {},
    [],
    [0, 0, 0],
    3,
    [false, false, false, false, false],
    {}
] call ace_interact_menu_fnc_createAction;

[_unit, 0, ["ACE_MainActions"], _parentAction] call ace_interact_menu_fnc_addActionToObject;

// Create child actions for each unique item type
private _processedTypes = [];

{
    _x params ["_displayName", "_classname"];
    
    // Create unique action ID based on classname
    private _actionId = format ["Recondo_IntelItems_Take_%1", _classname];
    
    // Only add one action per item type (the action handles multiple items of same type)
    if (!(_classname in _processedTypes)) then {
        _processedTypes pushBack _classname;
        
        private _actionText = format [_takeActionText, _displayName];
        
        private _childAction = [
            _actionId,
            _actionText,
            "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\intel_ca.paa",
            {
                // Statement - take intel
                params ["_target", "_player", "_params"];
                _params params ["_displayName", "_classname"];
                
                [_target, _player, _displayName, _classname] remoteExec ["Recondo_fnc_takeIntelFromUnit", 2];
            },
            {
                // Condition - unit has this item type
                params ["_target", "_player", "_params"];
                _params params ["_displayName", "_classname"];
                
                private _inventory = _target getVariable ["RECONDO_INTELITEMS_inventory", []];
                private _hasItem = false;
                {
                    if ((_x select 1) == _classname) exitWith { _hasItem = true };
                } forEach _inventory;
                _hasItem
            },
            {},
            [_displayName, _classname],
            [0, 0, 0],
            3,
            [false, false, false, false, false],
            {}
        ] call ace_interact_menu_fnc_createAction;
        
        [_unit, 0, ["ACE_MainActions", "Recondo_IntelItems_Parent"], _childAction] call ace_interact_menu_fnc_addActionToObject;
    };
} forEach _intelItems;

// Mark as added
_unit setVariable ["RECONDO_INTELITEMS_actionsAdded", true, false];
