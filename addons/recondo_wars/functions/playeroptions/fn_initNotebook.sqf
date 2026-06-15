/*
    Recondo_fnc_initNotebook
    Client-side initialization for notebook access, ACE actions, and hotkey.
*/

if (!hasInterface) exitWith {};

if (!isNil "RECONDO_NOTEBOOK_CLIENT_INIT" && {RECONDO_NOTEBOOK_CLIENT_INIT}) exitWith {};

if (isNil "RECONDO_PLAYEROPTIONS_SETTINGS") exitWith {};

private _settings = RECONDO_PLAYEROPTIONS_SETTINGS;
private _giveAll = _settings getOrDefault ["notebookGiveAll", false];
private _itemClassname = _settings getOrDefault ["notebookItemClassname", "ACE_Notepad"];
private _debug = _settings getOrDefault ["enableDebug", false];
private _notebookIcon = "\recondo_wars\ui\Notebook_square.paa";

_itemClassname = _itemClassname trim [" ", 0];

private _enabled = _giveAll || {_itemClassname != ""};
if (!_enabled) exitWith {};

RECONDO_fnc_playerCanUseNotebook = {
    if (isNil "RECONDO_PLAYEROPTIONS_SETTINGS") exitWith { false };

    private _settings = RECONDO_PLAYEROPTIONS_SETTINGS;
    private _giveAll = _settings getOrDefault ["notebookGiveAll", false];
    private _itemClassname = _settings getOrDefault ["notebookItemClassname", "ACE_Notepad"];
    _itemClassname = _itemClassname trim [" ", 0];

    if (_giveAll) exitWith { true };
    if (_itemClassname == "") exitWith { false };

    [player, _itemClassname] call BIS_fnc_hasItem
};

private _fnc_grantNotebookItem = {
    if (isNil "RECONDO_PLAYEROPTIONS_SETTINGS") exitWith {};

    private _settings = RECONDO_PLAYEROPTIONS_SETTINGS;
    private _giveAll = _settings getOrDefault ["notebookGiveAll", false];
    if (!_giveAll) exitWith {};

    private _itemClassname = _settings getOrDefault ["notebookItemClassname", "ACE_Notepad"];
    _itemClassname = _itemClassname trim [" ", 0];

    if (_itemClassname == "") exitWith {};

    if !([player, _itemClassname] call BIS_fnc_hasItem) then {
        player addItem _itemClassname;
    };
};

call _fnc_grantNotebookItem;

player addEventHandler ["Respawn", {
    [] call Recondo_fnc_notebookLoadData;
    if (!isNil "RECONDO_PLAYEROPTIONS_SETTINGS") then {
        private _settings = RECONDO_PLAYEROPTIONS_SETTINGS;
        if (_settings getOrDefault ["notebookGiveAll", false]) then {
            private _itemClassname = _settings getOrDefault ["notebookItemClassname", "ACE_Notepad"];
            _itemClassname = _itemClassname trim [" ", 0];
            if (_itemClassname != "" && {!([player, _itemClassname] call BIS_fnc_hasItem)}) then {
                player addItem _itemClassname;
            };
        };
    };
}];

[] call Recondo_fnc_notebookLoadData;

if (isNil "RECONDO_NOTEBOOK_ACTIONS_ADDED" || {!RECONDO_NOTEBOOK_ACTIONS_ADDED}) then {
    if (!isNil "ace_interact_menu_fnc_createAction") then {
        private _openAction = [
            "RECONDO_NOTEBOOK_Open",
            "Notebook",
            _notebookIcon,
            {
                [] call Recondo_fnc_openNotebook;
            },
            {
                [] call RECONDO_fnc_playerCanUseNotebook
            }
        ] call ace_interact_menu_fnc_createAction;

        ["CAManBase", 1, ["ACE_SelfActions"], _openAction, true] call ace_interact_menu_fnc_addActionToClass;
        RECONDO_NOTEBOOK_ACTIONS_ADDED = true;
    };
};

if (isNil "RECONDO_NOTEBOOK_KEYBIND_ADDED" || {!RECONDO_NOTEBOOK_KEYBIND_ADDED}) then {
    if (!isNil "CBA_fnc_addKeybind") then {
        [
            "Recondo Wars",
            "Recondo_OpenNotebook",
            ["Open Notebook", "Open the personal notebook."],
            {
                if (!isNil "RECONDO_NOTEBOOK_OPEN" && {RECONDO_NOTEBOOK_OPEN}) exitWith {
                    closeDialog 0;
                    true
                };

                if !([] call RECONDO_fnc_playerCanUseNotebook) exitWith { false };
                [] call Recondo_fnc_openNotebook;
                true
            },
            {},
            [49, [false, true, false]]
        ] call CBA_fnc_addKeybind;
        RECONDO_NOTEBOOK_KEYBIND_ADDED = true;
    };
};

RECONDO_NOTEBOOK_CLIENT_INIT = true;

if (_debug) then {
    diag_log format ["[RECONDO_NOTEBOOK] Initialized. GiveAll: %1, Item: '%2'", _giveAll, _itemClassname];
};
