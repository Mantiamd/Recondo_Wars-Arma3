/*
    Recondo_fnc_parseClassnames
    Parses a comma-separated string into an array of trimmed strings
    
    Description:
        Takes a comma-separated string and returns an array of 
        individual classnames with whitespace trimmed.
        Used by both AI Tweaks and Player Options modules.
    
    Parameters:
        0: STRING - Comma-separated list of classnames
        
    Returns:
        ARRAY - Array of parsed classname strings
        
    Example:
        ["vn_b_men_sog_04, vn_b_men_sog_09"] call Recondo_fnc_parseClassnames;
        // Returns: ["vn_b_men_sog_04", "vn_b_men_sog_09"]
*/

params [["_input", "", [""]]];

if (_input isEqualTo "") exitWith { [] };

private _result = [];
private _items = _input splitString ",";

{
    // Trim spaces, tabs, newlines, carriage returns
    private _trimmed = _x trim [" " + toString [9, 10, 13], 0];
    if (_trimmed != "") then {
        _result pushBack _trimmed;
    };
} forEach _items;

_result
