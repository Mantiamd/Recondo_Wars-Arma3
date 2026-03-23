/*
    Recondo_fnc_spawnReinforcementParty
    Spawns Wave 1 reinforcement party (main group + flankers)
    
    Description:
        Spawns the initial reinforcement wave consisting of a main group
        and optional flanker groups. Main group can have a tracker dog.
        All Wave 1 groups use tracker sounds.
    
    Parameters:
        _moduleSettings - HashMap of module settings
        _detector - The OPFOR unit that detected the target
        _targetGroup - The BLUFOR group being tracked
    
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params ["_moduleSettings", "_detector", "_targetGroup"];

private _moduleId = _moduleSettings get "moduleId";
private _reinforcementSide = _moduleSettings get "reinforcementSide";
private _targetSide = _moduleSettings get "targetSide";
private _unitClassnames = _moduleSettings get "unitClassnames";
private _maxActiveGroups = _moduleSettings get "maxActiveGroups";
private _spawnDistance = _moduleSettings get "spawnDistance";
private _safetyDistance = _moduleSettings get "safetyDistance";
private _heightLimit = _moduleSettings get "heightLimit";
private _wave1MinSize = _moduleSettings get "wave1MinSize";
private _wave1MaxSize = _moduleSettings get "wave1MaxSize";
private _enableFlankers = _moduleSettings get "enableFlankers";
private _dogSpawnChance = _moduleSettings get "dogSpawnChance";
private _numberOfWaves = _moduleSettings get "numberOfWaves";
private _debugMarkers = _moduleSettings get "debugMarkers";
private _debugLogging = _moduleSettings get "debugLogging";

// Check max groups
private _activeGroups = _moduleSettings get "activeGroups";
if (_maxActiveGroups != -1 && count _activeGroups >= _maxActiveGroups) exitWith {
    if (_debugLogging) then {
        diag_log format ["[RECONDO_RW] Module %1: Max active groups reached, cannot spawn reinforcements", _moduleId];
    };
};

// Calculate spawn position
private _detectorPos = getPos _detector;
private _detectorDir = getDir _detector;

// Get initial target position (where the detected units are)
private _targetUnits = units _targetGroup select { alive _x };
private _initialTargetPos = [];
if (count _targetUnits > 0) then {
    _initialTargetPos = getPos (_targetUnits select 0);
    _detectorDir = _detectorPos getDir _initialTargetPos;
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_RW] Module %1: Target group detected at %2", _moduleId, _initialTargetPos];
};

// Find safe spawn position
private _spawnResult = [_detectorPos, _detectorDir, _spawnDistance, _safetyDistance, _targetSide, _heightLimit] call Recondo_fnc_findSafeSpawnPos;
private _spawnPos = _spawnResult select 0;
private _isSafe = _spawnResult select 1;

if (_debugLogging) then {
    diag_log format ["[RECONDO_RW] Module %1: Spawning reinforcement party at %2 (safe: %3)", _moduleId, _spawnPos, _isSafe];
};

// Generate unique party ID
private _partyId = format ["%1_%2_%3", _moduleId, groupId _targetGroup, time];

// ========================================
// CREATE MAIN REINFORCEMENT GROUP
// ========================================

private _mainGroup = createGroup [_reinforcementSide, true];
if (isNull _mainGroup) exitWith {
    diag_log format ["[RECONDO_RW] Module %1: ERROR - Failed to create main group", _moduleId];
};

// Set group variables
_mainGroup setVariable ["RECONDO_RW_moduleId", _moduleId];
_mainGroup setVariable ["RECONDO_RW_targetGroup", _targetGroup];
_mainGroup setVariable ["RECONDO_RW_targetGroupId", groupId _targetGroup];
_mainGroup setVariable ["RECONDO_RW_waveNumber", 1];
_mainGroup setVariable ["RECONDO_RW_isMainGroup", true];
_mainGroup setVariable ["RECONDO_RW_isFlanker", false];
_mainGroup setVariable ["RECONDO_RW_partyId", _partyId];
_mainGroup setVariable ["RECONDO_RW_originPos", _spawnPos];
_mainGroup setVariable ["RECONDO_RW_initialTargetPos", _initialTargetPos];
_mainGroup setVariable ["RECONDO_RW_moduleSettings", _moduleSettings];

// Calculate group size
private _groupSize = _wave1MinSize + floor random ((_wave1MaxSize - _wave1MinSize) + 1);
_groupSize = _groupSize max 1;

// Create units
private _unitsCreated = 0;
for "_i" from 1 to _groupSize do {
    private _class = selectRandom _unitClassnames;
    if (isClass (configFile >> "CfgVehicles" >> _class)) then {
        private _unit = _mainGroup createUnit [_class, _spawnPos, [], 0, "NONE"];
        if (!isNull _unit) then {
            _unit disableAI "AUTOCOMBAT";
            _unit setUnitPos "UP";
            _unitsCreated = _unitsCreated + 1;
        };
    };
};

if (_unitsCreated == 0) exitWith {
    deleteGroup _mainGroup;
    diag_log format ["[RECONDO_RW] Module %1: ERROR - Failed to create any units", _moduleId];
};

// Configure group behavior
_mainGroup setFormation "FILE";
_mainGroup setBehaviour "AWARE";
_mainGroup setCombatMode "RED";
_mainGroup setSpeedMode "LIMITED";

// Add to active groups
_activeGroups pushBack _mainGroup;
RECONDO_RW_ACTIVE_GROUPS pushBack _mainGroup;

// Determine if this group has a dog
private _hasDog = random 1 < _dogSpawnChance;
_mainGroup setVariable ["RECONDO_RW_hasDog", _hasDog];

// Create tracker dog if enabled
if (_hasDog) then {
    private _dogClassnames = _moduleSettings get "dogClassnames";
    if (count _dogClassnames > 0) then {
        // Use the Trackers module dog creation if available, otherwise create basic dog
        private _dog = [_mainGroup, _moduleSettings] call Recondo_fnc_createRWDog;
        if (_debugLogging && !isNull _dog) then {
            diag_log format ["[RECONDO_RW] Module %1: Tracker dog created for main group", _moduleId];
        };
    };
};

// Create debug marker
if (_debugMarkers) then {
    private _markerName = format ["RECONDO_RW_main_%1_%2", _moduleId, time];
    private _marker = createMarker [_markerName, _spawnPos];
    _marker setMarkerType "mil_dot";
    _marker setMarkerColor "ColorRed";
    _marker setMarkerText "Wave1_Main";
};

// ========================================
// CREATE FLANKER GROUPS
// ========================================

private _leftFlanker = grpNull;
private _rightFlanker = grpNull;

if (_enableFlankers) then {
    private _leftSpawnPos = _spawnPos vectorAdd [-50, 0, 0];
    private _rightSpawnPos = _spawnPos vectorAdd [50, 0, 0];
    
    _leftFlanker = [_moduleSettings, _leftSpawnPos, _targetGroup, _mainGroup, "left", _partyId] call Recondo_fnc_createRWFlankerGroup;
    _rightFlanker = [_moduleSettings, _rightSpawnPos, _targetGroup, _mainGroup, "right", _partyId] call Recondo_fnc_createRWFlankerGroup;
    
    if (!isNull _leftFlanker) then {
        _activeGroups pushBack _leftFlanker;
        RECONDO_RW_ACTIVE_GROUPS pushBack _leftFlanker;
    };
    if (!isNull _rightFlanker) then {
        _activeGroups pushBack _rightFlanker;
        RECONDO_RW_ACTIVE_GROUPS pushBack _rightFlanker;
    };
};

// Link all groups for convergence
private _allLinkedGroups = [_mainGroup, _leftFlanker, _rightFlanker] select {!isNull _x};
{
    _x setVariable ["RECONDO_RW_linkedGroups", _allLinkedGroups];
} forEach _allLinkedGroups;

_mainGroup setVariable ["RECONDO_RW_leftFlanker", _leftFlanker];
_mainGroup setVariable ["RECONDO_RW_rightFlanker", _rightFlanker];

// ========================================
// ADD DETECTION HANDLERS FOR NEXT WAVE
// ========================================

if (_numberOfWaves > 0) then {
    [_mainGroup, _moduleSettings, _partyId, 2] call Recondo_fnc_addRWDetectionHandlers;
    if (!isNull _leftFlanker) then {
        [_leftFlanker, _moduleSettings, _partyId, 2] call Recondo_fnc_addRWDetectionHandlers;
    };
    if (!isNull _rightFlanker) then {
        [_rightFlanker, _moduleSettings, _partyId, 2] call Recondo_fnc_addRWDetectionHandlers;
    };
};

// ========================================
// START BEHAVIORS
// ========================================

// Add to Trackers footprint tracking if Trackers module is active
private _targetGroupIdStr = groupId _targetGroup;
if (!(_targetGroupIdStr in RECONDO_TRACKERS_TRACKED_GROUPS)) then {
    RECONDO_TRACKERS_TRACKED_GROUPS pushBack _targetGroupIdStr;
    publicVariable "RECONDO_TRACKERS_TRACKED_GROUPS";
    
    // Also add to always-track so footprints are created regardless of speed
    if (!(_targetGroupIdStr in RECONDO_TRACKERS_ALWAYS_TRACK_GROUPS)) then {
        RECONDO_TRACKERS_ALWAYS_TRACK_GROUPS pushBack _targetGroupIdStr;
        publicVariable "RECONDO_TRACKERS_ALWAYS_TRACK_GROUPS";
    };
};

// Start main group behavior (uses tracker behavior)
[_mainGroup, _moduleSettings] spawn Recondo_fnc_rwTrackerBehavior;

// Start flanker behaviors
if (!isNull _leftFlanker) then {
    [_leftFlanker, _moduleSettings] spawn Recondo_fnc_rwFlankerBehavior;
};
if (!isNull _rightFlanker) then {
    [_rightFlanker, _moduleSettings] spawn Recondo_fnc_rwFlankerBehavior;
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_RW] Module %1: Wave 1 spawned - Main: %2 (%3 units), Left: %4, Right: %5, Dog: %6",
        _moduleId, _mainGroup, _unitsCreated, _leftFlanker, _rightFlanker, _hasDog];
};
