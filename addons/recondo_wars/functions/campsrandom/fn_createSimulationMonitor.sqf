/*
    Recondo_fnc_createSimulationMonitor
    Creates a periodic check for camp simulation management
    
    Description:
        Monitors player proximity to camp locations and enables/disables
        simulation on objects and AI based on distance. When players leave
        and AI have not been alerted, they return to sitting positions.
    
    Parameters:
        _settings - HASHMAP - Module settings
        _markerId - STRING - Marker ID for the camp
    
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [
    ["_settings", nil, [createHashMap]],
    ["_markerId", "", [""]]
];

if (isNil "_settings" || _markerId == "") exitWith {
    diag_log format ["[RECONDO_CAMPS] ERROR: Invalid parameters for createSimulationMonitor - marker: %1", _markerId];
};

private _simulationDistance = _settings get "simulationDistance";
private _debugLogging = _settings get "debugLogging";
private _sentryAnimations = _settings get "sentryAnimations";

private _markerPos = getMarkerPos _markerId;

// Initialize simulation state
private _simStateVar = format ["RECONDO_CAMPS_%1_simEnabled", _markerId];
missionNamespace setVariable [_simStateVar, false];

if (_debugLogging) then {
    diag_log format ["[RECONDO_CAMPS] Creating simulation monitor for %1, distance: %2m", _markerId, _simulationDistance];
};

// Create per-frame handler for monitoring
[{
    params ["_args", "_handle"];
    _args params ["_markerId", "_simDistance", "_markerPos", "_debug", "_sittingAnims"];
    
    // Get camp data
    private _objectsVar = format ["RECONDO_CAMPS_%1_objects", _markerId];
    private _unitsVar = format ["RECONDO_CAMPS_%1_units", _markerId];
    private _simStateVar = format ["RECONDO_CAMPS_%1_simEnabled", _markerId];
    
    private _objects = missionNamespace getVariable [_objectsVar, []];
    private _units = missionNamespace getVariable [_unitsVar, []];
    private _simEnabled = missionNamespace getVariable [_simStateVar, false];
    
    // Clean up null references
    _objects = _objects select { !isNull _x };
    _units = _units select { !isNull _x && alive _x };
    
    // If no objects and no units, remove the handler
    if (count _objects == 0 && count _units == 0) exitWith {
        [_handle] call CBA_fnc_removePerFrameHandler;
        if (_debug) then {
            diag_log format ["[RECONDO_CAMPS] Simulation monitor removed for %1 - no objects/units remaining", _markerId];
        };
    };
    
    // Check for players in range
    private _playersInRange = allPlayers findIf { (alive _x) && (_x distance _markerPos < _simDistance) } != -1;
    
    // Enable simulation when players approach
    if (_playersInRange && !_simEnabled) then {
        // Enable simulation on objects
        {
            _x enableSimulationGlobal true;
        } forEach _objects;
        
        // Enable simulation on units and re-apply sitting state
        {
            _x enableSimulationGlobal true;
            
            // If unit is still marked as sitting, re-apply the animation and AI locks
            if (_x getVariable ["RECONDO_CAMPS_sitting", false]) then {
                // Keep AI disabled for sitting
                _x disableAI "MOVE";
                _x disableAI "PATH";
                _x disableAI "ANIM";
                
                // Re-apply sitting animation
                private _storedAnim = _x getVariable ["RECONDO_CAMPS_sittingAnim", ""];
                if (_storedAnim != "") then {
                    [_x, _storedAnim] remoteExec ["switchMove", 0, true];
                };
            };
        } forEach _units;
        
        missionNamespace setVariable [_simStateVar, true];
        
        if (_debug) then {
            diag_log format ["[RECONDO_CAMPS] Simulation ENABLED for %1 - players in range", _markerId];
        };
    };
    
    // Disable simulation when players leave
    if (!_playersInRange && _simEnabled) then {
        // Check if any unit was alerted (not sitting anymore)
        private _anyAlerted = _units findIf { !(_x getVariable ["RECONDO_CAMPS_sitting", true]) } != -1;
        
        if (!_anyAlerted) then {
            // Units were never alerted - disable simulation normally
            {
                _x enableSimulationGlobal false;
            } forEach _objects;
            
            {
                _x enableSimulationGlobal false;
            } forEach _units;
            
            if (_debug) then {
                diag_log format ["[RECONDO_CAMPS] Simulation DISABLED for %1 - players left, units not alerted", _markerId];
            };
        } else {
            // Units were alerted - return them to sitting positions first
            {
                if (alive _x) then {
                    // Re-disable AI movement
                    _x disableAI "MOVE";
                    _x disableAI "PATH";
                    _x disableAI "ANIM";
                    
                    // Reset behavior
                    _x setBehaviour "CARELESS";
                    _x setUnitPos "UP";
                    
                    // Apply sitting animation (use stored animation or pick random)
                    private _storedAnim = _x getVariable ["RECONDO_CAMPS_sittingAnim", ""];
                    private _anim = if (_storedAnim != "") then { _storedAnim } else { selectRandom _sittingAnims };
                    [_x, _anim] remoteExec ["switchMove", 0, true];
                    
                    // Mark as sitting again
                    _x setVariable ["RECONDO_CAMPS_sitting", true];
                };
            } forEach _units;
            
            // Reset group behavior
            if (count _units > 0) then {
                private _grp = group (_units select 0);
                if (!isNull _grp) then {
                    _grp setBehaviour "CARELESS";
                    _grp setCombatMode "WHITE";
                };
            };
            
            // Disable simulation after resetting positions
            [{
                params ["_objects", "_units", "_debug", "_markerId"];
                
                {
                    if (!isNull _x) then {
                        _x enableSimulationGlobal false;
                    };
                } forEach _objects;
                
                {
                    if (!isNull _x && alive _x) then {
                        _x enableSimulationGlobal false;
                    };
                } forEach _units;
                
                if (_debug) then {
                    diag_log format ["[RECONDO_CAMPS] Simulation DISABLED for %1 - units returned to sitting", _markerId];
                };
            }, [_objects, _units, _debug, _markerId], 1] call CBA_fnc_waitAndExecute;
        };
        
        missionNamespace setVariable [_simStateVar, false];
    };
    
}, 2, [_markerId, _simulationDistance, _markerPos, _debugLogging, _sentryAnimations]] call CBA_fnc_addPerFrameHandler;

if (_debugLogging) then {
    diag_log format ["[RECONDO_CAMPS] Simulation monitor active for %1", _markerId];
};
