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
    
    // Wait for mission to fully initialize
    sleep 5;
    
    private _triggered = false;
    
    while {!_triggered} do {
        // Check if this module was already triggered
        if (_moduleId in RECONDO_RW_TRIGGERED_MODULES) exitWith {
            _triggered = true;
        };
        
        // Find all reinforcement side units within trigger radius
        private _detectorUnits = allUnits select {
            alive _x &&
            side _x == _reinforcementSide &&
            _x distance _modulePos <= _triggerRadius &&
            (getPosATL _x select 2) <= _heightLimit
        };
        
        // Check if any detector unit has detected a target side unit
        {
            private _detector = _x;
            
            // Check what this unit knows about
            {
                private _target = _x;
                
                // Skip if not target side or not alive
                if (!alive _target || side _target != _targetSide) then { continue };
                
                // Check height filter
                private _targetHeight = (getPosATL _target) select 2;
                if (_targetHeight > _heightLimit) then { continue };
                
                // Check knowsAbout threshold
                private _knowsAbout = _detector knowsAbout _target;
                
                if (_knowsAbout >= _detectionThreshold) then {
                    // Detection! Check reinforcement chance
                    if (random 1 <= _reinforcementChance) then {
                        // Mark as triggered
                        RECONDO_RW_TRIGGERED_MODULES pushBack _moduleId;
                        _moduleSettings set ["triggered", true];
                        _triggered = true;
                        
                        if (_debugLogging) then {
                            diag_log format ["[RECONDO_RW] Module %1: %2 detected %3 (knowsAbout: %4)", 
                                _moduleId, _detector, _target, _knowsAbout];
                        };
                        
                        // Get target group for tracking
                        private _targetGroup = group _target;
                        
                        // Spawn reinforcements
                        [_moduleSettings, _detector, _targetGroup] call Recondo_fnc_spawnReinforcementParty;
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
            } forEach allUnits;
            
            if (_triggered) exitWith {};
        } forEach _detectorUnits;
        
        if (!_triggered) then {
            sleep 2; // Check every 2 seconds
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
