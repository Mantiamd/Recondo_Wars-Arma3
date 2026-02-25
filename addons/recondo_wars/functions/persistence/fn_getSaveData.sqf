/*
    Recondo_fnc_getSaveData
    Retrieve data from persistence storage
    
    Description:
        Gets saved data from missionProfileNamespace using the provided tag.
        Returns default value if data doesn't exist.
    
    Parameters:
        0: STRING - Data type identifier (e.g., "markers", "playerstats")
        1: ANY - Default value to return if no data exists (default: [])
        
    Returns:
        ANY - Retrieved data or default value
        
    Example:
        private _markers = ["markers", []] call Recondo_fnc_getSaveData;
*/

params [["_dataType", "data", [""]], ["_default", []]];

// Get the save tag
private _tag = [_dataType] call Recondo_fnc_getSaveTag;

// Retrieve data from missionProfileNamespace
private _data = missionProfileNamespace getVariable [_tag, _default];

// Debug logging
if (!isNil "RECONDO_PERSISTENCE_SETTINGS") then {
    if (RECONDO_PERSISTENCE_SETTINGS get "enableDebug") then {
        private _dataCount = if (_data isEqualType []) then { count _data } else { 
            if (_data isEqualType createHashMap) then { count keys _data } else { 1 }
        };
        diag_log format ["[RECONDO_PERSISTENCE] getSaveData: %1 = %2 entries", _tag, _dataCount];
    };
};

_data
