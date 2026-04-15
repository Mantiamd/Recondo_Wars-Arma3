/*
    Recondo_fnc_moduleAddAICrew
    Main module initialization - runs on server, adds ACE actions on all clients
    
    Description:
        Called when the Add AI Crew module is activated.
        Adds ACE self-interaction options to all synced vehicles
        allowing players to request/remove AI crew.
    
    Parameters:
        0: OBJECT - Logic module
        1: ARRAY - Synced units/vehicles
        2: BOOL - Is activated
        
    Returns:
        Nothing
*/

params ["_logic", "_units", "_activated"];

// Only run on server to prevent duplicate execution
if (!isServer) exitWith {};

// Get all module settings
private _settings = createHashMap;

// General Settings
_settings set ["crewSide", _logic getVariable ["crewside", -1]];

// Unit Settings
private _gunnerClassnamesStr = _logic getVariable ["gunnerclassnames", ""];
private _gunnerClassnames = [_gunnerClassnamesStr] call Recondo_fnc_parseClassnames;
_settings set ["gunnerClassnames", _gunnerClassnames];
_settings set ["maxCrewCount", _logic getVariable ["maxcrewcount", 0]];

// Skill Settings
_settings set ["skill_aimingAccuracy", _logic getVariable ["skill_aimingaccuracy", 0.5]];
_settings set ["skill_aimingShake", _logic getVariable ["skill_aimingshake", 0.3]];
_settings set ["skill_aimingSpeed", _logic getVariable ["skill_aimingspeed", 0.5]];
_settings set ["skill_spotDistance", _logic getVariable ["skill_spotdistance", 0.6]];
_settings set ["skill_spotTime", _logic getVariable ["skill_spottime", 0.5]];
_settings set ["skill_courage", _logic getVariable ["skill_courage", 1.0]];

// Behavior Settings
_settings set ["deletionDistance", _logic getVariable ["deletiondistance", 30]];
_settings set ["monitorInterval", _logic getVariable ["monitorinterval", 5]];
_settings set ["lockPositions", _logic getVariable ["lockpositions", true]];

// Condition Settings
_settings set ["requireLanded", _logic getVariable ["requirelanded", true]];
_settings set ["requireEngineOff", _logic getVariable ["requireengineoff", true]];

// Debug
_settings set ["enableDebug", _logic getVariable ["enabledebug", false]];
if (RECONDO_MASTER_DEBUG) then { _settings set ["enableDebug", true]; };

private _debug = _settings get "enableDebug";

// Get synced vehicles
private _syncedVehicles = synchronizedObjects _logic;
_syncedVehicles = _syncedVehicles select { _x isKindOf "AllVehicles" && !(_x isKindOf "Man") };

if (count _syncedVehicles == 0) exitWith {
    diag_log "[RECONDO_AIC] WARNING: No vehicles synced to module. Module disabled.";
};

if (_debug) then {
    diag_log format ["[RECONDO_AIC] Module initialized with %1 synced vehicles", count _syncedVehicles];
    diag_log format ["[RECONDO_AIC] Crew side setting: %1", _settings get "crewSide"];
    diag_log format ["[RECONDO_AIC] Gunner classnames: %1", _settings get "gunnerClassnames"];
    diag_log format ["[RECONDO_AIC] Deletion distance: %1m, Monitor interval: %2s", _settings get "deletionDistance", _settings get "monitorInterval"];
};

// Store settings globally for use by other functions
RECONDO_AIC_SETTINGS = _settings;
publicVariable "RECONDO_AIC_SETTINGS";

// Process each synced vehicle
{
    private _vehicle = _x;
    
    // Store settings on vehicle for access by action functions
    _vehicle setVariable ["RECONDO_AIC_Settings", _settings, true];
    _vehicle setVariable ["RECONDO_AIC_HasCrew", false, true];
    _vehicle setVariable ["RECONDO_AIC_Enabled", true, true];
    
    // Add ACE actions to all clients
    [_vehicle, _settings] remoteExec ["Recondo_fnc_monitorCrew", 0, true]; // JIP compatible
    
    // Add vehicle destroyed event handler on server
    if (isServer) then {
        _vehicle addEventHandler ["Killed", {
            params ["_vehicle"];
            
            // Clean up crew if vehicle is destroyed
            if (_vehicle getVariable ["RECONDO_AIC_HasCrew", false]) then {
                private _crew = _vehicle getVariable ["RECONDO_AIC_Crew", []];
                {
                    if (!isNull _x && {alive _x}) then {
                        deleteVehicle _x;
                    };
                } forEach _crew;
                
                // Stop monitoring
                private _monitorHandle = _vehicle getVariable ["RECONDO_AIC_MonitorHandle", -1];
                if (_monitorHandle != -1) then {
                    [_monitorHandle] call CBA_fnc_removePerFrameHandler;
                };
                
                // Clear variables
                _vehicle setVariable ["RECONDO_AIC_HasCrew", false, true];
                _vehicle setVariable ["RECONDO_AIC_Crew", nil, true];
                _vehicle setVariable ["RECONDO_AIC_MonitorHandle", nil, true];
                
                if (!isNil "RECONDO_AIC_SETTINGS") then {
                    if (RECONDO_AIC_SETTINGS get "enableDebug") then {
                        diag_log format ["[RECONDO_AIC] Vehicle destroyed, crew cleaned up: %1", _vehicle];
                    };
                };
            };
        }];
    };
    
    if (_debug) then {
        diag_log format ["[RECONDO_AIC] Enabled crew management for vehicle: %1", typeOf _vehicle];
    };
} forEach _syncedVehicles;

// Track enabled vehicles
RECONDO_AIC_VEHICLES = _syncedVehicles;
publicVariable "RECONDO_AIC_VEHICLES";

diag_log format ["[RECONDO_AIC] Initialized. Enabled crew management on %1 vehicles.", count _syncedVehicles];
