/*
    Recondo_fnc_commanderOpenCommandMap
    Opens the officer's squad command dialog (officer's client)

    Description:
        Antistasi-style command interface: a dedicated dialog with its own map
        control. Squad icons are drawn on that map; clicking selects a squad or
        (when armed) sets its move destination. The button column issues orders
        through Recondo_fnc_commanderIssueOrder on the server. Using a self-contained
        map avoids the vanilla fullscreen-map input/marker conflicts entirely.

    Parameters:
        None

    Returns:
        Nothing
*/

if (!hasInterface) exitWith {};

// Prune squads that no longer exist before opening.
RECONDO_CMD_CLIENT_SQUADS = RECONDO_CMD_CLIENT_SQUADS select {
    private _g = _x select 0;
    !isNull _g && {({alive _x} count units _g) > 0}
};

if (RECONDO_CMD_CLIENT_SQUADS isEqualTo []) exitWith {
    hint "You have no active squads to command.";
};

if (!createDialog "RscCommanderMap") exitWith {};
private _dlg = findDisplay 58330;
if (isNull _dlg) exitWith {};

// Default selection: first squad still in the list.
RECONDO_CMD_SELECTED_GROUP = (RECONDO_CMD_CLIENT_SQUADS select 0) select 0;
private _selLabel = (RECONDO_CMD_CLIENT_SQUADS select 0) select 1;
(_dlg displayCtrl 58332) ctrlSetText format ["Selected: %1", _selLabel];

// Centre the command map on the officer.
private _map = _dlg displayCtrl 58333;
ctrlMapAnimClear _map;
_map ctrlMapAnimAdd [0, 0.12, getPosVisual player];
ctrlMapAnimCommit _map;

// --- Move Here: reveal the 8-digit grid entry box ---
(_dlg displayCtrl 58340) ctrlAddEventHandler ["ButtonClick", {
    private _d = findDisplay 58330;
    if (isNull RECONDO_CMD_SELECTED_GROUP) exitWith {
        (_d displayCtrl 58335) ctrlSetText "Select a squad first.";
    };
    ["HIDE"] call Recondo_fnc_commanderMenuPanel;
    { (_d displayCtrl _x) ctrlShow true; } forEach [58347, 58345, 58346];
    (_d displayCtrl 58345) ctrlSetText "";
    ctrlSetFocus (_d displayCtrl 58345);
    (_d displayCtrl 58335) ctrlSetText "Enter an 8-digit grid (e.g. 1234 5678), then Confirm.";
}];

// --- Confirm Move: parse the grid, order the move, hide the entry box ---
(_dlg displayCtrl 58346) ctrlAddEventHandler ["ButtonClick", {
    private _d = findDisplay 58330;
    if (isNull RECONDO_CMD_SELECTED_GROUP) exitWith {
        (_d displayCtrl 58335) ctrlSetText "Select a squad first.";
    };

    // Flexible input: strip everything that is not a digit, require exactly 8.
    private _raw = ctrlText (_d displayCtrl 58345);
    private _digits = "";
    {
        if (_x >= 48 && {_x <= 57}) then { _digits = _digits + (toString [_x]); };
    } forEach (toArray _raw);

    if (count _digits != 8) exitWith {
        (_d displayCtrl 58335) ctrlSetText "Invalid grid - enter exactly 8 digits.";
    };

    private _pos = [_digits] call Recondo_fnc_commanderGridToPos;
    if (_pos isEqualTo []) exitWith {
        (_d displayCtrl 58335) ctrlSetText "Invalid grid - enter exactly 8 digits.";
    };

    [player, RECONDO_CMD_SELECTED_GROUP, "MOVE", _pos] remoteExec ["Recondo_fnc_commanderIssueOrder", 2];
    RECONDO_CMD_SQUAD_DEST set [netId RECONDO_CMD_SELECTED_GROUP, _pos];

    { (_d displayCtrl _x) ctrlShow false; } forEach [58347, 58345, 58346];
    (_d displayCtrl 58335) ctrlSetText format ["Move order issued to grid %1 %2.", _digits select [0, 4], _digits select [4, 4]];
}];

// --- Halt / Hold ---
(_dlg displayCtrl 58341) ctrlAddEventHandler ["ButtonClick", {
    if (isNull RECONDO_CMD_SELECTED_GROUP) exitWith {};
    [player, RECONDO_CMD_SELECTED_GROUP, "HALT", ""] remoteExec ["Recondo_fnc_commanderIssueOrder", 2];
    // Squad is holding now, so drop its move-destination marker.
    RECONDO_CMD_SQUAD_DEST deleteAt (netId RECONDO_CMD_SELECTED_GROUP);
    (findDisplay 58330 displayCtrl 58335) ctrlSetText "Halt order issued.";
    ["HIDE"] call Recondo_fnc_commanderMenuPanel;
}];

// --- Behaviour / Formation: reveal fly-out sub-panels ---
(_dlg displayCtrl 58342) ctrlAddEventHandler ["ButtonClick", { ["BEH"] call Recondo_fnc_commanderMenuPanel; }];
(_dlg displayCtrl 58343) ctrlAddEventHandler ["ButtonClick", { ["FORM"] call Recondo_fnc_commanderMenuPanel; }];

// --- Close ---
(_dlg displayCtrl 58344) ctrlAddEventHandler ["ButtonClick", { closeDialog 0; }];

// --- Sub-panel buttons: tag each with its order + data, share one handler ---
private _behData = [
    [58350, "CARELESS"], [58351, "SAFE"], [58352, "AWARE"], [58353, "COMBAT"], [58354, "STEALTH"]
];
private _formData = [
    [58360, "COLUMN"], [58361, "STAG COLUMN"], [58362, "WEDGE"], [58363, "ECH LEFT"],
    [58364, "ECH RIGHT"], [58365, "VEE"], [58366, "LINE"], [58367, "FILE"], [58368, "DIAMOND"]
];

{
    _x params ["_idc", "_data"];
    private _c = _dlg displayCtrl _idc;
    _c setVariable ["cmdOrder", "BEHAVIOUR"];
    _c setVariable ["cmdData", _data];
} forEach _behData;

{
    _x params ["_idc", "_data"];
    private _c = _dlg displayCtrl _idc;
    _c setVariable ["cmdOrder", "FORMATION"];
    _c setVariable ["cmdData", _data];
} forEach _formData;

{
    (_dlg displayCtrl _x) ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        private _order = _ctrl getVariable ["cmdOrder", ""];
        private _data = _ctrl getVariable ["cmdData", ""];
        if (!isNull RECONDO_CMD_SELECTED_GROUP && {_order != ""}) then {
            [player, RECONDO_CMD_SELECTED_GROUP, _order, _data] remoteExec ["Recondo_fnc_commanderIssueOrder", 2];
            (findDisplay 58330 displayCtrl 58335) ctrlSetText format ["%1 set: %2", _order, _data];
        };
        ["HIDE"] call Recondo_fnc_commanderMenuPanel;
    }];
} forEach [58350, 58351, 58352, 58353, 58354, 58360, 58361, 58362, 58363, 58364, 58365, 58366, 58367, 58368];
