/*
    Recondo_fnc_createTrackerGroup
    Creates a tracker group
    
    Description:
        Creates a scout tracker group at the given position to track the target group.
        Optionally includes a tracker dog.
    
    Parameters:
        _markerPos - Position to spawn the group (near marker)
        _targetGroup - Group to track
        _markerName - Name of the marker (optional, for logging)
    
    Returns:
        Group object or grpNull if failed
*/

if (!isServer) exitWith { grpNull };

params ["_markerPos", "_targetGroup", ["_markerName", ""]];

private _settings = RECONDO_TRACKERS_SETTINGS;

// Check max groups limit
private _maxActiveGroups = _settings get "maxActiveGroups";
if (_maxActiveGroups != -1 && count RECONDO_TRACKERS_ACTIVE_GROUPS >= _maxActiveGroups) exitWith {
    if (_settings get "debugLogging") then {
        diag_log "[RECONDO_TRACKERS] Maximum tracker groups reached, cannot spawn more";
    };
    grpNull
};

// Check if marker is enabled (if marker name provided)
if (_markerName != "" && !(_markerName in RECONDO_TRACKERS_ENABLED_MARKERS)) exitWith {
    if (_settings get "debugLogging") then {
        diag_log format ["[RECONDO_TRACKERS] Marker %1 is not enabled for spawning", _markerName];
    };
    grpNull
};

// Get settings
private _trackerSide = _settings get "trackerSide";
private _trackerClassnames = _settings get "trackerClassnames";
private _minGroupSize = _settings get "minGroupSize";
private _maxGroupSize = _settings get "maxGroupSize";
private _movementSpeed = _settings get "movementSpeed";
private _dogSpawnChance = _settings get "dogSpawnChance";
private _debugLogging = _settings get "debugLogging";
private _debugMarkers = _settings get "debugMarkers";

// Calculate group size
private _groupSize = _minGroupSize + floor random ((_maxGroupSize - _minGroupSize) + 1);
_groupSize = _groupSize max 1;

// Create group
private _group = createGroup [_trackerSide, true];
if (isNull _group) exitWith {
    diag_log "[RECONDO_TRACKERS] ERROR: Failed to create tracker group";
    grpNull
};

// Set group variables
_group setVariable ["RECONDO_TRACKERS_targetGroup", _targetGroup, true];
_group setVariable ["RECONDO_TRACKERS_targetGroupId", groupId _targetGroup, true];
_group setVariable ["RECONDO_TRACKERS_isScout", true, true];
_group setVariable ["RECONDO_TRACKERS_originPos", _markerPos, true];

// Determine if this group will have a dog
private _hasDog = random 1 < _dogSpawnChance;
_group setVariable ["RECONDO_TRACKERS_hasDog", _hasDog, true];

// Link footprints to this tracker group
private _targetGroupIdStr = groupId _targetGroup;
{
    private _footprint = _x;
    if (_footprint select 2 == _targetGroupIdStr) then {
        (_footprint select 3) pushBack _group;
    };
} forEach RECONDO_TRACKERS_FOOTPRINTS;

// Randomly determine if speed-based tracking
if (random 1 < 0.5) then {
    RECONDO_TRACKERS_SPEED_BASED pushBack _group;
};

// Create units
private _unitsCreated = 0;
for "_i" from 1 to _groupSize do {
    private _class = selectRandom _trackerClassnames;
    
    if (isClass (configFile >> "CfgVehicles" >> _class)) then {
        private _unit = _group createUnit [_class, _markerPos, [], 0, "NONE"];
        if (!isNull _unit) then {
            _unit disableAI "AUTOCOMBAT";
            _unit setUnitPos "UP";
            _unitsCreated = _unitsCreated + 1;
        };
    } else {
        if (_debugLogging) then {
            diag_log format ["[RECONDO_TRACKERS] WARNING: Invalid classname '%1'", _class];
        };
    };
};

// Validate units were created
if (_unitsCreated == 0) exitWith {
    deleteGroup _group;
    diag_log "[RECONDO_TRACKERS] ERROR: Failed to create any tracker units";
    grpNull
};

// Configure group behavior
_group setFormation "FILE";
_group setBehaviour "SAFE";
_group setCombatMode "RED";
_group setSpeedMode _movementSpeed;

// Add to active groups
RECONDO_TRACKERS_ACTIVE_GROUPS pushBack _group;

// Create debug marker if enabled
if (_debugMarkers) then {
    private _debugMarkerName = format ["RECONDO_TRACKERS_scout_%1_%2", groupId _targetGroup, time];
    private _marker = createMarker [_debugMarkerName, _markerPos];
    _marker setMarkerType "mil_dot";
    _marker setMarkerColor "ColorGreen";
    _marker setMarkerText format ["Scout_%1", groupId _targetGroup];
};

// Create tracker dog if enabled for this group
if (_hasDog) then {
    private _dog = [_group] call Recondo_fnc_createTrackerDog;
    if (!isNull _dog) then {
        if (_debugLogging) then {
            diag_log format ["[RECONDO_TRACKERS] Tracker dog created for group %1", _group];
        };
    };
};

// Start tracker behavior
[_group] spawn Recondo_fnc_trackerBehavior;

if (_debugLogging) then {
    diag_log format ["[RECONDO_TRACKERS] Scout group created: %1 tracking %2, %3 units, hasDog=%4", 
        _group, _targetGroup, _unitsCreated, _hasDog];
};

_group
