/*
    Recondo_fnc_sogTrackerSpawn
    Spawns a 2-man OPFOR stalker team at the marker center and
    applies SOG PF tracking functions to both the BLUFOR group
    and the stalker group.

    Parameters:
        _settings     - HASHMAP - Module settings
        _marker       - STRING  - Marker name (spawn location)
        _triggerGroup - GROUP   - The BLUFOR group to track
*/

if (!isServer) exitWith {};

params [
    ["_settings", nil, [createHashMap]],
    ["_marker", "", [""]],
    ["_triggerGroup", grpNull, [grpNull]]
];

if (isNil "_settings" || isNull _triggerGroup) exitWith {
    diag_log "[RECONDO_SOGTRACKER] ERROR: Invalid parameters for sogTrackerSpawn.";
};

private _debugLogging = _settings get "debugLogging";
private _trackerSide = _settings get "trackerSide";
private _trackerClassnames = _settings get "trackerClassnames";

private _spawnPos = getMarkerPos _marker;

// Convert side string to side
private _side = switch (toUpper _trackerSide) do {
    case "EAST": { east };
    case "GUER": { independent };
    default { east };
};

// ========================================
// APPLY TRACKS LOOP TO BLUFOR GROUP
// ========================================

[_triggerGroup] call vn_ms_fnc_tracker_tracksLoop;

if (_debugLogging) then {
    diag_log format ["[RECONDO_SOGTRACKER] Applied tracksLoop to BLUFOR group: %1 (leader: %2)", _triggerGroup, leader _triggerGroup];
};

// ========================================
// SPAWN 2 STALKER UNITS
// ========================================

private _stalkerGroup = createGroup [_side, true];

for "_i" from 1 to 2 do {
    private _classname = selectRandom _trackerClassnames;
    private _offsetPos = _spawnPos getPos [5 + random 5, random 360];

    private _unit = _stalkerGroup createUnit [_classname, _offsetPos, [], 0, "NONE"];
    if (isNull _unit) then { continue };

    _unit setPosATL _offsetPos;
    _unit setVariable ["RECONDO_SOGTRACKER_Stalker", true];

    if (_debugLogging) then {
        diag_log format ["[RECONDO_SOGTRACKER] Spawned stalker: %1 at %2", _classname, _offsetPos];
    };
};

if (count (units _stalkerGroup) == 0) exitWith {
    diag_log format ["[RECONDO_SOGTRACKER] ERROR: Failed to spawn stalker units at marker '%1'.", _marker];
    deleteGroup _stalkerGroup;
};

// ========================================
// APPLY STALKER BEHAVIOR
// ========================================

[_stalkerGroup, false] call vn_ms_fnc_tracker_stalker;

if (_debugLogging) then {
    diag_log format ["[RECONDO_SOGTRACKER] Applied stalker to OPFOR group at '%1'. Pursuing BLUFOR group: %2", _marker, leader _triggerGroup];
};
