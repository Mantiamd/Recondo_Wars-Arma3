/*
    Recondo_fnc_parseMessages
    Parses a multi-line message string into an array of message strings

    Description:
        Splits module message attributes (e.g. intel reveal messages) into
        one entry per line. Unlike Recondo_fnc_parseClassnames this does
        NOT split on commas, so messages can contain normal punctuation.

        Accepts both real newlines (Enter pressed in the Eden multi-line
        edit box) and the literal two-character sequence "\n" - config
        defaultValue strings cannot contain real newlines, so module
        defaults ship with literal "\n" separators.

    Parameters:
        0: STRING - Message text, one message per line

    Returns:
        ARRAY - Array of trimmed, non-empty message strings

    Example:
        ["First message.\nSecond message."] call Recondo_fnc_parseMessages;
        // Returns: ["First message.", "Second message."]
*/

params [["_input", "", [""]]];

if (_input isEqualTo "") exitWith { [] };

// Literal backslash-n -> real newline, then split on newlines only
private _normalized = _input regexReplace ["\\n", toString [10]];

((_normalized splitString (toString [10, 13])) apply { _x trim [" ", 0] }) select { _x != "" }
