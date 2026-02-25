/*
    Recondo_fnc_openIntelBoard
    Creates and displays the Intel Board using dynamic controls
    
    Description:
        Creates a minimal dialog for cursor/input handling, then
        dynamically creates all UI controls on that dialog display.
        Hybrid approach: dialog for input, dynamic controls for flexibility.
    
    Parameters:
        None
    
    Returns:
        Nothing
    
    Example:
        [] call Recondo_fnc_openIntelBoard;
*/

if (!hasInterface) exitWith {};

// Check if already open
if (!isNil "RECONDO_INTELBOARD_OPEN" && {RECONDO_INTELBOARD_OPEN}) exitWith {
    diag_log "[RECONDO_INTELBOARD] Intel Board already open";
};

disableSerialization;

// Create the base dialog (provides cursor and input blocking)
if (!createDialog "Recondo_IntelBoard_Base") exitWith {
    diag_log "[RECONDO_INTELBOARD] ERROR: Could not create dialog";
};

// Get the dialog display
private _display = uiNamespace getVariable ["Recondo_IntelBoard_Display", displayNull];
if (isNull _display) exitWith {
    diag_log "[RECONDO_INTELBOARD] ERROR: Could not get dialog display";
};

// Mark as open
RECONDO_INTELBOARD_OPEN = true;

// Get settings
private _settings = if (isNil "RECONDO_INTELBOARD_SETTINGS") then { createHashMap } else { RECONDO_INTELBOARD_SETTINGS };
private _boardName = _settings getOrDefault ["boardName", "MISSION INTEL"];
private _debugLogging = _settings getOrDefault ["debugLogging", false];

// Get all objective data
private _boardData = [] call Recondo_fnc_getIntelBoardData;
private _categories = _boardData get "categories";
private _totalTargets = _boardData get "totalTargets";
private _remainingTargets = _boardData get "remainingTargets";

// ========================================
// LAYOUT CONSTANTS
// ========================================

private _screenX = safeZoneX;
private _screenY = safeZoneY;
private _screenW = safeZoneW;
private _screenH = safeZoneH;

// Main panel dimensions (80% of screen, centered)
private _panelX = _screenX + _screenW * 0.1;
private _panelY = _screenY + _screenH * 0.08;
private _panelW = _screenW * 0.8;
private _panelH = _screenH * 0.84;

// Sidebar dimensions
private _sidebarX = _panelX;
private _sidebarY = _panelY + _screenH * 0.05;
private _sidebarW = _screenW * 0.22;
private _sidebarH = _panelH - _screenH * 0.1;

// Detail panel dimensions
private _detailX = _panelX + _sidebarW + _screenW * 0.01;
private _detailY = _sidebarY;
private _detailW = _panelW - _sidebarW - _screenW * 0.02;
private _detailH = _sidebarH;

// Colors
private _bgColor = [0.05, 0.05, 0.05, 0.95];
private _titleBarColor = [0.15, 0.15, 0.15, 1];
private _sidebarColor = [0.08, 0.08, 0.08, 1];
private _detailColor = [0.06, 0.06, 0.06, 1];
private _overlayColor = [0, 0, 0, 0.7];

// ========================================
// CREATE CONTROLS
// ========================================

private _controls = [];

// Screen overlay (click to close)
private _overlay = _display ctrlCreate ["RscText", -1];
_overlay ctrlSetPosition [_screenX, _screenY, _screenW, _screenH];
_overlay ctrlSetBackgroundColor _overlayColor;
_overlay ctrlCommit 0;
_controls pushBack _overlay;

// Main background
private _bg = _display ctrlCreate ["RscText", -1];
_bg ctrlSetPosition [_panelX, _panelY, _panelW, _panelH];
_bg ctrlSetBackgroundColor _bgColor;
_bg ctrlCommit 0;
_controls pushBack _bg;

// Title bar background
private _titleBar = _display ctrlCreate ["RscText", -1];
_titleBar ctrlSetPosition [_panelX, _panelY, _panelW, _screenH * 0.05];
_titleBar ctrlSetBackgroundColor _titleBarColor;
_titleBar ctrlCommit 0;
_controls pushBack _titleBar;

