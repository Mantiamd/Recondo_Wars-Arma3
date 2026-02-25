/*
    Recondo_fnc_updateTriangulation
    Update triangulation markers based on cumulative transmission time
    
    Description:
        Server-side function that tracks cumulative transmission time per group.
        Creates/updates triangulation markers that progressively get more accurate.
        Markers are visible to all players (global).
    
    Parameters:
        0: OBJECT - Player unit who transmitted
        1: NUMBER - Duration of transmission in seconds
        
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params ["_unit", "_duration"];

if (isNil "RECONDO_RWR_SETTINGS") exitWith {};

private _settings = RECONDO_RWR_SETTINGS;
private _debug = _settings get "enableDebug";

// Get group identifier
private _groupId = groupId group _unit;

// Get current cumulative time for this group
private _groupTotalTime = RECONDO_RWR_GROUP_TIMES getOrDefault [_groupId, 0];
_groupTotalTime = _groupTotalTime + _duration;

// Store updated time
RECONDO_RWR_GROUP_TIMES set [_groupId, _groupTotalTime];
publicVariable "RECONDO_RWR_GROUP_TIMES";

if (_debug) then {
    diag_log format ["[RECONDO_RWR] Group %1 cumulative time: %2s (+%3s)", 
        _groupId, _groupTotalTime toFixed 1, _duration toFixed 1];
};

// Get triangulation thresholds
private _threshold1 = _settings get "triangThreshold1";
private _radius1 = _settings get "triangRadius1";
private _threshold2 = _settings get "triangThreshold2";
private _radius2 = _settings get "triangRadius2";
private _threshold3 = _settings get "triangThreshold3";
private _radius3 = _settings get "triangRadius3";
private _threshold4 = _settings get "triangThreshold4";
private _radius4 = _settings get "triangRadius4";
private _markerDuration = _settings get "markerDuration";
private _markerColor = _settings get "markerColor";

// Calculate radius based on cumulative time
private _fnc_getRadius = {
    params ["_time"];
    
    if (_time < _threshold2) exitWith { _radius1 };
    if (_time < _threshold3) exitWith { _radius2 };
    if (_time < _threshold4) exitWith { _radius3 };
    _radius4
};

// Check if we've reached a marker threshold
if (_groupTotalTime < _threshold1) exitWith {
    if (_debug) then {
        diag_log format ["[RECONDO_RWR] Below threshold - no marker yet (%1s / %2s)", 
            _groupTotalTime toFixed 1, _threshold1];
    };
};

// Calculate how many times threshold has been crossed
private _timesThresholdReached = floor (_groupTotalTime / _threshold1);
private _lastMarkerCount = RECONDO_RWR_GROUP_MARKERS getOrDefault [_groupId + "_count", 0];

// Only create/update marker if we've crossed a new threshold
if (_timesThresholdReached > _lastMarkerCount) then {
    
    // Update marker count
    RECONDO_RWR_GROUP_MARKERS set [_groupId + "_count", _timesThresholdReached];
    
    // Calculate marker radius
    private _radius = [_groupTotalTime] call _fnc_getRadius;
    
    // Calculate marker position with random offset
    private _playerPos = getPos _unit;
    private _maxOffset = _radius * 0.8;
    private _offsetDistance = random _maxOffset;
    private _offsetDirection = random 360;
    private _offsetX = _offsetDistance * sin _offsetDirection;
    private _offsetY = _offsetDistance * cos _offsetDirection;
    private _markerPos = [(_playerPos select 0) + _offsetX, (_playerPos select 1) + _offsetY];
    
    // Delete existing markers for this group
    private _existingMarkers = RECONDO_RWR_GROUP_MARKERS getOrDefault [_groupId, []];
    if (count _existingMarkers > 0) then {
        {
            deleteMarker _x;
        } forEach _existingMarkers;
        
        if (_debug) then {
            diag_log format ["[RECONDO_RWR] Deleted previous markers for group %1", _groupId];
        };
    };
    
    // Create circle marker
    private _markerName = format ["RECONDO_RWR_triang_%1_%2", _groupId, serverTime];
    private _marker = createMarker [_markerName, _markerPos];
    _marker setMarkerShape "ELLIPSE";
    _marker setMarkerSize [_radius, _radius];
    _marker setMarkerColor _markerColor;
    _marker setMarkerBrush "SolidBorder";
    _marker setMarkerAlpha 0.5;
    
    // Create text marker at center
    private _textMarkerName = format ["RECONDO_RWR_triang_txt_%1_%2", _groupId, serverTime];
    private _textMarker = createMarker [_textMarkerName, _markerPos];
    _textMarker setMarkerType "hd_dot";
    _textMarker setMarkerColor _markerColor;
    _textMarker setMarkerSize [0.5, 0.5];
    private _timestamp = [daytime, "HH:MM"] call BIS_fnc_timeToString;
    _textMarker setMarkerText format ["Radio Activity Triangulated - %1", _timestamp];
    
    // Store marker names
    RECONDO_RWR_GROUP_MARKERS set [_groupId, [_markerName, _textMarkerName]];
    
    if (_debug) then {
        diag_log format ["[RECONDO_RWR] Created triangulation marker for group %1 - Radius: %2m, Position: %3", 
            _groupId, _radius, _markerPos];
    };
    
    // Notify players on OTHER sides (not the side being triangulated)
    private _transmittingSide = side _unit;
    {
        if (isPlayer _x && {side _x != _transmittingSide}) then {
            ["Radio transmission detected in the area. Approximate location marked."] remoteExec ["hint", _x];
        };
    } forEach allPlayers;
    
    // Schedule marker deletion
    [_markerName, _textMarkerName, _groupId, _markerDuration] spawn {
        params ["_markerName", "_textMarkerName", "_groupId", "_duration"];
        
        sleep _duration;
        
        // Only delete if this is still the current marker for the group
        private _currentMarkers = RECONDO_RWR_GROUP_MARKERS getOrDefault [_groupId, []];
        if (_markerName in _currentMarkers) then {
            deleteMarker _markerName;
            deleteMarker _textMarkerName;
            RECONDO_RWR_GROUP_MARKERS set [_groupId, []];
            
            if (RECONDO_RWR_SETTINGS getOrDefault ["enableDebug", false]) then {
                diag_log format ["[RECONDO_RWR] Auto-deleted triangulation marker for group %1", _groupId];
            };
        };
    };
};
