/*
    Recondo_fnc_commanderMenuPanel
    Toggles the Behaviour / Formation fly-out sub-panel (officer's client)

    Description:
        Shows one sub-panel (Behaviour or Formation) and hides the other, along with
        the shared sub-panel background. "HIDE" collapses both. Buttons are already
        positioned by the dialog config, so this only flips visibility.

    Parameters:
        0: _which - STRING - "BEH" | "FORM" | "HIDE"

    Returns:
        Nothing
*/

if (!hasInterface) exitWith {};

params [["_which", "HIDE", [""]]];

private _dlg = findDisplay 58330;
if (isNull _dlg) exitWith {};

private _showBeh = _which == "BEH";
private _showForm = _which == "FORM";

{ (_dlg displayCtrl _x) ctrlShow _showBeh; } forEach [58350, 58351, 58352, 58353, 58354];
{ (_dlg displayCtrl _x) ctrlShow _showForm; } forEach [58360, 58361, 58362, 58363, 58364, 58365, 58366, 58367, 58368];

(_dlg displayCtrl 58348) ctrlShow (_showBeh || _showForm);

// Collapse the grid-entry box whenever a sub-panel is toggled (the Move handler
// re-shows it afterwards).
{ (_dlg displayCtrl _x) ctrlShow false; } forEach [58347, 58345, 58346];
