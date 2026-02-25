/*
    Recondo_fnc_completeWiretapRetrieve
    Server-side: Completes wiretap retrieval
    
    Description:
        Marks the pole as no longer having a wiretap,
        gives the player the reward item, and removes
        the retrieve action.
    
    Parameters:
        _pole - OBJECT - The pole the wiretap was on
        _player - OBJECT - The player who retrieved it
*/

if (!isServer) exitWith {};

params [
    ["_pole", objNull, [objNull]],
    ["_player", objNull, [objNull]]
];

if (isNull _pole || isNull _player) exitWith {};

private _debugLogging = RECONDO_WIRETAP_SETTINGS get "debugLogging";
private _textRetrieved = RECONDO_WIRETAP_SETTINGS get "textRetrieved";
private _rewardItem = RECONDO_WIRETAP_SETTINGS get "rewardItem";

// Mark pole as no longer having wiretap
_pole setVariable ["RECONDO_WIRETAP_hasWiretap", false, true];

// ========================================
// CLEAN UP ROPE AND GROUND WIRETAP ITEM
// ========================================

private _rope = _pole getVariable ["RECONDO_WIRETAP_rope", objNull];
private _topHelper = _pole getVariable ["RECONDO_WIRETAP_topHelper", objNull];
private _bottomHelper = _pole getVariable ["RECONDO_WIRETAP_bottomHelper", objNull];
private _groundItem = _pole getVariable ["RECONDO_WIRETAP_groundItem", objNull];

// Destroy the rope first
if (!isNull _rope) then {
    ropeDestroy _rope;
    if (_debugLogging) then {
        diag_log "[RECONDO_WIRETAP] Destroyed wiretap rope";
    };
};

// Delete the hidden helper at pole top
if (!isNull _topHelper) then {
    deleteVehicle _topHelper;
};

// Delete the hidden helper at ground
if (!isNull _bottomHelper) then {
    deleteVehicle _bottomHelper;
};

// Delete the visible ground wiretap item
if (!isNull _groundItem) then {
    deleteVehicle _groundItem;
    if (_debugLogging) then {
        diag_log "[RECONDO_WIRETAP] Deleted ground wiretap item";
    };
};

// Clear the stored references
_pole setVariable ["RECONDO_WIRETAP_rope", nil, true];
_pole setVariable ["RECONDO_WIRETAP_topHelper", nil, true];
_pole setVariable ["RECONDO_WIRETAP_bottomHelper", nil, true];
_pole setVariable ["RECONDO_WIRETAP_groundItem", nil, true];

// ========================================
// END ROPE CLEANUP
// ========================================

// Give reward item to player
if (_rewardItem != "") then {
    _player addItem _rewardItem;
    
    // Also register with Intel system if available
    if (!(_rewardItem in RECONDO_INTEL_ITEMS)) then {
        RECONDO_INTEL_ITEMS pushBack _rewardItem;
        publicVariable "RECONDO_INTEL_ITEMS";
    };
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_WIRETAP] Player %1 received reward item: %2", name _player, _rewardItem];
    };
} else {
    diag_log format ["[RECONDO_WIRETAP] WARNING: No reward item configured, player %1 received nothing", name _player];
};

// Remove retrieve actions from pole (they won't be valid anymore anyway)
[_pole, 0, ["ACE_MainActions", "Recondo_RetrieveWiretap"]] remoteExec ["ace_interact_menu_fnc_removeActionFromObject", 0];
[_pole, 0, ["ACE_MainActions", "Recondo_CheckWiretapTime"]] remoteExec ["ace_interact_menu_fnc_removeActionFromObject", 0];

// Notify player
[_textRetrieved] remoteExec ["hint", _player];

if (_debugLogging) then {
    diag_log format ["[RECONDO_WIRETAP] Player %1 retrieved wiretap from pole at %2", name _player, getPosATL _pole];
};
