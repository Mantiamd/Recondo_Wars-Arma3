/*
    Recondo_fnc_deployRallypointServer
    Server-side rally point creation
    
    Description:
        Called via remoteExec from client when deploying a rally point.
        Creates the rally object, map marker, and handles max rally limit.
    
    Parameters:
        0: ARRAY - Position to spawn rally
        1: NUMBER - Side number (0=OPFOR, 1=BLUFOR, 2=INDFOR, 3=CIV)
        2: STRING - Player UID who deployed
    
    Returns:
        Nothing
    
    Execution:
        Server only
*/

if (!isServer) exitWith {};

params [["_pos", [0,0,0], [[]]], ["_sideNum", 1, [0]], ["_playerUID", "", [""]]];

private _settings = RECONDO_DRP_SETTINGS;
if (isNil "_settings") exitWith {
    diag_log "[RECONDO_DRP] ERROR: Settings not initialized on server!";
};

private _enableDebug = _settings get "enableDebug";

// ========================================
// GET SETTINGS
// ========================================

private _rallyObjectClass = _settings get "rallyObjectClass";
private _markerType = _settings get "markerType";
private _markerColor = _settings get "markerColor";
private _markerText = _settings get "markerText";
private _maxRallies = _settings get "maxRallies";
private _packActionText = _settings get "packActionText";
private _replacedHint = _settings get "replacedHint";
private _enablePersistence = _settings get "enablePersistence";
private _destroyRemovesRally = _settings get "destroyRemovesRally";

// ========================================
// CHECK MAX RALLIES - REMOVE OLDEST IF NEEDED
// ========================================

private _rallies = missionNamespace getVariable ["RECONDO_DRP_RALLIES", []];
private _sideRallies = _rallies select { (_x get "sideNum") == _sideNum };

if (_maxRallies > 0 && {count _sideRallies >= _maxRallies}) then {
    // Find oldest rally for this side
    private _oldestIndex = -1;
    {
        if ((_x get "sideNum") == _sideNum) exitWith {
            _oldestIndex = _forEachIndex;
        };
    } forEach _rallies;
    
    if (_oldestIndex > -1) then {
        private _oldEntry = _rallies select _oldestIndex;
        private _oldTentNetId = _oldEntry get "tentNetId";
        private _oldMarkerName = _oldEntry get "markerName";
        
        // Delete old tent
        if (!isNil "_oldTentNetId" && {_oldTentNetId != ""}) then {
            private _oldTent = objectFromNetId _oldTentNetId;
            if (!isNull _oldTent) then {
                deleteVehicle _oldTent;
            };
        };
        
        // Delete old marker
        if (!isNil "_oldMarkerName" && {_oldMarkerName != ""} && {getMarkerColor _oldMarkerName != ""}) then {
            deleteMarker _oldMarkerName;
        };
        
        // Remove from array
        _rallies deleteAt _oldestIndex;
        
        if (_enableDebug) then {
            diag_log format ["[RECONDO_DRP] Removed oldest rally (max limit reached): %1", _oldMarkerName];
        };
        
        // Notify players of replacement
        _replacedHint remoteExec ["hint", _sideNum];
    };
};

// ========================================
// CREATE RALLY POINT OBJECT
// ========================================

private _tent = createVehicle [_rallyObjectClass, _pos, [], 0, "NONE"];
_tent setPosATL _pos;

// Store side info on tent
_tent setVariable ["RECONDO_DRP_SIDE_NUM", _sideNum, true];
_tent setVariable ["RECONDO_DRP_DEPLOYER_UID", _playerUID, true];

// ========================================
// ADD KILLED EVENT HANDLER (if destroy removes rally)
// ========================================

