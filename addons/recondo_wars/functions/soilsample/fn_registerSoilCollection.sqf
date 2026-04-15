/*
    Recondo_fnc_registerSoilCollection
    Server-side: Records a pending soil sample collection for a player

    Description:
        Called via remoteExec from client after successful collection.
        Adds the marker name to the player's pending samples list.

    Parameters:
        _playerUID - STRING - Player UID
        _markerName - STRING - Marker area name or "__GLOBAL__"
*/

if (!isServer) exitWith {};

params [["_playerUID", "", [""]], ["_markerName", "", [""]]];

if (_playerUID == "" || _markerName == "") exitWith {};

private _settings = missionNamespace getVariable ["RECONDO_SOIL_SETTINGS", nil];
if (isNil "_settings") exitWith {};
private _debugLogging = _settings getOrDefault ["debugLogging", false];

// Find the player object by UID
private _playerObj = objNull;
{
    if (getPlayerUID _x == _playerUID) exitWith { _playerObj = _x; };
} forEach allPlayers;

if (isNull _playerObj) exitWith {
    if (_debugLogging) then {
        diag_log format ["[RECONDO_SOIL] WARNING: Could not find player with UID %1 for collection registration", _playerUID];
    };
};

// Add to player's pending samples (public variable so clients can check)
private _pending = _playerObj getVariable ["RECONDO_SOIL_PendingSamples", []];
_pending pushBack _markerName;
_playerObj setVariable ["RECONDO_SOIL_PendingSamples", _pending, true];

if (_debugLogging) then {
    diag_log format ["[RECONDO_SOIL] Registered pending sample for %1 (UID: %2) from marker: %3 (total pending: %4)",
        name _playerObj, _playerUID, _markerName, count _pending];
};