// Title text
private _title = _display ctrlCreate ["RscStructuredText", -1];
_title ctrlSetPosition [_panelX + 0.01, _panelY + 0.005, _panelW * 0.7, _screenH * 0.045];
_title ctrlSetStructuredText parseText format ["<t color='#FFCC00' size='1.3' font='PuristaBold'>%1</t>", _boardName];
_title ctrlCommit 0;
_controls pushBack _title;

// Close instruction text
private _closeText = _display ctrlCreate ["RscStructuredText", -1];
_closeText ctrlSetPosition [_panelX + _panelW - 0.15, _panelY + 0.01, 0.14, _screenH * 0.035];
_closeText ctrlSetStructuredText parseText "<t color='#888888' size='0.9' align='right'>Press ESC to close</t>";
_closeText ctrlCommit 0;
_controls pushBack _closeText;

// Sidebar background
private _sidebarBg = _display ctrlCreate ["RscText", -1];
_sidebarBg ctrlSetPosition [_sidebarX, _sidebarY, _sidebarW, _sidebarH];
_sidebarBg ctrlSetBackgroundColor _sidebarColor;
_sidebarBg ctrlCommit 0;
_controls pushBack _sidebarBg;

// Detail panel background
private _detailBg = _display ctrlCreate ["RscText", -1];
_detailBg ctrlSetPosition [_detailX, _detailY, _detailW, _detailH];
_detailBg ctrlSetBackgroundColor _detailColor;
_detailBg ctrlCommit 0;
_controls pushBack _detailBg;

// Sidebar listbox
private _listbox = _display ctrlCreate ["RscListbox", -1];
_listbox ctrlSetPosition [_sidebarX + 0.005, _sidebarY + 0.01, _sidebarW - 0.01, _sidebarH - 0.02];
_listbox ctrlSetBackgroundColor [0, 0, 0, 0];
_listbox ctrlCommit 0;
_controls pushBack _listbox;

// Photo frame background (480:700 portrait aspect ratio)
private _photoFrame = _display ctrlCreate ["RscText", -1];
_photoFrame ctrlSetPosition [_detailX + 0.02, _detailY + 0.02, _screenH * 0.15, _screenH * 0.22];
_photoFrame ctrlSetBackgroundColor [0.15, 0.15, 0.15, 1];
_photoFrame ctrlShow false;
_photoFrame ctrlCommit 0;
_controls pushBack _photoFrame;

// Photo image (480x700 portrait photo - RscPicture scales image to fit control)
private _photo = _display ctrlCreate ["RscPicture", -1];
_photo ctrlSetPosition [_detailX + 0.025, _detailY + 0.025, _screenH * 0.14, _screenH * 0.205];
_photo ctrlShow false;
_photo ctrlCommit 0;
_controls pushBack _photo;

// Target name (positioned beside portrait photo)
private _nameCtrl = _display ctrlCreate ["RscStructuredText", -1];
_nameCtrl ctrlSetPosition [_detailX + 0.02 + _screenH * 0.17, _detailY + 0.02, _detailW - _screenH * 0.19 - 0.04, _screenH * 0.05];
_nameCtrl ctrlSetStructuredText parseText "<t color='#FFFFFF' size='1.4' font='PuristaBold'>Select a target</t>";
_nameCtrl ctrlCommit 0;
_controls pushBack _nameCtrl;

// Target status
private _statusCtrl = _display ctrlCreate ["RscStructuredText", -1];
_statusCtrl ctrlSetPosition [_detailX + 0.02 + _screenH * 0.17, _detailY + 0.07, _detailW - _screenH * 0.19 - 0.04, _screenH * 0.03];
_statusCtrl ctrlSetStructuredText parseText "";
_statusCtrl ctrlCommit 0;
_controls pushBack _statusCtrl;

