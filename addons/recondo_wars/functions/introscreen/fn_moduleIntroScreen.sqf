/*
    Recondo_fnc_moduleIntroScreen
    Main initialization for Intro Screen module
    
    Description:
        Reads module attributes and triggers the intro screen
        sequence on all clients with interface.
    
    Parameters:
        _logic - Module logic object
        _units - Synchronized units (unused)
        _activated - Whether module is activated
*/

params ["_logic", "_units", "_activated"];

// Validate activation
if (!_activated) exitWith {
    diag_log "[RECONDO_INTRO] Module not activated.";
};

// Only run on clients with interface
if (!hasInterface) exitWith {};

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

// Title settings
private _missionTitle = _logic getVariable ["missiontitle", "MISSION TITLE"];
private _titleSize = _logic getVariable ["titlesize", 5];
private _titleColor = _logic getVariable ["titlecolor", "#FFFFFF"];
private _subtitle = _logic getVariable ["subtitle", ""];
private _subtitleColor = _logic getVariable ["subtitlecolor", "#FFFFFF"];

// Story panels
private _storyPanel1 = _logic getVariable ["storypanel1", ""];
private _storyPanel2 = _logic getVariable ["storypanel2", ""];
private _storyPanel3 = _logic getVariable ["storypanel3", ""];
private _storyPanel4 = _logic getVariable ["storypanel4", ""];
private _storyPanel5 = _logic getVariable ["storypanel5", ""];
private _storyTextColor = _logic getVariable ["storytextcolor", "#FFFFFF"];

// Timing
private _initialDelay = _logic getVariable ["initialdelay", 3];
private _panelDuration = _logic getVariable ["panelduration", 10];
private _titleDuration = _logic getVariable ["titleduration", 6];
private _fadeInTime = _logic getVariable ["fadeintime", 3];

// Audio
private _muteAudio = _logic getVariable ["muteaudio", true];

// Debug
private _debugLogging = _logic getVariable ["debuglogging", false];

// ========================================
// BUILD SETTINGS ARRAY
// ========================================

private _settings = createHashMapFromArray [
    ["missionTitle", _missionTitle],
    ["titleSize", _titleSize],
    ["titleColor", _titleColor],
    ["subtitle", _subtitle],
    ["subtitleColor", _subtitleColor],
    ["storyPanels", [_storyPanel1, _storyPanel2, _storyPanel3, _storyPanel4, _storyPanel5]],
    ["storyTextColor", _storyTextColor],
    ["initialDelay", _initialDelay],
    ["panelDuration", _panelDuration],
    ["titleDuration", _titleDuration],
    ["fadeInTime", _fadeInTime],
    ["muteAudio", _muteAudio],
    ["debugLogging", _debugLogging]
];

// ========================================
// START INTRO SEQUENCE
// ========================================

// Run intro immediately in spawned context
[_settings] spawn Recondo_fnc_showIntroScreen;

if (_debugLogging) then {
    diag_log "[RECONDO_INTRO] Module initialized, starting intro sequence";
};
