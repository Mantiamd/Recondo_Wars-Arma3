/*
    Recondo_fnc_startArtilleryFire
    Runs the repeating artillery fire loop

    Description:
        Loops while the weapon is alive, firing at the target marker
        position at the configured interval.

    Parameters:
        _settings     - HASHMAP - Module settings
        _markerId     - STRING  - POO site marker (for logging)
        _targetMarker - STRING  - Marker to fire at
        _weapon       - OBJECT  - The artillery static weapon

    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [
    ["_settings", nil, [createHashMap]],
    ["_markerId", "", [""]],
    ["_targetMarker", "", [""]],
    ["_weapon", objNull, [objNull]]
];

if (isNil "_settings" || isNull _weapon) exitWith {};

private _firingInterval = _settings get "firingInterval";
private _debugLogging   = _settings get "debugLogging";
private _targetPos      = getMarkerPos _targetMarker;

if (_debugLogging) then {
    diag_log format ["[RECONDO_POO] Artillery fire loop starting at %1 -> target %2 (interval: %3s)",
        _markerId, _targetMarker, _firingInterval];
};

// Update status
{
    _x params ["_iId", "_mId"];
    if (_mId == _markerId) then {
        _x set [3, "firing"];
    };
} forEach RECONDO_POO_ACTIVE;
publicVariable "RECONDO_POO_ACTIVE";

[_weapon, _targetPos, _firingInterval, _markerId, _debugLogging] spawn {
    params ["_weapon", "_targetPos", "_firingInterval", "_markerId", "_debugLogging"];

    private _roundsFired = 0;

    while {!isNull _weapon && {alive _weapon}} do {
        private _gunner = gunner _weapon;

        if (isNull _gunner || !alive _gunner) exitWith {
            if (_debugLogging) then {
                diag_log format ["[RECONDO_POO] No alive gunner for %1, stopping fire loop", _markerId];
            };
        };

        private _ammoArray = getArtilleryAmmo [_weapon];

        if (count _ammoArray == 0) exitWith {
            if (_debugLogging) then {
                diag_log format ["[RECONDO_POO] No artillery ammo available for weapon at %1", _markerId];
            };
        };

        private _ammo = _ammoArray select 0;

        _weapon doArtilleryFire [_targetPos, _ammo, 1];
        _roundsFired = _roundsFired + 1;

        if (_debugLogging && (_roundsFired mod 5 == 1)) then {
            diag_log format ["[RECONDO_POO] %1 fired round #%2 at %3", _markerId, _roundsFired, _targetPos];
        };

        sleep _firingInterval;
    };

    if (_debugLogging) then {
        diag_log format ["[RECONDO_POO] Fire loop ended for %1 (%2 rounds fired)", _markerId, _roundsFired];
    };
};
