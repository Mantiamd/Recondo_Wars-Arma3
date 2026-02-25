/*
    Recondo_fnc_getHostageObjectiveStatus
    Returns comprehensive hostage objective status for Terminal display
    
    Description:
        Returns a hashmap with all status information for a hostage
        objective including counts, name lists, and detailed per-hostage data.
    
    Parameters:
        _objectiveName - STRING - The objective name to query
    
    Returns:
        HASHMAP - Status hashmap with keys:
            total - NUMBER - Total hostage count
            rescued - NUMBER - Number rescued
            remaining - NUMBER - Number still at large
            complete - BOOL - True if all rescued
            rescuedNames - ARRAY - Names of rescued hostages
            remainingNames - ARRAY - Names of hostages still at large
            hostages - ARRAY - Detailed per-hostage data [id, name, status, marker]
            objectiveName - STRING - Objective display name
            instanceId - STRING - Module instance ID
    
    Example:
        ["Hostage Rescue"] call Recondo_fnc_getHostageObjectiveStatus;
*/

params [["_objectiveName", "", [""]]];

// Return empty hashmap if no name provided
if (_objectiveName == "") exitWith {
    createHashMapFromArray [
        ["total", 0],
        ["rescued", 0],
        ["remaining", 0],
        ["complete", true],
        ["rescuedNames", []],
        ["remainingNames", []],
        ["hostages", []],
        ["objectiveName", ""],
        ["instanceId", ""]
    ]
};

// Find the settings for this objective
private _settings = nil;
private _instanceId = "";

{
    if ((_x get "objectiveName") == _objectiveName) exitWith {
        _settings = _x;
        _instanceId = _x get "instanceId";
    };
} forEach RECONDO_HOSTAGE_INSTANCES;

if (isNil "_settings") exitWith {
    createHashMapFromArray [
        ["total", 0],
        ["rescued", 0],
        ["remaining", 0],
        ["complete", true],
        ["rescuedNames", []],
        ["remainingNames", []],
        ["hostages", []],
        ["objectiveName", _objectiveName],
        ["instanceId", ""]
    ]
};

private _hostageCount = _settings get "hostageCount";
private _hostageNames = _settings get "hostageNames";

// Get location data for marker info
private _locationData = RECONDO_HOSTAGE_LOCATIONS getOrDefault [_instanceId, [[], [], createHashMap]];
_locationData params ["_hostageMarkers", "_decoyMarkers", "_hostageAssignments"];

// Build detailed hostage list
private _hostages = [];
private _rescuedNames = [];
private _remainingNames = [];
private _rescuedCount = 0;

for "_i" from 0 to (_hostageCount - 1) do {
    private _hostageId = format ["%1_hostage_%2", _instanceId, _i];
    private _hostageName = _hostageNames select (_i min (count _hostageNames - 1));
    
    // Find which marker this hostage is assigned to
    private _assignedMarker = "";
    {
        private _marker = _x;
        private _hostagesHere = _y;
        {
            _x params ["_hIndex", "_hName"];
            if (_hIndex == _i) exitWith {
                _assignedMarker = _marker;
            };
        } forEach _hostagesHere;
        if (_assignedMarker != "") exitWith {};
    } forEach _hostageAssignments;
    
    // Check rescue status
    private _isRescued = _hostageId in RECONDO_HOSTAGE_RESCUED;
    private _status = if (_isRescued) then { "rescued" } else { "at_large" };
    
    // Add to appropriate name list
    if (_isRescued) then {
        _rescuedNames pushBack _hostageName;
        _rescuedCount = _rescuedCount + 1;
    } else {
        _remainingNames pushBack _hostageName;
    };
    
    // Add to detailed list as hashmap for easier access
    _hostages pushBack (createHashMapFromArray [
        ["id", _hostageId],
        ["name", _hostageName],
        ["index", _i],
        ["status", _status],
        ["rescued", _isRescued],
        ["marker", _assignedMarker]
    ]);
};

private _remaining = _hostageCount - _rescuedCount;
private _complete = _remaining == 0;

// Build and return the status hashmap
createHashMapFromArray [
    ["total", _hostageCount],
    ["rescued", _rescuedCount],
    ["remaining", _remaining],
    ["complete", _complete],
    ["rescuedNames", _rescuedNames],
    ["remainingNames", _remainingNames],
    ["hostages", _hostages],
    ["objectiveName", _objectiveName],
    ["instanceId", _instanceId]
]
