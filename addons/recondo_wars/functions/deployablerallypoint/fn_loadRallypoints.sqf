/*
    Recondo_fnc_loadRallypoints
    Load rally points from persistence
    
    Description:
        Loads saved rally points from missionProfileNamespace and
        recreates the objects and markers.
    
    Parameters:
        None
    
    Returns:
        Nothing
    
    Execution:
        Server only
*/

if (!isServer) exitWith {};

private _settings = RECONDO_DRP_SETTINGS;
if (isNil "_settings") exitWith {
    diag_log "[RECONDO_DRP] ERROR: Cannot load - settings not initialized!";
};

private _enablePersistence = _settings get "enablePersistence";
if (!_enablePersistence) exitWith {
    RECONDO_DRP_RALLIES = [];
    publicVariable "RECONDO_DRP_RALLIES";
};

private _enableDebug = _settings get "enableDebug";
private _rallyObjectClass = _settings get "rallyObjectClass";
private _packActionText = _settings get "packActionText";

// ========================================
// LOAD SAVED DATA
// ========================================

private _saveData = [];

// Check if Persistence module is available
if (isNil "RECONDO_PERSISTENCE_SETTINGS") then {
    // Persistence module not placed - load directly
    private _saveTag = "RECONDO_DRP_RALLIES";
    _saveData = missionProfileNamespace getVariable [_saveTag, []];
    
    if (_enableDebug) then {
        diag_log format ["[RECONDO_DRP] Loading rally points directly (no Persistence module)"];
    };
} else {
    // Use Persistence module's load system
    _saveData = ["DRP_RALLIES", []] call Recondo_fnc_getSaveData;
    
    if (_enableDebug) then {
        diag_log format ["[RECONDO_DRP] Loading rally points via Persistence module"];
    };
};

if (isNil "_saveData") then { _saveData = [] };

if (_saveData isEqualTo []) exitWith {
    RECONDO_DRP_RALLIES = [];
    publicVariable "RECONDO_DRP_RALLIES";
    
    if (_enableDebug) then {
        diag_log "[RECONDO_DRP] No saved rally points found";
    };
};

// ========================================
// RECREATE RALLY POINTS
// ========================================

private _loadedRallies = [];
private _rallyCount = createHashMap;  // Track count per side for marker numbering

{
    private _savedEntry = _x;
    
    private _sideNum = _savedEntry get "sideNum";
    private _pos = _savedEntry get "position";
    private _createTime = _savedEntry get "createTime";
    private _deployerUID = _savedEntry get "deployerUID";
    private _markerType = _savedEntry getOrDefault ["markerType", _settings get "markerType"];
    private _markerColor = _savedEntry getOrDefault ["markerColor", _settings get "markerColor"];
    private _markerTextBase = _savedEntry getOrDefault ["markerText", _settings get "markerText"];
    
    if (isNil "_pos" || {_pos isEqualTo [0,0,0]}) then {
        continue;
    };
    
    // Track rally count per side
    private _sideCount = _rallyCount getOrDefault [_sideNum, 0];
    _sideCount = _sideCount + 1;
    _rallyCount set [_sideNum, _sideCount];
    
    // ========================================
    // CREATE RALLY OBJECT
    // ========================================
    
    private _tent = createVehicle [_rallyObjectClass, _pos, [], 0, "NONE"];
    _tent setPosATL _pos;
    
    _tent setVariable ["RECONDO_DRP_SIDE_NUM", _sideNum, true];
    _tent setVariable ["RECONDO_DRP_DEPLOYER_UID", _deployerUID, true];
    
    // ========================================
    // ADD DESTROY FUNCTIONALITY (if enabled)
    // ========================================
    
    private _destroyRemovesRally = _settings get "destroyRemovesRally";
    if (_destroyRemovesRally) then {
        // Add Killed event handler for physical destruction
        _tent addEventHandler ["Killed", {
            params ["_unit", "_killer", "_instigator", "_useEffects"];
            
            [_unit] call Recondo_fnc_removeRallypoint;
            
            private _settings = RECONDO_DRP_SETTINGS;
            if (!isNil "_settings" && {_settings get "enableDebug"}) then {
                diag_log format ["[RECONDO_DRP] Loaded rally object destroyed - rally point removed"];
            };
        }];
        
        // Mark tent as destroyable and broadcast ACE action to clients
        _tent setVariable ["RECONDO_DRP_DESTROYABLE", true, true];
        [_tent] remoteExec ["Recondo_fnc_addDestroyAction", 0, true];
    };
    
    // ========================================
    // CREATE MARKER
    // ========================================
    
    private _markerName = format ["RECONDO_DRP_%1_%2_%3", _sideNum, _sideCount, diag_tickTime];
    
    private _marker = createMarker [_markerName, _pos];
    _marker setMarkerShape "ICON";
    _marker setMarkerType _markerType;
    _marker setMarkerColor _markerColor;
    
    // Format marker text with rally number
    private _formattedText = if (_markerTextBase find "%1" > -1) then {
        format [_markerTextBase, _sideCount]
    } else {
        format ["%1 %2", _markerTextBase, _sideCount]
    };
    _marker setMarkerText _formattedText;
    
    // ========================================
    // ADD PACK ACTION
    // ========================================
    
    _tent addAction [
        format ["<t color='#FFFF00'>%1</t>", _packActionText],
        {
            params ["_target", "_caller", "_actionId", "_args"];
            
            private _tentSideNum = _target getVariable ["RECONDO_DRP_SIDE_NUM", -1];
            
            private _callerSideNum = switch (side _caller) do {
                case east: { 0 };
                case west: { 1 };
                case independent: { 2 };
                case civilian: { 3 };
                default { -1 };
            };
            
            private _settings = RECONDO_DRP_SETTINGS;
            private _allowedSideNum = _settings get "allowedSideNum";
            
            private _canPack = false;
            if (_allowedSideNum == 4) then {
                _canPack = _callerSideNum == _tentSideNum;
            } else {
                _canPack = _callerSideNum == _allowedSideNum;
            };
            
            if (!_canPack) exitWith {
                hint "You are not authorized to pack this rally point.";
            };
            
            [_target] remoteExec ["Recondo_fnc_removeRallypoint", 2];
            
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
        ["createTime", _createTime],
        ["deployerUID", _deployerUID]
    ];
    
    _loadedRallies pushBack _rallyData;
    
    if (_enableDebug) then {
        diag_log format ["[RECONDO_DRP] Loaded rally point at %1 for side %2", _pos, _sideNum];
    };
    
} forEach _saveData;

// ========================================
// UPDATE GLOBAL STATE
// ========================================

RECONDO_DRP_RALLIES = _loadedRallies;
publicVariable "RECONDO_DRP_RALLIES";

diag_log format ["[RECONDO_DRP] Loaded %1 rally points from persistence", count _loadedRallies];
