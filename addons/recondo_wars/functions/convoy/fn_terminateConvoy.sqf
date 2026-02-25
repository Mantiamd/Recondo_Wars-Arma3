/*
    Recondo_fnc_terminateConvoy
    Gracefully terminates a convoy
    
    Description:
        Sets the terminate flag on a convoy, which causes all
        behavior loops to exit. Then cleans up vehicles and crew.
    
    Parameters:
        0: OBJECT - Leader vehicle of the convoy
        
    Returns:
        Nothing
*/

params [["_leaderVeh", objNull, [objNull]]];

if (isNull _leaderVeh) exitWith {
    diag_log "[RECONDO_CONVOY] terminateConvoy: Invalid leader vehicle";
};

// Check if already terminated
if (_leaderVeh getVariable ["RECONDO_CONVOY_Terminate", false]) exitWith {
    // Already terminated
};

private _settings = _leaderVeh getVariable ["RECONDO_CONVOY_Settings", nil];
private _debugLogging = if (!isNil "_settings") then { _settings get "debugLogging" } else { false };

if (_debugLogging) then {
    diag_log format ["[RECONDO_CONVOY] Terminating convoy with leader %1", typeOf _leaderVeh];
};

// Set terminate flag (this will cause all behavior loops to exit)
_leaderVeh setVariable ["RECONDO_CONVOY_Terminate", true, true];

// Wait a moment for loops to exit
sleep 0.5;

// Get vehicles
private _vehicles = _leaderVeh getVariable ["RECONDO_CONVOY_Vehicles", []];
private _group = _leaderVeh getVariable ["RECONDO_CONVOY_Group", grpNull];

// Clean up debug markers
private _debugMkr = _leaderVeh getVariable ["RECONDO_CONVOY_DebugMarker", ""];
if (_debugMkr != "") then {
    deleteMarker _debugMkr;
};

// Clean up path debug objects
private _drawObjects = _leaderVeh getVariable ["RECONDO_CONVOY_DrawObjects", []];
{
    { deleteVehicle _x } forEach _x;
} forEach _drawObjects;

// Delete vehicles and crew
{
    if (!isNull _x) then {
        // Delete crew first
        {
            deleteVehicle _x;
        } forEach (crew _x);
        
        // Delete vehicle
        deleteVehicle _x;
    };
} forEach _vehicles;

// Delete group
if (!isNull _group) then {
    deleteGroup _group;
};

if (_debugLogging) then {
    diag_log "[RECONDO_CONVOY] Convoy terminated and cleaned up";
};
