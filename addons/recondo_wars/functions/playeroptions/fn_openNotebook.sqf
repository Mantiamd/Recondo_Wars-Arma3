/*
    Recondo_fnc_openNotebook
    Client-side notebook UI with 4 spreads (8 pages).
*/

if (!hasInterface) exitWith {};
if (isNil "RECONDO_NOTEBOOK_PAGES") exitWith {};
if (isNil "RECONDO_NOTEBOOK_HEADERS") then {
    RECONDO_NOTEBOOK_HEADERS = [];
    for "_i" from 0 to 11 do {
        RECONDO_NOTEBOOK_HEADERS pushBack "";
    };
};

if (!isNil "RECONDO_NOTEBOOK_OPEN" && {RECONDO_NOTEBOOK_OPEN}) exitWith {};

disableSerialization;

if (!createDialog "Recondo_Notebook_Base") exitWith {
    diag_log "[RECONDO_NOTEBOOK] ERROR: Could not create dialog";
};

private _display = uiNamespace getVariable ["Recondo_Notebook_Display", displayNull];
if (isNull _display) exitWith {};

RECONDO_NOTEBOOK_OPEN = true;

// Reading pose, broadcast so nearby players see it. Only fires if TSP Animate
// is loaded; the handler itself no-ops otherwise, so this is safe either way.
if (!isNil "tsp_fnc_gesture_play") then {
    ["Recondo_notebookAnim", [player, true]] call CBA_fnc_globalEvent;
};

// Build read-only image spreads from mission-folder images.
// Side-specific pages (notebook\<side>\imageN.jpg) come first, then shared global
// pages (notebook\global\imageN.jpg). The scan probes a fixed range and skips gaps,
// so any image can be added/removed without breaking the sequence. Runs locally, so
// each client only loads its own side's images.
RECONDO_NOTEBOOK_WRITABLE_SPREADS = 6;
RECONDO_NOTEBOOK_IMAGES = [];

private _fnc_scanFolder = {
    params ["_folder"];
    private _result = [];
    for "_i" from 1 to 50 do {
        // Prefer .paa (native), fall back to .jpg so either format works per image.
        private _paa = format ["notebook\%1\image%2.paa", _folder, _i];
        private _jpg = format ["notebook\%1\image%2.jpg", _folder, _i];
        if (fileExists _paa) then {
            _result pushBack _paa;
        } else {
            if (fileExists _jpg) then {
                _result pushBack _jpg;
            };
        };
    };
    _result
};

private _sideFolder = switch (playerSide) do {
    case west:        { "blufor" };
    case east:        { "opfor" };
    case independent: { "ind" };
    case civilian:    { "civ" };
    default           { "" };
};

if (_sideFolder != "") then {
    RECONDO_NOTEBOOK_IMAGES append ([_sideFolder] call _fnc_scanFolder);
};
RECONDO_NOTEBOOK_IMAGES append (["global"] call _fnc_scanFolder);

RECONDO_NOTEBOOK_TOTAL_SPREADS = RECONDO_NOTEBOOK_WRITABLE_SPREADS + (count RECONDO_NOTEBOOK_IMAGES);
if !(RECONDO_NOTEBOOK_SPREAD isEqualType 0) then {
    RECONDO_NOTEBOOK_SPREAD = 0;
};
RECONDO_NOTEBOOK_SPREAD = (RECONDO_NOTEBOOK_SPREAD max 0) min (RECONDO_NOTEBOOK_TOTAL_SPREADS - 1);

private _screenW = safezoneW;
private _screenH = safezoneH;
private _panelScale = 0.55;
private _panelW = (_screenW * 0.68) * _panelScale;
private _panelH = (_screenH * 0.82) * _panelScale;
private _panelMarginX = 0.02;
private _panelMarginY = 0.02;
private _panelX = safezoneX + _screenW - _panelW - _panelMarginX;
private _panelY = safezoneY + _screenH - _panelH - _panelMarginY;
private _notebookTexture = "\recondo_wars\ui\MILITARY_NOTEBOOK_Blank.paa";

