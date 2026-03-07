/*
    Recondo_fnc_createPhotoSmellTrigger
    Creates a proximity trigger for smell hints at photo objective locations
    
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

if (isNil "_settings" || _marker == "") exitWith {};

private _smellHintRadius = _settings getOrDefault ["smellHintRadius", 200];
private _smellHintMessages = _settings getOrDefault ["smellHintMessages", []];
private _triggerSide = _settings get "triggerSide";
private _debugLogging = _settings get "debugLogging";

if (count _smellHintMessages == 0) exitWith {};

private _markerPos = getMarkerPos _marker;

private _sideStr = switch (toUpper _triggerSide) do {
    case "WEST": { "WEST" };
    case "EAST": { "EAST" };
    case "GUER": { "GUER" };
    default { "ANY" };
};

private _trigger = createTrigger ["EmptyDetector", _markerPos, true];
_trigger setTriggerArea [_smellHintRadius, _smellHintRadius, 0, false, 50];

if (_sideStr == "ANY") then {
    _trigger setTriggerActivation ["ANY", "PRESENT", true];
} else {
    _trigger setTriggerActivation [_sideStr, "PRESENT", true];
};

_trigger setVariable ["RECONDO_PHOTO_marker", _marker];
_trigger setVariable ["RECONDO_PHOTO_smellMessages", _smellHintMessages];
_trigger setVariable ["RECONDO_PHOTO_debugLogging", _debugLogging];

_trigger setTriggerStatements [
    "
        private _marker = thisTrigger getVariable 'RECONDO_PHOTO_marker';
        private _messages = thisTrigger getVariable 'RECONDO_PHOTO_smellMessages';
        private _debug = thisTrigger getVariable 'RECONDO_PHOTO_debugLogging';
        {
            if (isPlayer _x) then {
                private _playerUID = getPlayerUID _x;
                private _smellKey = format ['%1_%2', _marker, _playerUID];
                if !(_smellKey in RECONDO_PHOTO_SMELL_TRIGGERED) then {
                    RECONDO_PHOTO_SMELL_TRIGGERED pushBack _smellKey;
                    private _message = selectRandom _messages;
                    [_message] remoteExec ['Recondo_fnc_showPhotoSmellHint', _x];
                    if (_debug) then {
                        diag_log format ['[RECONDO_PHOTO] Smell hint triggered for %1 at %2', name _x, _marker];
                    };
                };
            };
        } forEach thisList;
        false
    ",
    "",
    ""
];

RECONDO_PHOTO_TRIGGERS pushBack _trigger;

if (_debugLogging) then {
    diag_log format ["[RECONDO_PHOTO] Created smell trigger at %1, radius: %2m", _marker, _smellHintRadius];
};
