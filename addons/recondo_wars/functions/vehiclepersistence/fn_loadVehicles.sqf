/*
    Recondo_fnc_loadVehicles
    Load vehicle data from persistence and apply

    Description:
        Restores vehicle positions from saved data.
        Destroyed vehicles are deleted from the mission.
        Waits for Vehicle Persistence module to register vehicles.
*/

if (!isServer) exitWith {};

private _savedData = ["VEHICLE_PERSIST_DATA", []] call Recondo_fnc_getSaveData;

if (count _savedData == 0) exitWith {
    diag_log "[RECONDO_VEHPERSIST] No saved vehicle data found.";
};

private _debug = RECONDO_VEHICLE_PERSISTENCE_DEBUG;

[{
    count RECONDO_VEHICLE_PERSISTENCE_UNITS > 0 || time > 30
}, {
    params ["_savedData", "_debug"];

    {
        private _savedEntry = _x;
        private _savedID = _savedEntry get "id";
        private _wasDestroyed = _savedEntry getOrDefault ["destroyed", false];

        private _vehicle = objNull;
        {
            if (_x getVariable ["RECONDO_VehicleID", ""] == _savedID) exitWith {
                _vehicle = _x;
            };
        } forEach RECONDO_VEHICLE_PERSISTENCE_UNITS;

        if (isNull _vehicle) then {
            if (_debug) then {
                diag_log format ["[RECONDO_VEHPERSIST] Vehicle '%1' not found, skipping.", _savedID];
            };
            continue;
        };

        if (_wasDestroyed) then {
            deleteVehicle _vehicle;
            RECONDO_VEHICLE_PERSISTENCE_UNITS = RECONDO_VEHICLE_PERSISTENCE_UNITS - [_vehicle];

            if (_debug) then {
                diag_log format ["[RECONDO_VEHPERSIST] Vehicle '%1' (%2) was destroyed last session, removed.", _savedID, _savedEntry get "type"];
            };
            continue;
        };

        private _savedPos = _savedEntry getOrDefault ["pos", []];
        private _savedDir = _savedEntry getOrDefault ["dir", 0];

        if (count _savedPos >= 2) then {
            _vehicle setPos _savedPos;
            _vehicle setDir _savedDir;

            if (_debug) then {
                diag_log format ["[RECONDO_VEHPERSIST] Restored '%1' (%2) to pos %3", _savedID, typeOf _vehicle, _savedPos];
            };
        };
    } forEach _savedData;

    diag_log format ["[RECONDO_VEHPERSIST] Vehicle data load complete. %1 entries.", count _savedData];

}, [_savedData, _debug], 30] call CBA_fnc_waitUntilAndExecute;
