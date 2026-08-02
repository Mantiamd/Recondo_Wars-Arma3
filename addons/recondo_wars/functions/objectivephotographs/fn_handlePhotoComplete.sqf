/*
    Recondo_fnc_handlePhotoComplete
    Server-side handler when a player successfully photographs a target
    
    Description:
        Called via remoteExec from the client. Records the photo but does NOT
        complete the objective yet - that happens when the photo item is turned in.
    
    Parameters:
        _instanceId - STRING - Instance ID
        _markerId - STRING - Marker that was photographed
        _player - OBJECT - Player who took the photo
    
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [
    ["_instanceId", "", [""]],
    ["_markerId", "", [""]],
    ["_player", objNull, [objNull]]
];

if (_instanceId == "" || _markerId == "") exitWith {};

// Track that this marker has been photographed (but not yet turned in)
if (isNil "RECONDO_PHOTO_PHOTOGRAPHED") then { RECONDO_PHOTO_PHOTOGRAPHED = [] };

if !(_markerId in RECONDO_PHOTO_PHOTOGRAPHED) then {
    RECONDO_PHOTO_PHOTOGRAPHED pushBack _markerId;
    publicVariable "RECONDO_PHOTO_PHOTOGRAPHED";
};

// Find the settings for this instance
private _settings = nil;
{
    if ((_x get "instanceId") == _instanceId) exitWith { _settings = _x };
} forEach RECONDO_PHOTO_INSTANCES;

if (isNil "_settings") exitWith {};

private _debugLogging = _settings getOrDefault ["debugLogging", false];
private _objectiveName = _settings get "objectiveName";

if (_debugLogging) then {
    diag_log format ["[RECONDO_PHOTO] %1 photographed target at %2 (instance: %3)", name _player, _markerId, _instanceId];
};

// Log to intel system
if (!isNil "RECONDO_INTEL_LOG") then {
    private _timeArray = systemTimeUTC;
    private _timestamp = format ["%1-%2-%3 %4:%5",
        _timeArray select 0,
        ([_timeArray select 1] call {
            params ["_n"];
            if (_n < 10) then { format ["0%1", _n] } else { str _n }
        }),
        ([_timeArray select 2] call {
            params ["_n"];
            if (_n < 10) then { format ["0%1", _n] } else { str _n }
        }),
        ([_timeArray select 3] call {
            params ["_n"];
            if (_n < 10) then { format ["0%1", _n] } else { str _n }
        }),
        ([_timeArray select 4] call {
            params ["_n"];
            if (_n < 10) then { format ["0%1", _n] } else { str _n }
        })
    ];

    private _logEntry = createHashMapFromArray [
        ["message", format ["%1 photographed %2 at grid %3", name _player, _objectiveName, mapGridPosition (getMarkerPos _markerId)]],
        ["timestamp", _timestamp],
        ["targetType", "photograph"],
        ["targetName", _objectiveName],
        ["grid", mapGridPosition (getMarkerPos _markerId)],
        ["source", "camera"]
    ];
    RECONDO_INTEL_LOG insert [0, [_logEntry]];   // newest first, matching processTurnIn
    // Broadcast only the new entry; clients append locally via event handler
    RECONDO_INTEL_LOG_LATEST = _logEntry;
    publicVariable "RECONDO_INTEL_LOG_LATEST";
};
