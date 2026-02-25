/*
    Recondo_fnc_registerSimulation
    Registers entities with the centralized simulation monitoring system
    
    Description:
        Adds a group of entities to the simulation registry, disables their
        simulation initially, and starts the monitor loop if not running.
    
    Parameters:
        _identifier - STRING - Unique identifier for this group of entities
        _entities - ARRAY - Array of objects/units to manage
        _position - ARRAY - Position to check distance from (usually module/spawn position)
        _simulationDistance - NUMBER - Distance at which to enable simulation (meters)
    
    Returns:
        BOOL - True if successfully registered
*/

if (!isServer) exitWith { false };

params [
    ["_identifier", "", [""]],
    ["_entities", [], [[]]],
    ["_position", [0,0,0], [[]]],
    ["_simulationDistance", 1000, [0]]
];

// Validate parameters
if (_identifier == "" || count _entities == 0 || _simulationDistance <= 0) exitWith {
    diag_log format ["[RECONDO_SIM] ERROR: Invalid parameters for registerSimulation - id: %1, entities: %2, dist: %3", 
        _identifier, count _entities, _simulationDistance];
    false
};

// Filter to valid entities only
private _validEntities = _entities select { !isNull _x && { alive _x || !(_x isKindOf "CAManBase") } };

if (count _validEntities == 0) exitWith {
    diag_log format ["[RECONDO_SIM] WARNING: No valid entities to register for %1", _identifier];
    false
};

// Disable simulation on all entities initially
{
    _x enableSimulationGlobal false;
} forEach _validEntities;

// Check if already registered (update existing entry)
private _existingIndex = RECONDO_SIM_REGISTRY findIf { (_x select 0) == _identifier };

if (_existingIndex >= 0) then {
    // Update existing registration
    private _existingEntry = RECONDO_SIM_REGISTRY select _existingIndex;
    private _existingEntities = _existingEntry select 1;
    _existingEntities append _validEntities;
    _existingEntry set [1, _existingEntities];
    RECONDO_SIM_REGISTRY set [_existingIndex, _existingEntry];
    
    if (RECONDO_SIM_DEBUG) then {
        diag_log format ["[RECONDO_SIM] Updated registration %1 with %2 additional entities (total: %3)", 
            _identifier, count _validEntities, count _existingEntities];
    };
} else {
    // New registration: [identifier, entities[], position, simulationDistance, currentlyEnabled]
    RECONDO_SIM_REGISTRY pushBack [_identifier, _validEntities, _position, _simulationDistance, false];
    
    if (RECONDO_SIM_DEBUG) then {
        diag_log format ["[RECONDO_SIM] Registered %1 with %2 entities at distance %3m", 
            _identifier, count _validEntities, _simulationDistance];
    };
};

// Start monitor loop if not already running
if (!RECONDO_SIM_LOOP_RUNNING) then {
    [] call Recondo_fnc_simulationMonitorLoop;
};

true
