/*
    Recondo_fnc_getHubObjectiveCount
    Gets the count of remaining and total hub objectives
    
    Description:
        Returns the number of remaining (not destroyed) and total
        hub objectives for a given objective name.
    
    Parameters:
        _objectiveName - STRING - Name of the objective type
    
    Returns:
        ARRAY - [remaining, total]
    
    Example:
        private _counts = ["Command Post"] call Recondo_fnc_getHubObjectiveCount;
        _counts params ["_remaining", "_total"];
*/

params [["_objectiveName", "", [""]]];

if (_objectiveName == "") exitWith {
    diag_log "[RECONDO_HUBSUBS] ERROR: getHubObjectiveCount called with empty name";
    [0, 0]
};

private _total = 0;
private _remaining = 0;

// Find the instance settings
private _instanceId = "";
{
    if ((_x get "objectiveName") == _objectiveName) exitWith {
        _instanceId = _x get "instanceId";
    };
} forEach RECONDO_HUBSUBS_INSTANCES;

if (_instanceId == "") exitWith {
    // No instance found with this name
    [0, 0]
};

// Count from active tracking
{
    _x params ["_instId", "_mkr", "_comp", "_subMarkers", "_destroyed"];
    
    if (_instId == _instanceId || {_instId find _objectiveName >= 0}) then {
        _total = _total + 1;
        
        if (!_destroyed) then {
            _remaining = _remaining + 1;
        };
    };
} forEach RECONDO_HUBSUBS_ACTIVE;

[_remaining, _total]
