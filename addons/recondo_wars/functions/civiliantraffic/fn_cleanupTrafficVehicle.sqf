/*
    Recondo_fnc_cleanupTrafficVehicle
    Cleans up a civilian traffic vehicle and its driver
    
    Description:
        Deletes a civilian traffic vehicle and its associated driver.
        Removes all references from tracking arrays.
    
    Parameters:
        _vehicle - OBJECT - The vehicle to clean up
    
    Returns:
        Nothing
    
    Example:
        [_vehicle] call Recondo_fnc_cleanupTrafficVehicle;
*/

params [["_vehicle", objNull, [objNull]]];

if (isNull _vehicle) exitWith {};

private _settings = RECONDO_CIVTRAFFIC_SETTINGS;
private _debugLogging = if (isNil "_settings") then { false } else { _settings getOrDefault ["debugLogging", false] };

// Get civilian driver
private _civilian = _vehicle getVariable ["RECONDO_CIVTRAFFIC_Civilian", objNull];
private _group = if (!isNull _civilian) then { group _civilian } else { grpNull };

// Remove from global tracking
RECONDO_CIVTRAFFIC_ACTIVE_VEHICLES = RECONDO_CIVTRAFFIC_ACTIVE_VEHICLES - [_vehicle];

// Remove from zone tracking
private _zoneIndex = _vehicle getVariable ["RECONDO_CIVTRAFFIC_ZoneIndex", -1];
if (_zoneIndex >= 0 && _zoneIndex < count RECONDO_CIVTRAFFIC_ZONES) then {
    private _zoneData = RECONDO_CIVTRAFFIC_ZONES select _zoneIndex;
    private _vehicles = _zoneData get "vehicles";
    _zoneData set ["vehicles", _vehicles - [_vehicle]];
};

// Delete civilian
if (!isNull _civilian) then {
    deleteVehicle _civilian;
};

// Delete group
if (!isNull _group && {count units _group == 0}) then {
    deleteGroup _group;
};

// Delete vehicle
deleteVehicle _vehicle;

if (_debugLogging) then {
    diag_log format ["[RECONDO_CIVTRAFFIC] Cleaned up vehicle and civilian"];
};
