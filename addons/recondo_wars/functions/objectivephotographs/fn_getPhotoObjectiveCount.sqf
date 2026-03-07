/*
    Recondo_fnc_getPhotoObjectiveCount
    Returns remaining and total count for photo objectives
    
    Parameters:
        _objectiveName - STRING - Objective name to check
    
    Returns:
        ARRAY - [remaining, total]
*/

params [["_objectiveName", "", [""]]];

private _remaining = 0;
private _total = 0;

{
    _x params ["_iId", "_mId", "_cData", "_status"];
    
    private _matchesName = false;
    {
        if ((_x get "instanceId") == _iId && {(_x get "objectiveName") == _objectiveName}) exitWith {
            _matchesName = true;
        };
    } forEach RECONDO_PHOTO_INSTANCES;
    
    if (_matchesName) then {
        _total = _total + 1;
        if (_status != "completed") then {
            _remaining = _remaining + 1;
        };
    };
} forEach RECONDO_PHOTO_ACTIVE;

[_remaining, _total]
