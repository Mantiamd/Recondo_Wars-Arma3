/*
    Recondo_fnc_isIntelRevealed
    Checks if a target has been revealed to a specific group
    
    Description:
        Returns whether the specified target ID has been revealed
        to the specified group.
    
    Parameters:
        _id - STRING - Target identifier to check
        _group - GROUP - Group to check reveal status for (default: player's group)
    
    Returns:
        BOOL - True if revealed to this group
    
    Example:
        ["cache_001", group player] call Recondo_fnc_isIntelRevealed;
*/

params [
    ["_id", "", [""]],
    ["_group", grpNull, [grpNull]]
];

if (_id == "") exitWith {
    false
};

// Default to player's group if not specified
if (isNull _group) then {
    if (hasInterface) then {
        _group = group player;
    } else {
        // Server with no player - can't determine group
        false
    };
};

if (isNull _group) exitWith {
    false
};

private _groupId = groupId _group;
private _revealedForGroup = RECONDO_INTEL_REVEALED getOrDefault [_groupId, []];

_id in _revealedForGroup
