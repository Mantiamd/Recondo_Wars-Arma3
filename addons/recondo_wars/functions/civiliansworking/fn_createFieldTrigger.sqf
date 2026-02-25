/*
    Recondo_fnc_createFieldTrigger
    Creates proximity trigger for spawning/despawning field workers
    
    Description:
        Creates a trigger that monitors for players within spawn distance.
        Spawns civilians when players enter, despawns when they leave.
    
    Parameters:
        _settings - HASHMAP - Module settings
    
    Returns:
        OBJECT - The created trigger
*/

params [["_settings", createHashMap, [createHashMap]]];

private _instanceId = _settings get "instanceId";
private _modulePos = _settings get "modulePos";
private _spawnDistance = _settings get "spawnDistance";
private _despawnDistance = _settings get "despawnDistance";
private _triggerSide = _settings get "triggerSide";
private _debugLogging = _settings get "debugLogging";

// Create trigger at module position with spawn radius
private _trigger = createTrigger ["EmptyDetector", _modulePos, false];
_trigger setTriggerArea [_spawnDistance, _spawnDistance, 0, false];

// Set trigger activation based on side
private _triggerActivation = switch (toUpper _triggerSide) do {
    case "WEST": { "WEST" };
    case "EAST": { "EAST" };
    case "GUER": { "GUER" };
    default { "ANY" };
};
_trigger setTriggerActivation [_triggerActivation, "PRESENT", true];

// Store settings on trigger for reference
_trigger setVariable ["RECONDO_CIVWORKING_Settings", _settings];
_trigger setVariable ["RECONDO_CIVWORKING_Spawned", false];
_trigger setVariable ["RECONDO_CIVWORKING_Civilians", []];
_trigger setVariable ["RECONDO_CIVWORKING_BehaviorHandles", []];
_trigger setVariable ["RECONDO_CIVWORKING_Props", []];

// Trigger condition - check for players in spawn range
_trigger setTriggerStatements [
    // Condition
    "this",
    
    // On Activation - spawn civilians
    "
        private _trigger = thisTrigger;
        private _settings = _trigger getVariable 'RECONDO_CIVWORKING_Settings';
        
        if (!(_trigger getVariable 'RECONDO_CIVWORKING_Spawned')) then {
            _trigger setVariable ['RECONDO_CIVWORKING_Spawned', true];
            [_trigger, _settings] call Recondo_fnc_spawnFieldCivilians;
        };
    ",
    
    // On Deactivation - handled by monitor loop (despawn distance may differ)
    ""
];

// Start despawn monitor loop
[_trigger, _settings] spawn {
    params ["_trigger", "_settings"];
    
    private _modulePos = _settings get "modulePos";
    private _despawnDistance = _settings get "despawnDistance";
    private _debugLogging = _settings get "debugLogging";
    private _instanceId = _settings get "instanceId";
    
    while {!isNull _trigger} do {
        sleep 5;
        
        // Only check if spawned
        if (_trigger getVariable ["RECONDO_CIVWORKING_Spawned", false]) then {
            // Check if any players still in despawn range (using allPlayers for reliability)
            private _playersNear = allPlayers select {
                alive _x && {(_x distance2D _modulePos) <= _despawnDistance}
            };
            
            if (_debugLogging) then {
                diag_log format ["[RECONDO_CIVWORKING] %1: Despawn check - %2 players within %3m of %4", _instanceId, count _playersNear, _despawnDistance, _modulePos];
            };
            
            if (count _playersNear == 0) then {
                // No players nearby - despawn civilians and props
                private _civilians = _trigger getVariable ["RECONDO_CIVWORKING_Civilians", []];
                private _behaviorHandles = _trigger getVariable ["RECONDO_CIVWORKING_BehaviorHandles", []];
                private _props = _trigger getVariable ["RECONDO_CIVWORKING_Props", []];
                
                // Terminate behavior scripts
                {
                    if (!isNull _x) then { terminate _x };
                } forEach _behaviorHandles;
                
                // Delete civilians
                {
                    if (!isNull _x) then {
                        deleteVehicle _x;
                    };
                } forEach _civilians;
                
                // Delete props
                {
                    if (!isNull _x) then {
                        deleteVehicle _x;
                    };
                } forEach _props;
                
                // Delete debug markers
                if (_debugLogging) then {
                    {
                        deleteMarker _x;
                    } forEach (allMapMarkers select { _x find format ["RECONDO_CIVWORK_UNIT_%1", _instanceId] == 0 });
                };
                
                // Reset state
                _trigger setVariable ["RECONDO_CIVWORKING_Spawned", false];
                _trigger setVariable ["RECONDO_CIVWORKING_Civilians", []];
                _trigger setVariable ["RECONDO_CIVWORKING_BehaviorHandles", []];
                _trigger setVariable ["RECONDO_CIVWORKING_Props", []];
                
                if (_debugLogging) then {
                    diag_log format ["[RECONDO_CIVWORKING] %1: Civilians and props despawned - no players within %2m", _instanceId, _despawnDistance];
                };
            };
        };
    };
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_CIVWORKING] %1: Created proximity trigger (spawn: %2m, despawn: %3m)", _instanceId, _spawnDistance, _despawnDistance];
};

_trigger
