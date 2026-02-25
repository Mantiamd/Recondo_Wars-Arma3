/*
    Recondo_fnc_showIntelCard
    
    Description:
        Displays a stylized intel notification card on screen.
        Used to provide visual feedback when intel is turned in.
        Supports optional face photo display for HVT/Hostage targets.
    
    Parameters:
        0: STRING - Card title (e.g., "INTEL RECEIVED")
        1: STRING - Card summary/body text (can be "" for none)
        2: NUMBER - Priority level: 0 = Primary, 1 = Secondary, 2 = Optional (default: 0)
        3: NUMBER - Display duration in seconds (default: 10)
        4: STRING - Sound classname from CfgSounds, or "" for default (default: "")
        5: NUMBER - Color index 0-7 for accent color (default: -1, auto based on priority)
        6: STRING - Photo path (optional, "" for no photo). Supports .paa, .jpg, .png. Recommended size: 480x700 (portrait)
    
    Color Index:
        0 - Orange/Gold
        1 - White
        2 - Green
        3 - Red
        4 - Blue
        5 - Yellow
        6 - Cyan
        7 - Purple
    
    Returns:
        Nothing
    
    Example:
        ["INTEL RECEIVED", "Enemy patrol schedules obtained.", 0, 10, "", 0] call Recondo_fnc_showIntelCard;
        ["NO INTEL", "You have no intel to turn in.", 2, 5, "", 3] call Recondo_fnc_showIntelCard;
        ["TARGET IDENTIFIED", "Warlord Kofi last seen near grid 03 85.", 0, 30, "", 2, "photos\hvt_kofi.paa"] call Recondo_fnc_showIntelCard;
*/

if (!hasInterface) exitWith {};

params [
    ["_title", "", [""]],
    ["_summary", "", [""]],
    ["_priority", 0, [0]],
    ["_duration", 10, [0]],
    ["_soundClass", "", [""]],
    ["_colorIndex", -1, [0]],
    ["_photoPath", "", [""]]
];

// Clamp duration to reasonable values
if (_duration <= 0) then { _duration = 10 };
if (_duration > 60) then { _duration = 60 };

// Open the intel card layer
"Recondo_IntelCard" cutRsc ["Recondo_IntelCard", "PLAIN"];

private _display = uiNamespace getVariable ["Recondo_IntelCard_Display", displayNull];
if (isNull _display) exitWith {
    diag_log "[RECONDO_INTEL] showIntelCard - Failed to create display";
};

// Get control references
private _bg = _display displayCtrl 9200;
private _accent = _display displayCtrl 9201;
private _titleCtrl = _display displayCtrl 9202;
private _tagCtrl = _display displayCtrl 9203;
private _textCtrl = _display displayCtrl 9205;
private _photoFrame = _display displayCtrl 9206;
private _photoImage = _display displayCtrl 9207;

// Set title text
_titleCtrl ctrlSetText toUpper _title;

// Set priority tag text
private _tagText = switch (_priority) do {
    case 0: { "PRIMARY" };
    case 1: { "SECONDARY" };
    case 2: { "OPTIONAL" };
    default { "INTEL" };
};
_tagCtrl ctrlSetText _tagText;

// Set summary text
_textCtrl ctrlSetStructuredText parseText _summary;

// Define color palette
private _colors = [
    [1, 0.7, 0, 1],      // 0 - Orange/Gold
    [1, 1, 1, 1],        // 1 - White
    [0, 0.85, 0.3, 1],   // 2 - Green
    [1, 0.2, 0.2, 1],    // 3 - Red
    [0.3, 0.6, 1, 1],    // 4 - Blue
    [1, 0.9, 0, 1],      // 5 - Yellow
    [0, 0.9, 0.9, 1],    // 6 - Cyan
    [0.7, 0.3, 1, 1]     // 7 - Purple
];

// Auto-select color based on priority if not specified
if (_colorIndex < 0 || _colorIndex > 7) then {
    _colorIndex = switch (_priority) do {
        case 0: { 0 };  // Primary = Orange
        case 1: { 4 };  // Secondary = Blue
        case 2: { 6 };  // Optional = Cyan
        default { 0 };
    };
};

private _accentColor = _colors select _colorIndex;

// Apply colors
_accent ctrlSetBackgroundColor _accentColor;
_titleCtrl ctrlSetTextColor _accentColor;