// Target location
private _locationCtrl = _display ctrlCreate ["RscStructuredText", -1];
_locationCtrl ctrlSetPosition [_detailX + 0.02 + _screenH * 0.17, _detailY + 0.10, _detailW - _screenH * 0.19 - 0.04, _screenH * 0.025];
_locationCtrl ctrlSetStructuredText parseText "";
_locationCtrl ctrlCommit 0;
_controls pushBack _locationCtrl;

// Background info text (positioned below portrait photo)
private _backgroundCtrl = _display ctrlCreate ["RscStructuredText", -1];
_backgroundCtrl ctrlSetPosition [_detailX + 0.02, _detailY + _screenH * 0.26, _detailW - 0.04, _sidebarH - _screenH * 0.30];
_backgroundCtrl ctrlSetBackgroundColor [0.04, 0.04, 0.04, 0.5];
_backgroundCtrl ctrlSetStructuredText parseText "<t color='#888888'>Select a target from the sidebar to view detailed information.</t>";
_backgroundCtrl ctrlCommit 0;
_controls pushBack _backgroundCtrl;

// Footer text
private _footer = _display ctrlCreate ["RscStructuredText", -1];
_footer ctrlSetPosition [_panelX + 0.01, _panelY + _panelH - _screenH * 0.04, _panelW - 0.02, _screenH * 0.035];
private _footerText = if (_remainingTargets == 0 && _totalTargets > 0) then {
    "<t color='#88CC88'>All targets complete. Mission objectives achieved.</t>"
} else {
    format ["<t color='#AAAAAA'>%1 of %2 targets remaining</t>", _remainingTargets, _totalTargets]
};
_footer ctrlSetStructuredText parseText _footerText;
_footer ctrlCommit 0;
_controls pushBack _footer;

// Eldest Son sabotage display (if module is active)
if (!isNil "RECONDO_ELDESTSON_SETTINGS") then {
    private _eldestSonChance = if (isNil "RECONDO_ELDESTSON_CHANCE") then { 0 } else { RECONDO_ELDESTSON_CHANCE };
    private _maxChance = RECONDO_ELDESTSON_SETTINGS getOrDefault ["maxChance", 5];
    
    private _eldestSonCtrl = _display ctrlCreate ["RscStructuredText", -1];
    _eldestSonCtrl ctrlSetPosition [_panelX + _panelW - 0.25, _panelY + _panelH - _screenH * 0.04, 0.24, _screenH * 0.035];
    
    private _sabotageColor = if (_eldestSonChance >= _maxChance) then { "#88CC88" } else { "#FFCC00" };
    private _eldestSonText = format ["<t color='%1' align='right'>ELDEST SON: %2%%</t>", _sabotageColor, _eldestSonChance];
    
    _eldestSonCtrl ctrlSetStructuredText parseText _eldestSonText;
    _eldestSonCtrl ctrlCommit 0;
    _controls pushBack _eldestSonCtrl;
};

// ========================================
// STORE CONTROL REFERENCES
// ========================================

uiNamespace setVariable ["RECONDO_INTELBOARD_CONTROLS", _controls];
uiNamespace setVariable ["RECONDO_INTELBOARD_LISTBOX", _listbox];
uiNamespace setVariable ["RECONDO_INTELBOARD_PHOTO_FRAME", _photoFrame];
uiNamespace setVariable ["RECONDO_INTELBOARD_PHOTO", _photo];
uiNamespace setVariable ["RECONDO_INTELBOARD_NAME", _nameCtrl];
uiNamespace setVariable ["RECONDO_INTELBOARD_STATUS", _statusCtrl];
uiNamespace setVariable ["RECONDO_INTELBOARD_LOCATION", _locationCtrl];
uiNamespace setVariable ["RECONDO_INTELBOARD_BACKGROUND", _backgroundCtrl];

// ========================================
// POPULATE SIDEBAR
// ========================================

private _targetList = [];

