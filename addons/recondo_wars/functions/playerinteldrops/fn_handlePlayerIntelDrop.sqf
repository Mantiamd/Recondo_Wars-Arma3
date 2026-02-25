/*
    Recondo_fnc_handlePlayerIntelDrop
    Handles adding intel to a dead player's body
    
    Description:
        Called when a player dies. Checks if they match the configured
        side and classname filters, rolls for drop chance, and if successful
        adds a random intel item to their body with ACE interactions.
    
    Parameters:
        0: OBJECT - The dead player unit
        
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [["_unit", objNull, [objNull]]];

if (isNull _unit) exitWith {};

// Get settings
private _settings = RECONDO_PLAYERINTELDROPS_SETTINGS;
if (isNil "_settings") exitWith {};

private _debug = _settings get "enableDebug";
private _affectedSide = _settings get "affectedSide";
private _unitClassnames = _settings get "unitClassnames";
private _dropChance = _settings get "dropChance";
private _intelItems = _settings get "intelItems";

// Check if unit's side matches
private _unitSide = side group _unit; // Use group side (more reliable for dead units)
if (_unitSide != _affectedSide) exitWith {
    if (_debug) then {
        diag_log format ["[RECONDO_PLAYERINTELDROPS] %1 side (%2) doesn't match affected side (%3). Skipping.", _unit, _unitSide, _affectedSide];
    };
};

// Check classname filter (if configured)
if (count _unitClassnames > 0) then {
    private _unitType = typeOf _unit;
    if !(_unitType in _unitClassnames) exitWith {
        if (_debug) then {
            diag_log format ["[RECONDO_PLAYERINTELDROPS] %1 classname (%2) not in filter list. Skipping.", _unit, _unitType];
        };
    };
};

// Roll for drop chance
private _roll = random 100;
if (_roll > _dropChance) exitWith {
    if (_debug) then {
        diag_log format ["[RECONDO_PLAYERINTELDROPS] Drop chance failed for %1. Roll: %2, Needed: <= %3", _unit, _roll, _dropChance];
    };
};

// Select random intel item
private _selectedItem = selectRandom _intelItems;
_selectedItem params ["_displayName", "_classname"];

if (_debug) then {
    diag_log format ["[RECONDO_PLAYERINTELDROPS] %1 died. Adding intel: '%2' (%3)", _unit, _displayName, _classname];
};

// Validate classname exists before adding
private _isValid = isClass (configFile >> "CfgWeapons" >> _classname) || 
                   isClass (configFile >> "CfgMagazines" >> _classname) || 
                   isClass (configFile >> "CfgVehicles" >> _classname);

if (!_isValid) exitWith {
    diag_log format ["[RECONDO_PLAYERINTELDROPS] ERROR: Invalid intel classname '%1'. Item not added.", _classname];
};

// Add the intel item to the body's inventory
_unit addItem _classname;

// Set up intel tracking variable (integrates with existing intel system)
private _existingIntel = _unit getVariable ["RECONDO_INTELITEMS_inventory", []];
_existingIntel pushBack [_displayName, _classname];
_unit setVariable ["RECONDO_INTELITEMS_inventory", _existingIntel, true];

// Reset the actions added flag so ACE actions will be created
_unit setVariable ["RECONDO_INTELITEMS_actionsAdded", false, true];

// Add ACE interactions for taking intel (uses existing intel system)
// This broadcasts to all clients including JIP
[_unit, _existingIntel] call Recondo_fnc_addTakeIntelAction;

if (_debug) then {
    diag_log format ["[RECONDO_PLAYERINTELDROPS] Successfully added '%1' (%2) to %3's body. ACE actions created.", 
        _displayName, _classname, name _unit];
};

// Log for mission makers
diag_log format ["[RECONDO_PLAYERINTELDROPS] Player %1 dropped intel: %2", name _unit, _displayName];
