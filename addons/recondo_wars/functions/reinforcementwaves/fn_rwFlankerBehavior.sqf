/*
    Recondo_fnc_rwFlankerBehavior
    Controls flanker group movement with lateral/forward offsets
    
    Description:
        Flanker groups move parallel to the main group but offset to the side
        and slightly forward. They follow the main group's position with offsets.
    
    Parameters:
        _flankerGroup - The flanker group
        _moduleSettings - HashMap of module settings
    
    Returns:
        Nothing (spawned behavior loop)
*/

if (!isServer) exitWith {};

params ["_flankerGroup", "_moduleSettings"];

if (isNull _flankerGroup) exitWith {};

private _moduleId = _moduleSettings get "moduleId";
private _soundInterval = _moduleSettings get "soundInterval";
private _debugLogging = _moduleSettings get "debugLogging";
private _soundsNoDog = _moduleSettings get "soundsNoDog";

private _mainGroup = _flankerGroup getVariable ["RECONDO_RW_mainGroup", grpNull];
private _flankerSide = _flankerGroup getVariable ["RECONDO_RW_flankerSide", "left"];
private _lateralOffset = _flankerGroup getVariable ["RECONDO_RW_lateralOffset", 120];
private _forwardOffset = _flankerGroup getVariable ["RECONDO_RW_forwardOffset", 75];

// Determine lateral direction multiplier (-1 for left, +1 for right)
private _lateralMult = if (_flankerSide == "left") then { -1 } else { 1 };

if (_debugLogging) then {
    diag_log format ["[RECONDO_RW] Module %1: Flanker behavior started for %2 side (lateral: %3m, forward: %4m)",
        _moduleId, _flankerSide, _lateralOffset, _forwardOffset];
};

private _leader = leader _flankerGroup;
// Each group gets its own randomized interval (base ±10 seconds)
// If soundInterval is 0 or less, disable sounds entirely
private _groupSoundInterval = if (_soundInterval <= 0) then { 
    0 
} else { 
    (_soundInterval + (random 20) - 10) max 5 
};
private _lastSoundTime = if (_groupSoundInterval > 0) then { time - (random _groupSoundInterval) } else { 0 };  // Random initial offset so groups don't sync up
private _lastMoveTime = time;

while {!isNull _flankerGroup && {count (units _flankerGroup select {alive _x}) > 0}} do {
    _leader = leader _flankerGroup;
    
    if (isNull _leader || !alive _leader) then {
        // Find new leader
        private _aliveUnits = units _flankerGroup select {alive _x};
        if (count _aliveUnits > 0) then {
            _flankerGroup selectLeader (_aliveUnits select 0);
            _leader = leader _flankerGroup;
        } else {
            // All dead
            break;
        };
    };
    
    // Filter out aircraft and excluded targets from AI awareness
    [_flankerGroup, _moduleSettings] call Recondo_fnc_filterAirTargets;
    
    // Get main group position and direction
    private _mainGroupPos = if (!isNull _mainGroup) then {
        private _mainLeader = leader _mainGroup;
        if (!isNull _mainLeader && alive _mainLeader) then {
            getPos _mainLeader
        } else {
            // Fallback: move toward last known target position
            _flankerGroup getVariable ["RECONDO_RW_lastTargetPos", getPos _leader]
        };
    } else {
        getPos _leader
    };
    
    // Calculate main group's movement direction
    private _mainGroupDir = 0;
    if (!isNull _mainGroup) then {
        private _mainLeader = leader _mainGroup;
        if (!isNull _mainLeader && alive _mainLeader) then {
            _mainGroupDir = getDir _mainLeader;
        };
    };
    
    // Calculate offset position relative to main group
    // Forward offset in the direction main group is moving
    // Lateral offset perpendicular to movement direction
    
    // Get forward position
    private _forwardPos = _mainGroupPos getPos [_forwardOffset, _mainGroupDir];
    
    // Get lateral offset (perpendicular to movement)
    private _lateralDir = (_mainGroupDir + (90 * _lateralMult)) mod 360;
    private _targetPos = _forwardPos getPos [_lateralOffset, _lateralDir];
    
    // Store for fallback if main group dies
    _flankerGroup setVariable ["RECONDO_RW_lastTargetPos", _targetPos];
    
    // Check if in combat
    private _inCombat = behaviour _leader == "COMBAT";
    
    if (!_inCombat) then {
        // Only update waypoint periodically to avoid spam
        if (time - _lastMoveTime > 5) then {
            // Clear existing waypoints
            while {count waypoints _flankerGroup > 0} do {
                deleteWaypoint [_flankerGroup, 0];
            };
            
            // Add movement waypoint
            private _wp = _flankerGroup addWaypoint [_targetPos, 0];
            _wp setWaypointType "MOVE";
            _wp setWaypointBehaviour "AWARE";
            _wp setWaypointSpeed "LIMITED";
            _wp setWaypointFormation "FILE";
            _wp setWaypointCompletionRadius 20;
            
            _flankerGroup setCurrentWaypoint _wp;
            
            _lastMoveTime = time;
        };
    };
    
    // Play sounds at interval (Wave 1 flankers use sounds)
    if (_groupSoundInterval > 0 && time - _lastSoundTime >= _groupSoundInterval) then {
        if (count _soundsNoDog > 0 && !isNull _leader && alive _leader) then {
            [_leader, _soundsNoDog] remoteExec ["RECONDO_RW_fnc_playSound", 0];
        };
        _lastSoundTime = time;
    };
    
    sleep 3;
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_RW] Module %1: Flanker behavior ended for %2 side", _moduleId, _flankerSide];
};
