/*
    Recondo_fnc_getJammerCount
    Gets the count of active and total jammers for an objective
    
    Description:
        Returns the number of remaining (active) jammers and
        the total number of jammers for a given objective name.
    
    Parameters:
        _objectiveName - STRING - The objective name to count
    
    Returns:
        ARRAY - [remainingCount, totalCount]
*/

params [["_objectiveName", "", [""]]];

private _remaining = 0;
private _total = 0;

{
    _x params ["_instId", "_mrkId", "_comp", "_status"];
    
    // Check if this belongs to the requested objective
    private _settings = nil;
    {
        if ((_x get "instanceId") == _instId) exitWith {
            _settings = _x;
        };
    } forEach RECONDO_JAMMER_INSTANCES;
    
    if (!isNil "_settings") then {
        if ((_settings get "objectiveName") == _objectiveName) then {
            _total = _total + 1;
            if (_status == "active") then {
                _remaining = _remaining + 1;
            };
        };
    };
} forEach RECONDO_JAMMER_ACTIVE;

[_remaining, _total]
