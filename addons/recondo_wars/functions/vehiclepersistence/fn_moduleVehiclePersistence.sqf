/*
    Recondo_fnc_moduleVehiclePersistence
    Vehicle Persistence module initialization

    Description:
        Registers synchronized vehicles for position persistence.
        Destroyed vehicles are tracked and deleted on load.
        Requires the Persistence module.

    Priority: 3 (runs after Persistence module)

    Parameters:
        _logic     - Module logic object
        _units     - Synchronized units (unused)
        _activated - Whether module is activated
*/

params ["_logic", "_units", "_activated"];

if (!isServer) exitWith {};

if (!_activated) exitWith {
    diag_log "[RECONDO_VEHPERSIST] Module not activated.";
};

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

private _debug = _logic getVariable ["debuglogging", false];
RECONDO_VEHICLE_PERSISTENCE_DEBUG = _debug;

// ========================================
// REGISTER SYNCED VEHICLES
// ========================================

private _syncedObjects = synchronizedObjects _logic;
private _registeredCount = 0;

{
    if (_x isKindOf "Module_F") then { continue };
    if (_x isKindOf "CAManBase") then { continue };
    if !(_x isKindOf "AllVehicles" || _x isKindOf "StaticWeapon" || _x isKindOf "ThingX") then { continue };

    private _vehicleID = format ["RECONDO_veh_%1", count RECONDO_VEHICLE_PERSISTENCE_UNITS];
    _x setVariable ["RECONDO_VehicleID", _vehicleID];
    _x setVariable ["RECONDO_IsTrackedVehicle", true];

    RECONDO_VEHICLE_PERSISTENCE_UNITS pushBack _x;
    _registeredCount = _registeredCount + 1;

    if (_debug) then {
        diag_log format ["[RECONDO_VEHPERSIST] Registered: %1 (%2) as %3", _x, typeOf _x, _vehicleID];
    };
} forEach _syncedObjects;

if (_registeredCount == 0) then {
    diag_log "[RECONDO_VEHPERSIST] WARNING: No vehicles synchronized to module.";
} else {
    diag_log format ["[RECONDO_VEHPERSIST] Registered %1 vehicles for persistence.", _registeredCount];
};
