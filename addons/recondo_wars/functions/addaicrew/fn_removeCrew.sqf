/*
    Recondo_fnc_removeCrew
    Removes AI crew from a vehicle
    
    Description:
        Called when a player removes crew via ACE interaction.
        Deletes all AI crew members, stops monitoring, and
        unlocks vehicle positions.
    
    Parameters:
        0: OBJECT - Target vehicle
        1: OBJECT - Player who requested removal
        
    Returns:
        BOOL - True if crew was removed successfully
        
    Example:
        [_vehicle, player] call Recondo_fnc_removeCrew;
*/

params ["_vehicle", "_caller"];

// Only execute on server
if (!isServer) exitWith {
    [_vehicle, _caller] remoteExec ["Recondo_fnc_removeCrew", 2];
    true
};

// Check if vehicle has crew
if !(_vehicle getVariable ["RECONDO_AIC_HasCrew", false]) exitWith {
    diag_log format ["[RECONDO_AIC] Vehicle %1 has no crew to remove", _vehicle];
    false
};

// Get settings
private _settings = _vehicle getVariable ["RECONDO_AIC_Settings", RECONDO_AIC_SETTINGS];
private _debug = false;
if (!isNil "_settings") then {
    _debug = _settings get "enableDebug";
};

if (_debug) then {
    diag_log format ["[RECONDO_AIC] Removing crew from %1", typeOf _vehicle];
};

// Stop monitoring first
private _monitorHandle = _vehicle getVariable ["RECONDO_AIC_MonitorHandle", -1];
if (_monitorHandle != -1) then {
    [_monitorHandle] call CBA_fnc_removePerFrameHandler;
    if (_debug) then {
        diag_log "[RECONDO_AIC] Monitoring stopped";
    };
};

// Get and delete crew
private _crew = _vehicle getVariable ["RECONDO_AIC_Crew", []];
private _deletedCount = 0;

{
    if (!isNull _x) then {
        if (alive _x) then {
            deleteVehicle _x;
            _deletedCount = _deletedCount + 1;
        };
    };
} forEach _crew;

// Delete the crew group if empty
private _group = _vehicle getVariable ["RECONDO_AIC_CrewGroup", grpNull];
if (!isNull _group && {count units _group == 0}) then {
    deleteGroup _group;
};

// Unlock all positions
_vehicle lockCargo false;
{
    _vehicle lockTurret [_x, false];
} forEach (allTurrets [_vehicle, true]);

// Clear all variables
_vehicle setVariable ["RECONDO_AIC_Crew", nil, true];
_vehicle setVariable ["RECONDO_AIC_HasCrew", false, true];
_vehicle setVariable ["RECONDO_AIC_CrewOwner", nil, true];
_vehicle setVariable ["RECONDO_AIC_CrewGroup", nil, true];
_vehicle setVariable ["RECONDO_AIC_MonitorHandle", nil, false];

if (_debug) then {
    diag_log format ["[RECONDO_AIC] Removed %1 crew members from %2", _deletedCount, typeOf _vehicle];
};

// Notify player
private _message = format ["AI Crew dismissed: %1 removed", _deletedCount];
[_message] remoteExec ["hint", _caller];

true
