/*
    Recondo_fnc_spawnHVT
    Spawns the High Value Target unit
    
    Description:
        Creates the HVT civilian unit inside a building position
        at the location. Sets up behavior and ACE captive variables.
    
    Parameters:
        _settings - HASHMAP - Module settings
        _marker - STRING - Location marker name
        _pos - ARRAY - Location position
    
    Returns:
        OBJECT - The spawned HVT unit
*/

if (!isServer) exitWith { objNull };

params [
    ["_settings", nil, [createHashMap]],
    ["_marker", "", [""]],
    ["_pos", [0,0,0], [[]]]
];

if (isNil "_settings") exitWith {
    diag_log "[RECONDO_HVT] ERROR: No settings provided for spawnHVT";
    objNull
};

private _instanceId = _settings get "instanceId";
private _hvtName = _settings get "hvtName";
private _hvtClassname = _settings get "hvtClassname";
private _hvtSide = _settings getOrDefault ["hvtSide", east];
private _hvtFace = _settings getOrDefault ["hvtFace", ""];
private _hvtIdentity = _settings getOrDefault ["hvtIdentity", ""];
private _hvtLoadout = _settings getOrDefault ["hvtLoadout", []];
private _hvtSpeaker = _settings getOrDefault ["hvtSpeaker", ""];
private _debugLogging = _settings get "debugLogging";
private _enableWandering = _settings getOrDefault ["hvtEnableWandering", false];
private _wanderWaitTime = _settings getOrDefault ["hvtWanderWaitTime", 15];
private _wanderTimeout = _settings getOrDefault ["hvtWanderTimeout", 60];
private _makeInvincible = _settings getOrDefault ["makeInvincible", false];

// Check if already captured
if (_instanceId in RECONDO_HVT_CAPTURED) exitWith {
    diag_log format ["[RECONDO_HVT] HVT '%1' already captured, not spawning", _hvtName];
    objNull
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_HVT] Spawning HVT '%1' at %2", _hvtName, _marker];
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
    diag_log format ["[RECONDO_HVT] Found %1 building positions from %2 nearby objects for HVT placement", count _buildingPositions, count _nearbyObjects];
};

// Find spawn position - prefer building interior
private _spawnPos = [];
if (count _buildingPositions > 0) then {
    _spawnPos = selectRandom _buildingPositions;
    if (_debugLogging) then {
        diag_log format ["[RECONDO_HVT] Placing HVT inside building at %1", _spawnPos];
    };
} else {
    // Fallback to position near center
    _spawnPos = _pos findEmptyPosition [2, 10, "CAManBase"];
    if (count _spawnPos == 0) then {
        _spawnPos = _pos getPos [3, random 360];
    };
    if (_debugLogging) then {
        diag_log "[RECONDO_HVT] No building positions found - placing HVT outside";
    };
};

// Create HVT group with configured side
private _hvtGroup = createGroup [_hvtSide, true];

if (_debugLogging) then {
    diag_log format ["[RECONDO_HVT] Created group with side: %1", _hvtSide];
};

// Create the HVT unit
private _hvt = _hvtGroup createUnit [_hvtClassname, _spawnPos, [], 0, "NONE"];
_hvt setPosATL _spawnPos;

// Force unit into correct group/side (workaround for classname side conflicts)
[_hvt] joinSilent _hvtGroup;

if (_debugLogging) then {
    diag_log format ["[RECONDO_HVT] HVT '%1' spawned - Group side: %2, Unit side: %3", _hvtName, side _hvtGroup, side _hvt];
};

// Configure HVT behavior
if (!_enableWandering) then {
    // Static HVT - disable all movement AI
    _hvt disableAI "MOVE";
    _hvt disableAI "PATH";
    _hvt disableAI "FSM";
    _hvt disableAI "ANIM";
};
_hvt setUnitPos "UP";
_hvt setBehaviour "CARELESS";
_hvt allowFleeing 0;

// If wandering enabled, set slow walking speed
if (_enableWandering) then {
    _hvt forceSpeed 2;  // Slow walking pace
};

// ========================================
// APPLY LOADOUT AND IDENTITY
// ========================================

// Apply loadout if defined in profile (with delay for unit initialization)
if (count _hvtLoadout > 0) then {
    if (_debugLogging) then {
        diag_log format ["[RECONDO_HVT] Scheduling loadout for HVT '%1' - %2 elements in array", _hvtName, count _hvtLoadout];
    };
    
    // Schedule loadout application after unit fully initializes
    [_hvt, _hvtLoadout, _hvtName, _debugLogging] spawn {
        params ["_unit", "_loadout", "_name", "_debug"];
        sleep 3;  // Wait for unit to fully initialize
        
        // ACE Arsenal exports wrap the loadout as [loadoutArray, aceExtras]
        if (count _loadout == 2 && {(_loadout select 0) isEqualType [] && {count (_loadout select 0) == 10}}) then {
            _loadout = _loadout select 0;
        };
        
        if (!isNull _unit && alive _unit) then {
            _unit setUnitLoadout _loadout;
            
            if (_debug) then {
                diag_log format ["[RECONDO_HVT] Applied profile loadout to HVT '%1' (delayed)", _name];
                diag_log format ["[RECONDO_HVT] HVT uniform after apply: %1", uniform _unit];
            };
        };
    };
} else {
    // Fallback: Strip to unarmed civilian (original behavior)
    removeAllWeapons _hvt;
    removeAllItems _hvt;
    removeAllAssignedItems _hvt;
    removeVest _hvt;
    removeBackpack _hvt;
    removeHeadgear _hvt;
    removeGoggles _hvt;
    
    // Add uniform back if removed
    if (uniform _hvt == "") then {
        _hvt forceAddUniform "U_C_Poloshirt_stripped";
    };
    
    if (_debugLogging) then {
        diag_log "[RECONDO_HVT] No profile loadout - using default stripped loadout";
    };
};

