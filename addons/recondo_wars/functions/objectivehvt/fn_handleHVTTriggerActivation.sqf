/*
    Recondo_fnc_handleHVTTriggerActivation
    Handles activation of HVT location trigger
    
    Description:
        Called when players enter the composition trigger radius.
        Spawns composition, then creates inner AI trigger.
    
    Parameters:
        _trigger - OBJECT - The activated trigger
        _settings - HASHMAP - Module settings
        _marker - STRING - Location marker name
        _composition - STRING - Composition name
        _isHVTLocation - BOOL - True if this is the real HVT location
        _isModPath - BOOL - True to load composition from mod folder
    
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [
    ["_trigger", objNull, [objNull]],
    ["_settings", nil, [createHashMap]],
    ["_marker", "", [""]],
    ["_composition", "", [""]],
    ["_isHVTLocation", false, [false]],
    ["_isModPath", true, [false]]
];

if (isNull _trigger || isNil "_settings" || _marker == "") exitWith {
    diag_log "[RECONDO_HVT] ERROR: Invalid parameters for handleHVTTriggerActivation";
};

private _debugLogging = _settings get "debugLogging";
private _instanceId = _settings get "instanceId";

if (_debugLogging) then {
    private _locType = if (_isHVTLocation) then { "HVT" } else { "DECOY" };
    diag_log format ["[RECONDO_HVT] %1 trigger activated at %2", _locType, _marker];
};

// Delete the outer trigger
deleteVehicle _trigger;

// Spawn composition
// Note: Composition spawner has internal 2-second delay via CBA_fnc_waitAndExecute
[_settings, _marker, _composition, _isHVTLocation, _isModPath] call Recondo_fnc_spawnHVTComposition;

// Track when composition will be ready (composition spawner uses 2s delay, add 0.5s buffer)
private _compositionReadyTime = time + 2.5;

// Create inner AI trigger
private _aiTriggerRadius = _settings get "aiTriggerRadius";
private _triggerSide = _settings get "triggerSide";
private _markerPos = getMarkerPos _marker;

// Determine trigger activation side
private _sideStr = switch (toUpper _triggerSide) do {
    case "WEST": { "WEST" };
    case "EAST": { "EAST" };
    case "GUER": { "GUER" };
    default { "ANY" };
};

// Create inner AI trigger
private _aiTrigger = createTrigger ["EmptyDetector", _markerPos, true];
_aiTrigger setTriggerArea [_aiTriggerRadius, _aiTriggerRadius, 0, false, 50];

if (_sideStr == "ANY") then {
    _aiTrigger setTriggerActivation ["ANY", "PRESENT", false];
} else {
    _aiTrigger setTriggerActivation [_sideStr, "PRESENT", false];
};

// Store data on trigger
_aiTrigger setVariable ["RECONDO_HVT_settings", _settings];
_aiTrigger setVariable ["RECONDO_HVT_marker", _marker];
_aiTrigger setVariable ["RECONDO_HVT_isHVTLocation", _isHVTLocation];
_aiTrigger setVariable ["RECONDO_HVT_aiSpawned", false];
_aiTrigger setVariable ["RECONDO_HVT_compositionReadyTime", _compositionReadyTime];

// Trigger condition includes check that composition has had time to spawn
_aiTrigger setTriggerStatements [
    "this && !(thisTrigger getVariable ['RECONDO_HVT_aiSpawned', false]) && (time >= (thisTrigger getVariable ['RECONDO_HVT_compositionReadyTime', 0]))",
    "
        thisTrigger setVariable ['RECONDO_HVT_aiSpawned', true];
        private _settings = thisTrigger getVariable 'RECONDO_HVT_settings';
        private _marker = thisTrigger getVariable 'RECONDO_HVT_marker';
        private _isHVTLocation = thisTrigger getVariable 'RECONDO_HVT_isHVTLocation';
        private _pos = getMarkerPos _marker;
        private _instanceId = _settings get 'instanceId';
        
        diag_log format ['[RECONDO_HVT] AI trigger activated at %1', _marker];
        
        [_settings, _marker, _pos] spawn Recondo_fnc_spawnHVTAI;
        
        if (_settings get 'enableRovingSentry') then {
            [{
                params ['_settings', '_marker', '_pos'];
                [_settings, _marker, _pos] call Recondo_fnc_spawnHVTRovingSentry;
            }, [_settings, _marker, _pos], 6] call CBA_fnc_waitAndExecute;
        };
        
        if (_settings get 'enableCivilians') then {
            [{
                params ['_settings', '_marker', '_pos'];
                [_settings, _marker, _pos] call Recondo_fnc_spawnHVTCivilians;
            }, [_settings, _marker, _pos], 6] call CBA_fnc_waitAndExecute;
        };
        
        if (_settings get 'enableAnimals') then {
            [{
                params ['_settings', '_marker', '_pos'];
                [_settings, _marker, _pos] call Recondo_fnc_spawnHVTAnimals;
            }, [_settings, _marker, _pos], 6] call CBA_fnc_waitAndExecute;
        };
        
        if (_isHVTLocation) then {
            private _isCaptured = _instanceId in RECONDO_HVT_CAPTURED;
            if (!_isCaptured) then {
                [{
                    params ['_settings', '_marker', '_pos'];
                    [_settings, _marker, _pos] call Recondo_fnc_spawnHVT;
                }, [_settings, _marker, _pos], 6] call CBA_fnc_waitAndExecute;
            } else {
                diag_log format ['[RECONDO_HVT] HVT already captured, not spawning unit at %1', _marker];
            };
            if ((_settings getOrDefault ['badCiviMax', 0]) > 0) then {
                [{
                    params ['_settings', '_marker', '_pos'];
                    [_settings, _marker, _pos] call Recondo_fnc_spawnBadCivis;
                }, [_settings, _marker, _pos], 6] call CBA_fnc_waitAndExecute;
            };
        };
        
        deleteVehicle thisTrigger;
    ",
    ""
];

RECONDO_HVT_TRIGGERS pushBack _aiTrigger;

if (_debugLogging) then {
    diag_log format ["[RECONDO_HVT] Created AI trigger at %1, radius: %2m", _marker, _aiTriggerRadius];
};
