/*
    Recondo_fnc_handleTrafficGetIn
    Handles player getting into a civilian traffic vehicle
    
    Description:
        Called when someone enters a civilian traffic vehicle.
        If a player enters, the civilian driver flees and the vehicle
        becomes abandoned (no longer managed by traffic system).
    
    Parameters:
        _vehicle - OBJECT - The vehicle
        _unit - OBJECT - The unit that entered
    
    Returns:
        Nothing
    
    Example:
        [_vehicle, player] call Recondo_fnc_handleTrafficGetIn;
*/

params ["_vehicle", "_unit"];

// Only react to players
if (!isPlayer _unit) exitWith {};

private _settings = RECONDO_CIVTRAFFIC_SETTINGS;
private _debugLogging = _settings get "debugLogging";

// Get civilian driver
private _civilian = _vehicle getVariable ["RECONDO_CIVTRAFFIC_Civilian", objNull];

if (isNull _civilian || !alive _civilian) exitWith {};

// Mark vehicle as abandoned
_vehicle setVariable ["RECONDO_CIVTRAFFIC_Abandoned", true, false];

// Remove from tracking
RECONDO_CIVTRAFFIC_ACTIVE_VEHICLES = RECONDO_CIVTRAFFIC_ACTIVE_VEHICLES - [_vehicle];

private _zoneIndex = _vehicle getVariable ["RECONDO_CIVTRAFFIC_ZoneIndex", -1];
if (_zoneIndex >= 0 && _zoneIndex < count RECONDO_CIVTRAFFIC_ZONES) then {
    private _zoneData = RECONDO_CIVTRAFFIC_ZONES select _zoneIndex;
    private _vehicles = _zoneData get "vehicles";
    _zoneData set ["vehicles", _vehicles - [_vehicle]];
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_CIVTRAFFIC] Player entered vehicle %1 - civilian fleeing", _vehicle];
};

// Make civilian exit and flee
[_civilian, _vehicle] spawn {
    params ["_civilian", "_vehicle"];
    
    // Wait a moment for the player to fully enter
    sleep 0.5;
    
    if (isNull _civilian || !alive _civilian) exitWith {};
    
    // Force civilian out of vehicle
    if (_civilian in _vehicle) then {
        unassignVehicle _civilian;
        moveOut _civilian;
    };
    
    // Wait for civilian to be out
    sleep 1;
    
    if (isNull _civilian || !alive _civilian) exitWith {};
    
    // Set fleeing behavior
    private _group = group _civilian;
    _group setBehaviour "CARELESS";
    _group setSpeedMode "FULL";
    
    // Find direction away from vehicle/player
    private _fleeDir = (_vehicle getDir _civilian) + 180;
    private _fleePos = _civilian getPos [100 + random 100, _fleeDir];
    
    // Make civilian run away
    _civilian doMove _fleePos;
    _civilian setUnitPos "UP";
    _civilian playMoveNow "ApanPercMstpSnonWnonDnon_G01";
    
    // Delete civilian after they've fled
    sleep 30;
    
    if (!isNull _civilian && alive _civilian) then {
        // Check if any player is nearby before deleting
        private _nearPlayers = allPlayers select { _x distance _civilian < 200 };
        if (count _nearPlayers == 0) then {
            deleteVehicle _civilian;
            deleteGroup _group;
        };
    };
};
