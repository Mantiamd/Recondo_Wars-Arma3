/*
    Recondo_fnc_showCampSmellHint
    Displays a smell hint to the player
    
    Description:
        Shows a formatted hint message indicating the player
        has detected a nearby campfire or smoke smell.
        Runs on client.
    
    Parameters:
        _message - STRING - The hint message to display
    
    Returns:
        Nothing
    
    Example:
        ["The smell of woodsmoke drifts on the breeze..."] call Recondo_fnc_showCampSmellHint;
*/

if (!hasInterface) exitWith {};

params [["_message", "", [""]]];

if (_message == "") exitWith {};

// Format and display hint
private _formattedHint = format [
    "<t size='1.1' color='#D4A574'>%1</t>",
    _message
];

hint parseText _formattedHint;

// Play subtle audio cue if ACE is available
if (!isNil "ace_common_fnc_playConfigSound") then {
    // Could play a subtle wind or ambient sound here
};
