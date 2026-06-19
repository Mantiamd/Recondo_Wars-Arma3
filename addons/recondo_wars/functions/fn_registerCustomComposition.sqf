/*
    Recondo_fnc_registerCustomComposition
    Registers a pasted (in-Eden) custom composition for a module.

    Description:
        Modules let mission makers paste a composition directly into an Eden
        attribute instead of shipping an .sqe file. This stores the pasted text
        in a server-side global keyed by a stable token. The token (not the text)
        is what gets placed in composition pools and persisted, so the pasted
        text is always re-read fresh from the module on each mission load.

        Recondo_fnc_loadComposition recognises the returned token (prefix
        "RECONDO_CUSTOMCOMP::") and spawns from the registered text.

    Parameters:
        0: BOOL   - Enable custom composition
        1: STRING - Pasted active composition text (SQF array literal)
        2: STRING - Pasted destroyed composition text (optional, "")
        3: STRING - Stable unique key for this module (e.g. prefix + name)

    Returns:
        ARRAY - [activeToken, destroyedToken]; entries are "" when not used.

    Example:
        private _t = [_enabled, _activeData, _destroyedData, format ["%1_%2", _markerPrefix, _objectiveName]] call Recondo_fnc_registerCustomComposition;
        _t params ["_activeToken", "_destroyedToken"];
*/

params [
    ["_enabled", false, [false]],
    ["_activeData", "", [""]],
    ["_destroyedData", "", [""]],
    ["_uniqueKey", "", [""]]
];

if (isNil "RECONDO_CUSTOM_COMP_TEXT") then { RECONDO_CUSTOM_COMP_TEXT = createHashMap; };

// Treat whitespace-only text (spaces, tabs, newlines) as empty.
private _fnc_notEmpty = { ((_this splitString (toString [10, 13, 9, 32])) joinString "") != "" };

if (!_enabled) exitWith { ["", ""] };
if !(_activeData call _fnc_notEmpty) exitWith { ["", ""] };

private _activeToken = format ["RECONDO_CUSTOMCOMP::%1::A", _uniqueKey];
RECONDO_CUSTOM_COMP_TEXT set [_activeToken, _activeData];

private _destroyedToken = "";
if (_destroyedData call _fnc_notEmpty) then {
    _destroyedToken = format ["RECONDO_CUSTOMCOMP::%1::D", _uniqueKey];
    RECONDO_CUSTOM_COMP_TEXT set [_destroyedToken, _destroyedData];
};

[_activeToken, _destroyedToken]
