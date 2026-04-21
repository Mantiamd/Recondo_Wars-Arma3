/*
    Recondo_fnc_exportOPORDPrompt
    Client-side: Generates the OPORD prompt and displays it in a
    scrollable dialog with a "Copy to Clipboard" button.
*/

if (!hasInterface) exitWith {};

if (!isNil "RECONDO_OPORD_OPEN" && {RECONDO_OPORD_OPEN}) exitWith {};

disableSerialization;

// Generate the prompt
private _prompt = call Recondo_fnc_generateOPORDPrompt;

if (_prompt == "") exitWith {
    systemChat "[OPORD] No data available to generate prompt.";
};

// Create base dialog
if (!createDialog "Recondo_OPORD_Base") exitWith {
    diag_log "[RECONDO_OPORD] ERROR: Could not create dialog";
};

private _display = uiNamespace getVariable ["Recondo_OPORD_Display", displayNull];
if (isNull _display) exitWith {};

RECONDO_OPORD_OPEN = true;

// Store prompt for clipboard copy
uiNamespace setVariable ["Recondo_OPORD_PromptText", _prompt];

// ========================================
// LAYOUT
// ========================================

private _screenW = safezoneW;
private _screenH = safezoneH;
private _panelW = _screenW * 0.6;
private _panelH = _screenH * 0.8;
private _panelX = safezoneX + (_screenW - _panelW) / 2;
private _panelY = safezoneY + (_screenH - _panelH) / 2;

// Background
private _bg = _display ctrlCreate ["RscText", -1];
_bg ctrlSetPosition [_panelX, _panelY, _panelW, _panelH];
_bg ctrlSetBackgroundColor [0.05, 0.05, 0.05, 0.95];
_bg ctrlCommit 0;

// Accent bar
private _accent = _display ctrlCreate ["RscText", -1];
_accent ctrlSetPosition [_panelX, _panelY, _panelW * 0.005, _panelH];
_accent ctrlSetBackgroundColor [0.8, 0.6, 0.1, 1];
_accent ctrlCommit 0;

// Title
private _title = _display ctrlCreate ["RscStructuredText", -1];
_title ctrlSetPosition [_panelX + 0.02, _panelY + 0.01, _panelW - 0.04, _screenH * 0.04];
_title ctrlSetStructuredText parseText "<t color='#CCAA33' size='1.4' font='PuristaBold'>OPORD PROMPT GENERATOR</t>";
_title ctrlCommit 0;

// Subtitle
private _subtitle = _display ctrlCreate ["RscStructuredText", -1];
_subtitle ctrlSetPosition [_panelX + 0.02, _panelY + 0.045, _panelW - 0.04, _screenH * 0.03];
_subtitle ctrlSetStructuredText parseText "<t color='#888888' size='0.9'>Copy this prompt and paste it into an AI assistant (e.g., ChatGPT) to generate your OPORD.</t>";
_subtitle ctrlCommit 0;

// Separator
private _sep = _display ctrlCreate ["RscText", -1];
_sep ctrlSetPosition [_panelX + 0.015, _panelY + 0.075, _panelW - 0.03, 0.001];
_sep ctrlSetBackgroundColor [0.3, 0.3, 0.3, 0.5];
_sep ctrlCommit 0;

// Prompt text area (scrollable structured text)
private _textAreaH = _panelH - 0.14;
private _textCtrl = _display ctrlCreate ["RscStructuredText", 9401];
_textCtrl ctrlSetPosition [_panelX + 0.02, _panelY + 0.085, _panelW - 0.04, _textAreaH];

// Format prompt for display: escape < > and convert newlines to <br/>
private _displayText = _prompt;
_displayText = _displayText regexReplace ["<", "&lt;"];
_displayText = _displayText regexReplace [">", "&gt;"];
_displayText = _displayText regexReplace [toString [10], "<br/>"];
_displayText = format ["<t color='#CCCCCC' size='0.85' font='EtelkaMonospacePro'>%1</t>", _displayText];

_textCtrl ctrlSetStructuredText parseText _displayText;
_textCtrl ctrlCommit 0;

// ========================================
// BUTTONS
// ========================================

private _btnY = _panelY + _panelH - 0.045;
private _btnH = 0.035;
private _btnW = _panelW * 0.2;

// Copy to Clipboard button
private _copyBtn = _display ctrlCreate ["RscButton", 9402];
_copyBtn ctrlSetPosition [_panelX + 0.02, _btnY, _btnW, _btnH];
_copyBtn ctrlSetText "COPY TO CLIPBOARD";
_copyBtn ctrlSetBackgroundColor [0.3, 0.25, 0.05, 0.8];
_copyBtn ctrlCommit 0;

_copyBtn ctrlAddEventHandler ["ButtonClick", {
    private _text = uiNamespace getVariable ["Recondo_OPORD_PromptText", ""];
    copyToClipboard _text;
    systemChat "[OPORD] Prompt copied to clipboard.";
}];

// Close button
private _closeBtn = _display ctrlCreate ["RscButton", 9403];
_closeBtn ctrlSetPosition [_panelX + _panelW - _btnW - 0.02, _btnY, _btnW, _btnH];
_closeBtn ctrlSetText "CLOSE";
_closeBtn ctrlSetBackgroundColor [0.2, 0.2, 0.2, 0.8];
_closeBtn ctrlCommit 0;

_closeBtn ctrlAddEventHandler ["ButtonClick", {
    closeDialog 0;
}];
