/*
    Recondo_fnc_filterAirTargets
    Makes tracker groups forget about aircraft/helicopter targets and excluded units
    
    Description:
        Iterates through all units in a tracker group and makes them forget
        about targets that meet exclusion criteria:
        - Units in vehicles that are aircraft (isKindOf "Air")
        - Units in vehicles matching excluded vehicle classnames
        - Units matching excluded unit classnames
        - Units in vehicles above the height threshold
        
        Should be called periodically from tracker behavior loops.
    
    Parameters:
        _group - Group to filter targets for
        _settings - HashMap containing filter settings:
            - ignoreHeight: Height threshold (units in vehicles above this are forgotten)
            - ignoreUnitClassnames: Array of unit classnames to ignore
            - ignoreVehicleClassnames: Array of vehicle classnames to ignore
    
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params ["_group", "_settings"];

if (isNull _group) exitWith {};

// Get filter settings
private _ignoreHeight = _settings getOrDefault ["ignoreHeight", 60];
private _ignoreUnitClassnames = _settings getOrDefault ["ignoreUnitClassnames", []];
private _ignoreVehicleClassnames = _settings getOrDefault ["ignoreVehicleClassnames", []];

// Convert classname arrays to uppercase for case-insensitive comparison
private _ignoreUnitsUpper = _ignoreUnitClassnames apply { toUpper _x };
private _ignoreVehiclesUpper = _ignoreVehicleClassnames apply { toUpper _x };

{
    private _unit = _x;
    if (!alive _unit) then { continue };
    
    // Get all enemies this unit knows about within 500m
    private _knownTargets = _unit targets [true, 500];
    
    {
        private _target = _x;
        if (!alive _target) then { continue };
        
        private _shouldForget = false;
        private _vehicle = vehicle _target;
        private _isInVehicle = _vehicle != _target;
        
        // Check 1: Target is in an aircraft (automatic for all Air vehicles)
        if (_isInVehicle && {_vehicle isKindOf "Air"}) then {
            _shouldForget = true;
        };
        
        // Check 2: Target is in a vehicle above height threshold
        if (!_shouldForget && _isInVehicle) then {
            private _vehicleHeight = (getPosATL _vehicle) select 2;
            if (_vehicleHeight > _ignoreHeight) then {
                _shouldForget = true;
            };
        };
        
        // Check 3: Target's vehicle is in excluded vehicle classnames
        if (!_shouldForget && _isInVehicle && count _ignoreVehiclesUpper > 0) then {
            private _vehicleClass = toUpper (typeOf _vehicle);
            if (_vehicleClass in _ignoreVehiclesUpper) then {
                _shouldForget = true;
            };
        };
        
        // Check 4: Target unit classname is in excluded list
        if (!_shouldForget && count _ignoreUnitsUpper > 0) then {
            private _targetClass = toUpper (typeOf _target);
            if (_targetClass in _ignoreUnitsUpper) then {
                _shouldForget = true;
            };
        };
        
        // Make unit forget this target
        if (_shouldForget) then {
            _unit forgetTarget _target;
        };
    } forEach _knownTargets;
} forEach (units _group);
