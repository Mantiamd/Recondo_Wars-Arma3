/*
    Recondo_fnc_convoyCleanup
    Cleanup loop for convoy system
    
    Description:
        Continuously monitors active convoys and cleans up
        destroyed, timed-out, or completed convoys.
    
    Parameters:
        0: HASHMAP - Settings from module
        
    Returns:
        Nothing
*/

params [["_settings", nil, [createHashMap]]];

if (isNil "_settings") exitWith {
    diag_log "[RECONDO_CONVOY] ERROR: No settings provided to cleanup loop";
};

private _timeout = (_settings get "timeout") * 60; // Convert minutes to seconds
private _debugLogging = _settings get "debugLogging";

if (_debugLogging) then {
    diag_log format ["[RECONDO_CONVOY] Cleanup loop started, timeout: %1 minutes", _settings get "timeout"];
};

while {true} do {
    private _currentTime = time;
    private _toRemove = [];
    
    {
        _x params ["_group", "_createTime", "_vehicles", "_destMarker", "_leaderVeh"];
        private _index = _forEachIndex;
        
        private _shouldRemove = false;
        private _reason = "";
        
        // Check if group is destroyed
        if (isNull _group || {count (units _group) == 0}) then {
            _shouldRemove = true;
            _reason = "group destroyed";
        };
        
        // Check if leader vehicle is destroyed/invalid
        if (!_shouldRemove && (isNull _leaderVeh || !alive _leaderVeh)) then {
            _shouldRemove = true;
            _reason = "leader destroyed";
        };
        
        // Check if convoy is terminated
        if (!_shouldRemove && _leaderVeh getVariable ["RECONDO_CONVOY_Terminate", false]) then {
            _shouldRemove = true;
            _reason = "terminated";
        };
        
        // Check timeout
        if (!_shouldRemove && (_currentTime - _createTime > _timeout)) then {
            _shouldRemove = true;
            _reason = "timeout";
            
            // Terminate the convoy
            if (!isNull _leaderVeh) then {
                [_leaderVeh] call Recondo_fnc_terminateConvoy;
            };
        };
        
        // Check if all vehicles are incapacitated
        if (!_shouldRemove) then {
            private _aliveVehicles = _vehicles select { !isNull _x && alive _x && canMove _x };
            
            if (count _aliveVehicles == 0) then {
                _shouldRemove = true;
                _reason = "all vehicles destroyed";
                
                // Terminate the convoy
                if (!isNull _leaderVeh) then {
                    [_leaderVeh] call Recondo_fnc_terminateConvoy;
                };
            };
        };
        
        if (_shouldRemove) then {
            _toRemove pushBack _index;
            
            if (_debugLogging) then {
                diag_log format ["[RECONDO_CONVOY] Cleanup: Removing convoy %1, reason: %2", _index, _reason];
            };
            
            // Final cleanup if not already done
            if (!isNull _group) then {
                // Delete any remaining vehicles and crew
                {
                    if (!isNull _x) then {
                        { deleteVehicle _x } forEach (crew _x);
                        deleteVehicle _x;
                    };
                } forEach _vehicles;
                
                deleteGroup _group;
            };
            
            // Clean up debug marker
            if (!isNull _leaderVeh) then {
                private _debugMkr = _leaderVeh getVariable ["RECONDO_CONVOY_DebugMarker", ""];
                if (_debugMkr != "") then {
                    deleteMarker _debugMkr;
                };
            };
        };
    } forEach RECONDO_CONVOY_ACTIVE;
    
    // Remove cleaned up convoys (in reverse order to preserve indices)
    {
        RECONDO_CONVOY_ACTIVE deleteAt _x;
    } forEachReversed _toRemove;
    
    if (count _toRemove > 0) then {
        publicVariable "RECONDO_CONVOY_ACTIVE";
        
        if (_debugLogging) then {
            diag_log format ["[RECONDO_CONVOY] Cleanup complete. Removed %1 convoys. Active: %2", count _toRemove, count RECONDO_CONVOY_ACTIVE];
        };
    };
    
    private _cleanupInterval = _settings get "cleanupInterval";
    sleep _cleanupInterval;
};
