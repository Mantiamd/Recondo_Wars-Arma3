/*
    Recondo_fnc_spawnHVTRovingSentry
    Spawns a roving sentry that patrols building positions
    
    Description:
        Creates a single sentry unit that patrols through all building
        positions in a random order, pausing at each one.
    
    Parameters:
        _settings - HASHMAP - Module settings
        _marker - STRING - Location marker name
        _pos - ARRAY - Location position
    
    Returns:
        OBJECT - The spawned sentry unit
*/

if (!isServer) exitWith { objNull };

params [
    ["_settings", nil, [createHashMap]],
    ["_marker", "", [""]],
    ["_pos", [0,0,0], [[]]]
];

if (isNil "_settings") exitWith {
    diag_log "[RECONDO_HVT] ERROR: No settings provided for spawnHVTRovingSentry";
    objNull
};

private _aiSide = _settings get "aiSide";
private _garrisonClassnames = _settings get "garrisonClassnames";
private _invulnTime = _settings get "invulnTime";
private _debugLogging = _settings get "debugLogging";

// Validate classnames
if (count _garrisonClassnames == 0) exitWith {
    if (_debugLogging) then {
        diag_log format ["[RECONDO_HVT] No garrison classnames for roving sentry at %1", _marker];
    };
    objNull
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_HVT] Spawning roving sentry at %1", _marker];
};

// Find building positions for patrol route
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

// Need at least 2 positions for patrol
if (count _buildingPositions < 2) exitWith {
    if (_debugLogging) then {
        diag_log "[RECONDO_HVT] Not enough building positions for roving sentry";
    };
    objNull
};

// Shuffle positions for random patrol route
_buildingPositions = _buildingPositions call BIS_fnc_arrayShuffle;

if (_debugLogging) then {
    diag_log format ["[RECONDO_HVT] Roving sentry patrol route: %1 positions", count _buildingPositions];
};

// Create sentry group
private _sentryGroup = createGroup [_aiSide, true];

// Select random unit type
private _unitType = selectRandom _garrisonClassnames;

// Spawn at first patrol position
private _spawnPos = _buildingPositions select 0;

// Create the sentry unit
private _sentry = _sentryGroup createUnit [_unitType, _spawnPos, [], 0, "NONE"];
_sentry setPosATL _spawnPos;

// Force standing and walking
_sentry setUnitPos "UP";
_sentry forceSpeed 2;
_sentryGroup setSpeedMode "LIMITED";
_sentryGroup setBehaviour "SAFE";
_sentryGroup setCombatMode "YELLOW";

// Make temporarily invulnerable
_sentry allowDamage false;

// Store reference
private _varName = format ["RECONDO_HVT_%1_sentry", _marker];
missionNamespace setVariable [_varName, _sentry, true];

if (_debugLogging) then {
    diag_log format ["[RECONDO_HVT] Roving sentry spawned: %1 at %2", _unitType, _spawnPos];
};

// Start the patrol loop
[_sentry, _buildingPositions] spawn {
    params ["_unit", "_positions"];
    
    private _posCount = count _positions;
    private _currentIndex = 0;
    
    diag_log "[RECONDO_HVT] Roving sentry patrol loop started";
    
    while {alive _unit} do {
        private _targetPos = _positions select _currentIndex;
        
        _unit doMove _targetPos;
        
        // Wait until arrived or timeout
        private _timeout = diag_tickTime + 60;
        waitUntil {
            sleep 0.5;
            !alive _unit || 
            {_unit distance _targetPos < 2} || 
            {diag_tickTime > _timeout}
        };
        
        if (!alive _unit) exitWith {
            diag_log "[RECONDO_HVT] Roving sentry died - stopping patrol";
        };
        
        // Wait at position and look around
        _unit doWatch (getPos _unit getPos [50, random 360]);
        sleep 10;
        
        // Move to next position
        _currentIndex = (_currentIndex + 1) mod _posCount;
    };
    
    diag_log "[RECONDO_HVT] Roving sentry patrol loop ended";
};

// Schedule vulnerability restoration
[_sentry, _invulnTime] spawn {
    params ["_unit", "_time"];
    diag_log format ["[RECONDO_HVT] Starting %1-second invulnerability for sentry", _time];
    sleep _time;
    
    if (!isNull _unit && {alive _unit}) then {
        _unit allowDamage true;
    };
    
    diag_log "[RECONDO_HVT] Invulnerability ended for roving sentry";
};

_sentry