// Apply identity if defined in profile (handles face, voice, name)
if (_hvtIdentity != "") then {
    [_hvt, _hvtIdentity, ""] call BIS_fnc_setIdentity;
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_HVT] Applied identity '%1' to HVT", _hvtIdentity];
    };
} else {
    if (_hvtFace != "") then {
        // Use direct face (and optionally speaker) when no identity class
        _hvt setFace _hvtFace;
        
        if (_hvtSpeaker != "") then {
            _hvt setSpeaker _hvtSpeaker;
        };
        
        if (_debugLogging) then {
            diag_log format ["[RECONDO_HVT] Applied face '%1' speaker '%2' to HVT", _hvtFace, _hvtSpeaker];
        };
    };
};

// Force unarmed civilian idle animation
[_hvt, "AmovPercMstpSnonWnonDnon"] remoteExec ["switchMove", 0, true];

// Make HVT capturable via ACE
_hvt setVariable ["ACE_captive", false, true];
_hvt setVariable ["ace_captives_isHandcuffed", false, true];

// Store marker and instance reference on HVT
_hvt setVariable ["RECONDO_HVT_marker", _marker, true];
_hvt setVariable ["RECONDO_HVT_instanceId", _instanceId, true];
_hvt setVariable ["RECONDO_HVT_isHVT", true, true];

// Apply invincibility if enabled
if (_makeInvincible) then {
    _hvt allowDamage false;
    if (_debugLogging) then {
        diag_log format ["[RECONDO_HVT] HVT '%1' set to invincible", _hvtName];
    };
};

// Set HVT name
_hvt setName _hvtName;

// ========================================
// HVT WANDERING BEHAVIOR
// ========================================
if (_enableWandering && {count _buildingPositions >= 2}) then {
    // Store wandering state on HVT
    _hvt setVariable ["RECONDO_HVT_wandering", true, true];
    _hvt setVariable ["RECONDO_HVT_wanderPositions", _buildingPositions, true];
    
    // Add FiredNear handler to stop wandering when combat detected
    _hvt addEventHandler ["FiredNear", {
        params ["_unit"];
        if (_unit getVariable ["RECONDO_HVT_wandering", false]) then {
            _unit setVariable ["RECONDO_HVT_wandering", false, true];
            _unit disableAI "MOVE";
            _unit disableAI "PATH";
            diag_log format ["[RECONDO_HVT] HVT '%1' stopped wandering - combat detected", name _unit];
        };
    }];
    
    // Start the wandering loop
    [_hvt, _buildingPositions, _wanderWaitTime, _wanderTimeout, _debugLogging] spawn {
        params ["_unit", "_positions", "_waitTime", "_timeout", "_debug"];
        
        // Shuffle positions for random patrol order
        _positions = _positions call BIS_fnc_arrayShuffle;
        
        private _posCount = count _positions;
        private _currentIndex = 0;
        
        if (_debug) then {
            diag_log format ["[RECONDO_HVT] HVT wandering started with %1 positions", _posCount];
        };
        
        // Initial delay before starting to wander
        sleep 5;
        
        while {alive _unit && {_unit getVariable ["RECONDO_HVT_wandering", false]}} do {
            // Check if captured (ACE handcuffed)
            if (_unit getVariable ["ace_captives_isHandcuffed", false]) exitWith {
                if (_debug) then {
                    diag_log "[RECONDO_HVT] HVT wandering stopped - captured";
                };
            };
            
            private _targetPos = _positions select _currentIndex;
            
            // Move to target position
            _unit doMove _targetPos;
            
            // Wait until arrived or timeout
            private _startTime = diag_tickTime;
            waitUntil {
                sleep 0.5;
                !alive _unit || 
                {!(_unit getVariable ["RECONDO_HVT_wandering", false])} ||
                {_unit getVariable ["ace_captives_isHandcuffed", false]} ||
                {_unit distance _targetPos < 2} || 
                {diag_tickTime - _startTime > _timeout}
            };
            
            // Exit conditions
            if (!alive _unit) exitWith {
                if (_debug) then {
                    diag_log "[RECONDO_HVT] HVT wandering stopped - dead";
                };
            };
            
            if (!(_unit getVariable ["RECONDO_HVT_wandering", false])) exitWith {
                if (_debug) then {
                    diag_log "[RECONDO_HVT] HVT wandering stopped - flag cleared";
                };
            };
            
            if (_unit getVariable ["ace_captives_isHandcuffed", false]) exitWith {
                if (_debug) then {
                    diag_log "[RECONDO_HVT] HVT wandering stopped - captured";
                };
            };
            
            // Wait at position before moving to next
            sleep _waitTime;
            
            // Move to next position (loop around)
            _currentIndex = (_currentIndex + 1) mod _posCount;
        };
        
        if (_debug) then {
            diag_log "[RECONDO_HVT] HVT wandering loop ended";
        };
    };
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_HVT] HVT wandering enabled with %1 positions, wait: %2s, timeout: %3s", 
            count _buildingPositions, _wanderWaitTime, _wanderTimeout];
    };
} else {
    if (_enableWandering && {count _buildingPositions < 2}) then {
        if (_debugLogging) then {
            diag_log "[RECONDO_HVT] HVT wandering requested but not enough building positions (<2)";
        };
    };
};

// Store HVT reference globally
RECONDO_HVT_UNITS set [_instanceId, _hvt];
publicVariable "RECONDO_HVT_UNITS";

if (_debugLogging) then {
    diag_log format ["[RECONDO_HVT] HVT '%1' spawned at %2", _hvtName, _spawnPos];
};

// Return the HVT unit
_hvt
