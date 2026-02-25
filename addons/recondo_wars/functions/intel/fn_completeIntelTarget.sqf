/*
    Recondo_fnc_completeIntelTarget
    Marks a target as completed
    
    Description:
        Marks a target as completed (e.g., cache destroyed, HVT eliminated).
        Completed targets will not be revealed to any group in the future.
    
    Parameters:
        _id - STRING - Target identifier to mark as completed
    
    Returns:
        BOOL - True if successfully marked as completed
    
    Example:
        ["cache_001"] call Recondo_fnc_completeIntelTarget;
*/

params [["_id", "", [""]]];

if (_id == "") exitWith {
    diag_log "[RECONDO_INTEL] ERROR: completeIntelTarget - Empty ID provided";
    false
};

// Check if already completed
if (_id in RECONDO_INTEL_COMPLETED) exitWith {
    true // Already completed, return success
};

// Add to completed list
RECONDO_INTEL_COMPLETED pushBack _id;
publicVariable "RECONDO_INTEL_COMPLETED";

// Save to persistence if enabled
private _enablePersistence = if (isNil "RECONDO_INTEL_SETTINGS") then { false } else { RECONDO_INTEL_SETTINGS getOrDefault ["enablePersistence", true] };
if (_enablePersistence) then {
    ["INTEL_COMPLETED", RECONDO_INTEL_COMPLETED] call Recondo_fnc_setSaveData;
};

private _debugLogging = if (isNil "RECONDO_INTEL_SETTINGS") then { false } else { RECONDO_INTEL_SETTINGS getOrDefault ["debugLogging", false] };
if (_debugLogging) then {
    diag_log format ["[RECONDO_INTEL] Target marked as completed: %1", _id];
};

true
