/*
    Recondo_fnc_selectRandomProfiles
    Randomly selects profiles from a loaded pool
    
    Description:
        Takes an array of profile hashmaps and randomly selects a specified
        number of them. Used to pick which HVTs or hostages will be active
        for the current mission.
    
    Parameters:
        _profiles - ARRAY - Array of profile hashmaps (from loadProfiles)
        _selectCount - NUMBER - How many profiles to select
        _debugLogging - BOOL - Enable debug logging
    
    Returns:
        ARRAY - Array of selected profile hashmaps
    
    Example:
        private _allProfiles = ["hvt", 10, false, "", false] call Recondo_fnc_loadProfiles;
        private _selected = [_allProfiles, 2, true] call Recondo_fnc_selectRandomProfiles;
*/

params [
    ["_profiles", [], [[]]],
    ["_selectCount", 1, [0]],
    ["_debugLogging", false, [false]]
];

if (count _profiles == 0) exitWith {
    diag_log "[RECONDO_PROFILES] ERROR: No profiles provided to selectRandomProfiles";
    []
};

// Clamp selection count to available profiles
private _actualCount = _selectCount min (count _profiles);

if (_actualCount < _selectCount && _debugLogging) then {
    diag_log format ["[RECONDO_PROFILES] WARNING: Requested %1 profiles but only %2 available", _selectCount, count _profiles];
};

// Shuffle and select
private _shuffled = _profiles call BIS_fnc_arrayShuffle;
private _selected = _shuffled select [0, _actualCount];

if (_debugLogging) then {
    diag_log format ["[RECONDO_PROFILES] Selected %1 profiles from pool of %2:", _actualCount, count _profiles];
    {
        private _name = _x getOrDefault ["name", "Unknown"];
        private _index = _x getOrDefault ["profileIndex", 0];
        diag_log format ["[RECONDO_PROFILES]   - %1 (Profile #%2)", _name, _index];
    } forEach _selected;
};

_selected
