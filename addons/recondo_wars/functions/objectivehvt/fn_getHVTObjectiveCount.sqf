/*
    Recondo_fnc_getHVTObjectiveCount
    Returns HVT objective status for Terminal display
    
    Description:
        Returns the count of remaining vs total HVT objectives
        for a given objective name.
    
    Parameters:
        _objectiveName - STRING - The objective name to query
    
    Returns:
        ARRAY - [remaining, total]
    
    Example:
        ["High Value Target"] call Recondo_fnc_getHVTObjectiveCount;
        // Returns [0, 1] if captured, [1, 1] if active
*/

params [["_objectiveName", "", [""]]];

if (_objectiveName == "") exitWith {
    [0, 0]
};

private _remaining = 0;
private _total = 0;

{
    private _settings = _x;
    private _name = _settings get "objectiveName";
    
    if (_name == _objectiveName) then {
        private _instanceId = _settings get "instanceId";
        
        _total = _total + 1;
        
        // Check if captured
        if !(_instanceId in RECONDO_HVT_CAPTURED) then {
            _remaining = _remaining + 1;
        };
    };
} forEach RECONDO_HVT_INSTANCES;

[_remaining, _total]
