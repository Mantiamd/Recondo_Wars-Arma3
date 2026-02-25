/*
    Recondo_fnc_distributeHostages
    Distributes hostages across markers based on distribution mode
    
    Description:
        Assigns hostages to markers. In "grouped" mode, all hostages
        go to a single marker. In "random" mode, hostages are randomly
        distributed across all hostage markers.
    
    Parameters:
        _settings - HASHMAP - Module settings
        _hostageMarkers - ARRAY - Array of marker names for hostage locations
    
    Returns:
        HASHMAP - marker -> array of [hostageIndex, hostageName]
*/

if (!isServer) exitWith { createHashMap };

params [
    ["_settings", nil, [createHashMap]],
    ["_hostageMarkers", [], [[]]]
];

if (isNil "_settings" || count _hostageMarkers == 0) exitWith {
    diag_log "[RECONDO_HOSTAGE] ERROR: Invalid parameters for distributeHostages";
    createHashMap
};

private _hostageCount = _settings get "hostageCount";
private _hostageNames = _settings get "hostageNames";
private _distributionMode = _settings get "distributionMode";
private _debugLogging = _settings get "debugLogging";

private _assignments = createHashMap;

// Initialize empty arrays for each marker
{
    _assignments set [_x, []];
} forEach _hostageMarkers;

switch (toLower _distributionMode) do {
    case "grouped": {
        // All hostages at the first marker
        private _targetMarker = _hostageMarkers select 0;
        
        for "_i" from 0 to (_hostageCount - 1) do {
            private _name = _hostageNames select (_i min (count _hostageNames - 1));
            private _currentAssignments = _assignments get _targetMarker;
            _currentAssignments pushBack [_i, _name];
            _assignments set [_targetMarker, _currentAssignments];
        };
        
        if (_debugLogging) then {
            diag_log format ["[RECONDO_HOSTAGE] Grouped distribution: All %1 hostages at %2", _hostageCount, _targetMarker];
        };
    };
    
    case "random";
    default {
        // Randomly distribute hostages across markers
        for "_i" from 0 to (_hostageCount - 1) do {
            private _targetMarker = selectRandom _hostageMarkers;
            private _name = _hostageNames select (_i min (count _hostageNames - 1));
            private _currentAssignments = _assignments get _targetMarker;
            _currentAssignments pushBack [_i, _name];
            _assignments set [_targetMarker, _currentAssignments];
        };
        
        if (_debugLogging) then {
            diag_log format ["[RECONDO_HOSTAGE] Random distribution across %1 markers:", count _hostageMarkers];
            {
                private _marker = _x;
                private _hostagesHere = _y;
                diag_log format ["[RECONDO_HOSTAGE]   %1: %2 hostages", _marker, count _hostagesHere];
            } forEach _assignments;
        };
    };
};

_assignments
