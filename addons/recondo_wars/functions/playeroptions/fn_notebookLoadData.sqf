/*
    Recondo_fnc_notebookLoadData
    Client-side: loads per-player notebook data from profileNamespace.
*/

if (!hasInterface) exitWith { false };

private _uid = getPlayerUID player;
if (_uid == "") exitWith {
    RECONDO_NOTEBOOK_HEADERS = [];
    RECONDO_NOTEBOOK_PAGES = [];
    for "_i" from 0 to 11 do {
        RECONDO_NOTEBOOK_HEADERS pushBack "";
        RECONDO_NOTEBOOK_PAGES pushBack "";
    };
    RECONDO_NOTEBOOK_SPREAD = 0;
    false
};

private _key = format ["RECONDO_NOTEBOOK_%1", _uid];
RECONDO_NOTEBOOK_KEY = _key;

private _saved = profileNamespace getVariable [_key, []];

private _headers = [];
private _pages = [];
private _spread = 0;

if (_saved isEqualType [] && {count _saved >= 3}) then {
    _headers = _saved param [0, [], [[]]];
    _pages = _saved param [1, [], [[]]];
    _spread = _saved param [2, 0, [0]];
} else {
    // Backward compatibility with older [pages, spread] format.
    if (_saved isEqualType [] && {count _saved >= 2}) then {
        _pages = _saved param [0, [], [[]]];
        _spread = _saved param [1, 0, [0]];
    };
};

if !(_headers isEqualType []) then {
    _headers = [];
};

if !(_pages isEqualType []) then {
    _pages = [];
};

while {count _headers < 12} do {
    _headers pushBack "";
};

if (count _headers > 12) then {
    _headers resize 12;
};

while {count _pages < 12} do {
    _pages pushBack "";
};

if (count _pages > 12) then {
    _pages resize 12;
};

// Keep the last visited spread index; final bounds are clamped in openNotebook
// after total spreads (including side/global image pages) are computed.
_spread = _spread max 0;

RECONDO_NOTEBOOK_HEADERS = _headers;
RECONDO_NOTEBOOK_PAGES = _pages;
RECONDO_NOTEBOOK_SPREAD = _spread;

true
