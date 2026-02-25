/*
    Recondo_fnc_spawnSubSiteGarrison
    Spawns garrison AI to man a sub-site object
    
    Description:
        Spawns AI units that man the spawned static weapon or bunker.
        For static weapons, uses moveInGunner.
        For bunkers with multiple turret positions, fills available turrets.
    
    Parameters:
        _settings - HASHMAP - Module settings
        _markerPos - ARRAY - Sub-site position
        _subSiteMarker - STRING - Sub-site marker name
        _spawnedObject - OBJECT - The spawned static weapon or bunker
    
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [
    ["_settings", nil, [createHashMap]],
    ["_markerPos", [0,0,0], [[]]],
    ["_subSiteMarker", "", [""]],
    ["_spawnedObject", objNull, [objNull]]
];

if (isNil "_settings" || isNull _spawnedObject) exitWith {
    diag_log format ["[RECONDO_HUBSUBS] ERROR: Invalid parameters for spawnSubSiteGarrison - object: %1", _spawnedObject];
};

private _hubAISide = _settings get "hubAISide";
private _aiClassnames = _settings get "subSiteAIClassnames";
private _garrisonMin = _settings get "subSiteGarrisonMin";
private _garrisonMax = _settings get "subSiteGarrisonMax";
private _simulationDistance = _settings get "simulationDistance";
private _debugLogging = _settings get "debugLogging";

// Validate classnames
if (count _aiClassnames == 0) exitWith {
    if (_debugLogging) then {
        diag_log format ["[RECONDO_HUBSUBS] No AI classnames for sub-site %1, skipping garrison", _subSiteMarker];
    };
};

// Create group
private _group = createGroup [_hubAISide, true];
if (isNull _group) exitWith {
    diag_log format ["[RECONDO_HUBSUBS] ERROR: Failed to create garrison group at %1", _subSiteMarker];
};

// Get turret paths for the object
private _turretPaths = fullCrew [_spawnedObject, "gunner", true] apply { _x select 3 };

// Calculate how many crew to spawn (limited by available positions)
private _maxCrew = count _turretPaths max 1;
private _garrisonSize = _garrisonMin + floor random ((_garrisonMax - _garrisonMin) + 1);
_garrisonSize = (_garrisonSize max 1) min _maxCrew;

private _unitsCreated = 0;

if (count _turretPaths > 0) then {
    // Object has turret positions - fill them
    for "_i" from 0 to (_garrisonSize - 1) do {
        if (_i >= count _turretPaths) exitWith {};
        
        private _turretPath = _turretPaths select _i;
        private _class = selectRandom _aiClassnames;
        
        if (isClass (configFile >> "CfgVehicles" >> _class)) then {
            private _unit = _group createUnit [_class, _markerPos, [], 5, "NONE"];
            if (!isNull _unit) then {
                _unit moveInTurret [_spawnedObject, _turretPath];
                _unitsCreated = _unitsCreated + 1;
                
                if (_debugLogging) then {
                    diag_log format ["[RECONDO_HUBSUBS] Unit manned turret %1 on %2 at %3", _turretPath, typeOf _spawnedObject, _subSiteMarker];
                };
            };
        };
    };
} else {
    // Object has no turrets - try to use it as a simple static weapon (fallback)
    private _class = selectRandom _aiClassnames;
    
    if (isClass (configFile >> "CfgVehicles" >> _class)) then {
        private _unit = _group createUnit [_class, _markerPos, [], 5, "NONE"];
        if (!isNull _unit) then {
            _unit moveInGunner _spawnedObject;
            
            if (vehicle _unit == _spawnedObject) then {
                _unitsCreated = _unitsCreated + 1;
                if (_debugLogging) then {
                    diag_log format ["[RECONDO_HUBSUBS] Unit manned gunner seat on %1 at %2", typeOf _spawnedObject, _subSiteMarker];
                };
            } else {
                // Failed to enter - position unit nearby
                _unit setPos (_markerPos vectorAdd [random 3 - 1.5, random 3 - 1.5, 0]);
                _unit setUnitPos "UP";
                doStop _unit;
                _unitsCreated = _unitsCreated + 1;
                
                if (_debugLogging) then {
                    diag_log format ["[RECONDO_HUBSUBS] Unit stationed near %1 at %2 (no gunner seat)", typeOf _spawnedObject, _subSiteMarker];
                };
            };
        };
    };
};

// If no units were created, delete the empty group
if (_unitsCreated == 0) then {
    deleteGroup _group;
    if (_debugLogging) then {
        diag_log format ["[RECONDO_HUBSUBS] No garrison units created at %1, deleted empty group", _subSiteMarker];
    };
} else {
    // Configure group behavior
    _group setBehaviour "AWARE";
    _group setCombatMode "RED";
    
    // Register with centralized simulation monitoring system
    if (_simulationDistance > 0) then {
        [{
            params ["_group", "_subSiteMarker", "_markerPos", "_simulationDistance", "_debugLogging"];
            if (!isNull _group && {count units _group > 0}) then {
                private _aliveUnits = units _group select { alive _x };
                if (count _aliveUnits > 0) then {
                    private _identifier = format ["HUBSUBS_GARRISON_%1", _subSiteMarker];
                    [_identifier, _aliveUnits, _markerPos, _simulationDistance] call Recondo_fnc_registerSimulation;
                    
                    if (_debugLogging) then {
                        diag_log format ["[RECONDO_HUBSUBS] Registered %1 garrison units with simulation system at distance %2m for %3", 
                            count _aliveUnits, _simulationDistance, _subSiteMarker];
                    };
                };
            };
        }, [_group, _subSiteMarker, _markerPos, _simulationDistance, _debugLogging], 2] call CBA_fnc_waitAndExecute;
    };
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_HUBSUBS] Spawned %1 garrison units at sub-site %2 manning %3", 
            _unitsCreated, _subSiteMarker, typeOf _spawnedObject];
    };
};
