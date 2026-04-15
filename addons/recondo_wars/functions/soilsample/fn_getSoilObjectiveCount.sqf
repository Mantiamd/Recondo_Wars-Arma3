/*
    Recondo_fnc_getSoilObjectiveCount
    Returns remaining and total counts for soil sample objectives

    Parameters:
        _markerName - STRING - Specific marker name, or "" for all objectives combined

    Returns:
        ARRAY - [remaining, total]
*/

params [["_markerName", "", [""]]];

private _settings = missionNamespace getVariable ["RECONDO_SOIL_SETTINGS", nil];
if (isNil "_settings") exitWith { [0, 0] };

private _samplesRequired = _settings get "samplesRequired";
private _turnedIn = missionNamespace getVariable ["RECONDO_SOIL_TURNED_IN", createHashMap];

if (_markerName != "") then {
    private _objData = _turnedIn getOrDefault [_markerName, nil];
    if (isNil "_objData") exitWith { [0, 0] };

    private _count = _objData get "turnedIn";
    private _remaining = (_samplesRequired - _count) max 0;
    [_remaining, _samplesRequired]
} else {
    private _totalRequired = 0;
    private _totalTurnedIn = 0;
    {
        _totalRequired = _totalRequired + _samplesRequired;
        _totalTurnedIn = _totalTurnedIn + (_y get "turnedIn");
    } forEach _turnedIn;

    private _remaining = (_totalRequired - _totalTurnedIn) max 0;
    [_remaining, _totalRequired]
};
