/*
    Recondo_fnc_spawnHVTAI
    Spawns garrison AI at an HVT location
    
    Description:
        Spawns AI units that garrison nearby building positions.
    
    Parameters:
        _settings - HASHMAP - Module settings
        _marker - STRING - Location marker name
        _pos - ARRAY - Location position
    
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [
    ["_settings", nil, [createHashMap]],
    ["_marker", "", [""]],
    ["_pos", [0,0,0], [[]]]
];

if (isNil "_settings") exitWith {
    diag_log "[RECONDO_HVT] ERROR: No settings provided for spawnHVTAI";
};

private _aiSide = _settings get "aiSide";
private _garrisonClassnames = _settings get "garrisonClassnames";
private _garrisonMin = _settings get "garrisonMin";
private _garrisonMax = _settings get "garrisonMax";
private _invulnTime = _settings get "invulnTime";
private _simulationDistance = _settings get "simulationDistance";
private _debugLogging = _settings get "debugLogging";

// Validate classnames
if (count _garrisonClassnames == 0) exitWith {
    if (_debugLogging) then {
        diag_log format ["[RECONDO_HVT] No garrison classnames defined, skipping AI spawn at %1", _marker];
    };
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_HVT] Spawning garrison AI at %1", _marker];
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

if (_debugLogging) then {
    diag_log format ["[RECONDO_HVT] Found %1 building positions from %2 nearby objects", count _buildingPositions, count _nearbyObjects];
};

// Calculate garrison size
private _garrisonCount = _garrisonMin + floor random ((_garrisonMax - _garrisonMin) + 1);
_garrisonCount = _garrisonCount max 1;

// Create garrison group
private _garrisonGroup = createGroup [_aiSide, true];
private _spawnedUnits = [];

// Spawn garrison units
for "_i" from 1 to _garrisonCount do {
    private _spawnPos = [];
    
    // Try to use a building position if available
    if (count _buildingPositions > 0) then {
        _spawnPos = selectRandom _buildingPositions;
        _buildingPositions = _buildingPositions - [_spawnPos];
    } else {
        // Fallback to random position near base
        _spawnPos = _pos findEmptyPosition [3, 20, "CAManBase"];
        if (count _spawnPos == 0) then {
            _spawnPos = _pos getPos [5 + random 15, random 360];
        };
    };
    
    // Select random unit type from pool
    private _unitType = selectRandom _garrisonClassnames;
    
    if (isClass (configFile >> "CfgVehicles" >> _unitType)) then {
        // Create the unit
        private _unit = _garrisonGroup createUnit [_unitType, _spawnPos, [], 0, "NONE"];
        _unit setPosATL _spawnPos;
        
        // Force standing position
        _unit setUnitPos "UP";
        _unit disableAI "ANIM";
        
        // Make temporarily invulnerable
        _unit allowDamage false;
        
        _spawnedUnits pushBack _unit;
        
        if (_debugLogging) then {
            diag_log format ["[RECONDO_HVT] Spawned garrison unit %1 (%2/%3) at %4", 
                _unitType, _i, _garrisonCount, _spawnPos];
        };
    };
};

// Set group behavior
_garrisonGroup setBehaviour "SAFE";
_garrisonGroup setCombatMode "YELLOW";
_garrisonGroup setSpeedMode "LIMITED";

// Register with centralized simulation monitoring system
if (_simulationDistance > 0 && {count _spawnedUnits > 0}) then {
    [{
        params ["_spawnedUnits", "_marker", "_pos", "_simulationDistance", "_debugLogging"];
        
        private _aliveUnits = _spawnedUnits select { alive _x };
        if (count _aliveUnits > 0) then {
            private _identifier = format ["HVT_AI_%1", _marker];
            [_identifier, _aliveUnits, _pos, _simulationDistance] call Recondo_fnc_registerSimulation;
            
            if (_debugLogging) then {
                diag_log format ["[RECONDO_HVT] Registered %1 garrison units with simulation system at distance %2m for %3", 
                    count _aliveUnits, _simulationDistance, _marker];
            };
        };
    }, [_spawnedUnits, _marker, _pos, _simulationDistance, _debugLogging], 2] call CBA_fnc_waitAndExecute;
};

// Store reference to units
private _varName = format ["RECONDO_HVT_%1_units", _marker];
missionNamespace setVariable [_varName, _spawnedUnits, true];

// Schedule vulnerability restoration
[_spawnedUnits, _invulnTime] spawn {
    params ["_units", "_time"];
    diag_log format ["[RECONDO_HVT] Starting %1-second invulnerability period for AI", _time];
    sleep _time;
    
    {
        if (!isNull _x && {alive _x}) then {
            _x allowDamage true;
        };
    } forEach _units;
    
    diag_log "[RECONDO_HVT] Invulnerability period ended for garrison AI";
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_HVT] Finished spawning %1 garrison units at %2", count _spawnedUnits, _marker];
};
