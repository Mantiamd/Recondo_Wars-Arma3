/*
    Recondo_fnc_requestCrew
    Creates AI crew for a vehicle
    
    Description:
        Called when a player requests crew via ACE interaction.
        Creates AI units for all turret positions using configured
        classnames and side. Sets up monitoring for crew distance.
    
    Parameters:
        0: OBJECT - Target vehicle
        1: OBJECT - Player who requested
        
    Returns:
        BOOL - True if crew creation was initiated
        
    Example:
        [_vehicle, player] call Recondo_fnc_requestCrew;
*/

params ["_vehicle", "_caller"];

// Only execute on server
if (!isServer) exitWith {
    [_vehicle, _caller] remoteExec ["Recondo_fnc_requestCrew", 2];
    true
};

// Check if vehicle already has crew
if (_vehicle getVariable ["RECONDO_AIC_HasCrew", false]) exitWith {
    diag_log format ["[RECONDO_AIC] Vehicle %1 already has crew", _vehicle];
    false
};

// Mark as processing to prevent duplicate requests
if (_vehicle getVariable ["RECONDO_AIC_Processing", false]) exitWith {
    diag_log "[RECONDO_AIC] Crew request already in progress";
    false
};
_vehicle setVariable ["RECONDO_AIC_Processing", true, true];

// Get settings from vehicle
private _settings = _vehicle getVariable ["RECONDO_AIC_Settings", RECONDO_AIC_SETTINGS];
if (isNil "_settings") exitWith {
    diag_log "[RECONDO_AIC] ERROR: No settings found for vehicle";
    _vehicle setVariable ["RECONDO_AIC_Processing", false, true];
    false
};

private _debug = _settings get "enableDebug";
private _crewSideSetting = _settings get "crewSide";
private _gunnerClassnames = _settings get "gunnerClassnames";
private _lockPositions = _settings get "lockPositions";
private _deletionDistance = _settings get "deletionDistance";
private _monitorInterval = _settings get "monitorInterval";

// Determine crew side
private _crewSide = west; // Default
if (_crewSideSetting == -1) then {
    // Same as driver - get caller's side
    _crewSide = side group _caller;
} else {
    private _sideMap = [east, west, independent, civilian];
    _crewSide = _sideMap select _crewSideSetting;
};

if (_debug) then {
    diag_log format ["[RECONDO_AIC] Creating crew for %1, side: %2", typeOf _vehicle, _crewSide];
};

// Get all turret positions (excluding driver)
private _turrets = allTurrets [_vehicle, false]; // false = exclude cargo turrets
private _allTurrets = allTurrets [_vehicle, true]; // true = include all

// Determine default unit classname based on side if none specified
private _defaultClassnames = switch (_crewSide) do {
    case east: { ["O_Soldier_F"] };
    case west: { ["B_Soldier_F"] };
    case independent: { ["I_Soldier_F"] };
    case civilian: { ["C_man_1"] };
    default { ["B_Soldier_F"] };
};

private _classnamesToUse = if (count _gunnerClassnames > 0) then {
    _gunnerClassnames
} else {
    _defaultClassnames
};

// Create group for crew
private _group = createGroup [_crewSide, true];
private _unitsToProcess = [];

// Get max crew count (0 = unlimited)
private _maxCrewCount = _settings getOrDefault ["maxCrewCount", 0];
private _unitsCreated = 0;

// Create units and move them into turrets
{
    private _turretPath = _x;
    
    // Check if we've hit the crew limit (0 = no limit)
    if (_maxCrewCount > 0 && {_unitsCreated >= _maxCrewCount}) exitWith {
        if (_debug) then {
            diag_log format ["[RECONDO_AIC] Reached max crew count of %1", _maxCrewCount];
        };
    };
    
    // Check if turret position is empty
    private _currentGunner = _vehicle turretUnit _turretPath;
    if (isNull _currentGunner) then {
        // Unlock turret first to ensure unit can enter
        _vehicle lockTurret [_turretPath, false];
        
        // Select random classname
        private _classname = selectRandom _classnamesToUse;
        
        // Create unit at vehicle position
        private _unit = _group createUnit [_classname, getPos _vehicle, [], 0, "NONE"];
        
        if (!isNull _unit) then {
            // Move into turret - don't verify immediately, will check after delay
            _unit moveInTurret [_vehicle, _turretPath];
            
            // Store for later verification
            _unitsToProcess pushBack [_unit, _turretPath, _classname];
            _unitsCreated = _unitsCreated + 1;
            
            if (_debug) then {
                diag_log format ["[RECONDO_AIC] Created %1, attempting turret %2", _classname, _turretPath];
            };
        };
    };
} forEach _turrets;

