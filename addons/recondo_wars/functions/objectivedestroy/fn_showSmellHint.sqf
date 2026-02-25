/*
    Recondo_fnc_showObjDestroySmellHint
    Displays a smell hint message to the player
    
    Parameters:
        _message - STRING - The smell hint message to display
    
    Returns:
        Nothing
*/

if (!hasInterface) exitWith {};

params [["_message", "", [""]]];

if (_message == "") exitWith {};

// Prevent overlapping hints - minimum 8 seconds between hints
private _lastHintTime = missionNamespace getVariable ["RECONDO_OBJDESTROY_LastSmellHintTime", 0];
if (time - _lastHintTime < 8) exitWith {};
missionNamespace setVariable ["RECONDO_OBJDESTROY_LastSmellHintTime", time];

// Display hint in top-right
hint parseText format ["<t color='#909090' shadow='1' shadowColor='#000000'>%1</t>", _message];

// Auto-clear after 25 seconds
[] spawn {
    sleep 25;
    hintSilent "";
};
