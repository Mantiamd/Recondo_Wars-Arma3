/*
    Recondo_fnc_kitCarsonProcess
    Server-side intel transaction for a Kit Carson informant

    Description:
        The whole exchange runs here in one pass so concurrent players
        can't race each other:

        1. Depleted check - each informant reveals once per mission start
           (runtime flag only, never saved, so restarts reset it).
        2. Intel pre-check - the target pool is filtered for the player's
           group BEFORE anything is consumed, so a dry pool never costs
           the player their item or the informant's one reveal.
        3. Item requirement - the player must carry one instance of the
           configured classname (item, magazine, or weapon); it is
           consumed on their client where the inventory is local.
        4. Reveal - same weighted pick and group bookkeeping as an intel
           item turn-in (Recondo_fnc_revealIntel), announced to the whole
           group with the informant's intel line, and logged on the Intel
           Board with source "informant".

    Parameters:
        0: OBJECT - Informant NPC
        1: OBJECT - Interacting player

    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [["_npc", objNull, [objNull]], ["_player", objNull, [objNull]]];

if (isNull _npc || {isNull _player}) exitWith {};

private _cfg = _npc getVariable ["RECONDO_KITCARSON_CFG", []];
if (_cfg isEqualTo []) exitWith {};
_cfg params ["", "_requiredItem", "_demandLine", "_intelLine", "_depletedLine", "", "", "_debugLogging"];

private _title = toUpper name _npc;

// ========================================
// DEPLETED / INTEL AVAILABILITY
// ========================================

if (_npc getVariable ["RECONDO_KITCARSON_USED", false]) exitWith {
    [_title, _depletedLine, 2, 8, "", 3] remoteExec ["Recondo_fnc_showIntelCard", _player];
};

private _noTargetsText = if (isNil "RECONDO_INTEL_SETTINGS") then {
    "No actionable intelligence at this time."
} else {
    RECONDO_INTEL_SETTINGS getOrDefault ["turnInNoTargetsText", "No actionable intelligence at this time."]
};

if (isNil "RECONDO_INTEL_TARGETS") exitWith {
    [_title, _noTargetsText, 2, 8, "", 3] remoteExec ["Recondo_fnc_showIntelCard", _player];
    diag_log "[RECONDO_KITCARSON] WARNING: Intel module not initialized - informant has nothing to reveal.";
};

// Same filter revealIntel applies - checked BEFORE consuming anything so a
// dry pool never costs the player their item or the informant's one reveal
private _revealedForGroup = RECONDO_INTEL_REVEALED getOrDefault [groupId group _player, []];
private _available = RECONDO_INTEL_TARGETS select {
    private _targetId = _x select 1;
    !(_targetId in _revealedForGroup) && !(_targetId in RECONDO_INTEL_COMPLETED)
};

if (_available isEqualTo []) exitWith {
    [_title, _noTargetsText, 2, 8, "", 3] remoteExec ["Recondo_fnc_showIntelCard", _player];
    if (_debugLogging) then {
        diag_log format ["[RECONDO_KITCARSON] No unrevealed targets for group %1 - nothing consumed", groupId group _player];
    };
};

// ========================================
// ITEM REQUIREMENT
// ========================================

if (_requiredItem != "" && {
    private _wanted = toLower _requiredItem;
    ((items _player) + (magazines _player) + (weapons _player)) findIf { (toLower _x) == _wanted } == -1
}) exitWith {
    [_title, _demandLine, 2, 8, "", 5] remoteExec ["Recondo_fnc_showIntelCard", _player];
    if (_debugLogging) then {
        diag_log format ["[RECONDO_KITCARSON] %1 lacks required item '%2'", name _player, _requiredItem];
    };
};

if (_requiredItem != "") then {
    // Inventory commands need a local argument - consume on the player's client
    [_player, _requiredItem] remoteExec ["Recondo_fnc_kitCarsonConsume", _player];
};

// ========================================
// REVEAL
// ========================================

// Claim the one-time reveal before the (unscheduled, same-frame) reveal call
_npc setVariable ["RECONDO_KITCARSON_USED", true, true];

private _result = [_player] call Recondo_fnc_revealIntel;
_result params ["_success", "_targetData"];

// Pre-check makes this near-impossible; un-claim so the informant isn't wasted
if (!_success) exitWith {
    _npc setVariable ["RECONDO_KITCARSON_USED", false, true];
    [_title, _noTargetsText, 2, 8, "", 3] remoteExec ["Recondo_fnc_showIntelCard", _player];
};

_targetData params ["_type", "_id", "_pos", "_data", "_weight"];

private _grid = [_pos] call Recondo_fnc_posToGrid;
private _name = if (_data isEqualType createHashMap) then { _data getOrDefault ["name", "Unknown"] } else { "Unknown" };
if (_data isEqualType createHashMap && {(toLower _type) == "hvt"}) then {
    _name = _data getOrDefault ["hvtName", _name];
};

// Same default texts as an intel item turn-in
private _typeText = switch (toLower _type) do {
    case "hvt": { format ["Intel indicates %1 was spotted near grid %2.", _name, _grid] };
    case "hostage": { format ["Intel indicates hostages may be held near grid %1.", _grid] };
    case "cache": { format ["Supply cache identified near grid %1.", _grid] };
    case "objective": { format ["%1 reported near grid %2.", _name, _grid] };
    default { format ["Target position acquired: grid %1.", _grid] };
};

private _message = format ["<t color='#AAAAAA'>""%1""</t><br/><br/>%2", _intelLine, _typeText];

{
    if (isPlayer _x) then {
        [_title, _message, 0, 30, "", 2] remoteExec ["Recondo_fnc_showIntelCard", _x];
    };
} forEach units group _player;

// ========================================
// INTEL BOARD LOG
// ========================================

if (!isNil "RECONDO_INTEL_LOG") then {
    private _pad = { params ["_n"]; if (_n < 10) then { format ["0%1", _n] } else { str _n } };
    private _timeArray = systemTimeUTC;
    private _timestamp = format ["%1-%2-%3 %4:%5",
        _timeArray select 0,
        [_timeArray select 1] call _pad,
        [_timeArray select 2] call _pad,
        [_timeArray select 3] call _pad,
        [_timeArray select 4] call _pad
    ];

    private _logEntry = createHashMapFromArray [
        ["message", _typeText],
        ["timestamp", _timestamp],
        ["targetType", _type],
        ["targetName", _name],
        ["grid", _grid],
        ["source", "informant"]
    ];

    RECONDO_INTEL_LOG insert [0, [_logEntry]];
    RECONDO_INTEL_LOG_LATEST = _logEntry;
    publicVariable "RECONDO_INTEL_LOG_LATEST";

    private _enablePersistence = if (isNil "RECONDO_INTEL_SETTINGS") then { false } else { RECONDO_INTEL_SETTINGS getOrDefault ["enablePersistence", true] };
    if (_enablePersistence) then {
        ["INTEL_LOG", RECONDO_INTEL_LOG] call Recondo_fnc_setSaveData;
    };
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_KITCARSON] Informant %1 revealed %2 target %3 at grid %4 to group %5 (item consumed: '%6')",
        _npc, _type, _id, _grid, groupId group _player, _requiredItem];
};