private _textureCtrl = _display ctrlCreate ["RscPicture", -1];
private _texX = _panelX + 0.01;
private _texY = _panelY + 0.045;
private _texW = _panelW - 0.02;
private _texH = _panelH - 0.11;
_textureCtrl ctrlSetPosition [_texX, _texY, _texW, _texH];
_textureCtrl ctrlSetText _notebookTexture;
_textureCtrl ctrlCommit 0;

private _spreadLabel = _display ctrlCreate ["RscStructuredText", 9650];
private _pageLabelX = _texX + (_texW * 0.800);
private _pageLabelY = _texY + (_texH * 0.004);
private _pageLabelW = _texW * (0.946 - 0.800);
private _pageLabelH = _texH * (0.040 - 0.004);
_spreadLabel ctrlSetPosition [_pageLabelX, _pageLabelY, _pageLabelW, _pageLabelH];
_spreadLabel ctrlCommit 0;

// Header/Body field rectangles (normalized to notebook texture bounds).
private _header1TL = [0.072, 0.063];
private _header1BR = [0.455, 0.103];
private _header2TL = [0.534, 0.062];
private _header2BR = [0.918, 0.103];
private _body1TL = [0.066, 0.112];
private _body1BR = [0.459, 0.852];
private _body2TL = [0.509, 0.115];
private _body2BR = [0.919, 0.855];
private _fieldLineStepN = 0.027;
private _headerFontH = (_fieldLineStepN * _texH) * 1.5;
private _bodyFontH = (_fieldLineStepN * _texH) * 1.0;

private _header1 = _display ctrlCreate ["RscEdit", 9651];
_header1 ctrlSetPosition [
    _texX + (_texW * (_header1TL select 0)),
    _texY + (_texH * (_header1TL select 1)),
    _texW * ((_header1BR select 0) - (_header1TL select 0)),
    _texH * ((_header1BR select 1) - (_header1TL select 1))
];
_header1 ctrlSetBackgroundColor [0.95, 0.92, 0.80, 0.03];
_header1 ctrlSetTextColor [0, 0, 0, 1];
_header1 ctrlSetFont "EtelkaMonospacePro";
_header1 ctrlSetFontHeight _headerFontH;
_header1 ctrlCommit 0;

private _header2 = _display ctrlCreate ["RscEdit", 9652];
_header2 ctrlSetPosition [
    _texX + (_texW * (_header2TL select 0)),
    _texY + (_texH * (_header2TL select 1)),
    _texW * ((_header2BR select 0) - (_header2TL select 0)),
    _texH * ((_header2BR select 1) - (_header2TL select 1))
];
_header2 ctrlSetBackgroundColor [0.95, 0.92, 0.80, 0.03];
_header2 ctrlSetTextColor [0, 0, 0, 1];
_header2 ctrlSetFont "EtelkaMonospacePro";
_header2 ctrlSetFontHeight _headerFontH;
_header2 ctrlCommit 0;

private _body1 = _display ctrlCreate ["RscEditMulti", 9653];
_body1 ctrlSetPosition [
    _texX + (_texW * (_body1TL select 0)),
    _texY + (_texH * (_body1TL select 1)),
    _texW * ((_body1BR select 0) - (_body1TL select 0)),
    _texH * ((_body1BR select 1) - (_body1TL select 1))
];
_body1 ctrlSetBackgroundColor [0.95, 0.92, 0.80, 0.03];
_body1 ctrlSetTextColor [0, 0, 0, 1];
_body1 ctrlSetFont "EtelkaMonospacePro";
_body1 ctrlSetFontHeight _bodyFontH;
_body1 ctrlCommit 0;

private _body2 = _display ctrlCreate ["RscEditMulti", 9654];
_body2 ctrlSetPosition [
    _texX + (_texW * (_body2TL select 0)),
    _texY + (_texH * (_body2TL select 1)),
    _texW * ((_body2BR select 0) - (_body2TL select 0)),
    _texH * ((_body2BR select 1) - (_body2TL select 1))
];
_body2 ctrlSetBackgroundColor [0.95, 0.92, 0.80, 0.03];
_body2 ctrlSetTextColor [0, 0, 0, 1];
_body2 ctrlSetFont "EtelkaMonospacePro";
_body2 ctrlSetFontHeight _bodyFontH;
_body2 ctrlCommit 0;

