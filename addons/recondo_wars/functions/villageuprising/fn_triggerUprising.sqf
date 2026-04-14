/*
    Recondo_fnc_triggerUprising
    Phase 1: Trigger side entered radius - spawn civilians
    Phase 2: Monitor OPFOR awareness - when OPFOR knowsAbout trigger side, rally/arm/attack

    Description:
        Called when the trigger side enters the village radius.
        Spawns civilians who wander peacefully. Then monitors all
        OPFOR units in the area — when any OPFOR unit knowsAbout
        a trigger-side unit, civilians rally, arm up, and attack.
        One-time per site.

    Parameters:
        _trigger       - OBJECT - The trigger that fired
        _thisList      - ARRAY  - Units detected in trigger
        _villageMarker - STRING - Village marker name
        _rallyMarker   - STRING - Rally marker name
*/

if (!isServer) exitWith {};

params [
    ["_trigger", objNull, [objNull]],
    ["_thisList", [], [[]]],
    ["_villageMarker", "", [""]],
    ["_rallyMarker", "", [""]]
];

if (_trigger getVariable ["RECONDO_UPRISING_triggered", false]) exitWith {};
_trigger setVariable ["RECONDO_UPRISING_triggered", true];

private _settings = _trigger getVariable ["RECONDO_UPRISING_settings", nil];
if (isNil "_settings") exitWith {};

private _debugLogging = _settings get "debugLogging";
private _detectionRadius = _settings get "detectionRadius";
private _combatSide = _settings get "combatSide";
private _weaponClassname = _settings get "weaponClassname";
private _magazineClassname = _settings get "magazineClassname";
private _magazineCount = _settings get "magazineCount";
private _armingDelay = _settings get "armingDelay";
private _uprisingPercent = _settings get "uprisingPercent";
private _triggerSideStr = _settings get "triggerSide";

// Convert trigger side string to side object for knowsAbout checks
private _triggerSideObj = switch (toUpper _triggerSideStr) do {
    case "EAST": { east };
    case "WEST": { west };
    case "GUER": { independent };
    default      { west };
};

// Convert combat side to string for OPFOR unit scanning
private _opforSideObj = _combatSide;

private _villagePos = getMarkerPos _villageMarker;

// Delete the trigger
deleteVehicle _trigger;

// ========================================
// PHASE 1: SPAWN CIVILIANS
// ========================================

private _civilians = [_settings, _villageMarker, _villagePos] call Recondo_fnc_spawnUprisingCivilians;

if (count _civilians == 0) exitWith {
    if (_debugLogging) then {
        diag_log format ["[RECONDO_UPRISING] No civilians spawned at %1, aborting.", _villageMarker];
    };
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_UPRISING] Phase 1: %1 civilians spawned at %2. Monitoring OPFOR awareness...", count _civilians, _villageMarker];
};

// ========================================
// PHASE 2: MONITOR OPFOR AWARENESS
// ========================================