// === Dynamic sizing based on content ===
private _hasSummary = !(_summary isEqualTo "");
private _hasPhoto = !(_photoPath isEqualTo "");

// Get current positions
private _bgPos = ctrlPosition _bg;
private _accentPos = ctrlPosition _accent;
private _textPos = ctrlPosition _textCtrl;

// Base dimensions
private _baseHeight = safeZoneH * 0.08;
private _extraPadding = safeZoneH * 0.02;
private _totalHeight = _baseHeight;
private _photoWidth = safeZoneH * 0.06;   // 480:700 aspect ratio
private _photoHeight = safeZoneH * 0.088;

// Handle photo display
if (_hasPhoto) then {
    // Determine photo path - check for mission folder first, then mod default
    private _finalPhotoPath = _photoPath;
    
    // If no extension, try common formats
    if (!(".paa" in toLower _photoPath) && !(".jpg" in toLower _photoPath) && !(".png" in toLower _photoPath)) then {
        _finalPhotoPath = _photoPath + ".paa";
    };
    
    // Set photo image
    _photoImage ctrlSetText _finalPhotoPath;
    _photoFrame ctrlShow true;
    _photoImage ctrlShow true;
    
    // Adjust summary text position to be beside photo
    private _photoOffsetWidth = safeZoneH * 0.065;  // Photo width + small gap
    _textPos set [0, (_textPos select 0) + _photoOffsetWidth];
    _textPos set [2, (_textPos select 2) - _photoOffsetWidth];
    _textCtrl ctrlSetPosition _textPos;
    _textCtrl ctrlCommit 0;
} else {
    // Hide photo elements
    _photoFrame ctrlShow false;
    _photoImage ctrlShow false;
};

if (_hasSummary) then {
    // Show summary and calculate height
    _textCtrl ctrlShow true;
    
    // Get actual text height
    private _txtHeight = ctrlTextHeight _textCtrl;
    _textPos set [3, _txtHeight];
    _textCtrl ctrlSetPosition _textPos;
    _textCtrl ctrlCommit 0;
    
    // Adjust total height - account for photo if present
    if (_hasPhoto) then {
        _totalHeight = _baseHeight + (_photoHeight max _txtHeight) + _extraPadding;
    } else {
        _totalHeight = _baseHeight + _txtHeight + _extraPadding;
    };
} else {
    // Hide summary if empty
    _textCtrl ctrlShow false;
    if (_hasPhoto) then {
        _totalHeight = _baseHeight + _photoHeight + _extraPadding;
    } else {
        _totalHeight = _baseHeight - (safeZoneH * 0.02);
    };
};

// Update background and accent bar heights
_bgPos set [3, _totalHeight];
_bg ctrlSetPosition _bgPos;
_bg ctrlCommit 0;

_accentPos set [3, _totalHeight];
_accent ctrlSetPosition _accentPos;
_accent ctrlCommit 0;

// === Fade in animation ===
{
    _x ctrlSetFade 1;
    _x ctrlCommit 0;
} forEach [_bg, _accent, _titleCtrl, _tagCtrl, _textCtrl, _photoFrame, _photoImage];

{
    _x ctrlSetFade 0;
    _x ctrlCommit 0.3;
} forEach [_bg, _accent, _titleCtrl, _tagCtrl, _textCtrl, _photoFrame, _photoImage];

// Play notification sound
if (_soundClass != "") then {
    playSound _soundClass;
};

// Spawn fade out after duration
[_duration] spawn {
    params ["_duration"];
    
    uiSleep _duration;
    
    private _display = uiNamespace getVariable ["Recondo_IntelCard_Display", displayNull];
    if (isNull _display) exitWith {};
    
    private _bg = _display displayCtrl 9200;
    private _accent = _display displayCtrl 9201;
    private _titleCtrl = _display displayCtrl 9202;
    private _tagCtrl = _display displayCtrl 9203;
    private _textCtrl = _display displayCtrl 9205;
    private _photoFrame = _display displayCtrl 9206;
    private _photoImage = _display displayCtrl 9207;
    
    // Fade out animation
    {
        _x ctrlSetFade 1;
        _x ctrlCommit 0.5;
    } forEach [_bg, _accent, _titleCtrl, _tagCtrl, _textCtrl, _photoFrame, _photoImage];
    
    uiSleep 0.6;
    
    // Close the layer
    "Recondo_IntelCard" cutText ["", "PLAIN"];
};
