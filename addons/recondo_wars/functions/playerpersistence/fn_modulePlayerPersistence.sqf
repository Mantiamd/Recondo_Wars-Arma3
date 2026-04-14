/*
    Recondo_fnc_modulePlayerPersistence
    Player Persistence module initialization

    Description:
        Resolves tracked units by Eden variable name, tags them for
        persistence tracking. Sets up HandleDisconnect to save on
        player leave and PlayerConnected to restore with configurable delay.
        Requires the Persistence module.

    Priority: 3 (runs after Persistence module)

    Parameters:
        _logic     - Module logic object
        _units     - Synchronized units (unused)
        _activated - Whether module is activated
*/

params ["_logic", "_units", "_activated"];

if (!isServer) exitWith {};

if (!_activated) exitWith {
    diag_log "[RECONDO_PLAYERPERSIST] Module not activated.";
};

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

private _debug = _logic getVariable ["debuglogging", false];
RECONDO_PLAYER_PERSISTENCE_DEBUG = _debug;
RECONDO_PLAYER_PERSISTENCE_ENABLED = true;
RECONDO_PLAYER_PERSISTENCE_DELAY = _logic getVariable ["restoredelay", 20];

private _unitNamesStr = _logic getVariable ["unitnames", ""];
RECONDO_PLAYER_PERSISTENCE_UNIT_NAMES = ((_unitNamesStr splitString (toString [10, 13] + ",")) apply { _x trim [" ", 0] }) select { _x != "" };
private _unitNames = RECONDO_PLAYER_PERSISTENCE_UNIT_NAMES;

if (count _unitNames == 0) exitWith {
    private _msg = "[RECONDO_PLAYERPERSIST] ERROR: No unit variable names configured.";
    diag_log _msg;
    _msg remoteExec ["systemChat", 0];
};

// ========================================
// TAG TRACKED UNITS
// ========================================

private _registeredCount = 0;

{
    private _varName = _x;
    private _unit = missionNamespace getVariable [_varName, objNull];

    if (isNull _unit) then {
        diag_log format ["[RECONDO_PLAYERPERSIST] WARNING: Variable '%1' not found or null.", _varName];
        continue;
    };

    _unit setVariable ["RECONDO_IsPlayerTracked", true, true];
    _registeredCount = _registeredCount + 1;

    if (_debug) then {
        diag_log format ["[RECONDO_PLAYERPERSIST] Tagged unit '%1': %2 (type: %3)", _varName, _unit, typeOf _unit];
    };
} forEach _unitNames;

if (_registeredCount == 0) then {
    diag_log format ["[RECONDO_PLAYERPERSIST] WARNING: No units resolved from variable names: %1", _unitNames];
} else {
    diag_log format ["[RECONDO_PLAYERPERSIST] Tagged %1 units for persistence.", _registeredCount];
};

// ========================================
// HANDLE DISCONNECT - SAVE IMMEDIATELY
// ========================================

addMissionEventHandler ["HandleDisconnect", {
    params ["_unit", "_id", "_uid", "_name"];

    if !(_unit getVariable ["RECONDO_IsPlayerTracked", false]) exitWith { false };
    if (!RECONDO_PLAYER_PERSISTENCE_ENABLED) exitWith { false };
    if (isNil "RECONDO_PERSISTENCE_SETTINGS") exitWith { false };

    private _entry = createHashMapFromArray [
        ["uid", _uid],
        ["name", _name],
        ["pos", getPosASL _unit],
        ["dir", getDir _unit],
        ["loadout", getUnitLoadout _unit]
    ];

    private _savedData = ["PLAYER_PERSIST_DATA", []] call Recondo_fnc_getSaveData;

    private _replaced = false;
    {
        if ((_x get "uid") == _uid) exitWith {
            _savedData set [_forEachIndex, _entry];
            _replaced = true;
        };
    } forEach _savedData;

    if (!_replaced) then {
        _savedData pushBack _entry;
    };

    ["PLAYER_PERSIST_DATA", _savedData] call Recondo_fnc_setSaveData;
    saveMissionProfileNamespace;

    if (RECONDO_PLAYER_PERSISTENCE_DEBUG) then {
        diag_log format ["[RECONDO_PLAYERPERSIST] Saved on disconnect: %1 (UID: %2)", _name, _uid];
    };

    false
}];

