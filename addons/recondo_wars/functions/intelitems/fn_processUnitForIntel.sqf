/*
    Recondo_fnc_processUnitForIntel
    Checks if a unit should receive intel and processes it
    
    Description:
        Evaluates a unit against the configured criteria (classname, side)
        and probability. If the unit passes, adds intel items to their inventory.
        Can be called manually by other modules for custom unit processing.
    
    Parameters:
        _unit - OBJECT - The unit to process
    
    Returns:
        BOOL - True if intel was added to the unit
    
    Example:
        [_spawnedUnit] call Recondo_fnc_processUnitForIntel;
*/

if (!isServer) exitWith { false };

params [["_unit", objNull, [objNull]]];

if (isNull _unit || !alive _unit || isPlayer _unit) exitWith { false };

// Check if already processed (array check)
if (_unit in RECONDO_INTELITEMS_PROCESSED_UNITS) exitWith { false };

// Check if unit already has intel flag set (backup check for race conditions)
if (_unit getVariable ["RECONDO_INTELITEMS_hasIntel", false]) exitWith { false };

// Get settings
if (isNil "RECONDO_INTELITEMS_SETTINGS") exitWith { false };

private _unitClassnames = RECONDO_INTELITEMS_SETTINGS get "unitClassnames";
private _targetSide = RECONDO_INTELITEMS_SETTINGS get "targetSide";
private _intelChance = RECONDO_INTELITEMS_SETTINGS get "intelChance";
private _debugLogging = RECONDO_INTELITEMS_SETTINGS get "debugLogging";

// Get unit classname for checks
private _unitClass = typeOf _unit;

// Check side filter
if (!isNil "_targetSide" && {side _unit != _targetSide}) exitWith { false };

// Check classname whitelist - unit MUST be in the list to receive intel
if !(_unitClass in _unitClassnames) exitWith {
    if (_debugLogging) then {
        diag_log format ["[RECONDO_INTELITEMS] Unit %1 (%2) - not in whitelist", _unit, _unitClass];
    };
    false
};

// Mark as processed (even if they don't get intel)
RECONDO_INTELITEMS_PROCESSED_UNITS pushBack _unit;

// Roll for intel chance
if (random 1 > _intelChance) exitWith {
    if (_debugLogging) then {
        diag_log format ["[RECONDO_INTELITEMS] Unit %1 (%2) - failed intel chance roll", _unit, _unitClass];
    };
    false
};

// Unit passed all checks - add intel
[_unit] call Recondo_fnc_addIntelToUnit;

if (_debugLogging) then {
    diag_log format ["[RECONDO_INTELITEMS] Unit %1 (%2) - passed checks, intel added", _unit, _unitClass];
};

true
