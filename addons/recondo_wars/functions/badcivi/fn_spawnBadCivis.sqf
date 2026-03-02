/*
    Recondo_fnc_spawnBadCivis
    Spawns bad civi units at an objective location

    Description:
        Creates unarmed civilian units that can pull a concealed weapon
        when a trigger side approaches. Each potential slot rolls a spawn
        chance. Spawned units are placed in building positions or near
        the marker center. Uses Recondo_fnc_setupBadCivi for trigger wiring.

    Parameters:
        _settings  - HASHMAP - Module settings (must contain badCivi* keys)
        _marker    - STRING  - Location marker name
        _pos       - ARRAY   - Location position

    Returns:
        ARRAY - Spawned bad civi units
*/

if (!isServer) exitWith { [] };

params [
    ["_settings", nil, [createHashMap]],
    ["_marker", "", [""]],
    ["_pos", [0,0,0], [[]]]
];

if (isNil "_settings") exitWith { [] };

private _maxBadCivis     = _settings getOrDefault ["badCiviMax", 0];
private _spawnChance     = _settings getOrDefault ["badCiviSpawnChance", 50];
private _pullChance      = _settings getOrDefault ["badCiviPullChance", 100];
private _detectionDist   = _settings getOrDefault ["badCiviDetectionDistance", 5];
private _triggerSide     = _settings getOrDefault ["badCiviTriggerSide", "WEST"];
private _unitClassname   = _settings getOrDefault ["badCiviClassname", "C_man_1"];
private _weaponClassname = _settings getOrDefault ["badCiviWeapon", "hgun_Pistol_01_F"];
private _magazineClassname = _settings getOrDefault ["badCiviMagazine", "10Rnd_9x21_Mag"];
private _debugLogging    = _settings getOrDefault ["debugLogging", false];

if (_maxBadCivis <= 0) exitWith { [] };

if (_debugLogging) then {
    diag_log format ["[RECONDO_BADCIVI] spawnBadCivis: max=%1, spawnChance=%2%%, pullChance=%3%%, at %4",
        _maxBadCivis, _spawnChance, _pullChance, _marker];
};

// Build a settings hashmap compatible with fn_setupBadCivi
private _badCiviSettings = createHashMapFromArray [
    ["triggerSide", _triggerSide],
    ["detectionDistance", _detectionDist],
    ["chance", _pullChance],
    ["weaponClassname", _weaponClassname],
    ["magazineClassname", _magazineClassname],
    ["magazineCount", 1],
    ["disableMovement", true],
    ["forceStanding", true],
    ["debugLogging", _debugLogging]
];

// Find building positions
private _nearbyObjects = nearestObjects [_pos, [], 50];
private _buildingPositions = [];

{
    private _obj = _x;
    if (!(_obj isKindOf "CAManBase") && !(_obj isKindOf "LandVehicle") && !(_obj isKindOf "Air") && !(_obj isKindOf "Ship")) then {
        private _i = 0;
        while {true} do {
            private _bPos = _obj buildingPos _i;
            if (_bPos isEqualTo [0,0,0]) exitWith {};
            _buildingPositions pushBack _bPos;
            _i = _i + 1;
        };
    };
} forEach _nearbyObjects;

_buildingPositions = _buildingPositions call BIS_fnc_arrayShuffle;

private _spawnedUnits = [];
private _posIndex = 0;
private _spawnChanceNorm = _spawnChance / 100;

for "_i" from 1 to _maxBadCivis do {
    if (random 1 >= _spawnChanceNorm) then {
        if (_debugLogging) then {
            diag_log format ["[RECONDO_BADCIVI] Bad civi slot %1 at %2: spawn roll failed", _i, _marker];
        };
        continue;
    };

    // Find position
    private _spawnPos = [];
    if (_posIndex < count _buildingPositions) then {
        _spawnPos = _buildingPositions select _posIndex;
        _posIndex = _posIndex + 1;
    } else {
        _spawnPos = _pos getPos [3, random 360];
    };

    // Create unit on the garrison's configured side
    private _side = _settings getOrDefault ["aiSide", civilian];
    private _group = createGroup [_side, true];
    private _unit = _group createUnit [_unitClassname, _spawnPos, [], 0, "NONE"];
    _unit setPosATL _spawnPos;
    [_unit] joinSilent _group;

    // Wire up trigger and behavior via existing Bad Civi system
    [_unit, _badCiviSettings] call Recondo_fnc_setupBadCivi;

    _spawnedUnits pushBack _unit;

    if (_debugLogging) then {
        diag_log format ["[RECONDO_BADCIVI] Spawned bad civi %1/%2 (%3) at %4 near %5",
            count _spawnedUnits, _maxBadCivis, _unitClassname, _spawnPos, _marker];
    };
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_BADCIVI] spawnBadCivis complete: %1 spawned of %2 max at %3",
        count _spawnedUnits, _maxBadCivis, _marker];
};

_spawnedUnits
