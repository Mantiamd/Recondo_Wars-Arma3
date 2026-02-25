/*
    Recondo_fnc_createTrackerTrigger
    Creates a trigger for tracker marker
    
    Description:
        Creates a trigger at the marker position that spawns trackers when
        the target side enters the area.
    
    Parameters:
        _markerName - Name of the marker to create trigger for
    
    Returns:
        Trigger object or objNull if failed
*/

if (!isServer) exitWith { objNull };

params ["_markerName"];

private _settings = RECONDO_TRACKERS_SETTINGS;
private _triggerDistance = _settings get "triggerDistance";
private _heightLimit = _settings get "heightLimit";
private _targetSide = _settings get "targetSide";
private _debugLogging = _settings get "debugLogging";

private _markerPos = getMarkerPos _markerName;

// Create trigger
private _trigger = createTrigger ["EmptyDetector", _markerPos, true];
if (isNull _trigger) exitWith {
    diag_log format ["[RECONDO_TRACKERS] ERROR: Failed to create trigger for marker %1", _markerName];
    objNull
};

// Configure trigger area
_trigger setTriggerArea [_triggerDistance, _triggerDistance, 0, false];

// Set activation based on target side
private _activationSide = switch (_targetSide) do {
    case east: { "EAST" };
    case west: { "WEST" };
    case independent: { "GUER" };
    default { "WEST" };
};

_trigger setTriggerActivation [_activationSide, "PRESENT", false];

// Store marker name on trigger
_trigger setVariable ["RECONDO_TRACKERS_markerName", _markerName, true];

// Build condition that checks height limit
private _condition = format [
    "if (count thisList > 0) then {
        private _unit = thisList select 0;
        if (!isNull _unit) then {
            private _vertDist = (getPosATL _unit select 2);
            _vertDist <= %1
        } else { false };
    } else { false }",
    _heightLimit
];

// Build activation code (no comments inside - they break trigger compilation)
private _activation = format [
    "
    if (count thisList > 0) then {
        private _unit = thisList select 0;
        if (!isNull _unit) then {
            private _unitGroup = group _unit;
            private _markerGroupKey = format ['RECONDO_TRACKERS_triggered_%%1_%%2', '%1', groupId _unitGroup];
            if (isNil _markerGroupKey) then {
                missionNamespace setVariable [_markerGroupKey, true, true];
                private _groupIdStr = groupId _unitGroup;
                if !(_groupIdStr in RECONDO_TRACKERS_TRACKED_GROUPS) then {
                    RECONDO_TRACKERS_TRACKED_GROUPS pushBack _groupIdStr;
                    publicVariable 'RECONDO_TRACKERS_TRACKED_GROUPS';
                };
                if ('%1' in RECONDO_TRACKERS_ALWAYS_TRACK_MARKERS) then {
                    if !(_groupIdStr in RECONDO_TRACKERS_ALWAYS_TRACK_GROUPS) then {
                        RECONDO_TRACKERS_ALWAYS_TRACK_GROUPS pushBack _groupIdStr;
                        publicVariable 'RECONDO_TRACKERS_ALWAYS_TRACK_GROUPS';
                    };
                    if (RECONDO_TRACKERS_SETTINGS get 'debugLogging') then {
                        diag_log format ['[RECONDO_TRACKERS] Group %%1 triggered ALWAYS-TRACK marker %1', groupId _unitGroup];
                    };
                } else {
                    if (RECONDO_TRACKERS_SETTINGS get 'debugLogging') then {
                        diag_log format ['[RECONDO_TRACKERS] Group %%1 triggered speed-based marker %1', groupId _unitGroup];
                    };
                };
                [%2, _unitGroup, '%1'] call Recondo_fnc_createTrackerGroup;
            };
        };
    };
    ", _markerName, _markerPos
];

_trigger setTriggerStatements [_condition, _activation, ""];

if (_debugLogging) then {
    diag_log format ["[RECONDO_TRACKERS] Trigger created for marker %1 at %2", _markerName, _markerPos];
};

_trigger
