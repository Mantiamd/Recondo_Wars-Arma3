/*
    Recondo_fnc_showOPORD
    Client-side: Displays the imported OPORD text in a
    scrollable dialog.
*/

if (!hasInterface) exitWith {};

if (!isNil "RECONDO_OPORD_OPEN" && {RECONDO_OPORD_OPEN}) exitWith {};

if (isNil "RECONDO_OPORD_TEXT") exitWith {
    systemChat "[OPORD] No OPORD has been loaded.";
};

disableSerialization;

if (!createDialog "Recondo_OPORD_Base") exitWith {
    diag_log "[RECONDO_OPORD] ERROR: Could not create dialog";
};

private _display = uiNamespace getVariable ["Recondo_OPORD_Display", displayNull];
if (isNull _display) exitWith {};

RECONDO_OPORD_OPEN = true;

// ========================================
// RESOLVE OPORD TEXT
// ========================================

private _opordData = RECONDO_OPORD_TEXT;
private _fullText = "";
private _titleText = "OPERATIONS ORDER";

if (_opordData isEqualType "") then {
    _fullText = _opordData;
} else {
    if (_opordData isEqualType createHashMap) then {
        _titleText = _opordData getOrDefault ["title", "OPERATIONS ORDER"];
        private _sections = ["situation", "mission", "execution", "sustainment", "command"];
        private _sectionNames = ["1. SITUATION", "2. MISSION", "3. EXECUTION", "4. SUSTAINMENT", "5. COMMAND AND SIGNAL"];
        private _parts = [];
        {
            private _key = _x;
            private _name = _sectionNames select _forEachIndex;
            private _content = _opordData getOrDefault [_key, ""];
            if (_content != "") then {
                _parts pushBack format ["%1%2%3%2", _name, toString [10], _content];
            };
        } forEach _sections;
        _fullText = _parts joinString (toString [10] + toString [10]);
    };
};

if (_fullText == "") exitWith {
    closeDialog 0;
    systemChat "[OPORD] OPORD file is empty.";
};

// ========================================
// LAYOUT
// ========================================

private _screenW = safezoneW;
private _screenH = safezoneH;
private _panelW = _screenW * 0.55;
private _panelH = _screenH * 0.8;
private _panelX = safezoneX + (_screenW - _panelW) / 2;
private _panelY = safezoneY + (_screenH - _panelH) / 2;

// Background
private _bg = _display ctrlCreate ["RscText", -1];
_bg ctrlSetPosition [_panelX, _panelY, _panelW, _panelH];
_bg ctrlSetBackgroundColor [0.04, 0.04, 0.04, 0.95];
_bg ctrlCommit 0;

// Accent bar
private _accent = _display ctrlCreate ["RscText", -1];
_accent ctrlSetPosition [_panelX, _panelY, _panelW * 0.005, _panelH];
_accent ctrlSetBackgroundColor [0.2, 0.5, 0.2, 1];
_accent ctrlCommit 0;

// Title
private _title = _display ctrlCreate ["RscStructuredText", -1];
_title ctrlSetPosition [_panelX + 0.02, _panelY + 0.01, _panelW - 0.04, _screenH * 0.04];
private _titleFormatted = format ["<t color='#66AA66' size='1.4' font='PuristaBold'>%1</t>", toUpper _titleText];
_title ctrlSetStructuredText parseText _titleFormatted;
_title ctrlCommit 0;

// Separator
private _sep = _display ctrlCreate ["RscText", -1];
_sep ctrlSetPosition [_panelX + 0.015, _panelY + 0.05, _panelW - 0.03, 0.001];
_sep ctrlSetBackgroundColor [0.3, 0.3, 0.3, 0.5];
_sep ctrlCommit 0;

// OPORD text (scrollable)
private _textAreaH = _panelH - 0.11;
private _textCtrl = _display ctrlCreate ["RscStructuredText", 9411];
_textCtrl ctrlSetPosition [_panelX + 0.02, _panelY + 0.06, _panelW - 0.04, _textAreaH];

private _displayText = _fullText;
_displayText = _displayText regexReplace ["<", "&lt;"];
_displayText = _displayText regexReplace [">", "&gt;"];
_displayText = _displayText regexReplace [toString [10], "<br/>"];
_displayText = format ["<t color='#DDDDDD' size='0.9' font='PuristaLight'>%1</t>", _displayText];

_textCtrl ctrlSetStructuredText parseText _displayText;
_textCtrl ctrlCommit 0;

// Close button
private _btnY = _panelY + _panelH - 0.045;
private _btnH = 0.035;
private _btnW = _panelW * 0.2;

private _closeBtn = _display ctrlCreate ["RscButton", 9412];
_closeBtn ctrlSetPosition [_panelX + _panelW - _btnW - 0.02, _btnY, _btnW, _btnH];
_closeBtn ctrlSetText "CLOSE";
_closeBtn ctrlSetBackgroundColor [0.2, 0.2, 0.2, 0.8];
_closeBtn ctrlCommit 0;

_closeBtn ctrlAddEventHandler ["ButtonClick", {
    closeDialog 0;
}];
