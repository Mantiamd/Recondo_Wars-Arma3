/*
    Recondo_fnc_spawnHVTCivilians
    Spawns civilians at an HVT location based on chance
    
    Description:
        Creates 1-2 civilian units in building positions
        at the location.
    
    Parameters:
        _settings - HASHMAP - Module settings
        _marker - STRING - Location marker name
        _pos - ARRAY - Location position
    
    Returns:
        ARRAY - Spawned civilian units
*/

if (!isServer) exitWith { [] };

params [
    ["_settings", nil, [createHashMap]],
    ["_marker", "", [""]],
    ["_pos", [0,0,0], [[]]]
];

if (isNil "_settings") exitWith {
    diag_log "[RECONDO_HVT] ERROR: No settings provided for spawnHVTCivilians";
    []
};

private _civilianChance = _settings get "civilianChance";
private _civilianClassnames = _settings get "civilianClassnames";
private _debugLogging = _settings get "debugLogging";

// Roll for spawn chance
if (random 1 > _civilianChance) exitWith {
    if (_debugLogging) then {
        diag_log format ["[RECONDO_HVT] Civilian spawn chance failed at %1", _marker];
    };
    []
};

// Validate civilian pool
if (count _civilianClassnames == 0) exitWith {
    if (_debugLogging) then {
        diag_log "[RECONDO_HVT] No civilian classnames defined";
    };
    []
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_HVT] Spawning civilians at %1", _marker];
};

// Find building positions for placement
// Search ALL nearby objects (not just "House"/"Building") because composition-spawned
// objects may use different class types but still have valid building positions
private _nearbyObjects = nearestObjects [_pos, [], 50];
private _buildingPositions = [];

// Collect all building positions from any object that has them
{
    private _obj = _x;
    // Skip units and vehicles - only want static objects
    if (!(_obj isKindOf "CAManBase") && !(_obj isKindOf "LandVehicle") && !(_obj isKindOf "Air") && !(_obj isKindOf "Ship")) then {
        private _i = 0;
        while {true} do {
            private _bPos = _obj buildingPos _i;
            if (_bPos isEqualTo [0,0,0]) exitWith {};
            _buildingPositions pushBack _bPos;
            _i = _i + 1;
        };
    };
} forEach _nearbyObjects;

// Need building positions
if (count _buildingPositions < 1) exitWith {
    if (_debugLogging) then {
        diag_log format ["[RECONDO_HVT] No building positions for civilians at %1", _marker];
    };
    []
};

// Spawn 1-2 civilians
private _civilianCount = 1 + floor random 2;

// Create civilian group
private _civilianGroup = createGroup [civilian, true];
private _spawnedCivilians = [];

for "_i" from 1 to _civilianCount do {
    if (count _buildingPositions == 0) exitWith {};
    
    private _spawnPos = selectRandom _buildingPositions;
    _buildingPositions = _buildingPositions - [_spawnPos];
    
    private _civilianType = selectRandom _civilianClassnames;
    
    if (isClass (configFile >> "CfgVehicles" >> _civilianType)) then {
        private _civilian = _civilianGroup createUnit [_civilianType, _spawnPos, [], 0, "NONE"];
        _civilian setPosATL _spawnPos;
        
        // Set behavior - will flee when combat starts
        _civilian setBehaviour "CARELESS";
        _civilian allowFleeing 1;
        _civilian setUnitPos "UP";
        
        // Remove weapons if any
        removeAllWeapons _civilian;
        
        // Force unarmed civilian idle animation
        [_civilian, "AmovPercMstpSnonWnonDnon"] remoteExec ["switchMove", 0, true];
        
        _spawnedCivilians pushBack _civilian;
        
        if (_debugLogging) then {
            diag_log format ["[RECONDO_HVT] Spawned civilian %1 at %2", _civilianType, _spawnPos];
        };
    };
};

// Store reference
private _varName = format ["RECONDO_HVT_%1_civilians", _marker];
missionNamespace setVariable [_varName, _spawnedCivilians, true];

if (_debugLogging) then {
    diag_log format ["[RECONDO_HVT] Finished spawning %1 civilians at %2", count _spawnedCivilians, _marker];
};

_spawnedCivilians
