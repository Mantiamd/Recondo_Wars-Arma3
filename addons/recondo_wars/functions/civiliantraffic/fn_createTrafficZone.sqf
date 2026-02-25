/*
    Recondo_fnc_createTrafficZone
    Creates a trigger-based traffic zone for a marker
    
    Description:
        Creates a proximity trigger around a marker. When players enter,
        the zone activates and begins spawning civilian traffic.
        When players leave, traffic despawns.
    
    Parameters:
        _markerName - STRING - Name of the marker defining the zone
    
    Returns:
        Nothing
    
    Example:
        ["CIVTRAFFIC_town1"] call Recondo_fnc_createTrafficZone;
*/

params [["_markerName", "", [""]]];

if (_markerName == "") exitWith {
    diag_log "[RECONDO_CIVTRAFFIC] ERROR: createTrafficZone - Empty marker name";
};

private _settings = RECONDO_CIVTRAFFIC_SETTINGS;
private _triggerRadius = _settings get "triggerRadius";
private _debugLogging = _settings get "debugLogging";
private _debugMarkers = _settings get "debugMarkers";

// Get marker position
private _markerPos = getMarkerPos _markerName;

if (_markerPos isEqualTo [0, 0, 0]) exitWith {
    diag_log format ["[RECONDO_CIVTRAFFIC] ERROR: Marker '%1' not found or has invalid position", _markerName];
};

// Create the trigger
private _trigger = createTrigger ["EmptyDetector", _markerPos, false];
_trigger setTriggerArea [_triggerRadius, _triggerRadius, 0, false];
_trigger setTriggerActivation ["ANY", "PRESENT", true];

// Store zone data
private _zoneData = createHashMapFromArray [
    ["markerId", _markerName],
    ["markerPos", _markerPos],
    ["trigger", _trigger],
    ["active", false],
    ["vehicles", []],
    ["spawnHandle", nil]
];

// Add to global zones list
private _zoneIndex = count RECONDO_CIVTRAFFIC_ZONES;
RECONDO_CIVTRAFFIC_ZONES pushBack _zoneData;

// Store zone index on trigger for reference
_trigger setVariable ["RECONDO_CIVTRAFFIC_ZoneIndex", _zoneIndex];

// Set trigger statements
_trigger setTriggerStatements [
    // Condition: Any player present
    "{isPlayer _x} count thisList > 0",
    // On Activation
    format ["[%1] call Recondo_fnc_activateTrafficZone;", _zoneIndex],
    // On Deactivation
    format ["[%1] call Recondo_fnc_deactivateTrafficZone;", _zoneIndex]
];

// Create debug marker if enabled
if (_debugMarkers) then {
    private _debugMkr = createMarker [format ["CIVTRAFFIC_debug_%1", _markerName], _markerPos];
    _debugMkr setMarkerShape "ELLIPSE";
    _debugMkr setMarkerSize [_triggerRadius, _triggerRadius];
    _debugMkr setMarkerColor "ColorYellow";
    _debugMkr setMarkerAlpha 0.3;
    _debugMkr setMarkerBrush "SolidBorder";
    
    // Spawn radius marker
    private _spawnMkr = createMarker [format ["CIVTRAFFIC_spawn_%1", _markerName], _markerPos];
    _spawnMkr setMarkerShape "ELLIPSE";
    _spawnMkr setMarkerSize [_settings get "spawnRadius", _settings get "spawnRadius"];
    _spawnMkr setMarkerColor "ColorGreen";
    _spawnMkr setMarkerAlpha 0.2;
    _spawnMkr setMarkerBrush "SolidBorder";
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_CIVTRAFFIC] Zone created: %1 at %2, trigger radius: %3m", _markerName, _markerPos, _triggerRadius];
};
