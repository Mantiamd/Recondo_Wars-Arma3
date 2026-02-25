/*
    Recondo_fnc_handleHostageDecoyTriggerActivation
    Handles activation of decoy location trigger
    
    Description:
        Called when a player enters the decoy trigger radius.
        Spawns the composition and optionally AI, but no hostages.
    
    Parameters:
        _trigger - OBJECT - The trigger that was activated
        _settings - HASHMAP - Module settings
        _marker - STRING - Location marker name
        _composition - STRING - Composition name to spawn
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
    ["_isModPath", true, [false]]
];

if (isNil "_settings" || _marker == "") exitWith {
    diag_log "[RECONDO_HOSTAGE] ERROR: Invalid parameters for handleHostageDecoyTriggerActivation";
};

private _aiTriggerRadius = _settings get "aiTriggerRadius";
private _triggerSide = _settings get "triggerSide";
private _decoyAIChance = _settings get "decoyAIChance";
private _debugLogging = _settings get "debugLogging";

private _markerPos = getMarkerPos _marker;

if (_debugLogging) then {
    diag_log format ["[RECONDO_HOSTAGE] Decoy trigger activated at %1", _marker];
};

// Spawn composition (reuse HVT composition spawner)
// Note: Composition spawner has internal 2-second delay via CBA_fnc_waitAndExecute
[_settings, _marker, _composition, false, _isModPath] call Recondo_fnc_spawnHVTComposition;

// Register buildings for night lights after composition spawns
private _enableNightLights = _settings get "enableNightLights";
if (_enableNightLights) then {
    [{
        params ["_markerPos", "_debugLogging"];
        
        // Find buildings near the marker position
        private _nearObjects = nearestObjects [_markerPos, [], 50];
        private _buildingsFound = 0;
        
        {
            // Check if object is a building (not a unit or vehicle)
            if (!(_x isKindOf "CAManBase") && !(_x isKindOf "LandVehicle") && !(_x isKindOf "Air") && !(_x isKindOf "Ship")) then {
                // Check if object has any building positions
                private _testPos = _x buildingPos 0;
                if !(_testPos isEqualTo [0,0,0]) then {
                    // This object has building positions - register it for night lights
                    if !(_x in RECONDO_HOSTAGE_NIGHT_LIGHT_BUILDINGS) then {
                        RECONDO_HOSTAGE_NIGHT_LIGHT_BUILDINGS pushBack _x;
                        _buildingsFound = _buildingsFound + 1;
                    };
                };
            };
        } forEach _nearObjects;
        
        if (_debugLogging && _buildingsFound > 0) then {
            diag_log format ["[RECONDO_HOSTAGE] Registered %1 buildings for night lights (decoy trigger)", _buildingsFound];
        };
    }, [_markerPos, _debugLogging], 2] call CBA_fnc_waitAndExecute;
};

// Track when composition will be ready (composition spawner uses 2s delay, add 0.5s buffer)
private _compositionReadyTime = time + 2.5;

// Roll for AI at decoy location
if (random 1 < _decoyAIChance) then {
    // Create inner trigger for AI spawning
    private _sideStr = switch (toUpper _triggerSide) do {
        case "WEST": { "WEST" };
        case "EAST": { "EAST" };
        case "GUER": { "GUER" };
        default { "ANY" };
    };
    
    private _aiTrigger = createTrigger ["EmptyDetector", _markerPos, true];
    _aiTrigger setTriggerArea [_aiTriggerRadius, _aiTriggerRadius, 0, false, 50];
    
    if (_sideStr == "ANY") then {
        _aiTrigger setTriggerActivation ["ANY", "PRESENT", false];
    } else {
        _aiTrigger setTriggerActivation [_sideStr, "PRESENT", false];
    };
    
    _aiTrigger setVariable ["RECONDO_HOSTAGE_settings", _settings];
    _aiTrigger setVariable ["RECONDO_HOSTAGE_marker", _marker];
    _aiTrigger setVariable ["RECONDO_HOSTAGE_aiSpawned", false];
    _aiTrigger setVariable ["RECONDO_HOSTAGE_compositionReadyTime", _compositionReadyTime];
    
    // Trigger activation code - no comments inside strings (breaks trigger compilation)
    // Condition includes check that composition has had time to spawn
    _aiTrigger setTriggerStatements [
        "this && !(thisTrigger getVariable ['RECONDO_HOSTAGE_aiSpawned', false]) && (time >= (thisTrigger getVariable ['RECONDO_HOSTAGE_compositionReadyTime', 0]))",
        "
            thisTrigger setVariable ['RECONDO_HOSTAGE_aiSpawned', true];
            private _settings = thisTrigger getVariable 'RECONDO_HOSTAGE_settings';
            private _marker = thisTrigger getVariable 'RECONDO_HOSTAGE_marker';
            private _pos = getMarkerPos _marker;
            [_settings, _marker, _pos] call Recondo_fnc_spawnHVTAI;
        ",
        ""
    ];
    
    RECONDO_HOSTAGE_TRIGGERS pushBack _aiTrigger;
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_HOSTAGE] Created DECOY AI inner trigger at %1, radius: %2m", _marker, _aiTriggerRadius];
    };
} else {
    if (_debugLogging) then {
        diag_log format ["[RECONDO_HOSTAGE] Decoy at %1 will have no AI garrison", _marker];
    };
};

// Spawn animals if enabled (independent of AI spawn chance)
if (_settings get "enableAnimals") then {
    [{
        params ["_settings", "_marker", "_pos"];
        [_settings, _marker, _pos] call Recondo_fnc_spawnHVTAnimals;
    }, [_settings, _marker, _markerPos], 3] call CBA_fnc_waitAndExecute;
};
