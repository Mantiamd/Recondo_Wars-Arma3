/*
    Recondo_fnc_survStopTransmission
    Server-side: handles the end of a survival radio transmission

    Description:
        Measures the transmission duration. If it exceeds the threshold,
        the transmitter is triangulated: subject to the per-player cooldown
        and the concurrent hunter-group cap, a hunter group is spawned on
        the transmitter's current position.

    Parameters:
        0: STRING - Radio ID
        1: OBJECT - Transmitting unit

    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params ["_radioId", "_unit"];

if (isNil "RECONDO_SURV_SETTINGS") exitWith {};

private _settings = RECONDO_SURV_SETTINGS;
private _debug = _settings get "debugLogging";

// Get transmission start time
private _startTime = RECONDO_SURV_TRANSMISSION_STARTS getOrDefault [_radioId, -1];
if (_startTime < 0) exitWith {
    if (_debug) then {
        diag_log format ["[RECONDO_SURV] No valid start time for radio %1", _radioId];
    };
};

RECONDO_SURV_TRANSMISSION_STARTS deleteAt _radioId;

private _duration = serverTime - _startTime;

if (_debug) then {
    diag_log format ["[RECONDO_SURV] Transmission ended - Radio: %1, Unit: %2, Duration: %3s", _radioId, name _unit, _duration toFixed 1];
};

// Below the triangulation threshold - no consequence
if (_duration < (_settings get "transmissionThreshold")) exitWith {};

// Only the configured side is hunted
if (side group _unit != (_settings get "targetSide")) exitWith {};

if (isNull _unit || !alive _unit) exitWith {};

// No consequence inside a no-count safe zone marker
if ([_unit] call Recondo_fnc_isSurvInSafeZone) exitWith {
    if (_debug) then {
        diag_log format ["[RECONDO_SURV] Transmission by %1 not counted - unit in safe zone", name _unit];
    };
};

// Per-player cooldown so back-to-back calls don't stack hunter teams
private _uid = getPlayerUID _unit;
if (_uid == "") then { _uid = netId _unit; };

private _lastTrigger = RECONDO_SURV_COOLDOWNS getOrDefault [_uid, -1e7];
if ((serverTime - _lastTrigger) < (_settings get "cooldownSeconds")) exitWith {
    if (_debug) then {
        diag_log format ["[RECONDO_SURV] Triangulation of %1 suppressed - on cooldown (%2s remaining)",
            name _unit, round ((_settings get "cooldownSeconds") - (serverTime - _lastTrigger))];
    };
};

// Concurrent hunter-group cap (prune dead/empty groups while counting)
RECONDO_SURV_ACTIVE_GROUPS = RECONDO_SURV_ACTIVE_GROUPS select {
    !isNull _x && {({alive _x} count units _x) > 0}
};
if (count RECONDO_SURV_ACTIVE_GROUPS >= (_settings get "maxHunterGroups")) exitWith {
    if (_debug) then {
        diag_log format ["[RECONDO_SURV] Triangulation of %1 suppressed - hunter group cap (%2) reached",
            name _unit, _settings get "maxHunterGroups"];
    };
};

// Triangulated - start the cooldown and spawn the hunters
RECONDO_SURV_COOLDOWNS set [_uid, serverTime];

diag_log format ["[RECONDO_SURV] %1 TRIANGULATED after %2s transmission", name _unit, _duration toFixed 1];

// Spawned (not called): hunter creation staggers unit spawns with sleeps,
// which is not allowed in the unscheduled remoteExec environment.
[_unit, getPos _unit] spawn Recondo_fnc_spawnSurvHunters;
