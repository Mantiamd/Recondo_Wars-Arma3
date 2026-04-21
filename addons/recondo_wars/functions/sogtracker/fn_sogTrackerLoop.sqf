/*
    Recondo_fnc_sogTrackerLoop
    Detection loop for SOG PF Tracker Group zones.
    Polls every 5 seconds for BLUFOR groups inside marker areas.
    Each zone triggers once, then is removed from the watch list.

    Parameters:
        _settings - HASHMAP - Module settings
        _markers  - ARRAY   - Marker names to monitor
*/

if (!isServer) exitWith {};

params [
    ["_settings", nil, [createHashMap]],
    ["_markers", [], [[]]]
];

if (isNil "_settings") exitWith {
    diag_log "[RECONDO_SOGTRACKER] ERROR: No settings provided to tracker loop.";
};

private _debugLogging = _settings get "debugLogging";
private _triggerRadius = _settings get "triggerRadius";
private _activeMarkers = +_markers;

if (_debugLogging) then {
    diag_log format ["[RECONDO_SOGTRACKER] Detection loop started. Monitoring %1 zone(s).", count _activeMarkers];
};

while {count _activeMarkers > 0} do {
    sleep 5;

    private _toRemove = [];

    {
        private _marker = _x;
        private _markerPos = getMarkerPos _marker;
        private _triggerGroup = grpNull;

        {
            if (alive _x && {side group _x == west} && {(_x distance2D _markerPos) < _triggerRadius}) exitWith {
                _triggerGroup = group _x;
            };
        } forEach allUnits;

        if (!isNull _triggerGroup) then {
            _toRemove pushBack _forEachIndex;

            if (_debugLogging) then {
                diag_log format ["[RECONDO_SOGTRACKER] BLUFOR group detected in zone '%1'. Leader: %2. Activating trackers.", _marker, leader _triggerGroup];
            };

            // Spawn stalkers and apply SOG PF tracking
            [_settings, _marker, _triggerGroup] call Recondo_fnc_sogTrackerSpawn;
        };

    } forEach _activeMarkers;

    // Remove triggered markers (reverse order to preserve indices)
    { _activeMarkers deleteAt _x } forEachReversed _toRemove;

    if (count _toRemove > 0 && _debugLogging) then {
        diag_log format ["[RECONDO_SOGTRACKER] %1 zone(s) triggered. %2 remaining.", count _toRemove, count _activeMarkers];
    };
};

if (_debugLogging) then {
    diag_log "[RECONDO_SOGTRACKER] All zones triggered. Detection loop complete.";
};
