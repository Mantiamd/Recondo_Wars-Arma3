/*
    Recondo_fnc_addIntelToUnit
    Adds intel items to a unit's inventory
    
    Description:
        Adds a random number of intel items (between min and max) to the unit.
        Uses weighted selection to choose which items to add.
        Adds ACE interactions for each intel item.
    
    Parameters:
        _unit - OBJECT - The unit to add intel to
    
    Returns:
        Nothing
    
    Example:
        [_unit] call Recondo_fnc_addIntelToUnit;
*/

if (!isServer) exitWith {};

params [["_unit", objNull, [objNull]]];

if (isNull _unit) exitWith {};

// Get settings
if (isNil "RECONDO_INTELITEMS_SETTINGS") exitWith {};

private _debugLogging = RECONDO_INTELITEMS_SETTINGS getOrDefault ["debugLogging", false];

// ========================================
// DUPLICATE PROTECTION
// ========================================

// Check if unit is already being processed or has been processed
// This flag is set IMMEDIATELY to prevent race conditions
if (_unit getVariable ["RECONDO_INTELITEMS_hasIntel", false]) exitWith {
    if (_debugLogging) then {
        diag_log format ["[RECONDO_INTELITEMS] addIntelToUnit - Unit %1 already has/getting intel, skipping", _unit];
    };
};

// Mark IMMEDIATELY as having intel (before any items are added)
// This prevents any other calls from also adding items
_unit setVariable ["RECONDO_INTELITEMS_hasIntel", true, true];

// Also mark in processed array for processUnitForIntel checks
if (!isNil "RECONDO_INTELITEMS_PROCESSED_UNITS") then {
    RECONDO_INTELITEMS_PROCESSED_UNITS pushBackUnique _unit;
};

// ========================================
// ADD INTEL ITEMS
// ========================================

private _minItems = RECONDO_INTELITEMS_SETTINGS get "minItems";
private _maxItems = RECONDO_INTELITEMS_SETTINGS get "maxItems";
private _itemDefs = RECONDO_INTELITEMS_SETTINGS get "itemDefs";

if (count _itemDefs == 0) exitWith {};

// Determine number of items to add
private _numItems = _minItems + floor random ((_maxItems - _minItems) + 1);
_numItems = _numItems max 1;

// Build weighted selection pool
private _pool = [];
{
    _x params ["_displayName", "_classname", "_weight"];
    private _tickets = _weight max 1;
    for "_i" from 1 to _tickets do {
        _pool pushBack _x;
    };
} forEach _itemDefs;

if (count _pool == 0) exitWith {};

// Track what intel this unit has (for ACE actions)
private _unitIntelItems = _unit getVariable ["RECONDO_INTELITEMS_inventory", []];

// Add items
for "_i" from 1 to _numItems do {
    private _selectedItem = selectRandom _pool;
    _selectedItem params ["_displayName", "_classname", "_weight"];
    
    // Validate classname exists
    if (isClass (configFile >> "CfgWeapons" >> _classname) || isClass (configFile >> "CfgMagazines" >> _classname) || isClass (configFile >> "CfgVehicles" >> _classname)) then {
        // Add to unit's inventory
        _unit addItem _classname;
        
        // Track for ACE actions
        _unitIntelItems pushBack [_displayName, _classname];
        
        if (_debugLogging) then {
            diag_log format ["[RECONDO_INTELITEMS] Added '%1' (%2) to unit %3", _displayName, _classname, _unit];
        };
    } else {
        if (_debugLogging) then {
            diag_log format ["[RECONDO_INTELITEMS] WARNING: Invalid classname '%1' - item not added", _classname];
        };
    };
};

// Store intel inventory on unit
_unit setVariable ["RECONDO_INTELITEMS_inventory", _unitIntelItems, true];

// Add ACE interactions for each unique intel item
[_unit, _unitIntelItems] call Recondo_fnc_addTakeIntelAction;
