/*
    Recondo_fnc_spawnPursuitGroup
    Spawns a Wave 2+ pursuit group
    
    Description:
        Spawns a larger pursuit group without dogs or sounds.
        These groups follow the same tracking behavior as the main group.
    
    Parameters:
        _moduleSettings - HashMap of module settings
        _detectorGroup - The group that triggered this wave
        _targetGroup - The group being tracked
        _waveNumber - Which wave this is (2-5)
        _partyId - Unique party ID for linking groups
    
    Returns:
        Group object (or grpNull on failure)
*/

if (!isServer) exitWith { grpNull };

params ["_moduleSettings", "_detectorGroup", "_targetGroup", "_waveNumber", "_partyId"];

private _moduleId = _moduleSettings get "moduleId";
private _reinforcementSide = _moduleSettings get "reinforcementSide";
private _targetSide = _moduleSettings get "targetSide";
private _unitClassnames = _moduleSettings get "unitClassnames";
private _maxActiveGroups = _moduleSettings get "maxActiveGroups";
private _spawnDistance = _moduleSettings get "spawnDistance";
private _safetyDistance = _moduleSettings get "safetyDistance";
private _heightLimit = _moduleSettings get "heightLimit";
private _pursuitMinSize = _moduleSettings get "pursuitMinSize";
private _pursuitMaxSize = _moduleSettings get "pursuitMaxSize";
private _numberOfWaves = _moduleSettings get "numberOfWaves";
private _debugMarkers = _moduleSettings get "debugMarkers";
private _debugLogging = _moduleSettings get "debugLogging";

// Check max groups
private _activeGroups = _moduleSettings get "activeGroups";
if (_maxActiveGroups != -1 && count _activeGroups >= _maxActiveGroups) exitWith {
    if (_debugLogging) then {
        diag_log format ["[RECONDO_RW] Module %1: Max active groups reached, cannot spawn Wave %2", _moduleId, _waveNumber];
    };
    grpNull
};

// Get spawn position (behind the detecting group)
private _detectorPos = getPos (leader _detectorGroup);
private _detectorDir = getDir (leader _detectorGroup);

// Get initial target position
private _targetUnits = units _targetGroup select { alive _x };
private _initialTargetPos = if (count _targetUnits > 0) then {
    getPos (_targetUnits select 0)
} else {
    _detectorPos // Fallback to detector position
};

// Find safe spawn position
private _spawnResult = [_detectorPos, _detectorDir, _spawnDistance, _safetyDistance, _targetSide, _heightLimit] call Recondo_fnc_findSafeSpawnPos;
private _spawnPos = _spawnResult select 0;

// Create group
private _pursuitGroup = createGroup [_reinforcementSide, true];
if (isNull _pursuitGroup) exitWith {
    diag_log format ["[RECONDO_RW] Module %1: ERROR - Failed to create Wave %2 pursuit group", _moduleId, _waveNumber];
    grpNull
};

// Set group variables
_pursuitGroup setVariable ["RECONDO_RW_moduleId", _moduleId, true];
_pursuitGroup setVariable ["RECONDO_RW_targetGroup", _targetGroup, true];
_pursuitGroup setVariable ["RECONDO_RW_targetGroupId", groupId _targetGroup, true];
_pursuitGroup setVariable ["RECONDO_RW_waveNumber", _waveNumber, true];
_pursuitGroup setVariable ["RECONDO_RW_isMainGroup", false, true];
_pursuitGroup setVariable ["RECONDO_RW_isFlanker", false, true];
_pursuitGroup setVariable ["RECONDO_RW_isPursuit", true, true];
_pursuitGroup setVariable ["RECONDO_RW_partyId", _partyId, true];
_pursuitGroup setVariable ["RECONDO_RW_originPos", _spawnPos, true];
_pursuitGroup setVariable ["RECONDO_RW_initialTargetPos", _initialTargetPos, true];
_pursuitGroup setVariable ["RECONDO_RW_moduleSettings", _moduleSettings, true];
_pursuitGroup setVariable ["RECONDO_RW_hasDog", false, true]; // No dogs in pursuit waves
_pursuitGroup setVariable ["RECONDO_RW_useSounds", false, true]; // No sounds in pursuit waves

// Calculate group size
private _groupSize = _pursuitMinSize + floor random ((_pursuitMaxSize - _pursuitMinSize) + 1);
_groupSize = _groupSize max 1;

// Create units
private _unitsCreated = 0;
for "_i" from 1 to _groupSize do {
    private _class = selectRandom _unitClassnames;
    if (isClass (configFile >> "CfgVehicles" >> _class)) then {
        private _unit = _pursuitGroup createUnit [_class, _spawnPos, [], 0, "NONE"];
        if (!isNull _unit) then {
            _unit disableAI "AUTOCOMBAT";
            _unit setUnitPos "UP";
            _unitsCreated = _unitsCreated + 1;
        };
    };
};

if (_unitsCreated == 0) exitWith {
    deleteGroup _pursuitGroup;
    diag_log format ["[RECONDO_RW] Module %1: ERROR - Failed to create any Wave %2 units", _moduleId, _waveNumber];
    grpNull
};

// Configure group behavior
_pursuitGroup setFormation "WEDGE";
_pursuitGroup setBehaviour "AWARE";
_pursuitGroup setCombatMode "RED";
_pursuitGroup setSpeedMode "NORMAL"; // Faster than Wave 1

// Add to active groups
_activeGroups pushBack _pursuitGroup;
RECONDO_RW_ACTIVE_GROUPS pushBack _pursuitGroup;

// Create debug marker
if (_debugMarkers) then {
    private _markerName = format ["RECONDO_RW_pursuit_%1_%2_%3", _waveNumber, _moduleId, time];
    private _marker = createMarker [_markerName, _spawnPos];
    _marker setMarkerType "mil_dot";
    _marker setMarkerColor "ColorYellow";
    _marker setMarkerText format ["Wave%1_Pursuit", _waveNumber];
};

// Add detection handlers for next wave (if there are more waves)
private _nextWave = _waveNumber + 1;
private _maxWave = 1 + _numberOfWaves; // Wave 1 + additional waves
if (_nextWave <= _maxWave) then {
    [_pursuitGroup, _moduleSettings, _partyId, _nextWave] call Recondo_fnc_addRWDetectionHandlers;
};

// Start pursuit behavior (uses tracker behavior without sounds)
[_pursuitGroup, _moduleSettings] spawn Recondo_fnc_rwTrackerBehavior;

if (_debugLogging) then {
    diag_log format ["[RECONDO_RW] Module %1: Wave %2 pursuit group spawned with %3 units at %4",
        _moduleId, _waveNumber, _unitsCreated, _spawnPos];
};

_pursuitGroup