if (_destroyRemovesRally) then {
    // Add Killed event handler for physical destruction
    _tent addEventHandler ["Killed", {
        params ["_unit", "_killer", "_instigator", "_useEffects"];
        
        // Call remove function to clean up rally data and marker
        [_unit] call Recondo_fnc_removeRallypoint;
        
        private _settings = RECONDO_DRP_SETTINGS;
        if (!isNil "_settings" && {_settings get "enableDebug"}) then {
            diag_log format ["[RECONDO_DRP] Rally object destroyed - rally point removed"];
        };
    }];
    
    // Mark tent as destroyable for ACE action (clients will check this)
    _tent setVariable ["RECONDO_DRP_DESTROYABLE", true, true];
    
    // Broadcast ACE action to all clients (including JIP)
    [_tent] remoteExec ["Recondo_fnc_addDestroyAction", 0, true];
    
    if (_enableDebug) then {
        diag_log "[RECONDO_DRP] Added Killed EH and marked for ACE destroy action (destroy removes rally)";
    };
};

// ========================================
// CREATE MAP MARKER
// ========================================

// Generate unique marker name
private _rallyCount = count (_rallies select { (_x get "sideNum") == _sideNum }) + 1;
private _markerName = format ["RECONDO_DRP_%1_%2_%3", _sideNum, _rallyCount, diag_tickTime];

private _marker = createMarker [_markerName, _pos];
_marker setMarkerShape "ICON";
_marker setMarkerType _markerType;
_marker setMarkerColor _markerColor;

// Format marker text with rally number
private _formattedText = if (_markerText find "%1" > -1) then {
    format [_markerText, _rallyCount]
} else {
    format ["%1 %2", _markerText, _rallyCount]
};
_marker setMarkerText _formattedText;

// ========================================
// ADD PACK ACTION TO TENT
// ========================================

private _packActionId = _tent addAction [
    format ["<t color='#FFFF00'>%1</t>", _packActionText],
    {
        params ["_target", "_caller", "_actionId", "_args"];
        
        private _tentSideNum = _target getVariable ["RECONDO_DRP_SIDE_NUM", -1];
        
        // Check if caller is on correct side
        private _callerSideNum = switch (side _caller) do {
            case east: { 0 };
            case west: { 1 };
            case independent: { 2 };
            case civilian: { 3 };
            default { -1 };
        };
        
        // Check side permission (allow if caller matches tent side or module allows any side)
        private _settings = RECONDO_DRP_SETTINGS;
        private _allowedSideNum = _settings get "allowedSideNum";
        
        private _canPack = false;
        if (_allowedSideNum == 4) then {
            // Any side mode - only tent owner's side can pack
            _canPack = _callerSideNum == _tentSideNum;
        } else {
            // Restricted mode - allowed side can pack
            _canPack = _callerSideNum == _allowedSideNum;
        };
        
        if (!_canPack) exitWith {
            hint "You are not authorized to pack this rally point.";
        };
        
        // Request server to remove rally
        [_target] remoteExec ["Recondo_fnc_removeRallypoint", 2];
        
        // Show undeploy hint
        private _undeployHint = _settings get "undeployHint";
        hint _undeployHint;
    },
    [],
    1.5,
    true,
    true,
    "",
    "true",
    5
];

// ========================================
// STORE RALLY DATA
// ========================================

private _rallyData = createHashMapFromArray [
    ["sideNum", _sideNum],
    ["tentNetId", netId _tent],
    ["markerName", _markerName],
    ["position", _pos],
    ["createTime", serverTime],
    ["deployerUID", _playerUID]
];

_rallies pushBack _rallyData;
RECONDO_DRP_RALLIES = _rallies;
publicVariable "RECONDO_DRP_RALLIES";

// ========================================
// SAVE TO PERSISTENCE
// ========================================

if (_enablePersistence) then {
    [] call Recondo_fnc_saveRallypoints;
};

// ========================================
// LOG
// ========================================

if (_enableDebug) then {
    diag_log format ["[RECONDO_DRP] Created rally point at %1 for side %2 (marker: %3)", _pos, _sideNum, _markerName];
    diag_log format ["[RECONDO_DRP] Total rallies: %1", count RECONDO_DRP_RALLIES];
};
