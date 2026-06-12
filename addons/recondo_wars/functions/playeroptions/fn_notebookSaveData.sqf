/*
    Recondo_fnc_notebookSaveData
    Client-side: persists current notebook data to profileNamespace.
*/

if (!hasInterface) exitWith { false };
if (isNil "RECONDO_NOTEBOOK_KEY") exitWith { false };
if (RECONDO_NOTEBOOK_KEY == "") exitWith { false };

private _headers = RECONDO_NOTEBOOK_HEADERS;
if !(_headers isEqualType []) then {
    _headers = [];
};

while {count _headers < 20} do {
    _headers pushBack "";
};

if (count _headers > 20) then {
    _headers resize 20;
};

private _pages = RECONDO_NOTEBOOK_PAGES;
if !(_pages isEqualType []) then {
    _pages = [];
};

while {count _pages < 20} do {
    _pages pushBack "";
};

if (count _pages > 20) then {
    _pages resize 20;
};

private _spread = RECONDO_NOTEBOOK_SPREAD;
if !(_spread isEqualType 0) then {
    _spread = 0;
};
_spread = (_spread max 0) min 9;

profileNamespace setVariable [RECONDO_NOTEBOOK_KEY, [_headers, _pages, _spread]];
saveProfileNamespace;

RECONDO_NOTEBOOK_HEADERS = _headers;
RECONDO_NOTEBOOK_PAGES = _pages;
RECONDO_NOTEBOOK_SPREAD = _spread;

true