// ========================================
// HANDLE CONNECT - RESTORE WITH DELAY
// ========================================

addMissionEventHandler ["PlayerConnected", {
    params ["_id", "_uid", "_name", "_jip"];

    if (!RECONDO_PLAYER_PERSISTENCE_ENABLED) exitWith {};
    if (isNil "RECONDO_PERSISTENCE_SETTINGS") exitWith {};

    private _delay = RECONDO_PLAYER_PERSISTENCE_DELAY;

    [{
        params ["_uid"];
        private _unit = [_uid] call BIS_fnc_getUnitByUID;
        !isNull _unit
    }, {
        params ["_uid", "_name", "_delay"];

        private _unit = [_uid] call BIS_fnc_getUnitByUID;
        if (isNull _unit) exitWith {};

        if !(_unit getVariable ["RECONDO_IsPlayerTracked", false]) then {
            private _tagged = false;
            {
                private _resolvedUnit = missionNamespace getVariable [_x, objNull];
                if (!isNull _resolvedUnit && {_resolvedUnit isEqualTo _unit}) exitWith {
                    _unit setVariable ["RECONDO_IsPlayerTracked", true, true];
                    _tagged = true;
                    if (RECONDO_PLAYER_PERSISTENCE_DEBUG) then {
                        diag_log format ["[RECONDO_PLAYERPERSIST] Late-tagged unit '%1' on connect: %2", _x, _name];
                    };
                };
            } forEach RECONDO_PLAYER_PERSISTENCE_UNIT_NAMES;

            if (!_tagged) exitWith {
                if (RECONDO_PLAYER_PERSISTENCE_DEBUG) then {
                    diag_log format ["[RECONDO_PLAYERPERSIST] Player %1 not tracked. Skipping.", _name];
                };
            };
        };

        [{
            params ["_uid", "_name"];

            private _unit = [_uid] call BIS_fnc_getUnitByUID;
            if (isNull _unit) exitWith {};

            private _savedData = ["PLAYER_PERSIST_DATA", []] call Recondo_fnc_getSaveData;

            private _playerData = nil;
            {
                if ((_x get "uid") == _uid) exitWith {
                    _playerData = _x;
                };
            } forEach _savedData;

            if (isNil "_playerData") exitWith {
                if (RECONDO_PLAYER_PERSISTENCE_DEBUG) then {
                    diag_log format ["[RECONDO_PLAYERPERSIST] No saved data for player %1 (UID: %2)", _name, _uid];
                };
            };

            private _savedPos = _playerData get "pos";
            private _savedDir = _playerData getOrDefault ["dir", 0];
            private _savedLoadout = _playerData getOrDefault ["loadout", []];
            private _owner = owner _unit;

            if (count _savedPos >= 2) then {
                [_unit, _savedPos] remoteExec ["setPosASL", _owner];
                [_unit, _savedDir] remoteExec ["setDir", _owner];
            };

            if (count _savedLoadout > 0) then {
                [_unit, _savedLoadout] remoteExec ["setUnitLoadout", _owner];
            };

            if (RECONDO_PLAYER_PERSISTENCE_DEBUG) then {
                diag_log format ["[RECONDO_PLAYERPERSIST] Restored player %1 (UID: %2) after %3s delay: pos=%4",
                    _name, _uid, RECONDO_PLAYER_PERSISTENCE_DELAY, _savedPos];
            };

        }, [_uid, _name], _delay] call CBA_fnc_waitAndExecute;

    }, [_uid, _name, _delay], 30] call CBA_fnc_waitUntilAndExecute;
}];

diag_log format ["[RECONDO_PLAYERPERSIST] Initialized. Tracking %1 units. Restore delay: %2s.", _registeredCount, RECONDO_PLAYER_PERSISTENCE_DELAY];
