/*
    Recondo_fnc_handleJammerDestroyed
    Handles jammer destruction
    
    Description:
        Called when the jammer object is destroyed.
        Updates persistence, removes from Intel system,
        updates tracking arrays, and notifies clients to update jamming.
    
    Parameters:
        _instanceId - STRING - Instance ID of the jammer module
        _markerId - STRING - Marker ID of the destroyed jammer
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
    diag_log "[RECONDO_JAMMER] ERROR: No marker ID provided to handleJammerDestroyed";
};

// Find settings for this instance
private _settings = nil;
{
    if ((_x get "instanceId") == _instanceId) exitWith {
        _settings = _x;
    };
} forEach RECONDO_JAMMER_INSTANCES;

private _debugLogging = if (isNil "_settings") then { false } else { _settings get "debugLogging" };

// ========================================
// UPDATE GLOBAL TRACKING
// ========================================

// Add to destroyed list
if (!(_markerId in RECONDO_JAMMER_DESTROYED)) then {
    RECONDO_JAMMER_DESTROYED pushBack _markerId;
};

// Update active objectives array (server-only tracking)
{
    _x params ["_instId", "_mrkId", "_comp", "_status"];
    if (_mrkId == _markerId) then {
        _x set [3, "destroyed"];
    };
} forEach RECONDO_JAMMER_ACTIVE;

// Update active jammer data (clients need this for jamming loops)
{
    if ((_x get "markerId") == _markerId) then {
        _x set ["active", false];
    };
} forEach RECONDO_JAMMER_ACTIVE_DATA;
publicVariable "RECONDO_JAMMER_ACTIVE_DATA";

// Remove from jammer objects tracking (server-only)
RECONDO_JAMMER_OBJECTS deleteAt _markerId;

// ========================================
// SAVE TO PERSISTENCE
// ========================================

private _persistenceKey = format ["JAMMER_%1", _objectiveName];
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
// UPDATE DEBUG MARKERS
// ========================================

private _debugMarker = format ["RECONDO_JAMMER_DEBUG_%1", _markerId];
if (getMarkerColor _debugMarker != "") then {
    _debugMarker setMarkerColor "ColorGrey";
    _debugMarker setMarkerText format ["%1 - DESTROYED", _objectiveName];
};

// Delete jam radius debug markers
deleteMarker (format ["RECONDO_JAMMER_PARTIAL_%1", _markerId]);
deleteMarker (format ["RECONDO_JAMMER_FULL_%1", _markerId]);

// ========================================
// NOTIFY CLIENTS TO UPDATE JAMMING
// ========================================

// Clients will automatically detect the change via RECONDO_JAMMER_ACTIVE_DATA

// ========================================
// LOG
// ========================================

diag_log format ["[RECONDO_JAMMER] Jammer destroyed: %1 at %2", _objectiveName, _markerId];

// Get remaining count
private _counts = [_objectiveName] call Recondo_fnc_getJammerCount;
_counts params ["_remaining", "_total"];

// Award Recon Points to nearby players
if (!isNil "RECONDO_RP_SETTINGS") then {
    private _markerPos = getMarkerPos _markerId;
    private _nearbyPlayers = allPlayers select { alive _x && (_x distance2D _markerPos) < 100 };
    {
        ["destroy", _x, 0, format ["Jammer %1 destroyed!", _objectiveName]] call Recondo_fnc_rpAwardPoints;
    } forEach _nearbyPlayers;
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_JAMMER] '%1' status: %2 remaining of %3 total", _objectiveName, _remaining, _total];
};
