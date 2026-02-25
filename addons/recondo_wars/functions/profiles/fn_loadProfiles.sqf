/*
    Recondo_fnc_loadProfiles
    Loads target profiles from .sqf files
    
    Description:
        Loads specified profile files from either the mod's default profiles
        or a custom mission folder path. Returns an array of profile hashmaps.
    
    Parameters:
        _profileType - STRING - "hvt" or "hostages"
        _profileList - ARRAY - Array of profile filenames to load (e.g., ["HVT1.sqf", "HVT2.sqf", "BadGuy.sqf"])
        _useCustom - BOOL - True to load from mission folder, false for mod defaults
        _customPath - STRING - Custom path in mission folder (e.g., "profiles\hvt")
        _debugLogging - BOOL - Enable debug logging
    
    Returns:
        ARRAY - Array of profile hashmaps
    
    Example:
        // Load specific HVT profiles from mod defaults
        private _profiles = ["hvt", ["HVT1.sqf", "HVT2.sqf", "HVT3.sqf"], false, "", false] call Recondo_fnc_loadProfiles;
        
        // Load custom hostage profiles from mission folder
        private _profiles = ["hostages", ["Journalist.sqf", "Mechanic.sqf"], true, "profiles\hostages", true] call Recondo_fnc_loadProfiles;
*/

params [
    ["_profileType", "hvt", [""]],
    ["_profileList", [], [[]]],
    ["_useCustom", false, [false]],
    ["_customPath", "", [""]],
    ["_debugLogging", false, [false]]
];

private _profiles = [];

if (count _profileList == 0) exitWith {
    diag_log "[RECONDO_PROFILES] ERROR: No profile filenames provided to loadProfiles";
    []
};

// Build base path
private _basePath = if (_useCustom && _customPath != "") then {
    // Mission folder path
    _customPath + "\"
} else {
    // Mod default path
    format ["\recondo_wars\profiles\%1\", toLower _profileType]
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_PROFILES] Loading %1 %2 profiles from: %3", count _profileList, _profileType, _basePath];
    diag_log format ["[RECONDO_PROFILES] Profile list: %1", _profileList];
};

// Load each specified profile
{
    private _fileName = _x;
    private _fullPath = _basePath + _fileName;
    
    private _profileData = createHashMap;
    
    // Try to load the profile file
    private _loadResult = if (_useCustom && _customPath != "") then {
        // Load from mission folder using loadFile
        private _code = loadFile _fullPath;
        if (_code != "") then {
            call compile _code
        } else {
            createHashMap
        }
    } else {
        // Load from mod using preprocessFileLineNumbers (more reliable for addon paths)
        private _code = preprocessFileLineNumbers _fullPath;
        if (!isNil "_code" && {_code != ""}) then {
            call compile _code
        } else {
            createHashMap
        }
    };
    
    // Validate the loaded profile
    if (!isNil "_loadResult" && {_loadResult isEqualType createHashMap} && {count keys _loadResult > 0}) then {
        // Add profile filename and index for reference
        _loadResult set ["profileFile", _fileName];
        _loadResult set ["profileIndex", _forEachIndex + 1];
        _profiles pushBack _loadResult;
        
        if (_debugLogging) then {
            private _name = _loadResult getOrDefault ["name", "Unknown"];
            diag_log format ["[RECONDO_PROFILES]   Loaded: %1 -> %2", _fileName, _name];
        };
    } else {
        if (_debugLogging) then {
            diag_log format ["[RECONDO_PROFILES]   WARNING: Failed to load profile from %1", _fullPath];
        };
    };
} forEach _profileList;

if (_debugLogging) then {
    diag_log format ["[RECONDO_PROFILES] Successfully loaded %1 of %2 requested profiles", count _profiles, count _profileList];
};

_profiles
