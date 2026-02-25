/*
    Recondo_fnc_activateTrafficZone
    Activates a traffic zone and starts spawning vehicles
    
    Description:
        Called when players enter a traffic zone trigger.
        Starts a spawn loop that creates civilian vehicles up to the max limit.
    
    Parameters:
        _zoneIndex - NUMBER - Index of the zone in RECONDO_CIVTRAFFIC_ZONES
    
    Returns:
        Nothing
    
    Example:
        [0] call Recondo_fnc_activateTrafficZone;
*/

params [["_zoneIndex", -1, [0]]];

if (_zoneIndex < 0 || _zoneIndex >= count RECONDO_CIVTRAFFIC_ZONES) exitWith {
    diag_log format ["[RECONDO_CIVTRAFFIC] ERROR: activateTrafficZone - Invalid zone index: %1", _zoneIndex];
};

private _zoneData = RECONDO_CIVTRAFFIC_ZONES select _zoneIndex;
private _markerId = _zoneData get "markerId";
private _isActive = _zoneData get "active";

// Don't activate if already active
if (_isActive) exitWith {};

private _settings = RECONDO_CIVTRAFFIC_SETTINGS;
private _debugLogging = _settings get "debugLogging";
private _maxVehicles = _settings get "maxVehicles";
private _spawnDelay = _settings get "spawnDelay";

// Mark zone as active
_zoneData set ["active", true];

if (_debugLogging) then {
    diag_log format ["[RECONDO_CIVTRAFFIC] Zone activated: %1", _markerId];
};

// Start spawn loop using CBA per-frame handler
private _spawnHandle = [{
    params ["_args", "_handle"];
    _args params ["_zoneIndex"];
    
    // Get zone data
    if (_zoneIndex >= count RECONDO_CIVTRAFFIC_ZONES) exitWith {
        [_handle] call CBA_fnc_removePerFrameHandler;
    };
    
    private _zoneData = RECONDO_CIVTRAFFIC_ZONES select _zoneIndex;
    private _isActive = _zoneData get "active";
    
    // Stop if zone deactivated
    if (!_isActive) exitWith {
        [_handle] call CBA_fnc_removePerFrameHandler;
    };
    
    private _settings = RECONDO_CIVTRAFFIC_SETTINGS;
    private _maxVehicles = _settings get "maxVehicles";
    private _debugLogging = _settings get "debugLogging";
    
    // Get current vehicle count for this zone
    private _vehicles = _zoneData get "vehicles";
    private _aliveVehicles = _vehicles select { !isNull _x && { alive _x } };
    
    // Update vehicle list (remove dead/null)
    _zoneData set ["vehicles", _aliveVehicles];
    
    // Spawn if under limit
    if (count _aliveVehicles < _maxVehicles) then {
        private _vehicle = [_zoneIndex] call Recondo_fnc_spawnTrafficVehicle;
        
        if (!isNull _vehicle) then {
            _aliveVehicles pushBack _vehicle;
            _zoneData set ["vehicles", _aliveVehicles];
            
            if (_debugLogging) then {
                private _markerId = _zoneData get "markerId";
                diag_log format ["[RECONDO_CIVTRAFFIC] Spawned vehicle in zone %1. Total: %2/%3", 
                    _markerId, count _aliveVehicles, _maxVehicles];
            };
        };
    };
}, _spawnDelay, [_zoneIndex]] call CBA_fnc_addPerFrameHandler;

// Store handle for cleanup
_zoneData set ["spawnHandle", _spawnHandle];
