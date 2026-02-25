/*
    Recondo_fnc_getRevealedTargets
    Gets all revealed targets for a group, optionally filtered by type
    
    Description:
        Returns an array of all targets that have been revealed to
        the specified group. Can optionally filter by target type.
    
    Parameters:
        _group - GROUP - Group to get revealed targets for (default: player's group)
        _type - STRING - Optional target type filter (empty = all types)
    
    Returns:
        ARRAY - Array of target data: [[type, id, pos, data, weight], ...]
    
    Example:
        // Get all revealed targets for player's group
        [group player] call Recondo_fnc_getRevealedTargets;
        
        // Get only weapon cache targets
        [group player, "WeaponCache"] call Recondo_fnc_getRevealedTargets;
*/

params [
    ["_group", grpNull, [grpNull]],
    ["_type", "", [""]]
];

// Default to player's group if not specified
if (isNull _group) then {
    if (hasInterface) then {
        _group = group player;
    };
};

if (isNull _group) exitWith {
    []
};

private _groupId = groupId _group;
private _revealedIds = RECONDO_INTEL_REVEALED getOrDefault [_groupId, []];

if (count _revealedIds == 0) exitWith {
    []
};

// Filter targets to only revealed ones
private _revealedTargets = RECONDO_INTEL_TARGETS select {
    private _targetId = _x select 1;
    _targetId in _revealedIds
};

// Apply type filter if specified
if (_type != "") then {
    _revealedTargets = _revealedTargets select {
        (_x select 0) == _type
    };
};

_revealedTargets
