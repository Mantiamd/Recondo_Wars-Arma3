/*
    Recondo_fnc_createRWSideGroup
    Creates a 2-man side group for the Wave 1 pincer

    Description:
        Spawns a small group at a fixed bearing from the player group so
        Wave 1 converges from multiple directions (replaces the old flanker
        system). The bearing is what sells the pincer, so it is never
        changed: if the spot is in water or on top of a target-side unit,
        the position is only pushed further out along the same bearing,
        and force-placed at the farthest candidate if nothing clears.
        Side groups hunt independently via the normal tracker behavior
        (sounds on, no dog) and never trigger further waves. Server-only.

    Parameters:
        0: HASHMAP - Module settings
        1: ARRAY - Player anchor position (centroid of the target group)
        2: NUMBER - Bearing from the anchor to spawn at (degrees)
        3: GROUP - Target group being hunted
        4: STRING - Party ID shared with the main group
        5: STRING - Label for debug markers/logs ("left"/"right")

    Returns:
        GROUP - The side group (grpNull on failure)
*/

if (!isServer) exitWith { grpNull };

params ["_moduleSettings", "_playerAnchor", "_bearing", "_targetGroup", "_partyId", "_sideLabel"];

private _moduleId = _moduleSettings get "moduleId";
private _reinforcementSide = _moduleSettings get "reinforcementSide";
private _targetSide = _moduleSettings get "targetSide";
private _unitClassnames = _moduleSettings get "unitClassnames";
private _sideDistance = _moduleSettings get "sideGroupDistance";
private _heightLimit = _moduleSettings get "heightLimit";
private _debugMarkers = _moduleSettings get "debugMarkers";
private _debugLogging = _moduleSettings get "debugLogging";

_bearing = (_bearing + 360) mod 360;

// Target-side units to avoid dropping the group directly on top of
private _targetUnits = allUnits select {
    alive _x && side _x == _targetSide && {(getPosATL _x select 2) <= _heightLimit}
};

// Walk outward along the fixed bearing until the point is on land and not
// within 100m of a target-side unit. Last tested point is the force-place
// fallback so the pincer direction is never dropped.
private _spawnPos = _playerAnchor getPos [_sideDistance, _bearing];
{
    private _offset = _x;
    private _testPos = _playerAnchor getPos [_sideDistance + _offset, _bearing];
    _testPos set [2, 0];
    _spawnPos = _testPos;

    private _tooClose = (_targetUnits findIf { _x distance _testPos < 100 }) != -1;
    if (!_tooClose && {!surfaceIsWater _testPos}) exitWith {};
} forEach [0, 50, 100, 150];

// Create group
private _sideGroup = createGroup [_reinforcementSide, true];
if (isNull _sideGroup) exitWith {
    diag_log format ["[RECONDO_RW] Module %1: ERROR - Failed to create %2 side group", _moduleId, _sideLabel];
    grpNull
};

// Set group variables (same contract the tracker behavior reads)
_sideGroup setVariable ["RECONDO_RW_moduleId", _moduleId];
_sideGroup setVariable ["RECONDO_RW_targetGroup", _targetGroup];
_sideGroup setVariable ["RECONDO_RW_targetGroupId", groupId _targetGroup];
_sideGroup setVariable ["RECONDO_RW_waveNumber", 1];
_sideGroup setVariable ["RECONDO_RW_isMainGroup", false];
_sideGroup setVariable ["RECONDO_RW_isSideGroup", true];
_sideGroup setVariable ["RECONDO_RW_partyId", _partyId];
_sideGroup setVariable ["RECONDO_RW_originPos", _spawnPos];
_sideGroup setVariable ["RECONDO_RW_initialTargetPos", _playerAnchor];
_sideGroup setVariable ["RECONDO_RW_moduleSettings", _moduleSettings];
_sideGroup setVariable ["RECONDO_RW_hasDog", false];
_sideGroup setVariable ["RECONDO_RW_useSounds", true];

// Create the 2-man team. Brief pause between creations spreads engine load.
private _unitsCreated = 0;
for "_i" from 1 to 2 do {
    private _class = selectRandom _unitClassnames;
    if (isClass (configFile >> "CfgVehicles" >> _class)) then {
        private _unit = _sideGroup createUnit [_class, _spawnPos, [], 0, "NONE"];
        if (!isNull _unit) then {
            _unit disableAI "AUTOCOMBAT";
            _unit setUnitPos "UP";
            _unitsCreated = _unitsCreated + 1;
        };
    };
    sleep 0.1;
};

if (_unitsCreated == 0) exitWith {
    deleteGroup _sideGroup;
    diag_log format ["[RECONDO_RW] Module %1: ERROR - Failed to create any %2 side group units", _moduleId, _sideLabel];
    grpNull
};

// Configure group behavior
_sideGroup setFormation "FILE";
_sideGroup setBehaviour "AWARE";
_sideGroup setCombatMode "RED";
_sideGroup setSpeedMode "LIMITED";

// Create debug marker
if (_debugMarkers) then {
    private _markerName = format ["RECONDO_RW_side_%1_%2_%3", _sideLabel, _moduleId, time];
    private _marker = createMarker [_markerName, _spawnPos];
    _marker setMarkerType "mil_dot";
    _marker setMarkerColor "ColorOrange";
    _marker setMarkerText format ["Wave1_Side_%1", _sideLabel];
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_RW] Module %1: %2 side group created (%3 units) at %4 (bearing %5)",
        _moduleId, _sideLabel, _unitsCreated, _spawnPos, round _bearing];
};

_sideGroup
