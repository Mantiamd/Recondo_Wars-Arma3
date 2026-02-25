/*
    Recondo_fnc_registerIntelTarget
    Registers a target with the intel system
    
    Description:
        Called by other modules (e.g., Weapon Caches, HVT) to register
        their targets with the central intel system. Registered targets
        can be revealed when intel is turned in.
    
    Parameters:
        _type - STRING - Target type identifier (e.g., "WeaponCache", "HVT")
        _id - STRING - Unique target identifier
        _pos - ARRAY - Position [x, y, z] of the target
        _data - ANY - Additional data specific to the target type (optional)
        _weight - NUMBER - Reveal weight 1-10 (1 = easiest, 10 = hardest) (default: 5)
    
    Returns:
        BOOL - True if registration successful
    
    Example:
        ["WeaponCache", "cache_001", getPos _cacheObject, _cacheData, 3] call Recondo_fnc_registerIntelTarget;
*/

params [
    ["_type", "", [""]],
    ["_id", "", [""]],
    ["_pos", [], [[]]],
    ["_data", nil],
    ["_weight", 5, [0]]
];

// Validate parameters
if (_type == "" || _id == "" || count _pos < 2) exitWith {
    diag_log format ["[RECONDO_INTEL] ERROR: registerIntelTarget - Invalid parameters: type=%1, id=%2, pos=%3", _type, _id, _pos];
    false
};

// Clamp weight to valid range
_weight = (_weight max 1) min 10;

// Check for duplicate ID
private _existingIndex = RECONDO_INTEL_TARGETS findIf { (_x select 1) == _id };
if (_existingIndex != -1) then {
    // Update existing entry
    RECONDO_INTEL_TARGETS set [_existingIndex, [_type, _id, _pos, _data, _weight]];
    
    private _debugLogging = if (isNil "RECONDO_INTEL_SETTINGS") then { false } else { RECONDO_INTEL_SETTINGS getOrDefault ["debugLogging", false] };
    if (_debugLogging) then {
        diag_log format ["[RECONDO_INTEL] Updated existing target: type=%1, id=%2, pos=%3, weight=%4", _type, _id, _pos, _weight];
    };
} else {
    // Add new entry
    RECONDO_INTEL_TARGETS pushBack [_type, _id, _pos, _data, _weight];
    
    private _debugLogging = if (isNil "RECONDO_INTEL_SETTINGS") then { false } else { RECONDO_INTEL_SETTINGS getOrDefault ["debugLogging", false] };
    if (_debugLogging) then {
        diag_log format ["[RECONDO_INTEL] Registered new target: type=%1, id=%2, pos=%3, weight=%4", _type, _id, _pos, _weight];
    };
};

publicVariable "RECONDO_INTEL_TARGETS";

true
