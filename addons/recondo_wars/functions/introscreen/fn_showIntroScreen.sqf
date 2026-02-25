/*
    Recondo_fnc_showIntroScreen
    Displays the intro screen sequence
    
    Description:
        Shows black screen with story panels, then title card,
        then fades to gameplay. Uses cutText on layer 99 to
        ensure it displays on top of other effects.
    
    Parameters:
        _settings - HASHMAP - Intro screen settings
    
    Returns:
        Nothing
*/

if (!hasInterface) exitWith {};

params [["_settings", nil, [createHashMap]]];

if (isNil "_settings") exitWith {
    diag_log "[RECONDO_INTRO] ERROR: No settings provided";
};

// ========================================
// EXTRACT SETTINGS
// ========================================

private _missionTitle = _settings get "missionTitle";
private _titleSize = _settings get "titleSize";
private _titleColor = _settings get "titleColor";
private _subtitle = _settings get "subtitle";
private _subtitleColor = _settings get "subtitleColor";
private _storyPanels = _settings get "storyPanels";
private _storyTextColor = _settings get "storyTextColor";
private _initialDelay = _settings get "initialDelay";
private _panelDuration = _settings get "panelDuration";
private _titleDuration = _settings get "titleDuration";
private _fadeInTime = _settings get "fadeInTime";
private _muteAudio = _settings get "muteAudio";
private _debugLogging = _settings get "debugLogging";

// ========================================
// INITIALIZE BLACK SCREEN IMMEDIATELY
// ========================================

// Use cutText with layer 99 (highest priority) to cover everything
cutText ["", "BLACK FADED", 0, true, true];

// Disable radio chatter
enableRadio false;

// Mute audio if enabled
if (_muteAudio) then {
    0 fadeSpeech 0;
    0 fadeRadio 0;
    0 fadeSound 0;
};

if (_debugLogging) then {
    diag_log "[RECONDO_INTRO] Black screen initialized, starting sequence";
};

// ========================================
// INITIAL DELAY
// ========================================

sleep _initialDelay;

// ========================================
// SHOW STORY PANELS
// ========================================

{
    private _panelText = _x;
    
    // Skip empty panels
    if (_panelText != "") then {
        // Replace newlines with <br/> for proper display
        _panelText = _panelText regexReplace ["\r\n|\r|\n", "<br/>"];
        
        // Build formatted text
        private _formattedText = format [
            "<t color='%1' size='1.2'>%2</t>",
            _storyTextColor,
            _panelText
        ];
        
        cutText [_formattedText, "BLACK FADED", _panelDuration, true, true];
        
        if (_debugLogging) then {
            diag_log format ["[RECONDO_INTRO] Showing story panel %1", _forEachIndex + 1];
        };
        
        sleep _panelDuration;
        
        // Brief black between panels
        cutText ["", "BLACK FADED", 1, true, true];
        sleep 1;
    };
} forEach _storyPanels;

// ========================================
// SHOW TITLE CARD
// ========================================

// Build title card text
private _titleCardText = "";

// Add subtitle if provided
if (_subtitle != "") then {
    _titleCardText = format [
        "<t color='%1' size='1'>%2<br/>____________________</t><br/>",
        _subtitleColor,
        _subtitle
    ];
};

// Add main title
_titleCardText = _titleCardText + format [
    "<t color='%1' size='%2'>%3</t>",
    _titleColor,
    _titleSize,
    _missionTitle
];

cutText [_titleCardText, "BLACK FADED", -1, true, true];

if (_debugLogging) then {
    diag_log format ["[RECONDO_INTRO] Showing title card: %1", _missionTitle];
};

sleep _titleDuration;

// ========================================
// FADE IN AUDIO
// ========================================

if (_muteAudio) then {
    _fadeInTime fadeSpeech 1;
    _fadeInTime fadeRadio 1;
    _fadeInTime fadeSound 1;
};

enableRadio true;

// ========================================
// FADE TO GAMEPLAY
// ========================================

// Brief black before fade
cutText ["", "BLACK FADED", 1, true, true];
sleep 1;

// Fade in from black
cutText ["", "BLACK IN", _fadeInTime, true, true];
sleep _fadeInTime;

// Clear title text
cutText ["", "PLAIN", 0, true, true];

if (_debugLogging) then {
    diag_log "[RECONDO_INTRO] Intro sequence complete";
};
