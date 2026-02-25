/*
    Recondo_fnc_matchesPattern
    Checks if a classname matches a pattern (supports wildcards)
    
    Description:
        Compares a classname against a pattern string.
        Supports wildcard (*) matching for flexible filtering.
        
        Pattern examples:
        - "HandGrenade"    -> Exact match only
        - "*grenade*"      -> Contains "grenade" anywhere (case-insensitive)
        - "vn_m67*"        -> Starts with "vn_m67"
        - "*_mine"         -> Ends with "_mine"
    
    Parameters:
        0: STRING - Classname to check
        1: STRING - Pattern to match against
        
    Returns:
        BOOL - True if classname matches pattern
*/

params [
    ["_classname", "", [""]],
    ["_pattern", "", [""]]
];

// Empty pattern matches nothing
if (_pattern == "") exitWith { false };

// Empty classname matches nothing
if (_classname == "") exitWith { false };

// Convert both to lowercase for case-insensitive matching
private _classLower = toLower _classname;
private _patternLower = toLower _pattern;

// Check for wildcards
private _hasWildcard = "*" in _patternLower;

if (!_hasWildcard) then {
    // Exact match (case-insensitive)
    _classLower == _patternLower
} else {
    // Split pattern by wildcards
    private _parts = _patternLower splitString "*";
    
    // Filter out empty strings from consecutive wildcards
    _parts = _parts select { _x != "" };
    
    // If no parts after splitting, pattern was just "*" or "**" - matches everything
    if (count _parts == 0) exitWith { true };
    
    // Check if pattern starts with wildcard (doesn't need to match from beginning)
    private _startsWithWildcard = (_patternLower select [0, 1]) == "*";
    
    // Check if pattern ends with wildcard (doesn't need to match to end)
    private _endsWithWildcard = (_patternLower select [count _patternLower - 1, 1]) == "*";
    
    private _currentPos = 0;
    private _matches = true;
    
    {
        private _part = _x;
        private _partIndex = _forEachIndex;
        
        // Find this part in the classname starting from current position
        private _foundPos = _classLower find [_part, _currentPos];
        
        if (_foundPos == -1) then {
            // Part not found
            _matches = false;
        } else {
            // For first part without leading wildcard, must match from start
            if (_partIndex == 0 && !_startsWithWildcard && _foundPos != 0) then {
                _matches = false;
            };
            
            // Move position past this match
            _currentPos = _foundPos + count _part;
        };
        
        if (!_matches) then { breakTo "matchLoop" };
    } forEach _parts;
    
    scopeName "matchLoop";
    
    // For last part without trailing wildcard, must match to end
    if (_matches && !_endsWithWildcard) then {
        _matches = _currentPos == count _classLower;
    };
    
    _matches
}
