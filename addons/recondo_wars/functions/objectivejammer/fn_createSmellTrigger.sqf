/*
    Recondo_fnc_createJammerSmellTrigger
    Creates a proximity trigger for smell hints at jammer locations
    
    Description:
        Creates a trigger that shows an atmospheric smell hint when
        players approach a location. Only triggers once per player
        per location.
    
    Parameters:
        _settings - HASHMAP - Module settings
        _marker - STRING - Location marker name
    
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [
    ["_settings", nil, [createHashMap]],
    ["_marker", "", [""]]
];

if (isNil "_settings" || _marker == "") exitWith {
    diag_log "[RECONDO_JAMMER] ERROR: Invalid parameters for createSmellTrigger";
};

private _smellHintRadius = _settings getOrDefault ["smellHintRadius", 200];
private _smellHintMessages = _settings getOrDefault ["smellHintMessages", []];
private _triggerSide = _settings get "triggerSide";
private _debugLogging = _settings get "debugLogging";

// Validate messages
if (count _smellHintMessages == 0) exitWith {
    if (_debugLogging) then {
        diag_log format ["[RECONDO_JAMMER] No smell messages configured, skipping smell trigger at %1", _marker];
    };
};

private _markerPos = getMarkerPos _marker;

// Determine trigger activation side
private _sideStr = switch (toUpper _triggerSide) do {
    case "WEST": { "WEST" };
    case "EAST": { "EAST" };
    case "GUER": { "GUER" };
    default { "ANY" };
};

// Create smell trigger
private _trigger = createTrigger ["EmptyDetector", _markerPos, true];
_trigger setTriggerArea [_smellHintRadius, _smellHintRadius, 0, false, 50];

if (_sideStr == "ANY") then {
    _trigger setTriggerActivation ["ANY", "PRESENT", true];
} else {
    _trigger setTriggerActivation [_sideStr, "PRESENT", true];
};

// Store data on trigger
_trigger setVariable ["RECONDO_JAMMER_marker", _marker];
_trigger setVariable ["RECONDO_JAMMER_smellMessages", _smellHintMessages];
_trigger setVariable ["RECONDO_JAMMER_debugLogging", _debugLogging];

// Trigger condition and activation - each player only gets the hint once per marker
_trigger setTriggerStatements [
    "this",
    "
        private _marker = thisTrigger getVariable 'RECONDO_JAMMER_marker';
        private _messages = thisTrigger getVariable 'RECONDO_JAMMER_smellMessages';
        private _debug = thisTrigger getVariable 'RECONDO_JAMMER_debugLogging';
        {
            if (isPlayer _x) then {
                private _playerUID = getPlayerUID _x;
                private _smellKey = format ['%1_%2', _marker, _playerUID];
                if !(_smellKey in RECONDO_JAMMER_SMELL_TRIGGERED) then {
                    RECONDO_JAMMER_SMELL_TRIGGERED pushBack _smellKey;
                    private _message = selectRandom _messages;
                    [_message] remoteExec ['Recondo_fnc_showJammerSmellHint', _x];
                    if (_debug) then {
                        diag_log format ['[RECONDO_JAMMER] Smell hint triggered for %1 at %2', name _x, _marker];
                    };
                };
            };
        } forEach thisList;
    ",
    ""
];

// Track trigger
RECONDO_JAMMER_TRIGGERS pushBack _trigger;

if (_debugLogging) then {
    diag_log format ["[RECONDO_JAMMER] Created smell trigger at %1, radius: %2m, messages: %3", 
        _marker, _smellHintRadius, count _smellHintMessages];
};
