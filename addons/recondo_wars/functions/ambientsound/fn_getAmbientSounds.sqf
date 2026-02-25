/*
    Recondo_fnc_getAmbientSounds
    Returns array of available ambient sounds for a category
    
    Description:
        Returns the file paths for default ambient sounds
        based on the specified category.
    
    Parameters:
        _category - STRING - Sound category ("wildlife", etc.)
    
    Returns:
        ARRAY - Array of sound file paths
    
    Example:
        private _sounds = ["wildlife"] call Recondo_fnc_getAmbientSounds;
*/

params [["_category", "wildlife", [""]]];

private _sounds = [];

switch (toLower _category) do {
    case "wildlife": {
        _sounds = [
            "\recondo_wars\sounds\ambient\wildlife\monkeys_1.ogg",
            "\recondo_wars\sounds\ambient\wildlife\monkeys_2.ogg",
            "\recondo_wars\sounds\ambient\wildlife\monkeys_howling.ogg"
        ];
    };
    
    // Future categories can be added here
    // case "dogs": {
    //     _sounds = [
    //         "\recondo_wars\sounds\ambient\dogs\bark_alert_1.ogg",
    //         "\recondo_wars\sounds\ambient\dogs\bark_distant.ogg"
    //     ];
    // };
    // 
    // case "birds": {
    //     _sounds = [
    //         "\recondo_wars\sounds\ambient\birds\birds_startled_1.ogg"
    //     ];
    // };
    
    default {
        // Default to wildlife if category not found
        _sounds = [
            "\recondo_wars\sounds\ambient\wildlife\monkeys_1.ogg"
        ];
    };
};

_sounds
