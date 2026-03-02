/*
    Recondo_fnc_spawnPOOSite
    Spawns the artillery asset and crew at a POO site

    Description:
        Clears terrain, spawns a static weapon with crew,
        sets invulnerability, then starts the firing loop.

    Parameters:
        _settings     - HASHMAP - Module settings
        _markerId     - STRING  - POO site marker
        _targetMarker - STRING  - Target marker

    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [
    ["_settings", nil, [createHashMap]],
    ["_markerId", "", [""]],
    ["_targetMarker", "", [""]]
];

if (isNil "_settings" || _markerId == "") exitWith {};

private _instanceId        = _settings get "instanceId";
private _terrainClearRadius = _settings get "terrainClearRadius";
private _weaponClassname   = _settings get "weaponClassname";
private _crewClassname     = _settings get "crewClassname";
private _crewSide          = _settings get "crewSide";
private _invulnTime        = _settings get "invulnTime";
private _firingInterval    = _settings get "firingInterval";
private _debugLogging      = _settings get "debugLogging";

private _markerPos = getMarkerPos _markerId;
private _markerDir = markerDir _markerId;

// ========================================
// UPDATE STATUS
// ========================================

{
    _x params ["_iId", "_mId"];
    if (_mId == _markerId && _iId == _instanceId) then {
        _x set [3, "spawned"];
    };
} forEach RECONDO_POO_ACTIVE;
publicVariable "RECONDO_POO_ACTIVE";

// ========================================
// CLEAR TERRAIN
// ========================================

if (_terrainClearRadius > 0) then {
    [_markerPos, _terrainClearRadius] call Recondo_fnc_clearTerrainObjects;

    if (_debugLogging) then {
        diag_log format ["[RECONDO_POO] Cleared terrain within %1m at %2", _terrainClearRadius, _markerId];
    };
};

// Small delay for terrain clear to propagate
sleep 0.5;

// ========================================
// SPAWN STATIC WEAPON
// ========================================

private _weapon = createVehicle [_weaponClassname, _markerPos, [], 0, "CAN_COLLIDE"];
_weapon setPosATL _markerPos;
_weapon setDir _markerDir;

if (_debugLogging) then {
    diag_log format ["[RECONDO_POO] Spawned weapon %1 at %2", _weaponClassname, _markerId];
};

// ========================================
// SPAWN CREW
// ========================================

private _group = createGroup [_crewSide, true];
_group deleteGroupWhenEmpty true;

private _gunner = _group createUnit [_crewClassname, _markerPos, [], 0, "NONE"];
_gunner moveInGunner _weapon;

private _loader = _group createUnit [_crewClassname, _markerPos, [], 2, "NONE"];
_loader moveInAny _weapon;

// If loader couldn't get in, position nearby
if (vehicle _loader == _loader) then {
    _loader setPosATL (_weapon modelToWorld [2, 0, 0]);
};

_group setBehaviour "COMBAT";
_group setCombatMode "RED";

if (_debugLogging) then {
    diag_log format ["[RECONDO_POO] Spawned crew for %1 (side: %2)", _markerId, _crewSide];
};

// ========================================
// INVULNERABILITY PERIOD
// ========================================

_weapon allowDamage false;
_gunner allowDamage false;
_loader allowDamage false;

[_weapon, _gunner, _loader, _invulnTime, _settings, _markerId, _targetMarker] spawn {
    params ["_weapon", "_gunner", "_loader", "_invulnTime", "_settings", "_markerId", "_targetMarker"];

    private _debugLogging = _settings get "debugLogging";

    if (_debugLogging) then {
        diag_log format ["[RECONDO_POO] Invulnerability active for %1s at %2", _invulnTime, _markerId];
    };

    sleep _invulnTime;

    if (!isNull _weapon) then { _weapon allowDamage true };
    if (alive _gunner) then { _gunner allowDamage true };
    if (alive _loader) then { _loader allowDamage true };

    if (_debugLogging) then {
        diag_log format ["[RECONDO_POO] Invulnerability ended for %1", _markerId];
    };

    // Start firing loop
    if (!isNull _weapon && alive _gunner) then {
        [_settings, _markerId, _targetMarker, _weapon] call Recondo_fnc_startArtilleryFire;
    };
};

// ========================================
// ATTACH KILLED EVENT HANDLER
// ========================================

_weapon addEventHandler ["Killed", {
    params ["_unit"];
    private _mId  = _unit getVariable ["RECONDO_POO_MARKER_ID", ""];
    private _iId  = _unit getVariable ["RECONDO_POO_INSTANCE_ID", ""];
    private _sets = _unit getVariable ["RECONDO_POO_SETTINGS", nil];

    if (_mId != "" && !isNil "_sets") then {
        [_sets, _mId] call Recondo_fnc_handlePOODestroyed;
    };
}];

_weapon setVariable ["RECONDO_POO_MARKER_ID", _markerId, false];
_weapon setVariable ["RECONDO_POO_INSTANCE_ID", _instanceId, false];
_weapon setVariable ["RECONDO_POO_SETTINGS", _settings, false];

if (_debugLogging) then {
    diag_log format ["[RECONDO_POO] Killed EH attached to weapon at %1", _markerId];
};
