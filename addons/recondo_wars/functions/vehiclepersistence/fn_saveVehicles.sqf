/*
    Recondo_fnc_saveVehicles
    Save synced vehicle positions to persistence

    Description:
        Saves position, direction, and destroyed state for all
        vehicles registered through the Vehicle Persistence module.
*/

if (!isServer) exitWith {};
if (count RECONDO_VEHICLE_PERSISTENCE_UNITS == 0) exitWith {};

private _debug = RECONDO_VEHICLE_PERSISTENCE_DEBUG;
private _saveData = [];

{
    private _vehicle = _x;

    if (isNull _vehicle) then { continue };

    private _vehicleID = _vehicle getVariable ["RECONDO_VehicleID", ""];
    if (_vehicleID == "") then { continue };

    private _entry = createHashMapFromArray [
        ["id", _vehicleID],
        ["type", typeOf _vehicle],
        ["destroyed", !alive _vehicle]
    ];

    if (alive _vehicle) then {
        _entry set ["pos", getPos _vehicle];
        _entry set ["dir", getDir _vehicle];
    };

    _saveData pushBack _entry;
} forEach RECONDO_VEHICLE_PERSISTENCE_UNITS;

["VEHICLE_PERSIST_DATA", _saveData] call Recondo_fnc_setSaveData;

if (_debug) then {
    diag_log format ["[RECONDO_VEHPERSIST] Saved %1 vehicles", count _saveData];
};
