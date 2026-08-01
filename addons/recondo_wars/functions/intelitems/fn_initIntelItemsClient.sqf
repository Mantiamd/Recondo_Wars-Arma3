/*
    Recondo_fnc_initIntelItemsClient
    Registers the class-based ACE loot actions for intel carriers

    Description:
        Runs once per client. Adds a "Search for Intel" ACE interaction to
        the CAManBase class whose children are generated dynamically from
        the unit's RECONDO_INTELITEMS_inventory variable.

        Class-based actions are used instead of per-object actions because
        per-object actions were broadcast via remoteExec at spawn time; on a
        dedicated server a client that had not yet received the entity got
        objNull and silently never created the action. Class actions have no
        such race and need no JIP handling - the inventory variable is
        public-synced, so the menu appears anywhere it is non-empty.

    Parameters:
        None

    Returns:
        Nothing
*/

if (!hasInterface) exitWith {};

// Guard against double registration (Intel Items and Player Intel Drops both trigger this)
if (missionNamespace getVariable ["RECONDO_INTELITEMS_CLIENT_INIT", false]) exitWith {};
RECONDO_INTELITEMS_CLIENT_INIT = true;

private _parentAction = [
    "Recondo_IntelItems_Parent",
    "Search for Intel",
    "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\search_ca.paa",
    {},
    {
        // Show only on units flagged as intel carriers
        params ["_target", "_player", "_params"];
        count (_target getVariable ["RECONDO_INTELITEMS_inventory", []]) > 0
    },
    {
        // Build one "Take X" child per unique item type the target carries
        params ["_target", "_player", "_params"];

        private _takeActionText = "Take %1";
        if (!isNil "RECONDO_INTELITEMS_SETTINGS") then {
            _takeActionText = RECONDO_INTELITEMS_SETTINGS getOrDefault ["takeActionText", "Take %1"];
        };

        private _actions = [];
        private _processedTypes = [];

        {
            _x params ["_displayName", "_classname"];

            // findIf with == keeps the comparison case-insensitive, unlike "in"
            if (_processedTypes findIf {_x == _classname} == -1) then {
                _processedTypes pushBack _classname;

                private _childAction = [
                    format ["Recondo_IntelItems_Take_%1", _classname],
                    format [_takeActionText, _displayName],
                    "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\intel_ca.paa",
                    {
                        // Statement - take intel (inventory transfer must run on the server)
                        params ["_target", "_player", "_params"];
                        _params params ["_displayName", "_classname"];

                        [_target, _player, _displayName, _classname] remoteExec ["Recondo_fnc_takeIntelFromUnit", 2];
                    },
                    {
                        // Condition - unit still has this item type
                        params ["_target", "_player", "_params"];
                        _params params ["_displayName", "_classname"];

                        (_target getVariable ["RECONDO_INTELITEMS_inventory", []]) findIf {(_x select 1) == _classname} > -1
                    },
                    {},
                    [_displayName, _classname],
                    [0, 0, 0],
                    3,
                    [false, false, false, false, false],
                    {}
                ] call ace_interact_menu_fnc_createAction;

                _actions pushBack [_childAction, [], _target];
            };
        } forEach (_target getVariable ["RECONDO_INTELITEMS_inventory", []]);

        _actions
    },
    [],
    [0, 0, 0],
    3,
    [false, false, false, false, false],
    {}
] call ace_interact_menu_fnc_createAction;

["CAManBase", 0, ["ACE_MainActions"], _parentAction, true] call ace_interact_menu_fnc_addActionToClass;

diag_log "[RECONDO_INTELITEMS] Client: class-based intel loot actions registered";
