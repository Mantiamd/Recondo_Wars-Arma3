/*
    Recondo_fnc_setSaveData
    Store data to persistence storage
    
    Description:
        Saves data to missionProfileNamespace using the provided tag.
        Does not call saveMissionProfileNamespace - that's done by saveMission.
    
    Parameters:
        0: STRING - Data type identifier (e.g., "markers", "playerstats")
        1: ANY - Data to save
        
    Returns:
        BOOL - True if successful
        
    Example:
        ["markers", _markersArray] call Recondo_fnc_setSaveData;
*/

params [["_dataType", "data", [""]], "_data"];

if (isNil "_data") exitWith {
    diag_log format ["[RECONDO_PERSISTENCE] setSaveData: Cannot save nil data for type '%1'", _dataType];
    false
};

// Get the save tag
private _tag = [_dataType] call Recondo_fnc_getSaveTag;

// Store data to missionProfileNamespace
missionProfileNamespace setVariable [_tag, _data];

// Debug logging
if (!isNil "RECONDO_PERSISTENCE_SETTINGS") then {
    if (RECONDO_PERSISTENCE_SETTINGS get "enableDebug") then {
        private _dataCount = if (_data isEqualType []) then { count _data } else { 
            if (_data isEqualType createHashMap) then { count keys _data } else { 1 }
        };
        diag_log format ["[RECONDO_PERSISTENCE] setSaveData: %1 = %2 entries", _tag, _dataCount];
    };
};

true
