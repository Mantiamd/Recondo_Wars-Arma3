/*
    Recondo_fnc_teleportToRally
    Teleport player to a rally point
    
    Description:
        Teleports the player to the specified rally point position.
        Verifies the rally still exists before teleporting.
    
    Parameters:
        0: OBJECT - Player to teleport
        1: HASHMAP - Rally data containing position info
    
    Returns:
        BOOL - True if teleport successful
    
    Execution:
        Client only
*/

params [["_player", objNull, [objNull]], ["_rallyData", nil]];

if (isNull _player) exitWith { false };
if (isNil "_rallyData") exitWith { 
    hint "Error: Invalid rally point data!";
    false 
};

private _settings = RECONDO_DRP_SETTINGS;
if (isNil "_settings") exitWith {
    hint "Rally point system not initialized!";
    false
};

private _enableDebug = _settings get "enableDebug";

// ========================================
// VERIFY RALLY STILL EXISTS
// ========================================

private _tentNetId = _rallyData get "tentNetId";
private _tent = objNull;

if (!isNil "_tentNetId" && {_tentNetId != ""}) then {
    _tent = objectFromNetId _tentNetId;
};

if (isNull _tent) exitWith {
    hint "This rally point is no longer available.";
    
    if (_enableDebug) then {
        diag_log format ["[RECONDO_DRP] Teleport failed - tent no longer exists (netId: %1)", _tentNetId];
    };
    
    false
};

// ========================================
// GET POSITION
// ========================================

private _pos = _rallyData get "position";

if (isNil "_pos" || {_pos isEqualTo [0,0,0]}) exitWith {
    hint "Error: Invalid rally point position!";
    false
};

// ========================================
// TELEPORT PLAYER
// ========================================

// Find safe position near rally
private _safePos = _pos findEmptyPosition [0, 10, typeOf _player];

if (_safePos isEqualTo []) then {
    _safePos = _pos;
};

_player setPosATL _safePos;

// ========================================
// PROVIDE FEEDBACK
// ========================================

private _markerName = _rallyData get "markerName";

if (_enableDebug) then {
    diag_log format ["[RECONDO_DRP] Teleported %1 to rally at %2 (marker: %3)", name _player, _safePos, _markerName];
};

true
