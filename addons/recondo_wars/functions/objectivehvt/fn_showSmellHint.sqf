/*
    Recondo_fnc_showSmellHint
    Displays a smell hint message to the player
    
    Parameters:
        _message - STRING - The smell hint message to display
    
    Returns:
        Nothing
*/

if (!hasInterface) exitWith {};

params [["_message", "", [""]]];

diag_log format ["[RECONDO_HVT] showSmellHint called with message: %1", _message];

if (_message == "") exitWith {
    diag_log "[RECONDO_HVT] showSmellHint - empty message, exiting";
};

// Prevent overlapping hints - minimum 8 seconds between hints
private _lastHintTime = missionNamespace getVariable ["RECONDO_HVT_LastSmellHintTime", 0];
if (time - _lastHintTime < 8) exitWith {
    diag_log format ["[RECONDO_HVT] showSmellHint - cooldown active, skipping (last: %1, now: %2)", _lastHintTime, time];
};
missionNamespace setVariable ["RECONDO_HVT_LastSmellHintTime", time];

diag_log format ["[RECONDO_HVT] Displaying smell hint: %1", _message];

// Display as italic hint in top-right
hint parseText format ["<t color='#909090' shadow='1' shadowColor='#000000'>%1</t>", _message];

// Auto-clear after 25 seconds
[] spawn {
    sleep 25;
    hintSilent "";
};
