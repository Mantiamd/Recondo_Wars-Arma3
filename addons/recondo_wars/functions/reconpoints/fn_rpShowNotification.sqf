/*
    Recondo_fnc_rpShowNotification
    Show RP notification to player
    
    Description:
        Displays a notification to the player about points earned/lost.
        Uses systemChat and hint for visibility.
        Client-side function.
    
    Parameters:
        _message - STRING - The notification message
        _amount - NUMBER - Point amount (positive = gained, negative = lost)
    
    Returns:
        Nothing
    
    Example:
        ["+25 Recon Points (HVT)", 25] call Recondo_fnc_rpShowNotification;
*/

params [["_message", "", [""]], ["_amount", 0, [0]]];

if (!hasInterface) exitWith {};

// Get current points for display
private _currentPoints = 0;

if (!isNil "RECONDO_RP_PLAYER_DATA") then {
    private _uid = getPlayerUID player;
    if (_uid != "") then {
        private _data = RECONDO_RP_PLAYER_DATA getOrDefault [_uid, createHashMap];
        _currentPoints = _data getOrDefault ["points", 0];
    };
};

// Format display message
private _color = if (_amount >= 0) then { "#7FFF7F" } else { "#FF7F7F" };  // Green for gain, red for loss

// Show via systemChat with formatting
private _chatMsg = format ["[RP] %1 | Balance: %2", _message, _currentPoints];
systemChat _chatMsg;

// Optional: Show subtle hint
hint parseText format [
    "<t size='1.2' color='%1'>%2</t><br/><t size='0.9'>Balance: %3 RP</t>",
    _color,
    _message,
    _currentPoints
];

// Clear hint after a few seconds
[] spawn {
    sleep 4;
    hintSilent "";
};
