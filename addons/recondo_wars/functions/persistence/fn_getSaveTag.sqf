/*
    Recondo_fnc_getSaveTag
    Generate unique save tag for persistence data
    
    Description:
        Creates a unique tag string used as a key for storing data
        in missionProfileNamespace. Format: RECONDO_[campaignID]_[dataType]
    
    Parameters:
        0: STRING - Data type identifier (e.g., "markers", "playerstats")
        
    Returns:
        STRING - Unique save tag
        
    Example:
        private _tag = ["markers"] call Recondo_fnc_getSaveTag;
        // Returns: "RECONDO_MyMission_Tanoa_markers"
*/

params [["_dataType", "data", [""]]];

// Get campaign ID from settings
private _campaignID = "";

if (!isNil "RECONDO_PERSISTENCE_SETTINGS") then {
    _campaignID = RECONDO_PERSISTENCE_SETTINGS get "campaignID";
};

// Fallback if settings not available
if (_campaignID == "") then {
    _campaignID = format ["%1_%2", missionName, worldName];
    _campaignID = _campaignID regexReplace ["[^a-zA-Z0-9_]", "_"];
};

// Build and return the tag
private _tag = format ["RECONDO_%1_%2", _campaignID, _dataType];

_tag
