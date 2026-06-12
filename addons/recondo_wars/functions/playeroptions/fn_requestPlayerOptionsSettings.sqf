/*
    Recondo_fnc_requestPlayerOptionsSettings
    Server-side handler that sends Player Options settings to a requesting client.
*/

if (!isServer) exitWith {};

params [["_ownerId", -1, [0]]];

if (_ownerId < 0) exitWith {};
if (isNil "RECONDO_PLAYEROPTIONS_SETTINGS") exitWith {};

[RECONDO_PLAYEROPTIONS_SETTINGS] remoteExecCall ["Recondo_fnc_receivePlayerOptionsSettings", _ownerId];
