/*
    Recondo_fnc_initEldestSonUnit
    Adds the Fired event handler to a unit for Eldest Son
    
    Description:
        When a unit is tagged, rolls ONCE against the current sabotage chance
        to determine if they received sabotaged ammo. If so, they will explode
        the first time they fire their weapon.
    
    Parameters:
        0: OBJECT - The unit to initialize
        
    Returns:
        Nothing
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit) exitWith {};
if (!alive _unit) exitWith {};

// Only run where unit is local (server for AI)
if (!local _unit) exitWith {};

// Check if already tagged
if (!isNil {_unit getVariable "RECONDO_ELDESTSON_TAGGED"}) exitWith {};

// Mark as tagged
_unit setVariable ["RECONDO_ELDESTSON_TAGGED", true, true];

// Store the unit's side (for dead body scanning - side group becomes UNKNOWN after death)
// Local only - scanner runs on server where bodies exist
_unit setVariable ["RECONDO_ELDESTSON_SIDE", side _unit];

// Get debug setting
private _debug = false;
if (!isNil "RECONDO_ELDESTSON_SETTINGS") then {
    _debug = RECONDO_ELDESTSON_SETTINGS getOrDefault ["enableDebug", false];
};

// === ONE-TIME SABOTAGE ROLL ===
// Roll NOW to determine if this unit has sabotaged ammo
private _chance = RECONDO_ELDESTSON_CHANCE;
if (isNil "_chance") then { _chance = 0; };

private _isSabotaged = false;
if (_chance > 0) then {
    private _roll = random 100;
    _isSabotaged = _roll <= _chance;
    
    if (_debug) then {
        diag_log format ["[RECONDO_ELDESTSON] Unit %1 (%2) - Roll: %3, Chance: %4%%, Sabotaged: %5", 
            _unit, typeOf _unit, _roll toFixed 1, _chance, _isSabotaged];
    };
};

// Store sabotage status on unit
_unit setVariable ["RECONDO_ELDESTSON_SABOTAGED", _isSabotaged];

// Only add Fired EH if unit has sabotaged ammo (optimization)
if (_isSabotaged) then {
    private _firedEH = _unit addEventHandler ["Fired", {
        params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
        
        // Pass to handler function
        [_unit] call Recondo_fnc_handleEldestSonFired;
    }];
    
    // Store EH ID in case we need to remove it later
    _unit setVariable ["RECONDO_ELDESTSON_FIRED_EH", _firedEH];
};

if (_debug) then {
    diag_log format ["[RECONDO_ELDESTSON] Tagged unit: %1 (%2) - Sabotaged: %3", _unit, typeOf _unit, _isSabotaged];
};
