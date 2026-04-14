/*
    Recondo_fnc_spawnQRFMounted
    Spawns the QRF vehicle convoy and moves it towards the target

    Description:
        Finds the nearest road ~spawnDistance meters from the target position,
        ensuring no Target Side units are within safetyDistance of the spawn.
        Creates all vehicles in one group, fills crew (driver, gunner, cargo).
        Vehicles move towards the target. Cargo passengers dismount at
        dismountDistance and engage on foot; drivers and gunners stay mounted.

    Parameters:
        _moduleSettings - HashMap of module settings
        _targetPos - Position of the detected target

    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params ["_moduleSettings", "_targetPos"];

private _moduleId = _moduleSettings get "moduleId";
private _qrfSide = _moduleSettings get "qrfSide";
private _targetSide = _moduleSettings get "targetSide";
private _vehiclePool = _moduleSettings get "vehicleClassnames";
private _unitClassnames = _moduleSettings get "unitClassnames";
private _crewClassname = _moduleSettings get "crewClassname";
private _fillCargo = _moduleSettings get "fillCargo";
private _minVehicles = _moduleSettings get "minVehicles";
private _maxVehicles = _moduleSettings get "maxVehicles";
private _spawnDistance = _moduleSettings get "spawnDistance";
private _safetyDistance = _moduleSettings get "safetyDistance";
private _dismountDistance = _moduleSettings get "dismountDistance";
private _heightLimit = _moduleSettings get "heightLimit";
private _debugMarkers = _moduleSettings get "debugMarkers";
private _debugLogging = _moduleSettings get "debugLogging";

// ========================================
// FIND SPAWN POSITION ON NEAREST ROAD
// ========================================

// Pick a rough candidate position spawnDistance from the target
private _candidatePos = _targetPos getPos [_spawnDistance, random 360];

// Try multiple directions if the first isn't safe
private _spawnRoadPos = [];
private _foundSafe = false;
private _directions = [0, 45, 90, 135, 180, 225, 270, 315];
_directions = _directions call BIS_fnc_arrayShuffle;

{
    private _testPos = _targetPos getPos [_spawnDistance, _x];
    private _roads = _testPos nearRoads 200;

    if (count _roads > 0) then {
        private _roadPos = getPos (_roads select 0);

        // Check safety distance from target side
        private _safe = true;
        {
            if (alive _x && side _x == _targetSide) then {
                if ((getPosATL _x select 2) <= _heightLimit && _x distance _roadPos < _safetyDistance) exitWith {
                    _safe = false;
                };
            };
        } forEach allUnits;

        if (_safe) then {
            _spawnRoadPos = _roadPos;
            _foundSafe = true;
        };
    };

    if (_foundSafe) exitWith {};
} forEach _directions;

// Fallback: if no safe road found, use raw position
if (!_foundSafe) then {
    private _fallbackRoads = _candidatePos nearRoads 500;
    if (count _fallbackRoads > 0) then {
        _spawnRoadPos = getPos (_fallbackRoads select 0);
    } else {
        _spawnRoadPos = _candidatePos;
    };

    if (_debugLogging) then {
        diag_log format ["[RECONDO_QRF] Module %1: WARNING - No safe road found, using fallback at %2", _moduleId, _spawnRoadPos];
    };
};

_spawnRoadPos set [2, 0];

if (_debugLogging) then {
    diag_log format ["[RECONDO_QRF] Module %1: Spawning QRF at %2 (road: %3)", _moduleId, _spawnRoadPos, _foundSafe];
};

// ========================================
// CREATE GROUP AND VEHICLES
// ========================================

private _group = createGroup [_qrfSide, true];
if (isNull _group) exitWith {
    diag_log format ["[RECONDO_QRF] Module %1: ERROR - Failed to create group", _moduleId];
};

_group setVariable ["RECONDO_QRF_moduleId", _moduleId];

// Determine crew classname (use first from list, or fall back to unit classnames)
private _crewClass = if (count _crewClassname > 0) then {
    _crewClassname select 0
} else {
    _unitClassnames select 0
};

// Randomly determine vehicle count and select from pool
private _vehicleCount = _minVehicles + floor random ((_maxVehicles - _minVehicles) + 1);
_vehicleCount = _vehicleCount max 1;

private _vehicleClassnames = [];
for "_i" from 1 to _vehicleCount do {
    _vehicleClassnames pushBack (selectRandom _vehiclePool);
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_QRF] Module %1: Selected %2 vehicles from pool: %3", _moduleId, _vehicleCount, _vehicleClassnames];
};

private _vehicles = [];
private _allCargoUnits = [];
private _spawnDir = _spawnRoadPos getDir _targetPos;

{
    private _vehClass = _x;
    private _offset = _spawnRoadPos getPos [(_forEachIndex * 20), (_spawnDir + 180) mod 360];
    _offset set [2, 0];

    private _vehicle = createVehicle [_vehClass, _offset, [], 0, "NONE"];
    if (isNull _vehicle) then { continue };

    _vehicle setDir _spawnDir;
    _vehicles pushBack _vehicle;

    // Create driver
    private _driver = _group createUnit [_crewClass, _offset, [], 0, "NONE"];
    if (!isNull _driver) then {
        _driver assignAsDriver _vehicle;
        _driver moveInDriver _vehicle;
        _driver setVariable ["RECONDO_QRF_role", "driver", true];
    };

    // Fill gunner seats
    private _turrets = allTurrets [_vehicle, false];
    {
        private _turretPath = _x;
        if (_vehicle turretUnit _turretPath isEqualTo objNull) then {
            private _gunner = _group createUnit [_crewClass, _offset, [], 0, "NONE"];
            if (!isNull _gunner) then {
                _gunner assignAsTurret [_vehicle, _turretPath];
                _gunner moveInTurret [_vehicle, _turretPath];
                _gunner setVariable ["RECONDO_QRF_role", "gunner", true];
            };
        };
    } forEach _turrets;

    // Fill cargo with infantry from unitClassnames
    if (_fillCargo) then {
        private _cargoCount = _vehicle emptyPositions "cargo";
        for "_i" from 1 to _cargoCount do {
            private _unitClass = selectRandom _unitClassnames;
            private _cargoUnit = _group createUnit [_unitClass, _offset, [], 0, "NONE"];
            if (!isNull _cargoUnit) then {
                _cargoUnit assignAsCargo _vehicle;
                _cargoUnit moveInCargo _vehicle;

                // Verify unit actually boarded; delete if not
                if (vehicle _cargoUnit != _vehicle) then {
                    deleteVehicle _cargoUnit;
                } else {
                    _cargoUnit setVariable ["RECONDO_QRF_role", "cargo", true];
                    _allCargoUnits pushBack _cargoUnit;
                };
            };
        };
    };

    if (_debugLogging) then {
        diag_log format ["[RECONDO_QRF] Module %1: Vehicle %2 created at %3 (crew: driver + %4 turrets + %5 cargo)",
            _moduleId, _vehClass, _offset, count _turrets, count (_allCargoUnits select { vehicle _x == _vehicle })];
    };
} forEach _vehicleClassnames;

if (count _vehicles == 0) exitWith {
    deleteGroup _group;
    diag_log format ["[RECONDO_QRF] Module %1: ERROR - No vehicles spawned", _moduleId];
};

// ========================================
// SET GROUP BEHAVIOR AND MOVE
// ========================================

_group setBehaviour "AWARE";
_group setCombatMode "RED";
_group setSpeedMode "NORMAL";

private _leadVehicle = _vehicles select 0;
private _wp = _group addWaypoint [_targetPos, 50];
_wp setWaypointType "MOVE";
_wp setWaypointBehaviour "AWARE";
_wp setWaypointCombatMode "RED";
_wp setWaypointSpeed "NORMAL";

RECONDO_QRF_ACTIVE_GROUPS pushBack _group;

if (_debugMarkers) then {
    private _spawnMarker = createMarker [format ["RECONDO_QRF_spawn_%1", _moduleId], _spawnRoadPos];
    _spawnMarker setMarkerType "mil_dot";
    _spawnMarker setMarkerColor "ColorOrange";
    _spawnMarker setMarkerText "QRF Spawn";

    private _targetMarker = createMarker [format ["RECONDO_QRF_target_%1", _moduleId], _targetPos];
    _targetMarker setMarkerType "mil_destroy";
    _targetMarker setMarkerColor "ColorRed";
    _targetMarker setMarkerText "QRF Target";
};

// ========================================
// DISMOUNT MONITOR
// ========================================

[_group, _vehicles, _allCargoUnits, _targetPos, _dismountDistance, _moduleId, _debugLogging] spawn {
    params ["_group", "_vehicles", "_cargoUnits", "_targetPos", "_dismountDist", "_moduleId", "_debugLogging"];

    // Wait until lead vehicle is close enough or destroyed
    private _dismounted = false;

    while {!_dismounted} do {
        private _aliveVehicles = _vehicles select { alive _x };
        if (count _aliveVehicles == 0) exitWith { _dismounted = true; };

        private _closestDist = 999999;
        {
            private _dist = _x distance _targetPos;
            if (_dist < _closestDist) then { _closestDist = _dist; };
        } forEach _aliveVehicles;

        if (_closestDist <= _dismountDist) then {
            _dismounted = true;

            if (_debugLogging) then {
                diag_log format ["[RECONDO_QRF] Module %1: Dismount triggered at %2m from target", _moduleId, _closestDist];
            };

            // Order cargo to dismount
            {
                if (alive _x && vehicle _x != _x) then {
                    unassignVehicle _x;
                    [_x] orderGetIn false;
                };
            } forEach _cargoUnits;

            // Wait for dismount
            sleep 5;

            // Create a separate infantry group for dismounted cargo
            private _infantryGroup = createGroup [side _group, true];
            if (!isNull _infantryGroup) then {
                {
                    if (alive _x && vehicle _x == _x) then {
                        [_x] joinSilent _infantryGroup;
                    };
                } forEach _cargoUnits;

                _infantryGroup setBehaviour "COMBAT";
                _infantryGroup setCombatMode "RED";
                _infantryGroup setSpeedMode "FULL";

                private _wp = _infantryGroup addWaypoint [_targetPos, 30];
                _wp setWaypointType "SAD";
                _wp setWaypointBehaviour "COMBAT";

                RECONDO_QRF_ACTIVE_GROUPS pushBack _infantryGroup;
            };

            // Keep vehicles moving (drivers/gunners stay mounted)
            {
                if (alive _x) then {
                    private _vehGroup = group driver _x;
                    if (!isNull _vehGroup) then {
                        _vehGroup setBehaviour "COMBAT";
                        _vehGroup setCombatMode "RED";
                    };
                };
            } forEach _vehicles;
        };

        if (!_dismounted) then {
            sleep 3;
        };
    };

    if (_debugLogging) then {
        diag_log format ["[RECONDO_QRF] Module %1: Dismount monitor complete", _moduleId];
    };
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_QRF] Module %1: QRF spawned - %2 vehicles, %3 cargo units, moving to %4",
        _moduleId, count _vehicles, count _allCargoUnits, _targetPos];
};
