/*
    Recondo_fnc_clearNotebook
    Clears all notebook pages after player confirmation.
*/

if (!hasInterface) exitWith {};

if (isNil "RECONDO_NOTEBOOK_PAGES") exitWith {};

[] spawn {
    private _confirmed = [
        "Clear all notebook pages? This cannot be undone.",
        "Notebook",
        "Clear",
        "Cancel"
    ] call BIS_fnc_guiMessage;

    if (!_confirmed) exitWith {};

    RECONDO_NOTEBOOK_PAGES = [];
    RECONDO_NOTEBOOK_HEADERS = [];
    for "_i" from 0 to 11 do {
        RECONDO_NOTEBOOK_HEADERS pushBack "";
        RECONDO_NOTEBOOK_PAGES pushBack "";
    };

    RECONDO_NOTEBOOK_SPREAD = 0;
    call Recondo_fnc_notebookSaveData;

    if (!isNil "RECONDO_NOTEBOOK_OPEN" && {RECONDO_NOTEBOOK_OPEN}) then {
        closeDialog 0;
    };

    hint "Notebook cleared.";
};
