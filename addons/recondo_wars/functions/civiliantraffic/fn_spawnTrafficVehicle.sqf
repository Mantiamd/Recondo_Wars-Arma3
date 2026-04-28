/*
    Recondo_fnc_spawnTrafficVehicle
    Spawns a civilian vehicle with driver on a road
    
    Description:
        Creates a civilian vehicle at a random road position within the zone.
        Adds a civilian driver and starts the driving behavior.
    
    Parameters:
        _zoneIndex - NUMBER - Index of the zone in RECONDO_CIVTRAFFIC_ZONES
    
    Returns:
        OBJECT - The spawned vehicle (or objNull if spawn failed)
    
    Example:
        _vehicle = [0] call Recondo_fnc_spawnTrafficVehicle;
*/

params [["_zoneIndex", -1, [0]]];

if (_zoneIndex < 0 || _zoneIndex >= count RECONDO_CIVTRAFFIC_ZONES) exitWith {
    diag_log format ["[RECONDO_CIVTRAFFIC] ERROR: spawnTrafficVehicle - Invalid zone index: %1", _zoneIndex];
    objNull
};

private _zoneData = RECONDO_CIVTRAFFIC_ZONES select _zoneIndex;
private _markerPos = _zoneData get "markerPos";
private _markerId = _zoneData get "markerId";

private _settings = RECONDO_CIVTRAFFIC_SETTINGS;
private _spawnRadius = _settings get "spawnRadius";
private _civilianClassnames = _settings get "civilianClassnames";
private _vehicleClassnames = _settings get "vehicleClassnames";
private _fleeOnPlayerEnter = _settings get "fleeOnPlayerEnter";
private _cowerUnderFire = _settings get "cowerUnderFire";
private _vehiclesInvincible = _settings getOrDefault ["vehiclesInvincible", false];
private _debugLogging = _settings get "debugLogging";

// Find random road position
private _roadData = [_markerPos, _spawnRadius] call Recondo_fnc_findRandomRoadPos;

if (_roadData isEqualTo []) exitWith {
    if (_debugLogging) then {
        diag_log format ["[RECONDO_CIVTRAFFIC] No road found in zone %1", _markerId];
    };
    objNull
};

_roadData params ["_roadPos", "_roadDir"];

// Select random classnames
private _vehicleClass = selectRandom _vehicleClassnames;
private _civilianClass = selectRandom _civilianClassnames;

// Create vehicle
private _vehicle = createVehicle [_vehicleClass, _roadPos, [], 0, "NONE"];
_vehicle setDir _roadDir;
_vehicle setPos _roadPos;

// Create civilian group and unit
private _group = createGroup [civilian, true];
private _civilian = _group createUnit [_civilianClass, _roadPos, [], 0, "NONE"];

// Move civilian into vehicle as driver
_civilian moveInDriver _vehicle;

// Apply invincibility if enabled
if (_vehiclesInvincible) then {
    _vehicle allowDamage false;
    _civilian allowDamage false;
};

// Set vehicle variables
_vehicle setVariable ["RECONDO_CIVTRAFFIC_ZoneIndex", _zoneIndex, false];
_vehicle setVariable ["RECONDO_CIVTRAFFIC_MarkerPos", _markerPos, false];
_vehicle setVariable ["RECONDO_CIVTRAFFIC_Civilian", _civilian, false];
_vehicle setVariable ["RECONDO_CIVTRAFFIC_Abandoned", false, false];

// Set civilian variables
_civilian setVariable ["RECONDO_CIVTRAFFIC_Vehicle", _vehicle, false];
_civilian setVariable ["RECONDO_CIVTRAFFIC_Cowering", false, false];

// Add to global tracking
RECONDO_CIVTRAFFIC_ACTIVE_VEHICLES pushBack _vehicle;

// Add event handlers
if (_fleeOnPlayerEnter) then {
    _vehicle addEventHandler ["GetIn", {
        params ["_vehicle", "_role", "_unit", "_turret"];
        [_vehicle, _unit] call Recondo_fnc_handleTrafficGetIn;
    }];
};

if (_cowerUnderFire) then {
    _civilian addEventHandler ["FiredNear", {
        params ["_unit", "_firer", "_distance", "_weapon", "_muzzle", "_mode", "_ammo", "_gunner"];
        [_unit] call Recondo_fnc_handleTrafficFiredNear;
    }];
};

// Killed event handler for cleanup
_vehicle addEventHandler ["Killed", {
    params ["_vehicle", "_killer", "_instigator", "_useEffects"];
    
    // Remove from active list
    RECONDO_CIVTRAFFIC_ACTIVE_VEHICLES = RECONDO_CIVTRAFFIC_ACTIVE_VEHICLES - [_vehicle];
    
    // Remove from zone list
    private _zoneIndex = _vehicle getVariable ["RECONDO_CIVTRAFFIC_ZoneIndex", -1];
    if (_zoneIndex >= 0 && _zoneIndex < count RECONDO_CIVTRAFFIC_ZONES) then {
        private _zoneData = RECONDO_CIVTRAFFIC_ZONES select _zoneIndex;
        private _vehicles = _zoneData get "vehicles";
        _zoneData set ["vehicles", _vehicles - [_vehicle]];
    };
}];

_civilian addEventHandler ["Killed", {
    params ["_unit", "_killer", "_instigator", "_useEffects"];
    
    private _vehicle = _unit getVariable ["RECONDO_CIVTRAFFIC_Vehicle", objNull];
    if (!isNull _vehicle) then {
        _vehicle setVariable ["RECONDO_CIVTRAFFIC_Abandoned", true, false];
    };
}];

// Start driving behavior
[_vehicle, _civilian, _zoneIndex] spawn Recondo_fnc_trafficVehicleBehavior;

if (_debugLogging) then {
    diag_log format ["[RECONDO_CIVTRAFFIC] Spawned %1 with %2 at %3 in zone %4", 
        _vehicleClass, _civilianClass, _roadPos, _markerId];
};

_vehicle
