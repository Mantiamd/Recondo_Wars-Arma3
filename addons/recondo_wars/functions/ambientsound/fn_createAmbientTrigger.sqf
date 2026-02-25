/*
    Recondo_fnc_createAmbientTrigger
    Creates an ambient sound trigger at a marker position
    
    Description:
        Creates a repeatable trigger that plays 3D sounds when
        units from the configured side enter the area.
    
    Parameters:
        _markerName - STRING - Name of the marker
        _settings - HASHMAP - Module settings
    
    Returns:
        OBJECT - The created trigger
    
    Example:
        ["AMBIENT_1", _settings] call Recondo_fnc_createAmbientTrigger;
*/

if (!isServer) exitWith { objNull };

params [
    ["_markerName", "", [""]],
    ["_settings", nil, [createHashMap]]
];

if (_markerName == "" || isNil "_settings") exitWith {
    diag_log "[RECONDO_AMBIENT] ERROR: Invalid parameters for createAmbientTrigger";
    objNull
};

private _debugLogging = _settings get "debugLogging";
private _triggerRadius = _settings get "triggerRadius";
private _triggerHeight = _settings get "triggerHeight";
private _triggerSide = _settings get "triggerSide";
private _triggerTarget = _settings get "triggerTarget";

// Get marker position
private _pos = getMarkerPos _markerName;

if (_pos isEqualTo [0, 0, 0]) exitWith {
    if (_debugLogging) then {
        diag_log format ["[RECONDO_AMBIENT] WARNING: Marker '%1' has invalid position", _markerName];
    };
    objNull
};

// Create trigger
private _trigger = createTrigger ["EmptyDetector", _pos, true];
_trigger setTriggerArea [_triggerRadius, _triggerRadius, 0, false, _triggerHeight];
_trigger setTriggerActivation [_triggerSide, "PRESENT", true]; // Repeatable

// Store settings on trigger
_trigger setVariable ["RECONDO_AMBIENT_settings", _settings, false];
_trigger setVariable ["RECONDO_AMBIENT_marker", _markerName, false];
_trigger setVariable ["RECONDO_AMBIENT_lastTriggered", -9999, false];
_trigger setVariable ["RECONDO_AMBIENT_triggerTarget", _triggerTarget, false];

// Set trigger statements with target filtering
_trigger setTriggerStatements [
    "call {
        private _settings = thisTrigger getVariable 'RECONDO_AMBIENT_settings';
        private _cooldown = _settings get 'cooldown';
        private _lastTriggered = thisTrigger getVariable ['RECONDO_AMBIENT_lastTriggered', -9999];
        private _triggerTarget = thisTrigger getVariable ['RECONDO_AMBIENT_triggerTarget', 0];
        
        if (time < (_lastTriggered + _cooldown)) exitWith { false };
        
        private _validUnits = thislist select {
            alive _x && {
                switch (_triggerTarget) do {
                    case 0: { isPlayer _x };
                    case 1: { !isPlayer _x };
                    case 2: { true };
                    default { isPlayer _x };
                }
            }
        };
        
        count _validUnits > 0
    }",
    "[thisTrigger, thisList] call Recondo_fnc_handleAmbientTrigger;",
    ""
];

if (_debugLogging) then {
    diag_log format ["[RECONDO_AMBIENT] Created trigger at '%1' - Radius: %2m, Height: %3m, Side: %4, Target: %5",
        _markerName, _triggerRadius, _triggerHeight, _triggerSide,
        switch (_triggerTarget) do { case 0: {"Players"}; case 1: {"AI"}; case 2: {"Both"}; default {"Players"} }
    ];
};

_trigger
