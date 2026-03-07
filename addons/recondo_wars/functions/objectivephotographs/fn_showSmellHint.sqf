/*
    Recondo_fnc_showPhotoSmellHint
    Displays a smell hint message to the player (client-side)
    
    Parameters:
        _message - STRING - The hint message to display
    
    Returns:
        Nothing
*/

if (!hasInterface) exitWith {};

params [["_message", "", [""]]];

if (_message == "") exitWith {};

private _lastHintTime = missionNamespace getVariable ["RECONDO_PHOTO_LastSmellHintTime", 0];
if (time - _lastHintTime < 8) exitWith {};
missionNamespace setVariable ["RECONDO_PHOTO_LastSmellHintTime", time];

hint parseText format ["<t color='#909090' shadow='1' shadowColor='#000000'>%1</t>", _message];

[] spawn {
    sleep 25;
    hintSilent "";
};
