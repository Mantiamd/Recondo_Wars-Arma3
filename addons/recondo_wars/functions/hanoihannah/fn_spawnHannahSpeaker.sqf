/*
    Recondo_fnc_spawnHannahSpeaker
    Spawns a single loudspeaker and starts its broadcast loop

    Parameters:
        _settings - HASHMAP - Module settings
        _markerId - STRING - Marker name for tracking
        _pos      - ARRAY  - World position to spawn at
*/

if (!isServer) exitWith {};

params [
    ["_settings", nil, [createHashMap]],
    ["_markerId", "", [""]],
    ["_pos", [0,0,0], [[]]]
];

if (isNil "_settings") exitWith {};

private _volume = _settings get "volume";
private _distance = _settings get "distance";
private _cooldown = _settings get "cooldown";
private _randomDelay = _settings get "randomDelay";
private _useCustomSound = _settings get "useCustomSound";
private _customSoundPath = _settings get "customSoundPath";
private _reconPointsAward = _settings get "reconPointsAward";
private _debugLogging = _settings get "debugLogging";

// ========================================
// CREATE SPEAKER
// ========================================

private _speaker = createVehicle ["Land_Loudspeakers_F", [0,0,0], [], 0, "NONE"];
if (isNull _speaker) exitWith {
    diag_log format ["[RECONDO_HANNAH] ERROR: Failed to create speaker at %1", _markerId];
};

_speaker setPosATL _pos;
_speaker setVectorUp [0,0,1];
_speaker setVariable ["RECONDO_HANNAH_markerId", _markerId];
_speaker setVariable ["RECONDO_HANNAH_settings", _settings];

RECONDO_HANNAH_SPEAKERS pushBack _speaker;

// ========================================
// KILLED EVENT HANDLER (tracks destruction for persistence)
// ========================================

_speaker addEventHandler ["Killed", {
    params ["_unit"];
    private _id = _unit getVariable ["RECONDO_HANNAH_markerId", ""];
    private _cfg = _unit getVariable ["RECONDO_HANNAH_settings", nil];
    if (_id == "" || isNil "_cfg") exitWith {};

    RECONDO_HANNAH_SPEAKERS = RECONDO_HANNAH_SPEAKERS - [_unit];
    if (!(_id in RECONDO_HANNAH_DISABLED)) then {
        RECONDO_HANNAH_DISABLED pushBack _id;
    };

    private _persist = _cfg get "enablePersistence";
    private _prefix = _cfg get "markerPrefix";
    if (_persist && {!isNil "RECONDO_PERSISTENCE_SETTINGS"}) then {
        private _key = format ["HANNAH_%1", _prefix];
        [_key + "_DISABLED", RECONDO_HANNAH_DISABLED] call Recondo_fnc_setSaveData;
        saveMissionProfileNamespace;
    };

    if (_cfg get "debugLogging") then {
        diag_log format ["[RECONDO_HANNAH] Speaker %1 destroyed", _id];
    };
}];

// ========================================
// ACE INTERACTION - RIP OUT WIRES
// ========================================

private _action = [
    "recondo_hannah_disable",
    "Rip Out Wires",
    "\a3\ui_f\data\igui\cfg\holdactions\holdAction_unloaddevice_ca.paa",
    {
        params ["_target", "_player"];
        [_target, _player] call Recondo_fnc_handleSpeakerDisabled;
    },
    { alive _target }
] call ace_interact_menu_fnc_createAction;

[_speaker, 0, ["ACE_MainActions"], _action] remoteExec ["ace_interact_menu_fnc_addActionToObject", 0, _speaker];

// ========================================
// BROADCAST LOOP
// ========================================

[_speaker, _volume, _distance, _cooldown, _randomDelay, _useCustomSound, _customSoundPath, _debugLogging, _markerId] spawn {
    params ["_speaker", "_volume", "_distance", "_cooldown", "_randomDelay", "_useCustomSound", "_customSoundPath", "_debugLogging", "_markerId"];

    if (_randomDelay > 0) then { sleep (random _randomDelay) };

    while {!isNull _speaker && {alive _speaker}} do {
        if (_useCustomSound && _customSoundPath != "") then {
            private _fullPath = getMissionPath _customSoundPath;
            [_fullPath, _speaker, false, getPosASL _speaker, _volume, 1, _distance] remoteExec ["playSound3D", 0];
        } else {
            [_speaker, ["hannah_broadcast", _distance, 1, _volume]] remoteExec ["say3D"];
        };

        if (_debugLogging) then {
            diag_log format ["[RECONDO_HANNAH] Broadcasting from %1", _markerId];
        };

        sleep _cooldown;
        if (isNull _speaker || {!alive _speaker}) exitWith {};
    };

    if (_debugLogging) then {
        diag_log format ["[RECONDO_HANNAH] Broadcast loop ended for %1", _markerId];
    };
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_HANNAH] Speaker spawned at %1 (%2)", _markerId, _pos];
};
