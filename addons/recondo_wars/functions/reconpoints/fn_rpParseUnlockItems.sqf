/*
    Recondo_fnc_rpParseUnlockItems
    Parse unlock items configuration string
    
    Description:
        Parses a multi-line string of unlock items into an array.
        Each line should be: classname, Display Name, cost
        
        Example input:
        "vn_m16_camo, M16 (Tiger Stripe), 25
         vn_m40a1, M40A1 Sniper, 100"
    
    Parameters:
        _raw - STRING - Raw configuration string from module attribute
    
    Returns:
        ARRAY - Array of [classname, displayName, cost] arrays
    
    Example:
        private _items = ["vn_m16, M16, 25\nvn_m40a1, M40A1, 100"] call Recondo_fnc_rpParseUnlockItems;
*/

params [["_raw", "", [""]]];

if (_raw == "") exitWith { [] };

private _result = [];

// Split by newlines and commas (handle both \n and actual newlines)
private _lines = _raw splitString (toString [10, 13]);

{
    private _line = _x trim [" ", 0];
    
    // Skip empty lines
    if (_line == "") then { continue; };
    
    // Split by comma
    private _parts = _line splitString ",";
    
    // Need at least 3 parts: classname, name, cost
    if (count _parts < 3) then {
        diag_log format ["[RECONDO_RP] WARNING: Invalid unlock item format (need classname, name, cost): %1", _line];
        continue;
    };
    
    private _classname = (_parts select 0) trim [" ", 0];
    private _displayName = (_parts select 1) trim [" ", 0];
    private _cost = parseNumber ((_parts select 2) trim [" ", 0]);
    
    // Validate
    if (_classname == "" || _displayName == "" || _cost <= 0) then {
        diag_log format ["[RECONDO_RP] WARNING: Invalid unlock item values: class='%1', name='%2', cost=%3", _classname, _displayName, _cost];
        continue;
    };
    
    _result pushBack [_classname, _displayName, _cost];
    
} forEach _lines;

_result
