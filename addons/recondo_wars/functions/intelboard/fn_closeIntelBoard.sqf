/*
    Recondo_fnc_closeIntelBoard
    Closes the Intel Board dialog
    
    Description:
        Closes the dialog which automatically cleans up all controls.
        The dialog's onUnload handler resets RECONDO_INTELBOARD_OPEN.
    
    Parameters:
        None
    
    Returns:
        Nothing
    
    Example:
        [] call Recondo_fnc_closeIntelBoard;
*/

if (!hasInterface) exitWith {};

// Check if open
if (isNil "RECONDO_INTELBOARD_OPEN" || {!RECONDO_INTELBOARD_OPEN}) exitWith {};

disableSerialization;

// Close the dialog - this automatically deletes all controls created on it
closeDialog 0;

// Clear uiNamespace variables
uiNamespace setVariable ["RECONDO_INTELBOARD_CONTROLS", nil];
uiNamespace setVariable ["RECONDO_INTELBOARD_LISTBOX", nil];
uiNamespace setVariable ["RECONDO_INTELBOARD_PHOTO_FRAME", nil];
uiNamespace setVariable ["RECONDO_INTELBOARD_PHOTO", nil];
uiNamespace setVariable ["RECONDO_INTELBOARD_NAME", nil];
uiNamespace setVariable ["RECONDO_INTELBOARD_STATUS", nil];
uiNamespace setVariable ["RECONDO_INTELBOARD_LOCATION", nil];
uiNamespace setVariable ["RECONDO_INTELBOARD_BACKGROUND", nil];
uiNamespace setVariable ["RECONDO_INTELBOARD_TARGETLIST", nil];

// Note: RECONDO_INTELBOARD_OPEN is reset by dialog's onUnload handler

private _settings = if (isNil "RECONDO_INTELBOARD_SETTINGS") then { createHashMap } else { RECONDO_INTELBOARD_SETTINGS };
private _debugLogging = _settings getOrDefault ["debugLogging", false];
if (_debugLogging) then {
    diag_log "[RECONDO_INTELBOARD] Intel Board closed";
};
