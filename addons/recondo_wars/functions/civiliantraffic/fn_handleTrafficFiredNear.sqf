/*
    Recondo_fnc_handleTrafficFiredNear
    Handles civilian reacting to nearby gunfire
    
    Description:
        Called when shots are fired near a civilian traffic driver.
        Makes the civilian stop the vehicle and cower in fear.
        After a delay, they may resume driving if the danger has passed.
    
    Parameters:
        _civilian - OBJECT - The civilian driver
    
    Returns:
        Nothing
    
    Example:
        [_civilian] call Recondo_fnc_handleTrafficFiredNear;
*/

params ["_civilian"];

if (isNull _civilian || !alive _civilian) exitWith {};

// Check if already cowering
if (_civilian getVariable ["RECONDO_CIVTRAFFIC_Cowering", false]) exitWith {};

private _settings = RECONDO_CIVTRAFFIC_SETTINGS;
private _debugLogging = _settings get "debugLogging";

private _vehicle = _civilian getVariable ["RECONDO_CIVTRAFFIC_Vehicle", objNull];

if (isNull _vehicle) exitWith {};

// Mark as cowering
_civilian setVariable ["RECONDO_CIVTRAFFIC_Cowering", true, false];

if (_debugLogging) then {
    diag_log format ["[RECONDO_CIVTRAFFIC] Civilian %1 cowering due to gunfire", _civilian];
};

// Stop the vehicle and cower
[_civilian, _vehicle] spawn {
    params ["_civilian", "_vehicle"];
    
    if (isNull _civilian || !alive _civilian) exitWith {};
    
    // Stop movement
    private _group = group _civilian;
    
    // Clear waypoints to stop
    while {count waypoints _group > 0} do {
        deleteWaypoint [_group, 0];
    };
    
    // Make civilian stay in vehicle but stop
    _civilian doMove (getPos _vehicle);
    
    // Wait for situation to calm down
    private _cowerDuration = 15 + random 30;
    sleep _cowerDuration;
    
    if (isNull _civilian || !alive _civilian) exitWith {};
    
    // Check if still in danger (any shots in last few seconds)
    // For now, just resume after delay
    
    // Resume driving
    _civilian setVariable ["RECONDO_CIVTRAFFIC_Cowering", false, false];
    
    private _settings = RECONDO_CIVTRAFFIC_SETTINGS;
    if (_settings get "debugLogging") then {
        diag_log format ["[RECONDO_CIVTRAFFIC] Civilian %1 resuming after cowering", _civilian];
    };
};