// Full two-page image control for read-only image spreads (hidden until shown).
private _imageCtrl = _display ctrlCreate ["RscPicture", 9655];
_imageCtrl ctrlSetPosition [
    _texX + (_texW * 0.066),
    _texY + (_texH * 0.062),
    _texW * (0.919 - 0.066),
    _texH * (0.855 - 0.062)
];
_imageCtrl ctrlShow false;
_imageCtrl ctrlCommit 0;

_display setVariable ["RECONDO_NOTEBOOK_HEADER1_CTRL", _header1];
_display setVariable ["RECONDO_NOTEBOOK_HEADER2_CTRL", _header2];
_display setVariable ["RECONDO_NOTEBOOK_BODY1_CTRL", _body1];
_display setVariable ["RECONDO_NOTEBOOK_BODY2_CTRL", _body2];
_display setVariable ["RECONDO_NOTEBOOK_IMAGE_CTRL", _imageCtrl];
_display setVariable ["RECONDO_NOTEBOOK_LABEL_CTRL", _spreadLabel];

private _prevTLN = [0.060, 0.857];
private _prevBRN = [0.148, 0.901];
private _btnW = _texW * ((_prevBRN select 0) - (_prevTLN select 0));
private _btnH = _texH * ((_prevBRN select 1) - (_prevTLN select 1));
private _btnFontH = _btnH * 0.75;

private _prevBtn = _display ctrlCreate ["RscButton", 9660];
private _prevX = _texX + (_texW * (_prevTLN select 0));
private _prevY = _texY + (_texH * (_prevTLN select 1));
_prevBtn ctrlSetPosition [_prevX, _prevY, _btnW, _btnH];
_prevBtn ctrlSetText "PREV";
_prevBtn ctrlSetFontHeight _btnFontH;
_prevBtn ctrlCommit 0;

private _nextBtn = _display ctrlCreate ["RscButton", 9661];
private _nextBRX = _texX + (_texW * 0.938);
private _nextBRY = _texY + (_texH * 0.901);
private _nextX = _nextBRX - _btnW;
private _nextY = _nextBRY - _btnH;
_nextBtn ctrlSetPosition [_nextX, _nextY, _btnW, _btnH];
_nextBtn ctrlSetText "NEXT";
_nextBtn ctrlSetFontHeight _btnFontH;
_nextBtn ctrlCommit 0;

private _clearBtn = _display ctrlCreate ["RscButton", 9662];
private _buttonTopCenterX = _texX + (_texW * 0.490);
private _clearY = _texY + (_texH * 0.908);
private _clearCloseGap = _texW * 0.012;
private _clearX = _buttonTopCenterX - (_btnW + (_clearCloseGap / 2));
_clearBtn ctrlSetPosition [_clearX, _clearY, _btnW, _btnH];
_clearBtn ctrlSetText "CLEAR ALL";
_clearBtn ctrlSetFontHeight _btnFontH;
_clearBtn ctrlCommit 0;

private _closeBtn = _display ctrlCreate ["RscButton", 9663];
private _closeX = _buttonTopCenterX + (_clearCloseGap / 2);
private _closeY = _clearY;
_closeBtn ctrlSetPosition [_closeX, _closeY, _btnW, _btnH];
_closeBtn ctrlSetText "CLOSE";
_closeBtn ctrlSetFontHeight _btnFontH;
_closeBtn ctrlCommit 0;

// Coordinate debug readout temporarily disabled.
private _coordDebug = false;

private _oldPFH = uiNamespace getVariable ["Recondo_NotebookCursorPFH", -1];
if (typeName _oldPFH == "SCALAR" && {_oldPFH >= 0}) then {
    [_oldPFH] call CBA_fnc_removePerFrameHandler;
};
uiNamespace setVariable ["Recondo_NotebookCursorPFH", -1];

