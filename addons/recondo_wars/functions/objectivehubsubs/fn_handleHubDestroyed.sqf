/*
    Recondo_fnc_handleHubDestroyed
    Handles hub destruction event
    
    Description:
        Called when a hub's target object is destroyed. Updates tracking,
        saves to persistence, optionally spawns destroyed composition,
        and notifies Intel system.
    
    Parameters:
        _instanceId - STRING - Module instance ID
        _hubMarker - STRING - Hub marker name
        _objectiveName - STRING - Objective display name
    
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [
    ["_instanceId", "", [""]],
    ["_hubMarker", "", [""]],
    ["_objectiveName", "", [""]]
];

if (_hubMarker == "") exitWith {
    diag_log "[RECONDO_HUBSUBS] ERROR: handleHubDestroyed called with empty marker";
};

diag_log format ["[RECONDO_HUBSUBS] Hub destroyed: %1 (%2)", _hubMarker, _objectiveName];

// Add to destroyed list
if !(_hubMarker in RECONDO_HUBSUBS_DESTROYED) then {
    RECONDO_HUBSUBS_DESTROYED pushBack _hubMarker;
    publicVariable "RECONDO_HUBSUBS_DESTROYED";
};

// Update active tracking
{
    _x params ["_instId", "_mkr", "_comp", "_subMarkers", "_destroyed"];
    if (_mkr == _hubMarker) exitWith {
        RECONDO_HUBSUBS_ACTIVE set [_forEachIndex, [_instId, _mkr, _comp, _subMarkers, true]];
    };
} forEach RECONDO_HUBSUBS_ACTIVE;
publicVariable "RECONDO_HUBSUBS_ACTIVE";

// Find settings for this instance
private _settings = nil;
{
    if ((_x get "instanceId") == _instanceId) exitWith {
        _settings = _x;
    };
} forEach RECONDO_HUBSUBS_INSTANCES;

if (!isNil "_settings") then {
    // Save to persistence
    private _persistenceKey = format ["HUBSUBS_%1", _objectiveName];
    private _savedDestroyed = [_persistenceKey + "_DESTROYED"] call Recondo_fnc_getSaveData;
    
    if (isNil "_savedDestroyed") then {
        _savedDestroyed = [];
    };
    
    if !(_hubMarker in _savedDestroyed) then {
        _savedDestroyed pushBack _hubMarker;
        [_persistenceKey + "_DESTROYED", _savedDestroyed] call Recondo_fnc_setSaveData;
        saveMissionProfileNamespace;
    };
    
    // Optionally spawn destroyed composition
    private _destroyedCompositions = _settings get "destroyedCompositions";
    
    if (count _destroyedCompositions > 0) then {
        private _compositionPath = _settings get "compositionPath";
        private _debugLogging = _settings get "debugLogging";
        
        private _destroyedComp = selectRandom _destroyedCompositions;
        private _markerPos = getMarkerPos _hubMarker;
        private _markerDir = markerDir _hubMarker;
        
        if (_debugLogging) then {
            diag_log format ["[RECONDO_HUBSUBS] Spawning destroyed composition %1 at %2", _destroyedComp, _hubMarker];
        };
        
        // Delay slightly to let explosion effects settle
        [{
            params ["_compositionPath", "_destroyedComp", "_markerPos", "_markerDir", "_debugLogging"];
            [_compositionPath, _destroyedComp, _markerPos, _markerDir, _debugLogging] call Recondo_fnc_loadComposition;
        }, [_compositionPath, _destroyedComp, _markerPos, _markerDir, _debugLogging], 3] call CBA_fnc_waitAndExecute;
    };
    
    // Notify Intel system
    private _targetId = format ["%1_%2", _instanceId, _hubMarker];
    [_targetId] call Recondo_fnc_completeIntelTarget;
    
    private _debugLogging = _settings get "debugLogging";
    if (_debugLogging) then {
        diag_log format ["[RECONDO_HUBSUBS] Completed intel target: %1", _targetId];
    };
};

// Broadcast notification
private _notificationMsg = format ["%1 has been destroyed!", _objectiveName];
_notificationMsg remoteExec ["systemChat", 0];

// Award Recon Points to nearby players
if (!isNil "RECONDO_RP_SETTINGS") then {
    private _markerPos = getMarkerPos _hubMarker;
    private _nearbyPlayers = allPlayers select { alive _x && (_x distance2D _markerPos) < 100 };
    {
        ["destroy", _x, 0, format ["%1 destroyed!", _objectiveName]] call Recondo_fnc_rpAwardPoints;
    } forEach _nearbyPlayers;
};