/*
    Recondo_fnc_moduleBadCivi
    Main initialization for Bad Civi module

    Description:
        Synced to one or more AI units. Strips their weapons so they
        appear as unarmed civilians, then creates per-unit proximity
        triggers. When the configured side enters detection range,
        each unit independently rolls a chance to pull a concealed
        weapon and switch to combat.

    Parameters:
        _logic - Module logic object
        _units - Synchronized units (unused — we read synchronizedObjects)
        _activated - Whether module is activated

    Priority: 5 (feature module)
*/

params ["_logic", "_units", "_activated"];

if (!isServer) exitWith {};

if (!_activated) exitWith {
    diag_log "[RECONDO_BADCIVI] Module not activated.";
};

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

private _triggerSide = _logic getVariable ["triggerside", "WEST"];
private _detectionDistance = _logic getVariable ["detectiondistance", 5];
private _chance = _logic getVariable ["chance", 50];
private _weaponClassname = _logic getVariable ["weaponclassname", "hgun_Pistol_01_F"];
private _magazineClassname = _logic getVariable ["magazineclassname", "10Rnd_9x21_Mag"];
private _magazineCount = _logic getVariable ["magazinecount", 1];
private _disableMovement = _logic getVariable ["disablemovement", true];
private _forceStanding = _logic getVariable ["forcestanding", true];
private _debugLogging = _logic getVariable ["debuglogging", false];
if (RECONDO_MASTER_DEBUG) then { _debugLogging = true; };

// ========================================
// GENERATE INSTANCE ID
// ========================================

private _instanceId = format ["badcivi_%1", count RECONDO_BADCIVI_INSTANCES];

// ========================================
// STORE SETTINGS
// ========================================

private _settings = createHashMapFromArray [
    ["instanceId", _instanceId],
    ["triggerSide", _triggerSide],
    ["detectionDistance", _detectionDistance],
    ["chance", _chance],
    ["weaponClassname", _weaponClassname],
    ["magazineClassname", _magazineClassname],
    ["magazineCount", _magazineCount],
    ["disableMovement", _disableMovement],
    ["forceStanding", _forceStanding],
    ["debugLogging", _debugLogging]
];

RECONDO_BADCIVI_INSTANCES pushBack _settings;

// ========================================
// FIND SYNCED UNITS
// ========================================

private _syncedUnits = [];
{
    if (_x isKindOf "CAManBase" && !(_x isKindOf "Module_F")) then {
        _syncedUnits pushBack _x;
    };
} forEach (synchronizedObjects _logic);

if (count _syncedUnits == 0) exitWith {
    diag_log "[RECONDO_BADCIVI] ERROR: No units synced to module. Sync one or more AI units in Eden.";
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_BADCIVI] Found %1 synced units for instance '%2'", count _syncedUnits, _instanceId];
};

// ========================================
// SETUP EACH UNIT
// ========================================

{
    [_x, _settings] call Recondo_fnc_setupBadCivi;
} forEach _syncedUnits;

// ========================================
// LOG INITIALIZATION
// ========================================

diag_log format ["[RECONDO_BADCIVI] '%1' initialized — %2 units, side: %3, distance: %4m, chance: %5%%, weapon: %6",
    _instanceId, count _syncedUnits, _triggerSide, _detectionDistance, _chance, _weaponClassname];
