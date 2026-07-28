/*
    Recondo_fnc_addRWDetectionHandlers
    Adds detection event handlers to spawn next wave
    
    Description:
        Adds handlers to a reinforcement group that spawn the next wave
        when they detect the target. Each party ID can only trigger
        each wave number once.
    
    Parameters:
        _group - The group to monitor
        _moduleSettings - HashMap of module settings
        _partyId - Unique party ID for tracking waves
        _nextWaveNumber - The wave number to spawn when detected
    
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params ["_group", "_moduleSettings", "_partyId", "_nextWaveNumber"];

if (isNull _group) exitWith {};

private _moduleId = _moduleSettings get "moduleId";
private _targetSide = _moduleSettings get "targetSide";
private _detectionThreshold = _moduleSettings get "detectionThreshold";
private _heightLimit = _moduleSettings get "heightLimit";
private _debugLogging = _moduleSettings get "debugLogging";

// Generate wave tracking ID
private _waveTrackId = format ["%1_wave%2", _partyId, _nextWaveNumber];

// Store tracking ID on module settings to prevent duplicate waves
private _spawnedWaves = _moduleSettings getOrDefault ["spawnedWaves", []];
_moduleSettings set ["spawnedWaves", _spawnedWaves];

if (_debugLogging) then {
    diag_log format ["[RECONDO_RW] Module %1: Adding detection handler for Wave %2 on group %3",
        _moduleId, _nextWaveNumber, _group];
};

// Start detection monitoring
[_group, _moduleSettings, _partyId, _nextWaveNumber, _waveTrackId] spawn {
    params ["_group", "_moduleSettings", "_partyId", "_nextWaveNumber", "_waveTrackId"];
    
    private _moduleId = _moduleSettings get "moduleId";
    private _targetSide = _moduleSettings get "targetSide";
    private _targetGroup = _group getVariable ["RECONDO_RW_targetGroup", grpNull];
    private _detectionThreshold = _moduleSettings get "detectionThreshold";
    private _heightLimit = _moduleSettings get "heightLimit";
    private _debugLogging = _moduleSettings get "debugLogging";
    
    // Wait for units to initialize (jittered to stagger multiple handlers)
    sleep (3 + random 2);
    
    private _triggered = false;
    
    while {!_triggered && !isNull _group && {count (units _group select {alive _x}) > 0}} do {
        // Check if this wave was already spawned
        private _spawnedWaves = _moduleSettings get "spawnedWaves";
        if (_waveTrackId in _spawnedWaves) exitWith {
            _triggered = true;
        };
        
        private _targetCandidates = allUnits select {
            alive _x && side _x == _targetSide && {(getPosATL _x select 2) <= _heightLimit}
        };

        {
            private _detector = _x;
            if (!alive _detector) then { continue };
            
            {
                private _target = _x;
                private _knowsAbout = _detector knowsAbout _target;
                
                if (_knowsAbout >= _detectionThreshold) then {
                    _spawnedWaves pushBack _waveTrackId;
                    _triggered = true;
                    
                    if (_debugLogging) then {
                        diag_log format ["[RECONDO_RW] Module %1: Group %2 detected target, spawning Wave %3",
                            _moduleId, _group, _nextWaveNumber];
                    };
                    
                    [_moduleSettings, _group, _targetGroup, _nextWaveNumber, _partyId] call Recondo_fnc_spawnPursuitGroup;
                };
                
                if (_triggered) exitWith {};
            } forEach _targetCandidates;
            
            if (_triggered) exitWith {};
        } forEach (units _group);
        
        if (!_triggered) then {
            sleep (4 + random 2); // ~5s polling, jittered to stagger handlers
        };
    };
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_RW] Module %1: Detection handler ended for Wave %2 trigger (triggered: %3)",
            _moduleId, _nextWaveNumber, _triggered];
    };
};
