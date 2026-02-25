/*
    Recondo_fnc_isVillageSpawned
    Check if a village's civilians are currently spawned
    
    Parameters:
        _markerName - STRING - Name of the village marker
    
    Returns:
        BOOL - True if village civilians are spawned
*/

params [["_markerName", "", [""]]];

if (_markerName == "") exitWith { false };

// Handle case where variable doesn't exist on clients
if (isNil "RECONDO_CIVPOL_VILLAGES") exitWith { false };

private _villageData = RECONDO_CIVPOL_VILLAGES getOrDefault [_markerName, createHashMap];
if (count keys _villageData == 0) exitWith { false };

_villageData getOrDefault ["spawned", false]
