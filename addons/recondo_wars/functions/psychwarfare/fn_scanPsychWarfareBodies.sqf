/*
    Recondo_fnc_scanPsychWarfareBodies
    Periodic scanner for psy-op items in dead enemy bodies

    Description:
        Runs on the server in a loop for one side instance. Scans dead bodies
        of the target side for configured psy-op items. Each found item is
        removed and consumed, the body marked processed, and the side's item
        count incremented. When the count changes, the demoralization factor
        is recomputed/applied and the new count is persisted.

    Parameters:
        0: HASHMAP - Instance settings hashmap
*/

params [["_settings", createHashMap, [createHashMap]]];

if (!isServer) exitWith {};

private _sideValue = _settings get "targetSideValue";
private _sideNum = _settings get "targetSideNum";
private _psyItems = _settings get "psyItems";
private _scanInterval = _settings get "scanInterval";
private _maxItems = _settings get "maxItems";
private _debug = _settings get "enableDebug";
private _persistKey = "RECONDO_PSYWAR_ITEMS_" + str _sideNum;

diag_log format ["[RECONDO_PSYWAR] Body scanner started for side %1. Looking for: %2", _sideValue, _psyItems];

while {true} do {
    sleep _scanInterval;

    // Stop if this instance was removed.
    private _stillActive = false;
    {
        if ((_x get "targetSideValue") isEqualTo _sideValue) exitWith { _stillActive = true; };
    } forEach RECONDO_PSYWAR_INSTANCES;
    if (!_stillActive) exitWith {
        diag_log format ["[RECONDO_PSYWAR] Scanner for side %1 stopping (instance removed).", _sideValue];
    };

    private _current = RECONDO_PSYWAR_ITEMS getOrDefault [_sideValue, 0];
    if (_current >= _maxItems) then {
        if (_debug) then {
            diag_log format ["[RECONDO_PSYWAR] Side %1 already at floor (%2 items). Skipping scan.", _sideValue, _current];
        };
        continue;
    };

    private _deadBodies = allDeadMen select {
        private _storedSide = _x getVariable "RECONDO_PSYWAR_SIDE";
        private _bodySide = if (!isNil "_storedSide") then { _storedSide } else { side group _x };
        (_bodySide isEqualTo _sideValue) && {isNil {_x getVariable "RECONDO_PSYWAR_PROCESSED"}}
    };

    private _found = 0;
    {
        private _body = _x;
        private _allItems = [];
        _allItems append (uniformItems _body);
        _allItems append (vestItems _body);
        _allItems append (backpackItems _body);
        // Explicitly include magazines (psy-op cards are CfgMagazines).
        _allItems append (magazines _body);

        private _hit = "";
        {
            if (_x in _allItems) exitWith { _hit = _x; };
        } forEach _psyItems;

        if (_hit != "") then {
            _body removeItem _hit;
            _body setVariable ["RECONDO_PSYWAR_PROCESSED", true];
            _found = _found + 1;
            diag_log format ["[RECONDO_PSYWAR] Found psy item '%1' in body %2.", _hit, typeOf _body];
        };
    } forEach _deadBodies;

    if (_found > 0) then {
        private _new = (_current + _found) min _maxItems;
        RECONDO_PSYWAR_ITEMS set [_sideValue, _new];

        if (!isNil "RECONDO_PERSISTENCE_SETTINGS") then {
            [_persistKey, _new] call Recondo_fnc_setSaveData;
            call Recondo_fnc_queueSave;
        };

        private _factor = [_sideValue] call Recondo_fnc_applyPsychWarfareFactor;

        diag_log format ["[RECONDO_PSYWAR] Side %1 items: %2 -> %3 (+%4). Skill factor now %5.", _sideValue, _current, _new, _found, _factor];
    } else {
        if (_debug) then {
            diag_log format ["[RECONDO_PSYWAR] No psy items found this scan for side %1 (%2 bodies checked).", _sideValue, count _deadBodies];
        };
    };
};
