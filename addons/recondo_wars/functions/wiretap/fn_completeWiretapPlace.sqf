/*
    Recondo_fnc_completeWiretapPlace
    Server-side: Completes wiretap placement
    
    Description:
        Marks the pole as having a wiretap, records placement time,
        and triggers the retrieve action to be added.
    
    Parameters:
        _pole - OBJECT - The pole with the wiretap
        _player - OBJECT - The player who placed it
*/

if (!isServer) exitWith {};

params [
    ["_pole", objNull, [objNull]],
    ["_player", objNull, [objNull]]
];

if (isNull _pole) exitWith {};

private _debugLogging = RECONDO_WIRETAP_SETTINGS get "debugLogging";
private _textPlaced = RECONDO_WIRETAP_SETTINGS get "textPlaced";
private _poleHeight = RECONDO_WIRETAP_SETTINGS get "poleHeight";
private _groundWiretapDistance = RECONDO_WIRETAP_SETTINGS get "groundWiretapDistance";
private _groundWiretapClassname = RECONDO_WIRETAP_SETTINGS get "groundWiretapClassname";

// Mark pole as having active wiretap
_pole setVariable ["RECONDO_WIRETAP_hasWiretap", true, true];
_pole setVariable ["RECONDO_WIRETAP_placementTime", time, true];
_pole setVariable ["RECONDO_WIRETAP_placedBy", _player, true];

// Add to used poles list (one-time use)
RECONDO_WIRETAP_USED_POLES pushBack _pole;
publicVariable "RECONDO_WIRETAP_USED_POLES";

// ========================================
// CREATE ROPE AND GROUND WIRETAP ITEM
// ========================================

// Get pole position and road direction
private _polePos = getPosATL _pole;
private _dirToRoad = _pole getVariable ["RECONDO_WIRETAP_dirToRoad", 0];

// Calculate direction AWAY from road
// Note: _dirToRoad is actually the direction the pole was offset from road (i.e., already AWAY from road)
private _dirAwayFromRoad = _dirToRoad;

// Calculate ground position: configurable distance from pole base, away from road
private _groundPos = [_polePos select 0, _polePos select 1, 0] getPos [_groundWiretapDistance, _dirAwayFromRoad];
_groundPos set [2, 0]; // Ensure at ground level

// Create hidden helper at POLE TOP for rope attachment
// Must use Recondo_STABO_Helper (inherits from Helicopter_Base_F) for rope physics
private _topHelper = "Recondo_STABO_Helper" createVehicle [0, 0, 0];
_topHelper setPosATL [_polePos select 0, _polePos select 1, _poleHeight];
[_topHelper, true] remoteExec ["hideObjectGlobal", 2];
_topHelper allowDamage false;

// Create hidden helper at GROUND for rope attachment
// ropeCreate requires BOTH ends to be rope-compatible vehicles
private _bottomHelper = "Recondo_STABO_Helper" createVehicle [0, 0, 0];
_bottomHelper setPosATL _groundPos;
[_bottomHelper, true] remoteExec ["hideObjectGlobal", 2];
_bottomHelper allowDamage false;

// Create the visible ground wiretap item (purely visual, NOT attached to rope)
private _groundItem = _groundWiretapClassname createVehicle _groundPos;
_groundItem setPosATL _groundPos;
_groundItem setDir (random 360); // Random rotation for visual variety

// Calculate rope length (pole height + small buffer)
private _ropeLength = _poleHeight + 3;

// Create physics rope between the TWO HELPERS
private _rope = ropeCreate [
    _topHelper,
    [0, 0, 0],
    _bottomHelper,
    [0, 0, 0],
    _ropeLength
];

// Store references on pole for cleanup during retrieval
_pole setVariable ["RECONDO_WIRETAP_rope", _rope, true];
_pole setVariable ["RECONDO_WIRETAP_topHelper", _topHelper, true];
_pole setVariable ["RECONDO_WIRETAP_bottomHelper", _bottomHelper, true];
_pole setVariable ["RECONDO_WIRETAP_groundItem", _groundItem, true];

if (_debugLogging) then {
    diag_log format ["[RECONDO_WIRETAP] Created rope from pole top (%1m) to ground at %2", _poleHeight, _groundPos];
};

// ========================================
// END ROPE CREATION
// ========================================

// Add retrieve action to pole on all clients (with JIP)
[_pole] remoteExec ["Recondo_fnc_addWiretapRetrieveAction", 0, _pole];

// Notify player
[_textPlaced] remoteExec ["hint", _player];

// Note: Points are awarded when intel is turned in at base, not on placement

if (_debugLogging) then {
    diag_log format ["[RECONDO_WIRETAP] Player %1 placed wiretap on pole at %2", name _player, getPosATL _pole];
};
