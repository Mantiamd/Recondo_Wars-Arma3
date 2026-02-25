/*
    Recondo_fnc_spawnRadioEnemy
    Spawn enemy group near player who used radio excessively
    
    Description:
        Server-side function that spawns an enemy patrol group near the player.
        Called when global radio call count reaches threshold.
    
    Parameters:
        0: OBJECT - Player who triggered spawn
        
    Returns:
        GROUP - Spawned group, or grpNull on failure
*/

if (!isServer) exitWith { grpNull };

params ["_player"];

if (isNil "RECONDO_RWR_SETTINGS") exitWith { grpNull };

private _settings = RECONDO_RWR_SETTINGS;
private _debug = _settings get "enableDebug";

// Get settings
private _enemyClassnames = _settings get "enemyClassnames";
private _enemySide = _settings get "enemySide";
private _minSize = _settings get "enemyMinSize";
private _maxSize = _settings get "enemyMaxSize";
private _spawnDistance = _settings get "spawnDistance";

// Validate
if (count _enemyClassnames == 0) exitWith {
    if (_debug) then {
        diag_log "[RECONDO_RWR] No enemy classnames configured - spawn skipped";
    };
    grpNull
};

// Calculate group size
private _groupSize = _minSize + floor random ((_maxSize - _minSize) + 1);
_groupSize = _groupSize max 1;

// Build group composition
private _groupArray = [];
_groupArray pushBack (_enemyClassnames select 0); // Leader

for "_i" from 1 to (_groupSize - 1) do {
    _groupArray pushBack (selectRandom _enemyClassnames);
};

// Calculate spawn position (random direction from player)
private _playerPos = getPos _player;
private _spawnDir = random 360;
private _spawnPos = _playerPos getPos [_spawnDistance, _spawnDir];

// Find safe position
private _safePos = [_spawnPos, 0, 100, 5, 0, 0.5, 0] call BIS_fnc_findSafePos;
if (_safePos isEqualTo []) then {
    _safePos = _spawnPos;
};

if (_debug) then {
    diag_log format ["[RECONDO_RWR] Spawning enemy group of %1 at %2 (dir %3 from player)", 
        _groupSize, _safePos, _spawnDir toFixed 0];
};

// Create group
private _group = [_safePos, _enemySide, _groupArray] call BIS_fnc_spawnGroup;

if (isNull _group) exitWith {
    diag_log "[RECONDO_RWR] ERROR: Failed to spawn enemy group";
    grpNull
};

// Configure group behavior
_group setBehaviour "AWARE";
_group setSpeedMode "NORMAL";
_group setCombatMode "RED";

// Make units invincible for 10 seconds to prevent spawn damage
{
    _x allowDamage false;
    [_x] spawn {
        params ["_unit"];
        sleep 10;
        if (!isNull _unit && alive _unit) then {
            _unit allowDamage true;
        };
    };
} forEach units _group;

// Move towards player's last known position
_group move _playerPos;

// Mark group
_group setVariable ["RECONDO_RWR_SPAWNED", true, true];

if (_debug) then {
    diag_log format ["[RECONDO_RWR] Enemy group spawned successfully with %1 units", count units _group];
};

// Notify player
"We believe your transmissions have been triangulated!" remoteExec ["hint", _player];

_group