if (_coordDebug) then {
    private _coordReadout = _display ctrlCreate ["RscText", 9657];
    _coordReadout ctrlSetPosition [_panelX + _panelW - 0.26, _panelY + 0.012, 0.24, 0.028];
    _coordReadout ctrlSetBackgroundColor [0, 0, 0, 0.45];
    _coordReadout ctrlSetTextColor [0.95, 0.6, 0.2, 1];
    _coordReadout ctrlSetText "NBX=---  NBY=---";
    _coordReadout ctrlCommit 0;
    _display setVariable ["RECONDO_NOTEBOOK_COORD_CTRL", _coordReadout];

    private _pfhId = [{
        params ["_args"];
        _args params ["_display", "_texX", "_texY", "_texW", "_texH"];

        if (isNull _display) exitWith {};

        private _txt = _display getVariable ["RECONDO_NOTEBOOK_COORD_CTRL", controlNull];
        if (isNull _txt) exitWith {};

        getMousePosition params ["_mx", "_my"];
        private _nx = (_mx - _texX) / _texW;
        private _ny = (_my - _texY) / _texH;

        private _nxs = if (_nx >= -0.1 && {_nx <= 1.1}) then { _nx toFixed 3 } else { "---" };
        private _nys = if (_ny >= -0.1 && {_ny <= 1.1}) then { _ny toFixed 3 } else { "---" };

        _txt ctrlSetText format ["NBX=%1  NBY=%2", _nxs, _nys];
    }, 0, [_display, _texX, _texY, _texW, _texH]] call CBA_fnc_addPerFrameHandler;
    uiNamespace setVariable ["Recondo_NotebookCursorPFH", _pfhId];
};

_display displayAddEventHandler ["Unload", {
    private _pfh = uiNamespace getVariable ["Recondo_NotebookCursorPFH", -1];
    if (typeName _pfh == "SCALAR" && {_pfh >= 0}) then {
        [_pfh] call CBA_fnc_removePerFrameHandler;
    };
    uiNamespace setVariable ["Recondo_NotebookCursorPFH", -1];

    // End the reading pose on every machine (matches the open broadcast).
    if (!isNil "tsp_fnc_gesture_stop") then {
        ["Recondo_notebookAnim", [player, false]] call CBA_fnc_globalEvent;
    };
}];

private _fnc_renderSpread = {
    params ["_display"];
    private _header1Ctrl = _display getVariable ["RECONDO_NOTEBOOK_HEADER1_CTRL", controlNull];
    private _header2Ctrl = _display getVariable ["RECONDO_NOTEBOOK_HEADER2_CTRL", controlNull];
    private _body1Ctrl = _display getVariable ["RECONDO_NOTEBOOK_BODY1_CTRL", controlNull];
    private _body2Ctrl = _display getVariable ["RECONDO_NOTEBOOK_BODY2_CTRL", controlNull];
    private _imageCtrl = _display getVariable ["RECONDO_NOTEBOOK_IMAGE_CTRL", controlNull];
    private _labelCtrl = _display getVariable ["RECONDO_NOTEBOOK_LABEL_CTRL", controlNull];

    if (isNull _header1Ctrl || isNull _header2Ctrl || isNull _body1Ctrl || isNull _body2Ctrl || isNull _labelCtrl) exitWith {};

    private _spread = RECONDO_NOTEBOOK_SPREAD;
    private _writable = RECONDO_NOTEBOOK_WRITABLE_SPREADS;
    private _total = RECONDO_NOTEBOOK_TOTAL_SPREADS;

    if (_spread >= _writable) then {
        // Read-only image spread: hide the writable controls and show the image.
        { _x ctrlShow false } forEach [_header1Ctrl, _header2Ctrl, _body1Ctrl, _body2Ctrl];
        if (!isNull _imageCtrl) then {
            private _imgPath = RECONDO_NOTEBOOK_IMAGES param [_spread - _writable, ""];
            _imageCtrl ctrlSetText _imgPath;
            _imageCtrl ctrlShow true;
        };
    } else {
        // Writable text spread.
        if (!isNull _imageCtrl) then { _imageCtrl ctrlShow false; };
        { _x ctrlShow true } forEach [_header1Ctrl, _header2Ctrl, _body1Ctrl, _body2Ctrl];

        private _leftPageIndex = _spread * 2;
        private _rightPageIndex = _leftPageIndex + 1;

        private _headers = RECONDO_NOTEBOOK_HEADERS;
        private _bodies = RECONDO_NOTEBOOK_PAGES;

        _header1Ctrl ctrlSetText (_headers param [_leftPageIndex, ""]);
        _header2Ctrl ctrlSetText (_headers param [_rightPageIndex, ""]);
        _body1Ctrl ctrlSetText (_bodies param [_leftPageIndex, ""]);
        _body2Ctrl ctrlSetText (_bodies param [_rightPageIndex, ""]);
    };

    _labelCtrl ctrlSetStructuredText parseText format ["<t align='center' color='#000000' size='0.75' font='PuristaSemibold'>PAGE %1 / %2</t>", _spread + 1, _total];
};