[_civilians, _villagePos, _villageMarker, _rallyMarker, _detectionRadius, _triggerSideObj, _opforSideObj, _combatSide, _weaponClassname, _magazineClassname, _magazineCount, _armingDelay, _uprisingPercent, _debugLogging] spawn {
    params ["_civilians", "_villagePos", "_villageMarker", "_rallyMarker", "_detectionRadius", "_triggerSideObj", "_opforSideObj", "_combatSide", "_weaponClassname", "_magazineClassname", "_magazineCount", "_armingDelay", "_uprisingPercent", "_debugLogging"];

    private _detected = false;
    private _threatPos = [0,0,0];

    while {!_detected} do {
        sleep 5;

        private _aliveCivs = _civilians select { alive _x };
        if (count _aliveCivs == 0) exitWith {};

        private _opforUnits = _villagePos nearEntities ["CAManBase", _detectionRadius];
        _opforUnits = _opforUnits select { side group _x == _opforSideObj && alive _x };

        if (count _opforUnits == 0) then { continue };

        private _triggerUnits = _villagePos nearEntities ["CAManBase", _detectionRadius];
        _triggerUnits = _triggerUnits select { side group _x == _triggerSideObj && alive _x };

        if (count _triggerUnits == 0) then { continue };

        {
            private _opfor = _x;
            {
                if (_opfor knowsAbout _x > 0) exitWith {
                    _detected = true;
                    _threatPos = getPosATL _x;

                    if (_debugLogging) then {
                        diag_log format ["[RECONDO_UPRISING] OPFOR %1 detected %2 (knowsAbout: %3) at %4",
                            _opfor, _x, _opfor knowsAbout _x, _villageMarker];
                    };
                };
            } forEach _triggerUnits;

            if (_detected) exitWith {};
        } forEach _opforUnits;
    };

    if (!_detected) exitWith {};

    if (_threatPos isEqualTo [0,0,0]) then {
        _threatPos = _villagePos;
    };

    private _rallyPos = getMarkerPos _rallyMarker;
    if (_rallyPos isEqualTo [0,0,0]) then {
        _rallyPos = _villagePos;
    };

    // ========================================
    // SPLIT CIVILIANS BY UPRISING PERCENT
    // ========================================

    private _aliveCivs = _civilians select { alive _x };
    if (count _aliveCivs == 0) exitWith {};

    private _uprisingCount = ceil (count _aliveCivs * (_uprisingPercent / 100));
    _uprisingCount = _uprisingCount min count _aliveCivs;

    private _shuffled = +_aliveCivs;
    _shuffled call BIS_fnc_arrayShuffle;

    private _rallyCivs = _shuffled select [0, _uprisingCount];
    private _ambientCivs = _shuffled select [_uprisingCount];

    if (_debugLogging) then {
        diag_log format ["[RECONDO_UPRISING] Phase 2: OPFOR aware at %1! %2 civilians rallying (%3%%), %4 staying ambient. Threat at %5",
            _villageMarker, count _rallyCivs, _uprisingPercent, count _ambientCivs, _threatPos];
    };

    // ========================================
    // PER-CIVILIAN RALLY, ARM, ATTACK
    // ========================================

    {
        private _unit = _x;

        [_unit, _rallyPos, _threatPos, _combatSide, _weaponClassname, _magazineClassname, _magazineCount, _armingDelay, _debugLogging, _villageMarker] spawn {
            params ["_unit", "_rallyPos", "_threatPos", "_combatSide", "_weaponClassname", "_magazineClassname", "_magazineCount", "_armingDelay", "_debugLogging", "_villageMarker"];

            if (!alive _unit) exitWith {};

            _unit setVariable ["RECONDO_UPRISING_active", false];
            _unit enableAI "MOVE";
            _unit setBehaviour "AWARE";
            _unit setSpeedMode "FULL";
            _unit doMove _rallyPos;

            // Wait for this civilian to arrive (or timeout)
            private _timeout = time + 60;
            waitUntil {
                sleep 2;
                !alive _unit || (_unit distance _rallyPos < 10) || time > _timeout
            };

            if (!alive _unit) exitWith {};

            sleep _armingDelay;

            if (!alive _unit) exitWith {};

            // Arm up in own combat group
            private _combatGroup = createGroup [_combatSide, true];
            [_unit] joinSilent _combatGroup;

            removeAllWeapons _unit;
            removeAllItems _unit;

            if (_magazineClassname != "") then {
                for "_m" from 1 to _magazineCount do {
                    _unit addMagazine _magazineClassname;
                };
            };
            if (_weaponClassname != "") then {
                _unit addWeapon _weaponClassname;
            };

            _unit setBehaviour "COMBAT";
            _unit setSpeedMode "FULL";
            _unit setCombatMode "RED";
            _combatGroup move _threatPos;

            if (_debugLogging) then {
                diag_log format ["[RECONDO_UPRISING] Civilian armed and attacking from %1 toward %2", _villageMarker, _threatPos];
            };
        };

        sleep 2;
    } forEach _rallyCivs;
};
