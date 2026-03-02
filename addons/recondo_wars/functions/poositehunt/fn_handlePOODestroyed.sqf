/*
    Recondo_fnc_handlePOODestroyed
    Handles destruction of a POO site's artillery weapon

    Description:
        Marks the site as destroyed, updates global tracking,
        persists if enabled, and updates debug markers.

    Parameters:
        _settings - HASHMAP - Module settings
        _markerId - STRING  - Marker ID of the destroyed POO site

    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [
    ["_settings", nil, [createHashMap]],
    ["_markerId", "", [""]]
];

if (isNil "_settings" || _markerId == "") exitWith {};

private _instanceId       = _settings get "instanceId";
private _objectiveName    = _settings get "objectiveName";
private _enablePersistence = _settings get "enablePersistence";
private _debugLogging     = _settings get "debugLogging";

// ========================================
// UPDATE GLOBAL TRACKING
// ========================================

if (!(_markerId in RECONDO_POO_DESTROYED)) then {
    RECONDO_POO_DESTROYED pushBack _markerId;
    publicVariable "RECONDO_POO_DESTROYED";
};

{
    _x params ["_iId", "_mId"];
    if (_mId == _markerId && _iId == _instanceId) then {
        _x set [3, "destroyed"];
    };
} forEach RECONDO_POO_ACTIVE;
publicVariable "RECONDO_POO_ACTIVE";

// ========================================
// SAVE TO PERSISTENCE
// ========================================

if (_enablePersistence) then {
    private _persistenceKey = format ["POO_%1", _objectiveName];
    private _savedDestroyed = [_persistenceKey + "_DESTROYED"] call Recondo_fnc_getSaveData;

    if (isNil "_savedDestroyed") then { _savedDestroyed = [] };

    if (!(_markerId in _savedDestroyed)) then {
        _savedDestroyed pushBack _markerId;
        [_persistenceKey + "_DESTROYED", _savedDestroyed] call Recondo_fnc_setSaveData;
        saveMissionProfileNamespace;
    };

    if (_debugLogging) then {
        diag_log format ["[RECONDO_POO] Persisted destruction of %1", _markerId];
    };
};

// ========================================
// UPDATE DEBUG MARKERS
// ========================================

private _debugMarker = format ["RECONDO_POO_DEBUG_%1", _markerId];
if (getMarkerColor _debugMarker != "") then {
    _debugMarker setMarkerColor "ColorGrey";
    _debugMarker setMarkerText format ["POO: %1 - DESTROYED", _markerId];
};

// ========================================
// LOG
// ========================================

diag_log format ["[RECONDO_POO] POO site destroyed: %1 (instance: %2)", _markerId, _instanceId];
