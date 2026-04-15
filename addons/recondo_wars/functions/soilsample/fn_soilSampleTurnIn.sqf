/*
    Recondo_fnc_soilSampleTurnIn
    Server-side: Processes a soil sample turn-in at an Intel turn-in object

    Description:
        Consumes the reward item from the player, credits the appropriate
        marker objective, and broadcasts updated tracking data.

    Parameters:
        _player - OBJECT - The player turning in the sample
*/

if (!isServer) exitWith {};

params [["_player", objNull, [objNull]]];

if (isNull _player || !alive _player) exitWith {};

private _settings = missionNamespace getVariable ["RECONDO_SOIL_SETTINGS", nil];
if (isNil "_settings") exitWith {};

private _rewardItem = _settings get "rewardItem";
private _samplesRequired = _settings get "samplesRequired";
private _debugLogging = _settings getOrDefault ["debugLogging", false];

// Validate player has the item
if !([_player, _rewardItem] call BIS_fnc_hasItem) exitWith {
    if (_debugLogging) then {
        diag_log format ["[RECONDO_SOIL] Turn-in failed: %1 does not have %2", name _player, _rewardItem];
    };
};

// Get pending samples
private _pending = _player getVariable ["RECONDO_SOIL_PendingSamples", []];
if (count _pending == 0) exitWith {
    if (_debugLogging) then {
        diag_log format ["[RECONDO_SOIL] Turn-in failed: %1 has no pending samples", name _player];
    };
};

// Pick the first pending marker
private _markerName = _pending deleteAt 0;
_player setVariable ["RECONDO_SOIL_PendingSamples", _pending, true];

// Consume the reward item from the player
private _isMag = isClass (configFile >> "CfgMagazines" >> _rewardItem);
if (_isMag) then {
    [_player, _rewardItem] remoteExecCall ["removeMagazine", _player];
} else {
    [_player, _rewardItem] remoteExecCall ["removeItem", _player];
};

// Credit the marker objective
private _turnedIn = missionNamespace getVariable ["RECONDO_SOIL_TURNED_IN", createHashMap];
private _objData = _turnedIn getOrDefault [_markerName, nil];

if (isNil "_objData") exitWith {
    if (_debugLogging) then {
        diag_log format ["[RECONDO_SOIL] Turn-in failed: no objective data for marker '%1'", _markerName];
    };
};

private _currentCount = _objData get "turnedIn";
_currentCount = _currentCount + 1;
_objData set ["turnedIn", _currentCount];

if (_currentCount >= _samplesRequired) then {
    _objData set ["complete", true];
};

_turnedIn set [_markerName, _objData];
RECONDO_SOIL_TURNED_IN = _turnedIn;
publicVariable "RECONDO_SOIL_TURNED_IN";

// Notify the player
private _grid = _objData get "grid";
private _completeText = if (_objData get "complete") then {
    format ["Soil sample turned in. Objective COMPLETE! (%1/%1)", _samplesRequired]
} else {
    format ["Soil sample turned in. (%1/%2)", _currentCount, _samplesRequired]
};

if (_grid != "") then {
    _completeText = _completeText + format [" [GRID %1]", _grid];
};

[[_completeText], { hint (_this select 0); }] remoteExec ["call", _player];

if (_debugLogging) then {
    diag_log format ["[RECONDO_SOIL] %1 turned in sample for '%2' (%3/%4)%5",
        name _player, _markerName, _currentCount, _samplesRequired,
        if (_objData get "complete") then { " - COMPLETE" } else { "" }];
};

// Check if ALL objectives are complete
private _allComplete = true;
{
    if !(_y get "complete") exitWith { _allComplete = false; };
} forEach _turnedIn;

if (_allComplete) then {
    diag_log "[RECONDO_SOIL] All soil sample objectives COMPLETE!";
};
