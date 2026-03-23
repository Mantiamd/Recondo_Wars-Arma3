/*
    Recondo_fnc_setupBadCivi
    Per-unit setup for Bad Civi module

    Description:
        Strips weapons from the unit, configures behavior, and creates
        a proximity trigger attached to the unit. When the configured
        side enters the trigger radius, the unit rolls a chance to
        pull a concealed weapon and switch to combat.
        Uses BIS_fnc_netId for dedicated server compatibility.

    Parameters:
        _unit - OBJECT - The AI unit to configure
        _settings - HASHMAP - Module settings

    Execution:
        Server only (called from module init)
*/

if (!isServer) exitWith {};

params [
    ["_unit", objNull, [objNull]],
    ["_settings", createHashMap, [createHashMap]]
];

if (isNull _unit) exitWith {
    diag_log "[RECONDO_BADCIVI] ERROR: Null unit passed to setupBadCivi";
};

private _triggerSide = _settings get "triggerSide";
private _detectionDistance = _settings get "detectionDistance";
private _chance = _settings get "chance";
private _weaponClassname = _settings get "weaponClassname";
private _magazineClassname = _settings get "magazineClassname";
private _magazineCount = _settings get "magazineCount";
private _disableMovement = _settings get "disableMovement";
private _forceStanding = _settings get "forceStanding";
private _debugLogging = _settings get "debugLogging";

// Convert percentage to 0-1 range for random check
private _chanceNormalized = _chance / 100;

// ========================================
// STRIP WEAPONS AND CONFIGURE BEHAVIOR
// ========================================

removeAllWeapons _unit;
{ _unit removeMagazine _x } forEach magazines _unit;

_unit allowFleeing 0;
_unit setBehaviour "CARELESS";

if (_disableMovement) then {
    _unit disableAI "MOVE";
};

if (_forceStanding) then {
    _unit setUnitPos "UP";
};

_unit setVariable ["RECONDO_BADCIVI_ARMED", false, true];

if (_debugLogging) then {
    diag_log format ["[RECONDO_BADCIVI] Unit %1 (%2) stripped and configured at %3",
        _unit, typeOf _unit, getPosATL _unit];
};

// ========================================
// CREATE ATTACHED PROXIMITY TRIGGER
// ========================================

private _netId = _unit call BIS_fnc_netId;

private _trigger = createTrigger ["EmptyDetector", getPos _unit, true];
_trigger setTriggerArea [_detectionDistance, _detectionDistance, 0, false, 100];

private _sideStr = switch (toUpper _triggerSide) do {
    case "WEST": { "WEST" };
    case "EAST": { "EAST" };
    case "GUER": { "GUER" };
    default { "ANY" };
};

if (_sideStr == "ANY") then {
    _trigger setTriggerActivation ["ANY", "PRESENT", true];
} else {
    _trigger setTriggerActivation [_sideStr, "PRESENT", true];
};

// Trigger statements use netId for MP/dedicated server safety
_trigger setTriggerStatements [
    "this",
    format [
        "
            private _unit = '%1' call BIS_fnc_objectFromNetId;
            if (!isNull _unit && {alive _unit} && {!(_unit getVariable ['RECONDO_BADCIVI_ARMED', false])}) then {
                if (random 1 < %2) then {
                    _unit setVariable ['RECONDO_BADCIVI_ARMED', true, true];
                    [_unit, '%3', %4, '%5'] call BIS_fnc_addWeapon;
                    _unit setBehaviour 'COMBAT';
                    _unit setCombatMode 'RED';
                    _unit enableAI 'MOVE';
                    if (%6) then {
                        diag_log format ['[RECONDO_BADCIVI] Unit %%1 pulled weapon!', _unit];
                    };
                } else {
                    if (%6) then {
                        diag_log format ['[RECONDO_BADCIVI] Unit %%1 chance roll failed', _unit];
                    };
                };
            };
        ",
        _netId,
        _chanceNormalized,
        _weaponClassname,
        _magazineCount,
        _magazineClassname,
        _debugLogging
    ],
    ""
];

_trigger attachTo [_unit];

RECONDO_BADCIVI_TRIGGERS pushBack _trigger;

if (_debugLogging) then {
    diag_log format ["[RECONDO_BADCIVI] Trigger created for unit %1 (netId: %2, radius: %3m, side: %4)",
        _unit, _netId, _detectionDistance, _sideStr];
};
