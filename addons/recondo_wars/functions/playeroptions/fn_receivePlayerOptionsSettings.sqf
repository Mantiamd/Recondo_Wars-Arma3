/*
    Recondo_fnc_receivePlayerOptionsSettings
    Client-side receiver for Player Options settings (JIP-safe fallback path).
*/

if (!hasInterface) exitWith {};

params [["_settings", createHashMap, [createHashMap]]];

RECONDO_PLAYEROPTIONS_SETTINGS = _settings;