{
    private _category = _x;
    private _categoryName = _category get "name";
    private _targets = _category get "targets";
    
    // Add category header
    private _headerIndex = _listbox lbAdd format ["═══ %1 ═══", _categoryName];
    _listbox lbSetColor [_headerIndex, [0.8, 0.7, 0.3, 1]];
    _listbox lbSetData [_headerIndex, "HEADER"];
    _targetList pushBack nil;
    
    // Add targets
    {
        private _target = _x;
        private _name = _target get "displayName";
        private _complete = _target get "complete";
        
        private _displayText = if (_complete) then {
            format ["  ✓ %1", _name]
        } else {
            format ["  ► %1", _name]
        };
        
        private _targetIndex = _listbox lbAdd _displayText;
        
        if (_complete) then {
            _listbox lbSetColor [_targetIndex, [0.5, 0.8, 0.5, 1]];
        } else {
            _listbox lbSetColor [_targetIndex, [0.9, 0.9, 0.9, 1]];
        };
        
        _listbox lbSetData [_targetIndex, str (count _targetList)];
        _targetList pushBack _target;
        
    } forEach _targets;
    
} forEach _categories;

// ========================================
// POPULATE INTEL LOG CATEGORY
// ========================================

private _intelLog = _boardData getOrDefault ["intelLog", []];

if (count _intelLog > 0) then {
    // Add Intel Log category header
    private _logHeaderIndex = _listbox lbAdd "═══ INTEL LOG ═══";
    _listbox lbSetColor [_logHeaderIndex, [0.5, 0.7, 0.9, 1]];
    _listbox lbSetData [_logHeaderIndex, "HEADER"];
    _targetList pushBack nil;
    
    // Add log entries (newest first, already sorted)
    {
        private _logEntry = _x;
        private _timestamp = _logEntry getOrDefault ["timestamp", ""];
        private _message = _logEntry getOrDefault ["message", ""];
        
        // Extract short date (MM-DD HH:MM) from full timestamp (YYYY-MM-DD HH:MM)
        private _shortDate = if (count _timestamp >= 16) then {
            (_timestamp select [5, 11])  // "MM-DD HH:MM"
        } else {
            _timestamp
        };
        
        // Truncate message for sidebar display
        private _truncatedMsg = if (count _message > 25) then {
            format ["%1...", _message select [0, 25]]
        } else {
            _message
        };
        
        private _displayText = format ["  • %1 - %2", _shortDate, _truncatedMsg];
        
        private _logIndex = _listbox lbAdd _displayText;
        _listbox lbSetColor [_logIndex, [0.7, 0.7, 0.7, 1]];
        
        // Store as a target entry with type "log"
        private _logTargetData = createHashMapFromArray [
            ["type", "log"],
            ["displayName", _shortDate],
            ["message", _message],
            ["timestamp", _timestamp],
            ["targetType", _logEntry getOrDefault ["targetType", ""]],
            ["targetName", _logEntry getOrDefault ["targetName", ""]],
            ["grid", _logEntry getOrDefault ["grid", ""]],
            ["source", _logEntry getOrDefault ["source", ""]]
        ];
        
        _listbox lbSetData [_logIndex, str (count _targetList)];
        _targetList pushBack _logTargetData;
        
    } forEach _intelLog;
};

uiNamespace setVariable ["RECONDO_INTELBOARD_TARGETLIST", _targetList];

// ========================================
// ADD LISTBOX EVENT HANDLER
// ========================================

_listbox ctrlAddEventHandler ["LBSelChanged", {
    params ["_ctrl", "_index"];
    [_ctrl, _index] call Recondo_fnc_updateIntelBoardDetail;
}];

// ========================================
// FADE IN
// ========================================
// Note: ESC key handling is automatic via dialog system (closeDialog)

{
    _x ctrlSetFade 1;
    _x ctrlCommit 0;
} forEach _controls;

{
    _x ctrlSetFade 0;
    _x ctrlCommit 0.3;
} forEach _controls;

// Select first non-header item
if (count _targetList > 0) then {
    private _firstIdx = -1;
    {
        if (!isNil "_x") exitWith { _firstIdx = _forEachIndex };
    } forEach _targetList;
    
    if (_firstIdx >= 0) then {
        _listbox lbSetCurSel (_firstIdx + 1); // +1 for header
    };
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_INTELBOARD] Opened Intel Board - Categories: %1, Targets: %2", count _categories, _totalTargets];
};
