/*
    Recondo_fnc_spawnHVTAnimals
    Spawns a group of animals at an HVT location
    
    Description:
        Creates animal agents (chickens, goats, etc.) near the location
        to add ambiance. Animals wander naturally on their own.
    
    Parameters:
        _settings - HASHMAP - Module settings
        _marker - STRING - Location marker name
        _pos - ARRAY - Location position
    
    Returns:
        ARRAY - Spawned animal agents
*/

if (!isServer) exitWith { [] };

params [
    ["_settings", nil, [createHashMap]],
    ["_marker", "", [""]],
    ["_pos", [0,0,0], [[]]]
];

if (isNil "_settings") exitWith {
    diag_log "[RECONDO_HVT] ERROR: No settings provided for spawnHVTAnimals";
    []
};

private _enableAnimals = _settings get "enableAnimals";
private _animalChance = _settings get "animalChance";
private _animalClassnames = _settings get "animalClassnames";
private _animalMin = _settings get "animalMin";
private _animalMax = _settings get "animalMax";
private _debugLogging = _settings get "debugLogging";

// Check if animals are enabled
if (!_enableAnimals) exitWith {
    if (_debugLogging) then {
        diag_log format ["[RECONDO_HVT] Animals disabled, skipping spawn at %1", _marker];
    };
    []
};

// Roll for spawn chance
if (random 1 > _animalChance) exitWith {
    if (_debugLogging) then {
        diag_log format ["[RECONDO_HVT] Animal spawn chance failed at %1", _marker];
    };
    []
};

// Validate animal pool
if (count _animalClassnames == 0) exitWith {
    if (_debugLogging) then {
        diag_log "[RECONDO_HVT] No animal classnames defined";
    };
    []
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_HVT] Spawning animals at %1", _marker];
};

// Calculate animal count
private _animalCount = _animalMin + floor random ((_animalMax - _animalMin) + 1);
_animalCount = _animalCount max 1;

// Find a suitable spawn area (flat ground near location)
private _spawnedAnimals = [];

for "_i" from 1 to _animalCount do {
    // Random position near the marker (within 15m, spread out)
    private _spawnPos = _pos getPos [3 + random 12, random 360];
    
    // Get terrain height at position
    _spawnPos set [2, 0];
    
    // Select random animal type
    private _animalType = selectRandom _animalClassnames;
    
    // Create the animal agent
    private _animal = createAgent [_animalType, _spawnPos, [], 3, "NONE"];
    
    if (!isNull _animal) then {
        _spawnedAnimals pushBack _animal;
        
        if (_debugLogging) then {
            diag_log format ["[RECONDO_HVT] Spawned animal %1 at %2", _animalType, _spawnPos];
        };
    };
};

// Store reference
private _varName = format ["RECONDO_HVT_%1_animals", _marker];
missionNamespace setVariable [_varName, _spawnedAnimals, true];

if (_debugLogging) then {
    diag_log format ["[RECONDO_HVT] Finished spawning %1 animals at %2", count _spawnedAnimals, _marker];
};

_spawnedAnimals
