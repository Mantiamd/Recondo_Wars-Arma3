/*
    Recondo_fnc_createJammerTrigger
    Creates proximity triggers for jammer composition and AI spawning
    
    Description:
        Creates two triggers: one for composition spawning at a larger radius,
        and one for AI spawning at a smaller radius. Handles both active
        and destroyed states.
    
    Parameters:
        _settings - HASHMAP - Module settings
        _markerId - STRING - Marker ID for this jammer
        _compData - ARRAY - Composition data [activeComp, destroyedComp, isModPath]
        _isDestroyed - BOOL - Whether the jammer is already destroyed
    
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [
    ["_settings", nil, [createHashMap]],
    ["_markerId", "", [""]],
    ["_compData", [], [[]]],
    ["_isDestroyed", false, [false]]
];

if (isNil "_settings" || _markerId == "" || count _compData == 0) exitWith {
    diag_log format ["[RECONDO_JAMMER] ERROR: Invalid parameters for createJammerTrigger - marker: %1, compData: %2", _markerId, _compData];
};

private _compositionTriggerRadius = _settings get "compositionTriggerRadius";
private _aiTriggerRadius = _settings get "aiTriggerRadius";
private _triggerSide = _settings get "triggerSide";
private _debugLogging = _settings get "debugLogging";

private _markerPos = getMarkerPos _markerId;

// ========================================
// COMPOSITION TRIGGER
// ========================================

private _compTrigger = createTrigger ["EmptyDetector", _markerPos, false];
_compTrigger setTriggerArea [_compositionTriggerRadius, _compositionTriggerRadius, 0, false];

// Set trigger activation based on side
private _activationStr = switch (_triggerSide) do {
    case "EAST": { "EAST" };
    case "WEST": { "WEST" };
    case "GUER": { "GUER" };
    case "ANY": { "ANY" };
    default { "WEST" };
};

_compTrigger setTriggerActivation [_activationStr, "PRESENT", true];

// Use variable-based approach to pass complex data
_compTrigger setVariable ["jammerSettings", _settings];
_compTrigger setVariable ["jammerMarkerId", _markerId];
_compTrigger setVariable ["jammerCompData", _compData];
_compTrigger setVariable ["jammerIsDestroyed", _isDestroyed];

_compTrigger setTriggerStatements [
    "this",
    "
        private _settings = thisTrigger getVariable 'jammerSettings';
        private _markerId = thisTrigger getVariable 'jammerMarkerId';
        private _compData = thisTrigger getVariable 'jammerCompData';
        private _isDestroyed = thisTrigger getVariable 'jammerIsDestroyed';
        [_settings, _markerId, _compData, _isDestroyed] call Recondo_fnc_spawnJammerComposition;
        deleteVehicle thisTrigger;
    ",
    ""
];

if (_debugLogging) then {
    diag_log format ["[RECONDO_JAMMER] Created composition trigger for %1 (radius: %2m, side: %3)", 
        _markerId, _compositionTriggerRadius, _triggerSide];
};

// ========================================
// AI TRIGGER (only for non-destroyed jammers with AI configured)
// ========================================

private _sentryClassnames = _settings get "sentryClassnames";
private _patrolClassnames = _settings get "patrolClassnames";

if (!_isDestroyed && (count _sentryClassnames > 0 || count _patrolClassnames > 0)) then {
    private _aiTrigger = createTrigger ["EmptyDetector", _markerPos, false];
    _aiTrigger setTriggerArea [_aiTriggerRadius, _aiTriggerRadius, 0, false];
    _aiTrigger setTriggerActivation [_activationStr, "PRESENT", true];
    
    _aiTrigger setVariable ["jammerSettings", _settings];
    _aiTrigger setVariable ["jammerMarkerId", _markerId];
    
    _aiTrigger setTriggerStatements [
        "this",
        "
            private _settings = thisTrigger getVariable 'jammerSettings';
            private _markerId = thisTrigger getVariable 'jammerMarkerId';
            private _pos = getMarkerPos _markerId;
            [_settings, _pos, _markerId] call Recondo_fnc_spawnJammerAI;
            deleteVehicle thisTrigger;
        ",
        ""
    ];
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_JAMMER] Created AI trigger for %1 (radius: %2m)", _markerId, _aiTriggerRadius];
    };
};