// If no units created, clean up and exit
if (count _unitsToProcess == 0) then {
    deleteGroup _group;
    _vehicle setVariable ["RECONDO_AIC_Processing", false, true];
    diag_log "[RECONDO_AIC] No turret positions available";
} else {
    // Wait for units to settle into turrets, then verify
    [{
        params ["_vehicle", "_group", "_unitsToProcess", "_settings", "_allTurrets", "_caller"];
        
        private _debug = _settings get "enableDebug";
        private _lockPositions = _settings get "lockPositions";
        private _deletionDistance = _settings get "deletionDistance";
        private _monitorInterval = _settings get "monitorInterval";
        
        private _createdCrew = [];
        
        // Verify each unit
        {
            _x params ["_unit", "_turretPath", "_classname"];
            
            if (!isNull _unit && alive _unit) then {
                // Check if unit is in the vehicle (any position)
                if (vehicle _unit == _vehicle) then {
                    // Success - apply skills
                    _unit setSkill ["aimingAccuracy", _settings get "skill_aimingAccuracy"];
                    _unit setSkill ["aimingShake", _settings get "skill_aimingShake"];
                    _unit setSkill ["aimingSpeed", _settings get "skill_aimingSpeed"];
                    _unit setSkill ["spotDistance", _settings get "skill_spotDistance"];
                    _unit setSkill ["spotTime", _settings get "skill_spotTime"];
                    _unit setSkill ["courage", _settings get "skill_courage"];
                    _unit setSkill ["commanding", 1];
                    _unit setSkill ["general", 0.5];
                    
                    // Mark as AI crew
                    _unit setVariable ["RECONDO_AIC_CrewMember", true, true];
                    _unit setVariable ["RECONDO_AIC_Vehicle", _vehicle, true];
                    
                    _createdCrew pushBack _unit;
                    
                    if (_debug) then {
                        diag_log format ["[RECONDO_AIC] Verified %1 in vehicle", _classname];
                    };
                } else {
                    // Failed to enter - clean up
                    deleteVehicle _unit;
                    if (_debug) then {
                        diag_log format ["[RECONDO_AIC] Unit %1 failed to enter turret %2, deleted", _classname, _turretPath];
                    };
                };
            };
        } forEach _unitsToProcess;
        
        // Check if any crew was successfully created
        if (count _createdCrew == 0) then {
            deleteGroup _group;
            _vehicle setVariable ["RECONDO_AIC_Processing", false, true];
            diag_log "[RECONDO_AIC] No crew successfully entered vehicle";
            ["No crew positions available"] remoteExec ["hint", _caller];
        } else {
            // Lock positions if enabled
            if (_lockPositions) then {
                _vehicle lockCargo true;
                {
                    _vehicle lockTurret [_x, true];
                } forEach _allTurrets;
                
                // Unlock turrets that have our crew in them
                {
                    private _turretPath = _vehicle unitTurret _x;
                    if (count _turretPath > 0) then {
                        _vehicle lockTurret [_turretPath, false];
                    };
                } forEach _createdCrew;
            };
            
            // Store crew data on vehicle - broadcast to all clients
            _vehicle setVariable ["RECONDO_AIC_HasCrew", true, true];
            _vehicle setVariable ["RECONDO_AIC_Crew", _createdCrew, true];
            _vehicle setVariable ["RECONDO_AIC_CrewOwner", _caller, true];
            _vehicle setVariable ["RECONDO_AIC_CrewGroup", _group, true];
            _vehicle setVariable ["RECONDO_AIC_Processing", false, true];
            
            if (_debug) then {
                diag_log format ["[RECONDO_AIC] Successfully created %1 crew members, HasCrew set to true", count _createdCrew];
            };
            
            // Start monitoring on server
            private _monitorHandle = [{
                params ["_args", "_handle"];
                _args params ["_vehicle", "_deletionDistance", "_debug"];
                
                // Check if vehicle still exists and has crew
                if (isNull _vehicle || !(_vehicle getVariable ["RECONDO_AIC_HasCrew", false])) exitWith {
                    [_handle] call CBA_fnc_removePerFrameHandler;
                    if (_debug && !isNull _vehicle) then {
                        diag_log format ["[RECONDO_AIC] Monitoring stopped for %1", _vehicle];
                    };
                };
                
                private _crew = _vehicle getVariable ["RECONDO_AIC_Crew", []];
                private _crewChanged = false;
                
                // Check each crew member
                {
                    private _unit = _x;
                    private _shouldDelete = false;
                    
                    if (isNull _unit || !alive _unit) then {
                        _shouldDelete = true;
                    } else {
                        // Check if unit is outside vehicle and too far away
                        if (vehicle _unit != _vehicle) then {
                            if (_deletionDistance > 0 && {_unit distance _vehicle > _deletionDistance}) then {
                                _shouldDelete = true;
                                if (_debug) then {
                                    diag_log format ["[RECONDO_AIC] Crew member too far (%1m), deleting", round (_unit distance _vehicle)];
                                };
                            };
                        };
                    };
                    
                    if (_shouldDelete && !isNull _unit) then {
                        deleteVehicle _unit;
                        _crewChanged = true;
                    };
                } forEach _crew;
                
                // Update crew array if changed
                if (_crewChanged) then {
                    private _remainingCrew = _crew select { !isNull _x && alive _x };
                    _vehicle setVariable ["RECONDO_AIC_Crew", _remainingCrew, true];
                    
                    if (count _remainingCrew == 0) then {
                        _vehicle setVariable ["RECONDO_AIC_HasCrew", false, true];
                        
                        _vehicle lockCargo false;
                        {
                            _vehicle lockTurret [_x, false];
                        } forEach (allTurrets [_vehicle, true]);
                        
                        if (_debug) then {
                            diag_log format ["[RECONDO_AIC] All crew gone, HasCrew set to false"];
                        };
                    };
                };
            }, _monitorInterval, [_vehicle, _deletionDistance, _debug]] call CBA_fnc_addPerFrameHandler;
            
            _vehicle setVariable ["RECONDO_AIC_MonitorHandle", _monitorHandle, false];
            
            // Notify player
            private _message = format ["AI Crew assigned: %1 gunners", count _createdCrew];
            [_message] remoteExec ["hint", _caller];
        };
    }, [_vehicle, _group, _unitsToProcess, _settings, _allTurrets, _caller], 1] call CBA_fnc_waitAndExecute;
};

true
