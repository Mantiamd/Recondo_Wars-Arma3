/*
    Recondo_fnc_getObjectiveCount
    Returns the count of remaining and total objectives
    
    Description:
        API function to query objective status.
        Can filter by objective name or return all.
    
    Parameters:
        _objectiveName - STRING - Name of objective type to query, or "" for all
    
    Returns:
        ARRAY - [remaining, total]
    
    Examples:
        ["Weapons Cache"] call Recondo_fnc_getObjectiveCount;  // [3, 5] - 3 remaining of 5
        [""] call Recondo_fnc_getObjectiveCount;               // [7, 10] - all objectives combined
*/

params [["_objectiveName", "", [""]]];

private _remaining = 0;
private _total = 0;

{
    _x params ["_instanceId", "_markerId", "_composition", "_status"];
    
    // Get the objective name for this instance
    private _instObjName = "";
    {
        if ((_x get "instanceId") == _instanceId) exitWith {
            _instObjName = _x get "objectiveName";
        };
    } forEach RECONDO_OBJDESTROY_INSTANCES;
    
    // Filter by name if specified
    if (_objectiveName == "" || _instObjName == _objectiveName) then {
        _total = _total + 1;
        
        if (_status == "active") then {
            _remaining = _remaining + 1;
        };
    };
} forEach RECONDO_OBJDESTROY_ACTIVE;

[_remaining, _total]
