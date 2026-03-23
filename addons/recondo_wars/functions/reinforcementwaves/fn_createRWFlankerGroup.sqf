/*
    Recondo_fnc_createRWFlankerGroup
    Creates a flanker group for Wave 1 reinforcements
    
    Description:
        Creates a left or right flanker group that will use lateral/forward
        offsets to approach the target from the side.
    
    Parameters:
        _moduleSettings - HashMap of module settings
        _spawnPos - Initial spawn position
        _targetGroup - The group being tracked
        _mainGroup - Reference to the main group
        _side - "left" or "right"
        _partyId - Unique party ID for linking groups
    
    Returns:
        Group object (or grpNull on failure)
*/

if (!isServer) exitWith { grpNull };

params ["_moduleSettings", "_spawnPos", "_targetGroup", "_mainGroup", "_side", "_partyId"];

private _moduleId = _moduleSettings get "moduleId";
private _reinforcementSide = _moduleSettings get "reinforcementSide";
private _unitClassnames = _moduleSettings get "unitClassnames";
private _flankerMinSize = _moduleSettings get "flankerMinSize";
private _flankerMaxSize = _moduleSettings get "flankerMaxSize";
private _flankerLateralOffset = _moduleSettings get "flankerLateralOffset";
private _flankerForwardOffset = _moduleSettings get "flankerForwardOffset";
private _debugMarkers = _moduleSettings get "debugMarkers";
private _debugLogging = _moduleSettings get "debugLogging";

// Create group
private _flankerGroup = createGroup [_reinforcementSide, true];
if (isNull _flankerGroup) exitWith {
    diag_log format ["[RECONDO_RW] Module %1: ERROR - Failed to create %2 flanker group", _moduleId, _side];
    grpNull
};

// Set group variables
_flankerGroup setVariable ["RECONDO_RW_moduleId", _moduleId];
_flankerGroup setVariable ["RECONDO_RW_targetGroup", _targetGroup];
_flankerGroup setVariable ["RECONDO_RW_targetGroupId", groupId _targetGroup];
_flankerGroup setVariable ["RECONDO_RW_waveNumber", 1];
_flankerGroup setVariable ["RECONDO_RW_isMainGroup", false];
_flankerGroup setVariable ["RECONDO_RW_isFlanker", true];
_flankerGroup setVariable ["RECONDO_RW_flankerSide", _side];
_flankerGroup setVariable ["RECONDO_RW_mainGroup", _mainGroup];
_flankerGroup setVariable ["RECONDO_RW_partyId", _partyId];
_flankerGroup setVariable ["RECONDO_RW_originPos", _spawnPos];
_flankerGroup setVariable ["RECONDO_RW_moduleSettings", _moduleSettings];
_flankerGroup setVariable ["RECONDO_RW_lateralOffset", _flankerLateralOffset];
_flankerGroup setVariable ["RECONDO_RW_forwardOffset", _flankerForwardOffset];
_flankerGroup setVariable ["RECONDO_RW_hasDog", false];

// Calculate group size
private _groupSize = _flankerMinSize + floor random ((_flankerMaxSize - _flankerMinSize) + 1);
_groupSize = _groupSize max 1;

// Create units
private _unitsCreated = 0;
for "_i" from 1 to _groupSize do {
    private _class = selectRandom _unitClassnames;
    if (isClass (configFile >> "CfgVehicles" >> _class)) then {
        private _unit = _flankerGroup createUnit [_class, _spawnPos, [], 0, "NONE"];
        if (!isNull _unit) then {
            _unit disableAI "AUTOCOMBAT";
            _unit setUnitPos "UP";
            _unitsCreated = _unitsCreated + 1;
        };
    };
};

if (_unitsCreated == 0) exitWith {
    deleteGroup _flankerGroup;
    diag_log format ["[RECONDO_RW] Module %1: ERROR - Failed to create any %2 flanker units", _moduleId, _side];
    grpNull
};

// Configure group behavior
_flankerGroup setFormation "FILE";
_flankerGroup setBehaviour "AWARE";
_flankerGroup setCombatMode "RED";
_flankerGroup setSpeedMode "LIMITED";

// Create debug marker
if (_debugMarkers) then {
    private _markerName = format ["RECONDO_RW_flanker_%1_%2_%3", _side, _moduleId, time];
    private _marker = createMarker [_markerName, _spawnPos];
    _marker setMarkerType "mil_dot";
    _marker setMarkerColor "ColorOrange";
    _marker setMarkerText format ["Wave1_%1", _side];
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_RW] Module %1: %2 flanker created with %3 units at %4", 
        _moduleId, _side, _unitsCreated, _spawnPos];
};

_flankerGroup
