/*
    Recondo_fnc_outpostDestroyed
    Handles outpost destruction — persists destroyed state and notifies allowed side
    
    Description:
        Called when the destroyable object at an outpost is killed.
        Marks the outpost as destroyed in persistence so it will be
        excluded on next mission restart. Sends an Intel Card notification
        to all players on the allowed side.
        The outpost remains usable for the rest of the current mission.
    
    Parameters:
        0: STRING - Instance ID
        1: STRING - Marker ID of the destroyed outpost
    
    Returns:
        Nothing
    
    Execution:
        Server only (called from Killed EH)
*/

if (!isServer) exitWith {};

params [
    ["_instanceId", "", [""]],
    ["_markerId", "", [""]]
];

if (_instanceId == "" || _markerId == "") exitWith {
    diag_log "[RECONDO_OUTPOSTTELE] ERROR: outpostDestroyed called with empty instanceId or markerId.";
};

// Find settings for this instance
private _settings = nil;
{
    if ((_x get "instanceId") == _instanceId) exitWith {
        _settings = _x;
    };
} forEach RECONDO_OUTPOSTTELE_INSTANCES;

if (isNil "_settings") exitWith {
    diag_log format ["[RECONDO_OUTPOSTTELE] ERROR: Could not find settings for instance '%1'", _instanceId];
};

private _enablePersistence = _settings get "enablePersistence";
private _debugLogging = _settings get "debugLogging";
private _allowedSideNum = _settings getOrDefault ["allowedSideNum", -1];

// Find outpost display name
private _displayName = _markerId;
{
    if ((_x get "instanceId") == _instanceId && (_x get "markerId") == _markerId) exitWith {
        _displayName = _x get "displayName";
        _x set ["destroyed", true];
    };
} forEach RECONDO_OUTPOSTTELE_OUTPOSTS;

diag_log format ["[RECONDO_OUTPOSTTELE] Outpost DESTROYED: %1 (marker: %2, instance: %3)", _displayName, _markerId, _instanceId];

// ========================================
// PERSIST DESTROYED STATE
// ========================================

if (_enablePersistence) then {
    private _persistenceKey = format ["OUTPOSTTELE_%1", _instanceId];
    private _destroyedMarkers = [_persistenceKey + "_DESTROYED"] call Recondo_fnc_getSaveData;
    
    if (isNil "_destroyedMarkers") then { _destroyedMarkers = [] };
    
    if !(_markerId in _destroyedMarkers) then {
        _destroyedMarkers pushBack _markerId;
        [_persistenceKey + "_DESTROYED", _destroyedMarkers] call Recondo_fnc_setSaveData;
        saveMissionProfileNamespace;
        
        if (_debugLogging) then {
            diag_log format ["[RECONDO_OUTPOSTTELE] Saved destroyed state for marker '%1'. Total destroyed: %2", _markerId, count _destroyedMarkers];
        };
    };
};

// ========================================
// NOTIFY ALLOWED SIDE
// ========================================

private _allowedSide = switch (_allowedSideNum) do {
    case 0: { east };
    case 1: { west };
    case 2: { independent };
    case 3: { civilian };
    default { nil };
};

private _markerPos = getMarkerPos _markerId;
private _gridRef = mapGridPosition _markerPos;
private _gridLen = count _gridRef;
private _halfLen = _gridLen / 2;
private _eastingGrid = _gridRef select [0, 3];
private _northingGrid = _gridRef select [_halfLen, 3];

private _notificationBody = format ["%1 has been destroyed at grid %2 %3. It will be unavailable on next restart.", _displayName, _eastingGrid, _northingGrid];

private _recipients = [];
{
    if (isPlayer _x) then {
        if (isNil "_allowedSide") then {
            _recipients pushBack _x;
        } else {
            if (side _x == _allowedSide) then {
                _recipients pushBack _x;
            };
        };
    };
} forEach allPlayers;

{
    ["OUTPOST DESTROYED", _notificationBody, 0, 8, "", 3] remoteExec ["Recondo_fnc_showIntelCard", _x];
} forEach _recipients;

if (_debugLogging) then {
    diag_log format ["[RECONDO_OUTPOSTTELE] Sent destruction notification to %1 players: %2", count _recipients, _notificationBody];
};
