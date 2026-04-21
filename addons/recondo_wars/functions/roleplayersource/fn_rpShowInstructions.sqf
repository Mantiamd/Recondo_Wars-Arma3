/*
    Recondo_fnc_rpShowInstructions
    Displays roleplayer instructions configured by the mission maker.
*/

if (!hasInterface) exitWith {};

// Read settings from the player's unit variable (JIP-safe) or fall back to global
private _settings = player getVariable ["RECONDO_RP_SOURCE_SETTINGS", nil];
if (isNil "_settings") then { _settings = missionNamespace getVariable ["RECONDO_RP_SOURCE_SETTINGS", nil]; };

if (isNil "_settings") exitWith {
    systemChat "[RP Source] Settings not available.";
};

private _instructionsText = _settings getOrDefault ["instructionsText", ""];

if (_instructionsText == "") then {
    _instructionsText = "No instructions have been provided by the mission maker.";
};

private _bodyText = _instructionsText;
_bodyText = _bodyText regexReplace ["<", "&lt;"];
_bodyText = _bodyText regexReplace [">", "&gt;"];
_bodyText = _bodyText regexReplace [toString [10], "<br/>"];

["ROLEPLAYER INSTRUCTIONS", _bodyText, 0, 30, "", 1] call Recondo_fnc_showIntelCard;

private _debug = _settings getOrDefault ["debugLogging", false];
if (_debug) then {
    diag_log "[RECONDO_RP_SOURCE] Displayed roleplayer instructions.";
};
