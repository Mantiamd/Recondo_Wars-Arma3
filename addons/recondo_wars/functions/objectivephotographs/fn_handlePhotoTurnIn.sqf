/*
    Recondo_fnc_handlePhotoTurnIn
    Server-side handler for when a player turns in a photo at the Intel object
    
    Parameters:
        _instanceId - STRING - Instance ID
        _rewardItemClassname - STRING - Item classname to remove from player
        _player - OBJECT - Player turning in
    
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [
    ["_instanceId", "", [""]],
    ["_rewardItemClassname", "", [""]],
    ["_player", objNull, [objNull]]
];

if (_instanceId == "" || isNull _player) exitWith {};

// Find instance settings
private _settings = nil;
{
    if ((_x get "instanceId") == _instanceId) exitWith { _settings = _x };
} forEach RECONDO_PHOTO_INSTANCES;

if (isNil "_settings") exitWith {};

private _objectiveName = _settings get "objectiveName";
private _debugLogging = _settings getOrDefault ["debugLogging", false];
private _persistenceKey = format ["OBJPHOTO_%1", _objectiveName];

// Find a photographed marker that isn't completed yet
if (isNil "RECONDO_PHOTO_PHOTOGRAPHED") exitWith {};

private _markerToComplete = "";
{
    if !(_x in RECONDO_PHOTO_COMPLETED) exitWith {
        _markerToComplete = _x;
    };
} forEach RECONDO_PHOTO_PHOTOGRAPHED;

if (_markerToComplete == "") exitWith {
    ["No photo targets available to turn in."] remoteExec ["hint", _player];
};

// Remove item from player
if (_rewardItemClassname != "") then {
    [_player, _rewardItemClassname] remoteExec ["removeItem", _player];
};

// Mark as completed
RECONDO_PHOTO_COMPLETED pushBack _markerToComplete;
publicVariable "RECONDO_PHOTO_COMPLETED";

// Update active status
{
    _x params ["_iId", "_mId", "_cData", "_status"];
    if (_mId == _markerToComplete) then {
        _x set [3, "completed"];
    };
} forEach RECONDO_PHOTO_ACTIVE;
publicVariable "RECONDO_PHOTO_ACTIVE";

// Save persistence
private _savedCompleted = [_persistenceKey + "_COMPLETED"] call Recondo_fnc_getSaveData;
if (isNil "_savedCompleted") then { _savedCompleted = [] };
_savedCompleted pushBack _markerToComplete;
[_persistenceKey + "_COMPLETED", _savedCompleted] call Recondo_fnc_setSaveData;
saveMissionProfileNamespace;

// Notify all players
private _grid = mapGridPosition (getMarkerPos _markerToComplete);
private _msg = format ["%1 turned in reconnaissance photo. Grid: %2", name _player, _grid];
[_msg] remoteExec ["systemChat", 0];

// Update debug markers
private _dbgMarkerName = format ["RECONDO_PHOTO_DEBUG_%1", _markerToComplete];
if (getMarkerType _dbgMarkerName != "") then {
    _dbgMarkerName setMarkerColor "ColorGrey";
    _dbgMarkerName setMarkerText format ["%1 - COMPLETE", _objectiveName];
};

// Intel log entry
if (!isNil "RECONDO_INTEL_LOG") then {
    private _logEntry = createHashMapFromArray [
        ["message", _msg],
        ["timestamp", serverTime],
        ["targetType", "photograph"],
        ["targetName", _objectiveName],
        ["grid", _grid],
        ["source", "turn_in"]
    ];
    RECONDO_INTEL_LOG pushBack _logEntry;
    // Broadcast only the new entry; clients append locally via event handler
    RECONDO_INTEL_LOG_LATEST = _logEntry;
    publicVariable "RECONDO_INTEL_LOG_LATEST";
};

// Check if all objectives complete
private _counts = [_objectiveName] call Recondo_fnc_getPhotoObjectiveCount;
_counts params ["_remaining", "_total"];

if (_remaining == 0) then {
    private _completeMsg = format ["All %1 objectives completed! (%2/%2)", _objectiveName, _total];
    [_completeMsg] remoteExec ["systemChat", 0];
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_PHOTO] %1 turned in photo for %2 at %3. Remaining: %4/%5", 
        name _player, _objectiveName, _markerToComplete, _remaining, _total];
};
