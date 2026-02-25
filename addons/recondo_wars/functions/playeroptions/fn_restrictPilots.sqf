/*
    Recondo_fnc_restrictPilots
    
    Description:
        Restricts pilot seats in specified aircraft to authorized player classnames only.
        Uses CBA class event handlers to survive respawn automatically.
        
    Usage:
        Called automatically from fn_postInit.sqf when pilot restrictions are enabled.
*/

if (!hasInterface) exitWith {};

// Prevent duplicate initialization
if (!isNil "RECONDO_PO_PILOTS_INITIALIZED") exitWith {};
RECONDO_PO_PILOTS_INITIALIZED = true;

private _settings = RECONDO_PLAYEROPTIONS_SETTINGS;
private _restrictedAircraft = _settings get "restrictedAircraftArray";
private _allowedPilots = _settings get "allowedPilotsArray";
private _debug = _settings get "enableDebug";

if (_restrictedAircraft isEqualTo [] || _allowedPilots isEqualTo []) exitWith {
    if (_debug) then {
        diag_log "[RECONDO_PLAYEROPTIONS] Pilot restrictions: No aircraft or pilots defined, skipping";
    };
};

if (_debug) then {
    diag_log format ["[RECONDO_PLAYEROPTIONS] Pilot restrictions initialized. Aircraft: %1, Allowed: %2", _restrictedAircraft, _allowedPilots];
};

// Use class event handler - survives respawn automatically
["CAManBase", "GetInMan", {
    params ["_unit", "_role", "_vehicle", "_turret"];
    
    // Only process for local player
    if (_unit != player) exitWith {};
    
    // Only check for driver (pilot) role
    if (_role != "driver") exitWith {};
    
    private _settings = RECONDO_PLAYEROPTIONS_SETTINGS;
    if (isNil "_settings") exitWith {};
    
    private _restrictedAircraft = _settings get "restrictedAircraftArray";
    private _allowedPilots = _settings get "allowedPilotsArray";
    private _debug = _settings get "enableDebug";
    
    // Check if this vehicle is a restricted aircraft
    private _vehicleClass = toLower (typeOf _vehicle);
    private _isRestricted = false;
    
    {
        if (_vehicleClass isEqualTo _x || {_vehicleClass isKindOf _x}) exitWith {
            _isRestricted = true;
        };
    } forEach _restrictedAircraft;
    
    if (!_isRestricted) exitWith {
        if (_debug) then {
            diag_log format ["[RECONDO_PLAYEROPTIONS] Vehicle %1 not in restricted list", _vehicleClass];
        };
    };
    
    // Check if player's unit classname is in allowed list
    private _playerClass = toLower (typeOf _unit);
    private _isAllowed = _playerClass in _allowedPilots;
    
    if (_debug) then {
        diag_log format ["[RECONDO_PLAYEROPTIONS] Pilot check - Player: %1, Class: %2, Allowed: %3", name _unit, _playerClass, _isAllowed];
    };
    
    if (!_isAllowed) then {
        // Eject the player from the pilot seat
        [{
            params ["_unit", "_vehicle"];
            moveOut _unit;
            cutText ["You are not authorized to pilot this aircraft. Only pilot roles are authorized to pilot this aircraft.", "PLAIN DOWN", 2];
        }, [_unit, _vehicle], 0.1] call CBA_fnc_waitAndExecute;
    };
}, true, [], true] call CBA_fnc_addClassEventHandler;

// Handle seat switching with class event handler
["CAManBase", "SeatSwitchedMan", {
    params ["_unit", "_vehicle", "_unit1", "_unit2"];
    
    // Only process for local player
    if (_unit != player) exitWith {};
    
    // Check if switched to driver seat
    if (driver _vehicle != _unit) exitWith {};
    
    private _settings = RECONDO_PLAYEROPTIONS_SETTINGS;
    if (isNil "_settings") exitWith {};
    
    private _restrictedAircraft = _settings get "restrictedAircraftArray";
    private _allowedPilots = _settings get "allowedPilotsArray";
    private _debug = _settings get "enableDebug";
    
    // Check if this vehicle is a restricted aircraft
    private _vehicleClass = toLower (typeOf _vehicle);
    private _isRestricted = false;
    
    {
        if (_vehicleClass isEqualTo _x || {_vehicleClass isKindOf _x}) exitWith {
            _isRestricted = true;
        };
    } forEach _restrictedAircraft;
    
    if (!_isRestricted) exitWith {};
    
    // Check if player's unit classname is in allowed list
    private _playerClass = toLower (typeOf _unit);
    private _isAllowed = _playerClass in _allowedPilots;
    
    if (_debug) then {
        diag_log format ["[RECONDO_PLAYEROPTIONS] Seat switch check - Player: %1, Class: %2, Allowed: %3", name _unit, _playerClass, _isAllowed];
    };
    
    if (!_isAllowed) then {
        [{
            params ["_unit", "_vehicle"];
            moveOut _unit;
            cutText ["You are not authorized to pilot this aircraft. Only pilot roles are authorized to pilot this aircraft.", "PLAIN DOWN", 2];
        }, [_unit, _vehicle], 0.1] call CBA_fnc_waitAndExecute;
    };
}, true, [], true] call CBA_fnc_addClassEventHandler;

if (_debug) then {
    diag_log "[RECONDO_PLAYEROPTIONS] Pilot restriction class event handlers added (respawn-safe)";
};

