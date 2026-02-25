/*
    Recondo_fnc_deployRallypoint
    Deploy a new rally point
    
    Description:
        Called when player uses ACE self-action to deploy a rally point.
        Validates all restrictions (distance, enemies, item requirement).
        If valid, requests server to create the rally point.
    
    Parameters:
        0: OBJECT - Player deploying the rally
    
    Returns:
        Nothing
    
    Execution:
        Client-side (requests server to create)
*/

params [["_player", objNull, [objNull]]];

if (isNull _player) exitWith {};

private _settings = RECONDO_DRP_SETTINGS;
if (isNil "_settings") exitWith {
    hint "Rally point system not initialized!";
};

private _enableDebug = _settings get "enableDebug";

// ========================================
// CHECK SIDE RESTRICTION
// ========================================

private _allowedSideNum = _settings get "allowedSideNum";
private _allowedSide = switch (_allowedSideNum) do {
    case 0: { east };
    case 1: { west };
    case 2: { independent };
    case 3: { civilian };
    default { nil };
};

if (!isNil "_allowedSide" && {side _player != _allowedSide}) exitWith {
    hint "You are not authorized to deploy rally points.";
};

// ========================================
// CHECK ITEM REQUIREMENT
// ========================================

private _requireItemEnabled = _settings get "requireItemEnabled";
private _requiredItem = _settings get "requiredItem";
private _requiredItemName = _settings get "requiredItemName";

// Smart item check - handles ACRE radios specially (they have unique instance IDs)
private _hasItem = false;

if ((_requiredItem find "ACRE_") == 0 && {!isNil "acre_api_fnc_getCurrentRadioList"}) then {
    // ACRE radio - use ACRE API to check
    private _radioList = [] call acre_api_fnc_getCurrentRadioList;
    {
        private _baseRadio = [_x] call acre_api_fnc_getBaseRadio;
        if (_baseRadio == _requiredItem) exitWith {
            _hasItem = true;
        };
    } forEach _radioList;
    
    diag_log format ["[RECONDO_DRP] Deploy: requireItemEnabled=%1, requiredItem='%2', hasItem=%3 (ACRE API)", _requireItemEnabled, _requiredItem, _hasItem];
} else {
    // Normal item - use standard check
    _hasItem = [_player, _requiredItem] call BIS_fnc_hasItem;
    
    diag_log format ["[RECONDO_DRP] Deploy: requireItemEnabled=%1, requiredItem='%2', hasItem=%3 (BIS_fnc_hasItem)", _requireItemEnabled, _requiredItem, _hasItem];
};

if (_requireItemEnabled && {!_hasItem}) exitWith {
    diag_log format ["[RECONDO_DRP] Deploy BLOCKED: Missing item '%1'", _requiredItem];
    hint format ["You need a %1 to deploy a rally point.", _requiredItemName];
};

// ========================================
// CALCULATE SPAWN POSITION
// ========================================

private _spawnDistance = _settings get "spawnDistance";
private _pos = _player modelToWorld [0, _spawnDistance, 0];
_pos set [2, 0];  // Ground level

// ========================================
// CHECK BASE DISTANCE RESTRICTION
// ========================================

private _baseMarkerName = _settings get "baseMarkerName";
private _minDistanceFromBase = _settings get "minDistanceFromBase";
private _failedBaseCheck = false;

if (_baseMarkerName != "" && {_minDistanceFromBase > 0}) then {
    if (!(_baseMarkerName in allMapMarkers)) then {
        hint format ["Cannot deploy: Base marker '%1' not found. Check marker variable name in Eden.", _baseMarkerName];
        _failedBaseCheck = true;
    } else {
        private _basePos = getMarkerPos _baseMarkerName;
        private _distToBase = _pos distance2D _basePos;
        
        if (_enableDebug) then {
            systemChat format ["[DRP] Base: %1, Distance: %2m, Required: %3m", _baseMarkerName, round _distToBase, _minDistanceFromBase];
        };
        
        if (_distToBase < _minDistanceFromBase) then {
            hint format ["Move at least %1 meters away from base to deploy a rally point. (Current: %2m)", _minDistanceFromBase, round _distToBase];
            _failedBaseCheck = true;
        };
    };
};

if (_failedBaseCheck) exitWith {};

// ========================================
// CHECK ENEMY PROXIMITY
// ========================================

private _enemyProximity = _settings get "enemyProximity";
private _failedEnemyCheck = false;

if (_enemyProximity > 0) then {
    private _playerSide = side group _player;
    
    private _nearEnemies = allUnits select {
        alive _x &&
        {_x != _player} &&
        {_x distance2D _player < _enemyProximity} &&
        {(_playerSide getFriend (side group _x)) < 0.6}
    };
    
    if (_enableDebug) then {
        systemChat format ["[DRP] Enemies within %1m: %2", _enemyProximity, count _nearEnemies];
    };
    
    if (count _nearEnemies > 0) then {
        hint format ["Cannot deploy rally point: Enemy forces detected within %1 meters.", _enemyProximity];
        _failedEnemyCheck = true;
    };
};

if (_failedEnemyCheck) exitWith {};

// ========================================
// ALL CHECKS PASSED - REQUEST SERVER TO CREATE RALLY
// ========================================

// Get player's side number for server
private _playerSideNum = switch (side _player) do {
    case east: { 0 };
    case west: { 1 };
    case independent: { 2 };
    case civilian: { 3 };
    default { -1 };
};

if (_enableDebug) then {
    diag_log format ["[RECONDO_DRP] Requesting rally point deployment at %1 for side %2", _pos, _playerSideNum];
};

// Send to server to create rally point
// Parameters: [position, sideNum, playerUID]
[_pos, _playerSideNum, getPlayerUID _player] remoteExec ["Recondo_fnc_deployRallypointServer", 2];

// Show deploy hint
private _deployHint = _settings get "deployHint";
hint _deployHint;
