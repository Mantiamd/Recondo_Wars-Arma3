/*
    Recondo_fnc_handlePhotoTaken
    Client-side handler for when a photo is taken with the SOG PF camera
    
    Description:
        Uses ATF-style robust validation: nearestObjects to find candidate objects
        matching any active target classname, validates proximity to an active marker,
        then applies worldToScreen for in-frame check, checkVisibility with
        bounding-box multi-point sampling, and zoom-adjusted range.
    
    Parameters:
        None (uses global state)
    
    Returns:
        Nothing
*/

if (!hasInterface) exitWith {};

#define VIS_THRESHOLD 0.4

private _player = focusOn;

if (isNil "RECONDO_PHOTO_INSTANCES" || {count RECONDO_PHOTO_INSTANCES == 0}) exitWith {};
if (isNil "RECONDO_PHOTO_MARKER_DATA" || {count RECONDO_PHOTO_MARKER_DATA == 0}) exitWith {};
if (isNil "RECONDO_PHOTO_COMPLETED") exitWith {};

// Build set of valid target classnames from all active markers
private _validClassnames = [];
{
    _x params ["_markerId", "_markerPos", "_targetClass", "_instanceId", "_searchRadius"];
    if !(_markerId in RECONDO_PHOTO_COMPLETED) then {
        if !(_targetClass in _validClassnames) then {
            _validClassnames pushBack _targetClass;
        };
    };
} forEach RECONDO_PHOTO_MARKER_DATA;

if (count _validClassnames == 0) exitWith {};

// Helper: check if a world position (ASL) is within the camera frame
private _fnc_isInFrame = {
    private _screenPos = worldToScreen ASLToAGL _this;
    if (_screenPos isEqualTo []) exitWith { false };
    _screenPos params ["_sX", "_sY"];
    (_sX >= -0.4 && _sX <= 1.4) && (_sY >= -0.13 && _sY <= 1.13)
};

// Helper: get bounding box sample points for an object (cached per classname)
private _fnc_getObjectPoints = {
    params ["_object"];
    RECONDO_PHOTO_BB_CACHE getOrDefaultCall [typeOf _object, {
        private _bb = 0 boundingBoxReal _object;
        _bb params ["_bbA", "_bbB"];
        [
            [0, 0, 0],
            [0, 0, _bbB select 2],
            [_bbA select 0, _bbA select 1, _bbB select 2],
            [_bbA select 0, _bbB select 1, _bbB select 2],
            [_bbB select 0, _bbA select 1, _bbB select 2],
            [_bbB select 0, _bbB select 1, _bbB select 2],
            [_bbA select 0, _bbA select 1, _bbA select 2],
            [_bbA select 0, _bbB select 1, _bbA select 2],
            [_bbB select 0, _bbA select 1, _bbA select 2],
            [_bbB select 0, _bbB select 1, _bbA select 2]
        ]
    }, true]
};

// Calculate zoom-adjusted effective range
private _zoom = (getResolution#6) / getObjectFOV _player;

// Get first instance settings for distance/messages
private _firstSettings = RECONDO_PHOTO_INSTANCES select 0;
private _maxPhotoDistance = _firstSettings get "maxPhotoDistance";
private _minPhotoDistance = _firstSettings get "minPhotoDistance";

// Find all candidate objects nearby using the max possible range
private _searchRange = _maxPhotoDistance * _zoom * 1.2;
private _candidates = nearestObjects [_player, _validClassnames, _searchRange];

if (count _candidates == 0) exitWith {
    private _failMsg = _firstSettings getOrDefault ["failMessage", "No valid target in view."];
    hint parseText format ["<t color='#CC8888' size='1.1'>%1</t>", _failMsg];
};

private _photographedMarker = "";
private _photographedInstanceId = "";
private _photographedSettings = nil;

{
    private _candidateObj = _x;
    private _candidateClass = typeOf _candidateObj;
    private _candidatePos = getPosATL _candidateObj;

    // Distance check (zoom-adjusted)
    private _rawDist = _player distance _candidateObj;
    private _perceivedDistance = _rawDist / _zoom;

    if (_perceivedDistance > _maxPhotoDistance || _rawDist < _minPhotoDistance) then { continue };

    // Check if target center is roughly on screen (small offset for ground-level objects)
    private _targetPosASL = getPosASL _candidateObj;
    _targetPosASL set [2, (_targetPosASL select 2) + 0.3];
    if !(_targetPosASL call _fnc_isInFrame) then { continue };

    // Multi-point visibility check
    private _posBeg = eyePos _player;
    private _visiblePoints = 0;

    {
        private _posEnd = _candidateObj modelToWorldWorld _x;
        if !(_posEnd call _fnc_isInFrame) then { continue };

        private _vis = [_player, "VIEW", _candidateObj] checkVisibility [_posBeg, _posEnd];
        if (_vis >= VIS_THRESHOLD) then {
            _visiblePoints = _visiblePoints + 1;
        };

        if (_visiblePoints >= 1) then { break };
    } forEach ([_candidateObj] call _fnc_getObjectPoints);

    if (_visiblePoints < 1) then { continue };

    // Object is visible and in frame -- match to an active marker by proximity + classname
    {
        _x params ["_markerId", "_markerPos", "_targetClass", "_instanceId", "_searchRadius"];

        if (_markerId in RECONDO_PHOTO_COMPLETED) then { continue };
        if (_candidateClass != _targetClass) then { continue };

        // Check proximity to marker
        if (_candidatePos distance2D _markerPos <= _searchRadius) exitWith {
            _photographedMarker = _markerId;
            _photographedInstanceId = _instanceId;

            // Find matching settings
            {
                if ((_x get "instanceId") == _instanceId) exitWith { _photographedSettings = _x };
            } forEach RECONDO_PHOTO_INSTANCES;
        };
    } forEach RECONDO_PHOTO_MARKER_DATA;

    if (_photographedMarker != "") then { break };
} forEach _candidates;

// Process result
if (_photographedMarker != "" && !isNil "_photographedSettings") then {
    private _rewardItem = _photographedSettings get "rewardItemClassname";
    private _successMsg = _photographedSettings get "successMessage";
    private _debugLogging = _photographedSettings getOrDefault ["debugLogging", false];

    // Track locally to prevent duplicate photos of same target
    if (isNil "RECONDO_PHOTO_TAKEN_LOCAL") then { RECONDO_PHOTO_TAKEN_LOCAL = [] };
    private _photoKey = format ["%1_%2", _photographedMarker, getPlayerUID _player];
    if (_photoKey in RECONDO_PHOTO_TAKEN_LOCAL) exitWith {};
    RECONDO_PHOTO_TAKEN_LOCAL pushBack _photoKey;

    // Flash effect
    cutText ["", "WHITE OUT", 0.1];
    [{cutText ["", "WHITE IN", 0.2];}, [], 0.15] call CBA_fnc_waitAndExecute;

    // Award item
    if (_rewardItem != "") then {
        _player addItem _rewardItem;
    };

    // Success feedback
    hint parseText format ["<t color='#88CC88' size='1.2'>%1</t>", _successMsg];
    playSound "FD_Finish_F";

    // Notify server
    [_photographedInstanceId, _photographedMarker, _player] remoteExec ["Recondo_fnc_handlePhotoComplete", 2];

    if (_debugLogging) then {
        diag_log format ["[RECONDO_PHOTO] Successfully photographed target at %1", _photographedMarker];
    };
} else {
    private _failMsg = _firstSettings getOrDefault ["failMessage", "No valid target in view."];
    hint parseText format ["<t color='#CC8888' size='1.1'>%1</t>", _failMsg];
};
