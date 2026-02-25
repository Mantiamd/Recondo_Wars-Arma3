/*
    Recondo_fnc_findSafeSpawnPos
    Finds a safe spawn position away from target side units
    
    Description:
        Calculates a spawn position behind the detecting unit that is
        at least safetyDistance away from any target side units.
        If all directions have targets nearby, picks the farthest point.
    
    Parameters:
        _detectorPos - Position of the detecting unit
        _detectorDir - Direction the detector is facing (or direction to target)
        _spawnDistance - Distance behind detector to spawn
        _safetyDistance - Minimum distance from target side units
        _targetSide - Side to avoid
        _heightLimit - Height limit for target check
    
    Returns:
        [position, success] - Spawn position and whether it's safe
*/

params ["_detectorPos", "_detectorDir", "_spawnDistance", "_safetyDistance", "_targetSide", "_heightLimit"];

// Calculate initial spawn position (behind the detector)
private _reverseDir = (_detectorDir + 180) mod 360;
private _initialPos = _detectorPos getPos [_spawnDistance, _reverseDir];
_initialPos set [2, 0]; // Ensure on ground

// Function to check if position is safe
private _fnc_isSafe = {
    params ["_pos", "_safetyDist", "_targetSide", "_heightLimit"];
    
    private _safe = true;
    {
        if (alive _x && side _x == _targetSide) then {
            private _targetHeight = (getPosATL _x) select 2;
            if (_targetHeight <= _heightLimit) then {
                if (_x distance _pos < _safetyDist) exitWith {
                    _safe = false;
                };
            };
        };
    } forEach allUnits;
    
    _safe
};

// Check if initial position is safe
if ([_initialPos, _safetyDistance, _targetSide, _heightLimit] call _fnc_isSafe) exitWith {
    [_initialPos, true]
};

// Try different directions (8 directions, 45 degrees apart)
private _directions = [0, 45, 90, 135, 180, 225, 270, 315];
private _bestPos = _initialPos;
private _bestDistance = 0;
private _foundSafe = false;

{
    private _testDir = _x;
    private _testPos = _detectorPos getPos [_spawnDistance, _testDir];
    _testPos set [2, 0];
    
    if ([_testPos, _safetyDistance, _targetSide, _heightLimit] call _fnc_isSafe) exitWith {
        _bestPos = _testPos;
        _foundSafe = true;
    };
    
    // Track the position with the greatest distance from any target
    private _minDist = 999999;
    {
        if (alive _x && side _x == _targetSide) then {
            private _targetHeight = (getPosATL _x) select 2;
            if (_targetHeight <= _heightLimit) then {
                private _dist = _x distance _testPos;
                if (_dist < _minDist) then {
                    _minDist = _dist;
                };
            };
        };
    } forEach allUnits;
    
    if (_minDist > _bestDistance) then {
        _bestDistance = _minDist;
        _bestPos = _testPos;
    };
} forEach _directions;

[_bestPos, _foundSafe]
