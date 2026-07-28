/*
    Recondo_fnc_waveAttackWatcher
    Polls unspent Wave Attack markers for trigger-side players

    Description:
        One watcher loop per module instance. Every 5 seconds each
        unspent marker is checked for trigger-side players within the
        trigger radius (below the height limit, so overflights don't
        arm markers). A triggered marker is spent immediately (one-time)
        and its wave sequence runs in its own thread. The watcher ends
        when every marker has been spent. Server-only.

    Parameters:
        0: HASHMAP - Module settings

    Returns:
        Nothing (spawned loop)
*/

if (!isServer) exitWith {};

params ["_settings"];

private _instanceId = _settings get "instanceId";
private _triggerRadius = _settings get "triggerRadius";
private _triggerSideStr = _settings get "triggerSideStr";
private _heightLimit = _settings get "heightLimit";
private _debugLogging = _settings get "debugLogging";

private _triggerSide = switch (_triggerSideStr) do {
    case "EAST": { east };
    case "WEST": { west };
    case "GUER": { independent };
    default { sideUnknown }; // ANY
};

while {count (_settings get "pendingMarkers") > 0} do {
    // Snapshot of eligible players this tick, shared by all marker checks
    private _players = allPlayers select {
        alive _x
        && {_triggerSideStr == "ANY" || side _x == _triggerSide}
        && {((getPosATL _x) select 2) <= _heightLimit}
    };

    if (count _players > 0) then {
        private _pending = _settings get "pendingMarkers";
        {
            private _marker = _x;
            private _markerPos = getMarkerPos _marker;

            if ((_players findIf { _x distance2D _markerPos <= _triggerRadius }) != -1) then {
                // Spend the marker immediately so it can never re-trigger
                _settings set ["pendingMarkers", (_settings get "pendingMarkers") - [_marker]];

                if (_debugLogging) then {
                    diag_log format ["[RECONDO_WAVEATK] %1: Marker %2 triggered - starting wave sequence", _instanceId, _marker];
                };

                [_settings, _marker] spawn Recondo_fnc_runWaveAttack;
            };
        } forEach _pending;
    };

    sleep 5;
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_WAVEATK] %1: All markers spent - watcher ended", _instanceId];
};
