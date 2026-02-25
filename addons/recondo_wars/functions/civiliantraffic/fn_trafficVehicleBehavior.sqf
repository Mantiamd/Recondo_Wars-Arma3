/*
    Recondo_fnc_trafficVehicleBehavior
    Main driving behavior loop for civilian traffic
    
    Description:
        Controls civilian vehicle behavior: drive to random destination,
        park briefly, then pick new destination. Continues until zone
        deactivates or vehicle/civilian is killed.
    
    Parameters:
        _vehicle - OBJECT - The vehicle
        _civilian - OBJECT - The civilian driver
        _zoneIndex - NUMBER - Index of the zone
    
    Returns:
        Nothing (spawned script)
    
    Example:
        [_vehicle, _civilian, 0] spawn Recondo_fnc_trafficVehicleBehavior;
*/

params ["_vehicle", "_civilian", "_zoneIndex"];

if (isNull _vehicle || isNull _civilian) exitWith {};

private _settings = RECONDO_CIVTRAFFIC_SETTINGS;
private _spawnRadius = _settings get "spawnRadius";
private _speedMode = _settings get "speedMode";
private _parkDurationMin = _settings get "parkDurationMin";
private _parkDurationMax = _settings get "parkDurationMax";
private _arrivalDistance = _settings getOrDefault ["arrivalDistance", 30];
private _earlyStopDistance = _settings getOrDefault ["earlyStopDistance", 100];
private _debugLogging = _settings get "debugLogging";

private _markerPos = _vehicle getVariable ["RECONDO_CIVTRAFFIC_MarkerPos", [0,0,0]];
private _group = group _civilian;

// Set initial behavior
_group setBehaviour "CARELESS";
_group setSpeedMode _speedMode;
_group setCombatMode "BLUE";

// Main behavior loop
while {true} do {
    // Check if we should stop
    if (isNull _vehicle || !alive _vehicle) exitWith {};
    if (isNull _civilian || !alive _civilian) exitWith {};
    if (_vehicle getVariable ["RECONDO_CIVTRAFFIC_Abandoned", false]) exitWith {};
    
    // Check if zone is still active
    if (_zoneIndex >= count RECONDO_CIVTRAFFIC_ZONES) exitWith {};
    private _zoneData = RECONDO_CIVTRAFFIC_ZONES select _zoneIndex;
    if !(_zoneData get "active") exitWith {};
    
    // Check if civilian is cowering
    if (_civilian getVariable ["RECONDO_CIVTRAFFIC_Cowering", false]) then {
        sleep 2;
        continue;
    };
    
    // Find random destination
    private _destData = [_markerPos, _spawnRadius] call Recondo_fnc_findRandomRoadPos;
    
    if (_destData isEqualTo []) then {
        // No road found, wait and retry
        sleep 5;
        continue;
    };
    
    _destData params ["_destPos", "_destDir"];
    
    // Clear existing waypoints
    while {count waypoints _group > 0} do {
        deleteWaypoint [_group, 0];
    };
    
    // Add waypoint to destination
    private _wp = _group addWaypoint [_destPos, 0];
    _wp setWaypointType "MOVE";
    _wp setWaypointBehaviour "CARELESS";
    _wp setWaypointSpeed _speedMode;
    _wp setWaypointCompletionRadius 20;
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_CIVTRAFFIC] Vehicle %1 driving to %2", _vehicle, _destPos];
    };
    
    // Wait until arrived or interrupted
    private _timeout = time + 300; // 5 minute timeout
    waitUntil {
        sleep 2;
        
        // Check interrupts
        if (isNull _vehicle || !alive _vehicle) exitWith { true };
        if (isNull _civilian || !alive _civilian) exitWith { true };
        if (_vehicle getVariable ["RECONDO_CIVTRAFFIC_Abandoned", false]) exitWith { true };
        if (_civilian getVariable ["RECONDO_CIVTRAFFIC_Cowering", false]) exitWith { true };
        
        // Check zone active
        if (_zoneIndex >= count RECONDO_CIVTRAFFIC_ZONES) exitWith { true };
        private _zoneData = RECONDO_CIVTRAFFIC_ZONES select _zoneIndex;
        if !(_zoneData get "active") exitWith { true };
        
        // Check if arrived or timeout
        (_vehicle distance2D _destPos < _arrivalDistance) || (time > _timeout) || (speed _vehicle < 1 && _vehicle distance2D _destPos < _earlyStopDistance)
    };
    
    // Check if we should stop after waiting
    if (isNull _vehicle || !alive _vehicle) exitWith {};
    if (isNull _civilian || !alive _civilian) exitWith {};
    if (_vehicle getVariable ["RECONDO_CIVTRAFFIC_Abandoned", false]) exitWith {};
    if (_zoneIndex >= count RECONDO_CIVTRAFFIC_ZONES) exitWith {};
    private _zoneData = RECONDO_CIVTRAFFIC_ZONES select _zoneIndex;
    if !(_zoneData get "active") exitWith {};
    
    // Skip parking if we were cowering
    if (_civilian getVariable ["RECONDO_CIVTRAFFIC_Cowering", false]) then {
        continue;
    };
    
    // Park for a while
    private _parkDuration = _parkDurationMin + random (_parkDurationMax - _parkDurationMin);
    
    // Stop the vehicle
    _civilian doMove (getPos _vehicle);
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_CIVTRAFFIC] Vehicle %1 parking for %2s", _vehicle, round _parkDuration];
    };
    
    // Wait during park (check for interrupts)
    private _parkEnd = time + _parkDuration;
    waitUntil {
        sleep 2;
        
        if (isNull _vehicle || !alive _vehicle) exitWith { true };
        if (isNull _civilian || !alive _civilian) exitWith { true };
        if (_vehicle getVariable ["RECONDO_CIVTRAFFIC_Abandoned", false]) exitWith { true };
        
        if (_zoneIndex >= count RECONDO_CIVTRAFFIC_ZONES) exitWith { true };
        private _zoneData = RECONDO_CIVTRAFFIC_ZONES select _zoneIndex;
        if !(_zoneData get "active") exitWith { true };
        
        time > _parkEnd
    };
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_CIVTRAFFIC] Behavior loop ended for vehicle %1", _vehicle];
};
