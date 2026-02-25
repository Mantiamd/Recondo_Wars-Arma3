/*
    Recondo_fnc_removeIntelTarget
    Removes a target from the intel system
    
    Description:
        Removes a registered target by its ID. Used when a target
        is destroyed or no longer valid.
    
    Parameters:
        _id - STRING - Unique target identifier to remove
    
    Returns:
        BOOL - True if target was found and removed
    
    Example:
        ["cache_001"] call Recondo_fnc_removeIntelTarget;
*/

params [["_id", "", [""]]];

if (_id == "") exitWith {
    diag_log "[RECONDO_INTEL] ERROR: removeIntelTarget - Empty ID provided";
    false
};

private _index = RECONDO_INTEL_TARGETS findIf { (_x select 1) == _id };

if (_index == -1) exitWith {
    private _debugLogging = if (isNil "RECONDO_INTEL_SETTINGS") then { false } else { RECONDO_INTEL_SETTINGS getOrDefault ["debugLogging", false] };
    if (_debugLogging) then {
        diag_log format ["[RECONDO_INTEL] removeIntelTarget - Target not found: %1", _id];
    };
    false
};

// Remove from targets array
RECONDO_INTEL_TARGETS deleteAt _index;
publicVariable "RECONDO_INTEL_TARGETS";

private _debugLogging = if (isNil "RECONDO_INTEL_SETTINGS") then { false } else { RECONDO_INTEL_SETTINGS getOrDefault ["debugLogging", false] };
if (_debugLogging) then {
    diag_log format ["[RECONDO_INTEL] Removed target: %1", _id];
};

true
