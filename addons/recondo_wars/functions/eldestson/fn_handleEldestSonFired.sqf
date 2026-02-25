/*
    Recondo_fnc_handleEldestSonFired
    Handles the explosion when a sabotaged unit fires
    
    Description:
        Called when a unit with sabotaged ammo fires their weapon.
        The sabotage was already determined at spawn time - this just
        triggers the explosion on their first shot.
    
    Parameters:
        0: OBJECT - The unit that fired
        
    Returns:
        Nothing
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit) exitWith {};
if (!alive _unit) exitWith {};

// Double-check unit is actually sabotaged (safety check)
private _isSabotaged = _unit getVariable ["RECONDO_ELDESTSON_SABOTAGED", false];
if (!_isSabotaged) exitWith {};

// === SABOTAGE TRIGGERED - FIRST SHOT ===

private _debug = false;
if (!isNil "RECONDO_ELDESTSON_SETTINGS") then {
    _debug = RECONDO_ELDESTSON_SETTINGS getOrDefault ["enableDebug", false];
};

if (_debug) then {
    diag_log format ["[RECONDO_ELDESTSON] SABOTAGE TRIGGERED! Unit: %1 fired with sabotaged ammo!", _unit];
};

// Remove the Fired EH immediately to prevent multiple triggers
private _firedEH = _unit getVariable ["RECONDO_ELDESTSON_FIRED_EH", -1];
if (_firedEH >= 0) then {
    _unit removeEventHandler ["Fired", _firedEH];
};

// Clear sabotage flag
_unit setVariable ["RECONDO_ELDESTSON_SABOTAGED", false];

// Small delay for dramatic effect (weapon appears to explode mid-firing)
[{
    params ["_unit"];
    
    if (isNull _unit) exitWith {};
    if (!alive _unit) exitWith {};
    
    // Get position at chest/weapon height
    private _pos = _unit modelToWorld [0, 0.3, 1.2];
    
    // Kill the unit
    _unit setDamage 1;
    
    // Create M61 mini grenade explosion - small but deadly
    "vn_m61_frag_ammo" createVehicle _pos;
    
    diag_log format ["[RECONDO_ELDESTSON] Unit killed by sabotaged ammo: %1", typeOf _unit];
    
}, [_unit], 0.05] call CBA_fnc_waitAndExecute;
