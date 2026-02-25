/*
    Recondo_fnc_parseIntelItemsConfig
    Parses the intel items configuration string
    
    Description:
        Parses a multi-line configuration string with format:
        DisplayName:Classname:Weight
        
        Returns an array of item definitions.
    
    Parameters:
        _configString - STRING - The configuration string to parse
    
    Returns:
        ARRAY - Array of [displayName, classname, weight] arrays
    
    Example:
        private _items = ["Mobile Phone:ACE_Cellphone:5\nField Orders:ACE_Documents:3"] call Recondo_fnc_parseIntelItemsConfig;
*/

params [["_configString", "", [""]]];

if (_configString == "") exitWith { [] };

private _result = [];

// ========================================
// NORMALIZE ESCAPED NEWLINES
// ========================================
// Eden EditMulti controls often deliver literal \n sequences
// instead of actual newline characters. We need to convert them.

private _normalizedString = _configString;

// Replace literal backslash-n with actual LF character
// Loop through and replace each occurrence
private _searchSeq = toString [92, 110]; // backslash (92) + n (110)
private _replaceChar = toString [10];     // LF

private _idx = _normalizedString find _searchSeq;
while {_idx != -1} do {
    _normalizedString = (_normalizedString select [0, _idx]) + _replaceChar + (_normalizedString select [_idx + 2]);
    _idx = _normalizedString find _searchSeq;
};

// Split by newlines (LF and CR)
private _lines = _normalizedString splitString (toString [10, 13]);

{
    private _line = _x trim [" ", 0]; // Trim whitespace
    
    if (_line != "" && !(_line select [0, 2] == "//")) then {
        // Split by colon
        private _parts = _line splitString ":";
        
        if (count _parts >= 3) then {
            private _displayName = _parts select 0;
            private _classname = _parts select 1;
            private _weightStr = _parts select 2;
            
            // Trim whitespace from each part
            _displayName = _displayName trim [" ", 0];
            _classname = _classname trim [" ", 0];
            _weightStr = _weightStr trim [" ", 0];
            
            // Parse weight
            private _weight = parseNumber _weightStr;
            _weight = (_weight max 1) min 10; // Clamp to 1-10
            
            if (_displayName != "" && _classname != "") then {
                _result pushBack [_displayName, _classname, _weight];
            };
        } else {
            diag_log format ["[RECONDO_INTELITEMS] WARNING: Invalid config line (need DisplayName:Classname:Weight): %1", _line];
        };
    };
} forEach _lines;

_result
