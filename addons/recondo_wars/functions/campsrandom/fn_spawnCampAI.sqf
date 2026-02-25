/*
    Recondo_fnc_spawnCampAI
    Spawns AI sentries at a camp in sitting animations
    
    Description:
        Creates sentry units that sit around the camp center (campfire area).
        Units are placed 2m from marker center in random directions.
        They stand up and enter combat when alerted.
    
    Parameters:
        _settings - HASHMAP - Module settings
        _position - ARRAY - Position of the camp center
        _markerId - STRING - Marker ID (for tracking)
    
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [
    ["_settings", nil, [createHashMap]],
    ["_position", [0,0,0], [[]]],
    ["_markerId", "", [""]]
];

if (isNil "_settings") exitWith {};

private _sentryClassnames = _settings get "sentryClassnames";
private _sentryMinCount = _settings get "sentryMinCount";
private _sentryMaxCount = _settings get "sentryMaxCount";
private _sentrySide = _settings get "sentrySide";
private _sentryAnimations = _settings get "sentryAnimations";
private _enableIntelUnit = _settings get "enableIntelUnit";
private _debugLogging = _settings get "debugLogging";

if (count _sentryClassnames == 0) exitWith {
    if (_debugLogging) then {
        diag_log format ["[RECONDO_CAMPS] No sentry classnames defined for %1", _markerId];
    };
};

// Sitting animations (configurable, with fallback)
private _sittingAnims = if (!isNil "_sentryAnimations" && {count _sentryAnimations > 0}) then {
    _sentryAnimations
} else {
    ["AmovPsitMstpSrasWrflDnon", "AmovPsitMstpSrasWrflDnon_WeaponCheck1", "AmovPsitMstpSrasWrflDnon_WeaponCheck2", "AmovPsitMstpSrasWrflDnon_Smoking"]
};

// Calculate sentry count
private _sentryCount = _sentryMinCount + floor random ((_sentryMaxCount - _sentryMinCount) + 1);

// Create group
private _sentryGroup = createGroup [_sentrySide, true];

private _spawnedUnits = [];

// Spawn sentries
for "_i" from 1 to _sentryCount do {
    // Position 2m from center in random direction
    private _angle = (_i - 1) * (360 / _sentryCount) + random 30 - 15;
    private _spawnPos = _position getPos [2, _angle];
    
    // Find empty position nearby
    private _finalPos = _spawnPos findEmptyPosition [0, 3, "Man"];
    if (count _finalPos == 0) then { _finalPos = _spawnPos };
    
    // Select random unit type
    private _unitClass = selectRandom _sentryClassnames;
    
    // Create unit
    private _unit = _sentryGroup createUnit [_unitClass, _finalPos, [], 0, "NONE"];
    _unit setPosATL _finalPos;
    
    // Face toward camp center
    _unit setDir (_unit getDir _position);
    
    // Configure unit
    _unit setUnitPos "UP";
    _unit setBehaviour "CARELESS";
    _unit allowDamage false;
    
    // Disable AI components for sitting
    _unit disableAI "MOVE";
    _unit disableAI "PATH";
    _unit disableAI "ANIM";
    
    // Apply sitting animation
    private _anim = selectRandom _sittingAnims;
    [_unit, _anim] remoteExec ["switchMove", 0, true];
    
    // Store sitting state and animation
    _unit setVariable ["RECONDO_CAMPS_sitting", true, true];
    _unit setVariable ["RECONDO_CAMPS_markerId", _markerId, true];
    _unit setVariable ["RECONDO_CAMPS_sittingAnim", _anim, true];
    
    // Disable simulation initially (simulation monitor will enable when players approach)
    _unit enableSimulationGlobal false;
    
    _spawnedUnits pushBack _unit;
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_CAMPS] Spawned sentry %1 (%2/%3) at %4 with anim %5", 
            _unitClass, _i, _sentryCount, _finalPos, _anim];
    };
};

// Set group behavior
_sentryGroup setBehaviour "CARELESS";
_sentryGroup setCombatMode "WHITE";

// Disable dynamic simulation (we handle simulation manually via simulation monitor)
_sentryGroup enableDynamicSimulation false;

// ========================================
// SETUP ALERT HANDLER
// ========================================

// Monitor for combat - when detected, stand units up
[_spawnedUnits, _position, _debugLogging, _markerId] spawn {
    params ["_units", "_centerPos", "_debug", "_markerId"];
    
    private _alertTriggered = false;
    private _simStateVar = format ["RECONDO_CAMPS_%1_simEnabled", _markerId];
    
    while {!_alertTriggered && {({alive _x} count _units) > 0}} do {
        sleep 1;
        
        // Only check for alerts when simulation is enabled
        private _simEnabled = missionNamespace getVariable [_simStateVar, false];
        if (!_simEnabled) then { continue };
        
        // Small delay after simulation enabled to let states stabilize
        sleep 0.5;
        
        // Check if any unit is in combat or has detected enemies
        {
            if (alive _x && {_x getVariable ["RECONDO_CAMPS_sitting", false]}) then {
                private _unit = _x;
                private _campSide = side _unit;
                
                // Check if unit has actually detected an enemy (knowsAbout > 1.5 means spotted)
                private _enemyUnits = allUnits select {side _x != _campSide && alive _x && isPlayer _x};
                private _knowsAboutAny = {_unit knowsAbout _x > 1.5} count _enemyUnits;
                
                // Check if unit behavior changed to combat (due to being shot at, etc)
                private _behaviour = behaviour _unit;
                
                if (_knowsAboutAny > 0 || _behaviour == "COMBAT") exitWith {
                    _alertTriggered = true;
                };
            };
        } forEach _units;
    };
    
    // Alert triggered - stand everyone up
    if (_alertTriggered) then {
        if (_debug) then {
            diag_log format ["[RECONDO_CAMPS] Alert triggered at %1 - standing up units", _centerPos];
        };
        
        {
            if (alive _x && {_x getVariable ["RECONDO_CAMPS_sitting", false]}) then {
                // Re-enable AI
                _x enableAI "MOVE";
                _x enableAI "PATH";
                _x enableAI "ANIM";
                
                // Break sitting animation
                [_x, ""] remoteExec ["switchMove", 0, true];
                
                // Set combat behavior
                _x setUnitPos "AUTO";
                _x setBehaviour "COMBAT";
                
                _x setVariable ["RECONDO_CAMPS_sitting", false, true];
            };
        } forEach _units;
        
        // Set group to combat
        if (count _units > 0) then {
            private _grp = group (_units select 0);
            _grp setBehaviour "COMBAT";
            _grp setCombatMode "RED";
        };
    };
};

// ========================================
// ADD INTEL TO ONE RANDOM UNIT (IF ENABLED)
// ========================================

if (_enableIntelUnit && {!isNil "RECONDO_INTELITEMS_SETTINGS"} && {count _spawnedUnits > 0}) then {
    // Select one random unit to carry intel
    private _intelUnit = selectRandom _spawnedUnits;
    
    // Add intel directly (bypasses chance roll - guaranteed intel on this unit)
    [_intelUnit] call Recondo_fnc_addIntelToUnit;
    
    // Mark this unit as the intel carrier for reference
    _intelUnit setVariable ["RECONDO_CAMPS_intelCarrier", true, true];
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_CAMPS] Added intel to unit %1 at %2", _intelUnit, _markerId];
    };
};

// ========================================
// ENABLE DAMAGE AFTER DELAY
// ========================================

[{
    params ["_units"];
    {
        if (!isNull _x && alive _x) then {
            _x allowDamage true;
        };
    } forEach _units;
}, [_spawnedUnits], 30] call CBA_fnc_waitAndExecute;

// Store reference to units
private _varName = format ["RECONDO_CAMPS_%1_units", _markerId];
missionNamespace setVariable [_varName, _spawnedUnits, true];

if (_debugLogging) then {
    diag_log format ["[RECONDO_CAMPS] Spawned %1 sentries at %2", count _spawnedUnits, _markerId];
};
