/*
    Recondo_fnc_handleObjectiveDestroyed
    Handles objective destruction
    
    Description:
        Called when the target object is destroyed.
        Updates persistence, removes from Intel system,
        and updates tracking arrays.
    
    Parameters:
        _instanceId - STRING - Instance ID of the objective module
        _markerId - STRING - Marker ID of the destroyed objective
        _objectiveName - STRING - Name of the objective type
    
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [
    ["_instanceId", "", [""]],
    ["_markerId", "", [""]],
    ["_objectiveName", "", [""]]
];

if (_markerId == "") exitWith {
    diag_log "[RECONDO_OBJDESTROY] ERROR: No marker ID provided to handleObjectiveDestroyed";
};

// Find settings for this instance
private _settings = nil;
{
    if ((_x get "instanceId") == _instanceId) exitWith {
        _settings = _x;
    };
} forEach RECONDO_OBJDESTROY_INSTANCES;

private _debugLogging = if (isNil "_settings") then { false } else { _settings get "debugLogging" };

// ========================================
// UPDATE GLOBAL TRACKING
// ========================================

if (!(_markerId in RECONDO_OBJDESTROY_DESTROYED)) then {
    RECONDO_OBJDESTROY_DESTROYED pushBack _markerId;
    publicVariable "RECONDO_OBJDESTROY_DESTROYED";
};

// Update active objectives array
{
    _x params ["_instId", "_mrkId", "_comp", "_status"];
    if (_mrkId == _markerId) then {
        _x set [3, "destroyed"];
    };
} forEach RECONDO_OBJDESTROY_ACTIVE;
publicVariable "RECONDO_OBJDESTROY_ACTIVE";

// ========================================
// SAVE TO PERSISTENCE
// ========================================

private _persistenceKey = format ["OBJDESTROY_%1", _objectiveName];
private _savedDestroyed = [_persistenceKey + "_DESTROYED"] call Recondo_fnc_getSaveData;

if (isNil "_savedDestroyed") then { _savedDestroyed = [] };

if (!(_markerId in _savedDestroyed)) then {
    _savedDestroyed pushBack _markerId;
    [_persistenceKey + "_DESTROYED", _savedDestroyed] call Recondo_fnc_setSaveData;
    saveMissionProfileNamespace;
};

// ========================================
// REMOVE FROM INTEL SYSTEM
// ========================================

private _targetId = format ["%1_%2", _instanceId, _markerId];
[_targetId] call Recondo_fnc_completeIntelTarget;

// ========================================
// LOG AND NOTIFY
// ========================================

diag_log format ["[RECONDO_OBJDESTROY] Objective destroyed: %1 at %2", _objectiveName, _markerId];

// Update debug marker if exists
private _debugMarker = format ["RECONDO_OBJ_DEBUG_%1", _markerId];
if (getMarkerColor _debugMarker != "") then {
    _debugMarker setMarkerColor "ColorGrey";
    _debugMarker setMarkerText format ["%1 - DESTROYED", _objectiveName];
};

// Get remaining count for logging
private _counts = [_objectiveName] call Recondo_fnc_getObjectiveCount;
_counts params ["_remaining", "_total"];

// Award Recon Points to nearby players (within 100m of objective)
if (!isNil "RECONDO_RP_SETTINGS") then {
    private _markerPos = getMarkerPos _markerId;
    private _nearbyPlayers = allPlayers select { alive _x && (_x distance2D _markerPos) < 100 };
    {
        ["destroy", _x, 0, format ["Objective %1 destroyed!", _objectiveName]] call Recondo_fnc_rpAwardPoints;
    } forEach _nearbyPlayers;
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_OBJDESTROY] '%1' status: %2 remaining of %3 total", _objectiveName, _remaining, _total];
};
