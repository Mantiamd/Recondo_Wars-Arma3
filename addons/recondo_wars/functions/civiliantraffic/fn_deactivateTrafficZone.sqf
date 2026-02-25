/*
    Recondo_fnc_deactivateTrafficZone
    Deactivates a traffic zone and despawns all vehicles
    
    Description:
        Called when players leave a traffic zone trigger.
        Stops spawn loop and deletes all civilian vehicles in the zone.
    
    Parameters:
        _zoneIndex - NUMBER - Index of the zone in RECONDO_CIVTRAFFIC_ZONES
    
    Returns:
        Nothing
    
    Example:
        [0] call Recondo_fnc_deactivateTrafficZone;
*/

params [["_zoneIndex", -1, [0]]];

if (_zoneIndex < 0 || _zoneIndex >= count RECONDO_CIVTRAFFIC_ZONES) exitWith {
    diag_log format ["[RECONDO_CIVTRAFFIC] ERROR: deactivateTrafficZone - Invalid zone index: %1", _zoneIndex];
};

private _zoneData = RECONDO_CIVTRAFFIC_ZONES select _zoneIndex;
private _markerId = _zoneData get "markerId";
private _isActive = _zoneData get "active";

// Don't deactivate if already inactive
if (!_isActive) exitWith {};

private _settings = RECONDO_CIVTRAFFIC_SETTINGS;
private _debugLogging = _settings get "debugLogging";
private _despawnDelay = _settings get "despawnDelay";

// Mark zone as inactive
_zoneData set ["active", false];

// Stop spawn loop
private _spawnHandle = _zoneData get "spawnHandle";
if (!isNil "_spawnHandle") then {
    [_spawnHandle] call CBA_fnc_removePerFrameHandler;
    _zoneData set ["spawnHandle", nil];
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_CIVTRAFFIC] Zone deactivating: %1 (despawn in %2s)", _markerId, _despawnDelay];
};

// Delay before despawning to prevent instant pop-in/pop-out
[{
    params ["_zoneIndex"];
    
    if (_zoneIndex >= count RECONDO_CIVTRAFFIC_ZONES) exitWith {};
    
    private _zoneData = RECONDO_CIVTRAFFIC_ZONES select _zoneIndex;
    private _isActive = _zoneData get "active";
    
    // If zone was reactivated during delay, don't despawn
    if (_isActive) exitWith {};
    
    private _settings = RECONDO_CIVTRAFFIC_SETTINGS;
    private _debugLogging = _settings get "debugLogging";
    private _markerId = _zoneData get "markerId";
    
    // Get vehicles
    private _vehicles = _zoneData get "vehicles";
    private _vehicleCount = count _vehicles;
    
    // Clean up all vehicles
    {
        if (!isNull _x) then {
            [_x] call Recondo_fnc_cleanupTrafficVehicle;
        };
    } forEach _vehicles;
    
    // Clear vehicle list
    _zoneData set ["vehicles", []];
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_CIVTRAFFIC] Zone deactivated: %1. Cleaned up %2 vehicles.", _markerId, _vehicleCount];
    };
}, [_zoneIndex], _despawnDelay] call CBA_fnc_waitAndExecute;
