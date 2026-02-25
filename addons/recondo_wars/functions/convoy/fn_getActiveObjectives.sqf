/*
    Recondo_fnc_getActiveObjectives
    Gets all active objectives that convoys can route to
    
    Description:
        Queries ONLY synced objective systems and returns an array
        of valid destinations. If no objectives are synced, returns
        an empty array (convoy will use direct start->end route).
        
        For HVT and Hostages, BOTH real locations AND decoy locations
        are included as valid destinations.
    
    Parameters:
        0: HASHMAP - Settings from module
        
    Returns:
        ARRAY - Array of [markerName, position, objectiveType]
*/

params [["_settings", nil, [createHashMap]]];

if (isNil "_settings") exitWith { [] };

private _objectives = [];
private _debugLogging = _settings get "debugLogging";

// Check if we have any synced objectives
private _hasSyncedObjectives = _settings get "hasSyncedObjectives";

if (!_hasSyncedObjectives) exitWith {
    if (_debugLogging) then {
        diag_log "[RECONDO_CONVOY] No synced objectives - returning empty (direct route)";
    };
    []
};

// Get synced instance IDs
private _syncedHVTInstances = _settings get "syncedHVTInstances";
private _syncedHostageInstances = _settings get "syncedHostageInstances";
private _syncedDestroyInstances = _settings get "syncedDestroyInstances";
private _syncedHubInstances = _settings get "syncedHubInstances";

// ========================================
// HVT LOCATIONS (including decoys)
// ========================================
if (count _syncedHVTInstances > 0 && !isNil "RECONDO_HVT_LOCATIONS") then {
    private _capturedHVTs = if (isNil "RECONDO_HVT_CAPTURED") then { [] } else { RECONDO_HVT_CAPTURED };
    
    {
        private _instanceId = _x;
        private _locData = RECONDO_HVT_LOCATIONS getOrDefault [_instanceId, nil];
        
        if (!isNil "_locData") then {
            _locData params ["_hvtMarker", "_decoyMarkers"];
            
            // Add real HVT location (if not captured)
            if !(_instanceId in _capturedHVTs) then {
                private _pos = getMarkerPos _hvtMarker;
                if !(_pos isEqualTo [0, 0, 0]) then {
                    _objectives pushBack [_hvtMarker, _pos, "HVT"];
                };
            };
            
            // Add ALL decoy locations (always valid for convoys - reinforces decoy purpose)
            {
                private _pos = getMarkerPos _x;
                if !(_pos isEqualTo [0, 0, 0]) then {
                    _objectives pushBack [_x, _pos, "HVT_Decoy"];
                };
            } forEach _decoyMarkers;
        };
    } forEach _syncedHVTInstances;
};

// ========================================
// HOSTAGE LOCATIONS (including decoys)
// ========================================
if (count _syncedHostageInstances > 0 && !isNil "RECONDO_HOSTAGE_LOCATIONS") then {
    {
        private _instanceId = _x;
        private _locData = RECONDO_HOSTAGE_LOCATIONS getOrDefault [_instanceId, nil];
        
        if (!isNil "_locData") then {
            _locData params ["_hostageMarkers", "_decoyMarkers", "_hostageAssignments"];
            
            // Add real hostage locations (if still has hostages)
            {
                private _marker = _x;
                private _pos = getMarkerPos _marker;
                
                if !(_pos isEqualTo [0, 0, 0]) then {
                    // Check if there are still hostages at this location
                    private _hostagesAtMarker = _hostageAssignments getOrDefault [_marker, []];
                    
                    if (count _hostagesAtMarker > 0) then {
                        _objectives pushBack [_marker, _pos, "Hostages"];
                    };
                };
            } forEach _hostageMarkers;
            
            // Add ALL decoy locations (always valid for convoys - reinforces decoy purpose)
            {
                private _pos = getMarkerPos _x;
                if !(_pos isEqualTo [0, 0, 0]) then {
                    _objectives pushBack [_x, _pos, "Hostage_Decoy"];
                };
            } forEach _decoyMarkers;
        };
    } forEach _syncedHostageInstances;
};

// ========================================
// DESTROY OBJECTIVES
// ========================================
if (count _syncedDestroyInstances > 0 && !isNil "RECONDO_OBJDESTROY_ACTIVE") then {
    private _destroyedMarkers = if (isNil "RECONDO_OBJDESTROY_DESTROYED") then { [] } else { RECONDO_OBJDESTROY_DESTROYED };
    
    // Also check persistence data for destroyed markers
    private _persData = missionProfileNamespace getVariable ["RECONDO_PERS_DATA", createHashMap];
    private _savedDestroyedMarkers = _persData getOrDefault ["destroyedMarkers", []];
    
    {
        _x params ["_objInstanceId", "_markerId", "_compositionName", "_status"];
        
        // Only include if this instance is synced
        if (_objInstanceId in _syncedDestroyInstances) then {
            // Skip destroyed objectives
            if !(_markerId in _destroyedMarkers) then {
                if !(_markerId in _savedDestroyedMarkers) then {
                    private _pos = getMarkerPos _markerId;
                    
                    if !(_pos isEqualTo [0, 0, 0]) then {
                        _objectives pushBack [_markerId, _pos, "Destroy"];
                    };
                };
            };
        };
    } forEach RECONDO_OBJDESTROY_ACTIVE;
};

// ========================================
// HUB OBJECTIVES
// ========================================
if (count _syncedHubInstances > 0 && !isNil "RECONDO_HUBSUBS_ACTIVE") then {
    private _destroyedHubs = if (isNil "RECONDO_HUBSUBS_DESTROYED") then { [] } else { RECONDO_HUBSUBS_DESTROYED };
    
    // Also check persistence data
    private _persData = missionProfileNamespace getVariable ["RECONDO_PERS_DATA", createHashMap];
    private _savedDestroyedHubs = _persData getOrDefault ["destroyedHubs", []];
    
    {
        _x params ["_hubInstanceId", "_markerId", "_compositionName", "_subSiteMarkers", "_status"];
        
        // Only include if this instance is synced
        if (_hubInstanceId in _syncedHubInstances) then {
            // Skip destroyed hubs
            if !(_markerId in _destroyedHubs) then {
                if !(_markerId in _savedDestroyedHubs) then {
                    private _pos = getMarkerPos _markerId;
                    
                    if !(_pos isEqualTo [0, 0, 0]) then {
                        _objectives pushBack [_markerId, _pos, "Hub"];
                    };
                };
            };
        };
    } forEach RECONDO_HUBSUBS_ACTIVE;
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_CONVOY] Found %1 active objectives:", count _objectives];
    {
        _x params ["_marker", "_pos", "_type"];
        diag_log format ["[RECONDO_CONVOY]   - %1 (%2) at %3", _marker, _type, _pos];
    } forEach _objectives;
};

_objectives