private _fnc_captureCurrentSpread = {
    params ["_display"];
    private _header1Ctrl = _display getVariable ["RECONDO_NOTEBOOK_HEADER1_CTRL", controlNull];
    private _header2Ctrl = _display getVariable ["RECONDO_NOTEBOOK_HEADER2_CTRL", controlNull];
    private _body1Ctrl = _display getVariable ["RECONDO_NOTEBOOK_BODY1_CTRL", controlNull];
    private _body2Ctrl = _display getVariable ["RECONDO_NOTEBOOK_BODY2_CTRL", controlNull];

    if (isNull _header1Ctrl || isNull _header2Ctrl || isNull _body1Ctrl || isNull _body2Ctrl) exitWith {};

    private _spread = RECONDO_NOTEBOOK_SPREAD;
    // Image spreads are read-only; nothing to capture.
    if (_spread >= RECONDO_NOTEBOOK_WRITABLE_SPREADS) exitWith {};

    private _leftPageIndex = _spread * 2;
    private _rightPageIndex = _leftPageIndex + 1;

    RECONDO_NOTEBOOK_HEADERS set [_leftPageIndex, ctrlText _header1Ctrl];
    RECONDO_NOTEBOOK_HEADERS set [_rightPageIndex, ctrlText _header2Ctrl];
    RECONDO_NOTEBOOK_PAGES set [_leftPageIndex, ctrlText _body1Ctrl];
    RECONDO_NOTEBOOK_PAGES set [_rightPageIndex, ctrlText _body2Ctrl];
};

_display setVariable ["RECONDO_NOTEBOOK_RENDER", _fnc_renderSpread];
_display setVariable ["RECONDO_NOTEBOOK_CAPTURE", _fnc_captureCurrentSpread];

[_display] call _fnc_renderSpread;

_prevBtn ctrlAddEventHandler ["ButtonClick", {
    params ["_ctrl"];
    private _display = ctrlParent _ctrl;
    private _capture = _display getVariable ["RECONDO_NOTEBOOK_CAPTURE", {}];
    [_display] call _capture;

    RECONDO_NOTEBOOK_SPREAD = (RECONDO_NOTEBOOK_SPREAD - 1) max 0;

    private _render = _display getVariable ["RECONDO_NOTEBOOK_RENDER", {}];
    [_display] call _render;
}];

_nextBtn ctrlAddEventHandler ["ButtonClick", {
    params ["_ctrl"];
    private _display = ctrlParent _ctrl;
    private _capture = _display getVariable ["RECONDO_NOTEBOOK_CAPTURE", {}];
    [_display] call _capture;

    RECONDO_NOTEBOOK_SPREAD = (RECONDO_NOTEBOOK_SPREAD + 1) min (RECONDO_NOTEBOOK_TOTAL_SPREADS - 1);

    private _render = _display getVariable ["RECONDO_NOTEBOOK_RENDER", {}];
    [_display] call _render;
}];

_clearBtn ctrlAddEventHandler ["ButtonClick", {
    params ["_ctrl"];
    private _display = ctrlParent _ctrl;
    private _capture = _display getVariable ["RECONDO_NOTEBOOK_CAPTURE", {}];
    [_display] call _capture;
    [] call Recondo_fnc_clearNotebook;
}];

_closeBtn ctrlAddEventHandler ["ButtonClick", {
    params ["_ctrl"];
    private _display = ctrlParent _ctrl;
    private _capture = _display getVariable ["RECONDO_NOTEBOOK_CAPTURE", {}];
    [_display] call _capture;
    call Recondo_fnc_notebookSaveData;
    closeDialog 0;
}];
