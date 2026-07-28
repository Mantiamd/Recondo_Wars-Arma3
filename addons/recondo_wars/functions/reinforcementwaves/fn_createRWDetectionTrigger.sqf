/*
    Recondo_fnc_createRWDetectionTrigger
    Creates the OPFOR detection trigger for a Reinforcement Waves module
    
    Description:
        Creates a trigger at the module position that monitors OPFOR units
        for detection of BLUFOR. When detection occurs, spawns reinforcements.
        Trigger fires once then deletes itself.
    
    Parameters:
        _moduleSettings - HashMap of module settings
    
    Returns:
        Nothing (spawned detection loop)
*/

if (!isServer) exitWith {};

params ["_moduleSettings"];

private _moduleId = _moduleSettings get "moduleId";
private _modulePos = _moduleSettings get "modulePos";
private _triggerRadius = _moduleSettings get "triggerRadius";
private _detectionThreshold = _moduleSettings get "detectionThreshold";
private _heightLimit = _moduleSettings get "heightLimit";
private _reinforcementSide = _moduleSettings get "reinforcementSide";
private _targetSide = _moduleSettings get "targetSide";
private _reinforcementChance = _moduleSettings get "reinforcementChance";
private _debugMarkers = _moduleSettings get "debugMarkers";
private _debugLogging = _moduleSettings get "debugLogging";

// Create debug marker if enabled
if (_debugMarkers) then {
    private _markerName = format ["RECONDO_RW_trigger_%1", _moduleId];
    private _marker = createMarker [_markerName, _modulePos];
    _marker setMarkerShape "ELLIPSE";
    _marker setMarkerSize [_triggerRadius, _triggerRadius];
    _marker setMarkerColor "ColorRed";
    _marker setMarkerBrush "Border";
    _marker setMarkerAlpha 0.5;
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_RW] Detection loop started for module %1 at %2", _moduleId, _modulePos];
};

// Start detection loop
[_moduleSettings] spawn {
    params ["_moduleSettings"];
    
    private _moduleId = _moduleSettings get "moduleId";
    private _modulePos = _moduleSettings get "modulePos";
    private _triggerRadius = _moduleSettings get "triggerRadius";
    private _detectionThreshold = _moduleSettings get "detectionThreshold";
    private _heightLimit = _moduleSettings get "heightLimit";
    private _reinforcementSide = _moduleSettings get "reinforcementSide";
    private _targetSide = _moduleSettings get "targetSide";
    private _reinforcementChance = _moduleSettings get "reinforcementChance";
    private _debugLogging = _moduleSettings get "debugLogging";
    
    // Wait for mission to fully initialize.
    // Random offset staggers multiple module instances so their
    // detection sweeps don't all land on the same scheduler frames.
    sleep (5 + random 4);
    
    private _triggered = false;
    
    while {!_triggered} do {
        // Check if this module was already triggered
        if (_moduleId in RECONDO_RW_TRIGGERED_MODULES) exitWith {
            _triggered = true;
        };
        
        private _cachedUnits = allUnits;

        // Find all reinforcement side units within trigger radius
        private _detectorUnits = _cachedUnits select {
            alive _x &&
            side _x == _reinforcementSide &&
            _x distance _modulePos <= _triggerRadius &&
            (getPosATL _x select 2) <= _heightLimit
        };
        
        private _targetCandidates = _cachedUnits select {
            alive _x && side _x == _targetSide && {(getPosATL _x select 2) <= _heightLimit}
        };
        
        // Check if any detector unit has detected a target side unit
        {
            private _detector = _x;
            
            {
                private _target = _x;
                private _knowsAbout = _detector knowsAbout _target;
                
                if (_knowsAbout >= _detectionThreshold) then {
                    private _targetGroupId = groupId (group _target);
                    
                    // Cross-module suppression: skip (module stays armed) if
                    // another RW module recently triggered on this group, or
                    // the global concurrent-party cap is reached. Prevents
                    // overlapping modules dogpiling one detection event.
                    private _lastTrigger = RECONDO_RW_GROUP_COOLDOWNS getOrDefault [_targetGroupId, -1e7];
                    private _onCooldown = (serverTime - _lastTrigger) < RECONDO_RW_GROUP_COOLDOWN_SECONDS;
                    private _capReached = (call Recondo_fnc_getActiveRWPartyCount) >= RECONDO_RW_MAX_ACTIVE_PARTIES;
                    
                    if (_onCooldown || _capReached) exitWith {
                        if (_debugLogging) then {
                            diag_log format ["[RECONDO_RW] Module %1: Detection of group %2 suppressed (cooldown: %3, cap reached: %4)",
                                _moduleId, _targetGroupId, _onCooldown, _capReached];
                        };
                    };
                    
                    // Detection! Check reinforcement chance
                    if (random 1 <= _reinforcementChance) then {
                        // Mark as triggered and start the cross-module cooldown for this group
                        RECONDO_RW_GROUP_COOLDOWNS set [_targetGroupId, serverTime];
                        RECONDO_RW_TRIGGERED_MODULES pushBack _moduleId;
                        _moduleSettings set ["triggered", true];
                        _triggered = true;
                        
                        if (_debugLogging) then {
                            diag_log format ["[RECONDO_RW] Module %1: %2 detected %3 (knowsAbout: %4)", 
                                _moduleId, _detector, _target, _knowsAbout];
                        };
                        
                        // Get target group for tracking
                        private _targetGroup = group _target;

                        // Delay first-wave spawn to create a reaction window:
                        // randomized between 10 and 30 seconds.
                        private _spawnDelay = 10 + random 20;

                        if (_debugLogging) then {
                            diag_log format [
                                "[RECONDO_RW] Module %1: Wave 1 scheduled in %2s (detector %3, target group %4)",
                                _moduleId,
                                round _spawnDelay,
                                _detector,
                                _targetGroup
                            ];
                        };

                        [_moduleSettings, _detector, _targetGroup, _spawnDelay] spawn {
                            params ["_moduleSettings", "_detector", "_targetGroup", "_spawnDelay"];
                            sleep _spawnDelay;
                            [_moduleSettings, _detector, _targetGroup] call Recondo_fnc_spawnReinforcementParty;
                        };
                    } else {
                        // Failed reinforcement chance - still mark as triggered
                        RECONDO_RW_TRIGGERED_MODULES pushBack _moduleId;
                        _moduleSettings set ["triggered", true];
                        _triggered = true;
                        
                        if (_debugLogging) then {
                            diag_log format ["[RECONDO_RW] Module %1: Detection occurred but reinforcement chance failed", _moduleId];
                        };
                    };
                };
                
                if (_triggered) exitWith {};
            } forEach _targetCandidates;
            
            if (_triggered) exitWith {};
        } forEach _detectorUnits;
        
        if (!_triggered) then {
            sleep (4 + random 2); // ~5s polling, jittered to stagger module instances
        };
    };
    
    // Cleanup debug marker
    private _debugMarkers = _moduleSettings get "debugMarkers";
    if (_debugMarkers) then {
        private _markerName = format ["RECONDO_RW_trigger_%1", _moduleId];
        deleteMarker _markerName;
    };
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_RW] Detection loop ended for module %1", _moduleId];
    };
};
