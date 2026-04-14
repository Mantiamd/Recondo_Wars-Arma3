/*
    Recondo_fnc_handleSpeakerDisabled
    Handles ACE "Rip Out Wires" action on a loudspeaker

    Description:
        Destroys the speaker, awards Recon Points to the player's group,
        and saves to persistence if enabled. Called via remoteExec on server.

    Parameters:
        _speaker - OBJECT - The loudspeaker being disabled
        _player  - OBJECT - The player who performed the action
*/

params [
    ["_speaker", objNull, [objNull]],
    ["_player", objNull, [objNull]]
];

if (isNull _speaker) exitWith {};

// Redirect to server if called on client
if (!isServer) exitWith {
    [_speaker, _player] remoteExec ["Recondo_fnc_handleSpeakerDisabled", 2];
};

private _markerId = _speaker getVariable ["RECONDO_HANNAH_markerId", ""];
private _settings = _speaker getVariable ["RECONDO_HANNAH_settings", nil];
if (isNil "_settings") exitWith {};

private _reconPointsAward = _settings get "reconPointsAward";
private _enablePersistence = _settings get "enablePersistence";
private _markerPrefix = _settings get "markerPrefix";
private _debugLogging = _settings get "debugLogging";

// ========================================
// DESTROY SPEAKER
// ========================================

_speaker setDamage 1;

// Remove from active list
RECONDO_HANNAH_SPEAKERS = RECONDO_HANNAH_SPEAKERS - [_speaker];

// ========================================
// TRACK DISABLED STATE
// ========================================

if (_markerId != "" && {!(_markerId in RECONDO_HANNAH_DISABLED)}) then {
    RECONDO_HANNAH_DISABLED pushBack _markerId;
};

// ========================================
// AWARD RECON POINTS
// ========================================

if (_reconPointsAward > 0 && {!isNull _player} && {isPlayer _player}) then {
    private _playerGroup = group _player;
    ["custom", _playerGroup, _reconPointsAward, "Loudspeaker disabled"] call Recondo_fnc_rpAwardPoints;

    if (_debugLogging) then {
        diag_log format ["[RECONDO_HANNAH] Awarded %1 RP to group %2 for disabling %3",
            _reconPointsAward, groupId _playerGroup, _markerId];
    };
};

// ========================================
// NOTIFY
// ========================================

["Hanoi Hannah silenced."] remoteExec ["systemChat", 0];

// ========================================
// SAVE PERSISTENCE
// ========================================

if (_enablePersistence && {!isNil "RECONDO_PERSISTENCE_SETTINGS"}) then {
    private _persistenceKey = format ["HANNAH_%1", _markerPrefix];
    [_persistenceKey + "_DISABLED", RECONDO_HANNAH_DISABLED] call Recondo_fnc_setSaveData;
    saveMissionProfileNamespace;

    if (_debugLogging) then {
        diag_log format ["[RECONDO_HANNAH] Saved disabled state for %1", _markerId];
    };
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_HANNAH] Speaker disabled at %1 by %2", _markerId, name _player];
};
