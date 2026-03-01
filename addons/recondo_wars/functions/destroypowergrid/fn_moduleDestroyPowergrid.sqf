/*
    Recondo_fnc_moduleDestroyPowergrid
    Main initialization for Destroy Powergrid module

    Description:
        Synced to an in-world object. Depending on mode, either an ACE
        interaction ("Turn Off Power") or destroying the linked object
        will turn off all lights within a configurable radius.
        Turn-off mode uses switchLight (clean, reversible).
        Destroy mode uses setDamage on lamp objects (physical breakage).

    Parameters:
        _logic - Module logic object
        _units - Synchronized units (unused)
        _activated - Whether module is activated

    Priority: 5 (feature module, may depend on persistence)
*/

params ["_logic", "_units", "_activated"];

if (!isServer) exitWith {};

if (!_activated) exitWith {
    diag_log "[RECONDO_POWERGRID] Module not activated.";
};

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

private _mode = _logic getVariable ["mode", "turnoff"];
private _effectRadius = _logic getVariable ["effectradius", 300];
private _additionalClassnamesRaw = _logic getVariable ["additionalclassnames", ""];
private _actionText = _logic getVariable ["actiontext", "Turn Off Power"];
private _restoreActionText = _logic getVariable ["restoreactiontext", "Turn On Power"];
private _enablePersistence = _logic getVariable ["enablepersistence", false];
private _debugLogging = _logic getVariable ["debuglogging", false];

// Parse additional classnames
private _additionalClassnames = ((_additionalClassnamesRaw splitString (toString [10, 13] + ",")) apply { _x trim [" ", 0] }) select { _x != "" };

if (_debugLogging) then {
    diag_log format ["[RECONDO_POWERGRID] Mode: %1, Radius: %2m, Additional classnames: %3", _mode, _effectRadius, _additionalClassnames];
};

// ========================================
// FIND SYNCED OBJECT
// ========================================

private _syncedObject = objNull;
{
    if (typeOf _x != "Recondo_Module_DestroyPowergrid" && !(_x isKindOf "Module_F")) exitWith {
        _syncedObject = _x;
    };
} forEach (synchronizedObjects _logic);

if (isNull _syncedObject) exitWith {
    diag_log "[RECONDO_POWERGRID] ERROR: No object synced to module. Sync a world object in Eden.";
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_POWERGRID] Synced object: %1 (%2) at %3", typeOf _syncedObject, _syncedObject, getPosATL _syncedObject];
};

// ========================================
// GENERATE INSTANCE ID
// ========================================

private _objPos = getPosATL _syncedObject;
private _instanceId = format ["pg_%1_%2", round (_objPos select 0), round (_objPos select 1)];

// ========================================
// STORE SETTINGS
// ========================================

private _settings = createHashMapFromArray [
    ["instanceId", _instanceId],
    ["mode", _mode],
    ["effectRadius", _effectRadius],
    ["additionalClassnames", _additionalClassnames],
    ["actionText", _actionText],
    ["restoreActionText", _restoreActionText],
    ["enablePersistence", _enablePersistence],
    ["debugLogging", _debugLogging],
    ["objectPos", _objPos],
    ["syncedObject", _syncedObject]
];

RECONDO_POWERGRID_INSTANCES pushBack _settings;
publicVariable "RECONDO_POWERGRID_INSTANCES";

RECONDO_POWERGRID_STATES set [_instanceId, "ON"];
publicVariable "RECONDO_POWERGRID_STATES";

// ========================================
// CHECK PERSISTENCE (DESTROY MODE ONLY)
// ========================================

private _alreadyDestroyed = false;

if ((_mode == "destroy" || _mode == "both") && _enablePersistence) then {
    if (!isNil "RECONDO_PERSISTENCE_SETTINGS") then {
        private _persistenceKey = format ["POWERGRID_%1_DESTROYED", _instanceId];
        private _savedState = [_persistenceKey] call Recondo_fnc_getSaveData;

        if (!isNil "_savedState" && {_savedState isEqualTo true}) then {
            _alreadyDestroyed = true;
            if (_debugLogging) then {
                diag_log format ["[RECONDO_POWERGRID] Instance '%1' was previously destroyed — restoring state", _instanceId];
            };
        };
    };
};

// ========================================
// SETUP BASED ON MODE
// ========================================

if (_alreadyDestroyed) then {
    // Restore destroyed state after a short delay for world objects to load
    [{
        params ["_instanceId", "_syncedObject"];
        [_instanceId, "OFF"] call Recondo_fnc_togglePowergridLights;
        _syncedObject setDamage 1;
    }, [_instanceId, _syncedObject], 5] call CBA_fnc_waitAndExecute;
} else {
    // Add ACE actions for turnoff and both modes
    if (_mode == "turnoff" || _mode == "both") then {
        [_syncedObject, _instanceId, _actionText, _restoreActionText] remoteExec ["Recondo_fnc_addPowergridActionClient", 0, true];

        if (_debugLogging) then {
            diag_log format ["[RECONDO_POWERGRID] ACE actions broadcast for '%1'", _instanceId];
        };
    };

    // Attach Killed EH for destroy and both modes
    if (_mode == "destroy" || _mode == "both") then {
        _syncedObject setVariable ["RECONDO_POWERGRID_INSTANCE_ID", _instanceId, true];

        _syncedObject addEventHandler ["Killed", {
            params ["_unit"];
            private _id = _unit getVariable ["RECONDO_POWERGRID_INSTANCE_ID", ""];
            if (_id != "") then {
                [_id] call Recondo_fnc_handlePowergridDestroyed;
            };
        }];

        if (_debugLogging) then {
            diag_log format ["[RECONDO_POWERGRID] Killed EH attached for '%1'", _instanceId];
        };
    };
};

// ========================================
// LOG INITIALIZATION
// ========================================

private _statusText = if (_alreadyDestroyed) then { "DESTROYED (restored)" } else { "ACTIVE" };

diag_log format ["[RECONDO_POWERGRID] '%1' initialized — mode: %2, radius: %3m, persistence: %4, status: %5",
    _instanceId, _mode, _effectRadius, _enablePersistence, _statusText];
