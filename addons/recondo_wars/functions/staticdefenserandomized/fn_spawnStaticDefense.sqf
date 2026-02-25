/*
    Recondo_fnc_spawnStaticDefense
    Spawn a static weapon with AI gunner at a marker position
    
    Description:
        Clears terrain objects at the marker position, spawns a random
        static weapon from the configured list, creates an AI gunner,
        and assigns them to the static.
    
    Parameters:
        0: STRING - Marker name
        1: HASHMAP - Settings from module
        
    Returns:
        ARRAY - [static weapon object, AI unit object] or false on failure
        
    Example:
        private _result = ["AA_1", _settings] call Recondo_fnc_spawnStaticDefense;
*/

params ["_markerName", "_settings"];

private _debug = _settings get "enableDebug";
private _staticClassnames = _settings get "staticClassnames";
private _unitClassnames = _settings get "unitClassnames";
private _clearRadius = _settings get "clearRadius";
private _targetSideValue = _settings get "targetSideValue";

// Get marker position
private _pos = getMarkerPos _markerName;

if (_pos isEqualTo [0, 0, 0]) exitWith {
    if (_debug) then {
        diag_log format ["[RECONDO_SDR] WARNING: Marker '%1' has invalid position. Skipping.", _markerName];
    };
    false
};

// Get proper ground position
_pos = ATLToASL [_pos select 0, _pos select 1, 0];
_pos = ASLToATL _pos;
_pos set [2, 0];

if (_debug) then {
    diag_log format ["[RECONDO_SDR] Spawning at marker '%1' position: %2", _markerName, _pos];
};

// Clear terrain objects if radius > 0
if (_clearRadius > 0) then {
    [_pos, _clearRadius] call Recondo_fnc_clearTerrainObjects;
};

// Select random static weapon classname
private _staticClassname = selectRandom _staticClassnames;

// Select random unit classname
private _unitClassname = selectRandom _unitClassnames;

// Generate random direction
private _dir = random 360;

// Create the static weapon
private _static = createVehicle [_staticClassname, _pos, [], 0, "CAN_COLLIDE"];
_static setDir _dir;
_static setPos _pos;
_static setVectorUp surfaceNormal _pos;

if (isNull _static) exitWith {
    diag_log format ["[RECONDO_SDR] ERROR: Failed to create static weapon '%1' at marker '%2'", _staticClassname, _markerName];
    false
};

// Create a group for the AI on the correct side
private _group = createGroup [_targetSideValue, true];

// Create the AI unit
private _unit = _group createUnit [_unitClassname, _pos, [], 0, "NONE"];

if (isNull _unit) exitWith {
    deleteVehicle _static;
    diag_log format ["[RECONDO_SDR] ERROR: Failed to create unit '%1' at marker '%2'", _unitClassname, _markerName];
    false
};

// Move unit into the static weapon as gunner
_unit moveInGunner _static;

// If unit couldn't get in, try commander or any position
if (vehicle _unit != _static) then {
    _unit moveInCommander _static;
};

if (vehicle _unit != _static) then {
    _unit moveInAny _static;
};

// Set the unit to hold position
_unit disableAI "PATH";
_group setBehaviour "AWARE";
_group setCombatMode "RED";

// Mark both as spawned by this module for potential cleanup
_static setVariable ["RECONDO_SDR_SPAWNED", true, true];
_unit setVariable ["RECONDO_SDR_SPAWNED", true, true];
_static setVariable ["RECONDO_SDR_MARKER", _markerName, true];
_unit setVariable ["RECONDO_SDR_MARKER", _markerName, true];

if (_debug) then {
    diag_log format ["[RECONDO_SDR] Spawned '%1' with gunner '%2' at marker '%3', facing %4 deg", 
        _staticClassname, _unitClassname, _markerName, round _dir];
};

[_static, _unit]
