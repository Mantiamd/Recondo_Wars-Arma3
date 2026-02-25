/*
    Recondo_fnc_revealIntel
    Reveals a random intel target to a player's group
    
    Description:
        Uses weighted random selection to pick an unrevealed target
        and reveals it to the player's group. Lower weight = higher
        chance of being selected.
        
        Weight calculation: tickets = 11 - weight
        Weight 1 = 10 tickets (easiest to reveal)
        Weight 10 = 1 ticket (hardest to reveal)
    
    Parameters:
        _player - OBJECT - The player turning in intel
    
    Returns:
        ARRAY - [success, targetData] where targetData is [type, id, pos, data, weight] or []
    
    Example:
        [player] call Recondo_fnc_revealIntel;
*/

params [["_player", objNull, [objNull]]];

if (isNull _player) exitWith {
    diag_log "[RECONDO_INTEL] ERROR: revealIntel - Null player provided";
    [false, []]
};

private _group = group _player;
private _groupId = groupId _group;
private _debugLogging = if (isNil "RECONDO_INTEL_SETTINGS") then { false } else { RECONDO_INTEL_SETTINGS getOrDefault ["debugLogging", false] };

// Get list of already revealed targets for this group
private _revealedForGroup = RECONDO_INTEL_REVEALED getOrDefault [_groupId, []];

// Filter to unrevealed and uncompleted targets
private _availableTargets = RECONDO_INTEL_TARGETS select {
    private _targetId = _x select 1;
    !(_targetId in _revealedForGroup) && !(_targetId in RECONDO_INTEL_COMPLETED)
};

if (count _availableTargets == 0) exitWith {
    if (_debugLogging) then {
        diag_log format ["[RECONDO_INTEL] revealIntel - No available targets for group %1", _groupId];
    };
    [false, []]
};

// Build weighted selection pool
// Weight 1 = 10 tickets, Weight 10 = 1 ticket
private _pool = [];
{
    _x params ["_type", "_id", "_pos", "_data", "_weight"];
    private _tickets = 11 - _weight; // weight 1 = 10, weight 10 = 1
    for "_i" from 1 to _tickets do {
        _pool pushBack _x;
    };
} forEach _availableTargets;

if (count _pool == 0) exitWith {
    [false, []]
};

// Random selection from pool
private _selectedTarget = selectRandom _pool;
_selectedTarget params ["_type", "_id", "_pos", "_data", "_weight"];

// Add to revealed list for this group
_revealedForGroup pushBack _id;
RECONDO_INTEL_REVEALED set [_groupId, _revealedForGroup];
publicVariable "RECONDO_INTEL_REVEALED";

// Save to persistence if enabled
private _enablePersistence = if (isNil "RECONDO_INTEL_SETTINGS") then { false } else { RECONDO_INTEL_SETTINGS getOrDefault ["enablePersistence", true] };
if (_enablePersistence) then {
    // Convert hashmap to array for saving
    private _revealedArray = [];
    {
        _revealedArray pushBack [_x, _y];
    } forEach RECONDO_INTEL_REVEALED;
    ["INTEL_REVEALED", _revealedArray] call Recondo_fnc_setSaveData;
    
    // Also save intel log
    ["INTEL_LOG", RECONDO_INTEL_LOG] call Recondo_fnc_setSaveData;
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_INTEL] Revealed target to group %1: type=%2, id=%3, pos=%4, weight=%5", 
        _groupId, _type, _id, _pos, _weight];
};

[true, _selectedTarget]
