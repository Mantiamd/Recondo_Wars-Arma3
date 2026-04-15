/*
    Recondo_fnc_moduleInventoryPersistence
    Inventory Persistence module initialization

    Description:
        Registers synchronized containers and vehicles for inventory
        persistence. Full cargo (weapons, magazines, items, backpacks)
        is saved and restored across sessions.
        Requires the Persistence module.

    Priority: 3 (runs after Persistence module)

    Parameters:
        _logic     - Module logic object
        _units     - Synchronized units (unused, we use synchronizedObjects)
        _activated - Whether module is activated
*/

params ["_logic", "_units", "_activated"];

if (!isServer) exitWith {};

if (!_activated) exitWith {
    diag_log "[RECONDO_INVPERSIST] Module not activated.";
};

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

private _debug = _logic getVariable ["debuglogging", false];
if (RECONDO_MASTER_DEBUG) then { _debug = true; };
RECONDO_INVENTORY_PERSISTENCE_DEBUG = _debug;

// ========================================
// REGISTER SYNCED CONTAINERS
// ========================================

private _syncedObjects = synchronizedObjects _logic;
private _registeredCount = 0;

{
    if (_x isKindOf "Module_F") then { continue };
    if (_x isKindOf "CAManBase") then { continue };

    private _containerID = format ["RECONDO_inv_%1", count RECONDO_INVENTORY_PERSISTENCE_CONTAINERS];
    _x setVariable ["RECONDO_InventoryID", _containerID];
    _x setVariable ["RECONDO_IsInventoryTracked", true];

    RECONDO_INVENTORY_PERSISTENCE_CONTAINERS pushBack _x;
    _registeredCount = _registeredCount + 1;

    if (_debug) then {
        diag_log format ["[RECONDO_INVPERSIST] Registered: %1 (type: %2, id: %3)", _x, typeOf _x, _containerID];
    };
} forEach _syncedObjects;

if (_registeredCount == 0) then {
    diag_log "[RECONDO_INVPERSIST] WARNING: No objects synchronized to module.";
} else {
    diag_log format ["[RECONDO_INVPERSIST] Registered %1 containers for inventory persistence.", _registeredCount];
};
