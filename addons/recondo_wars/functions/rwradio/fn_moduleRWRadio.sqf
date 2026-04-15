/*
    Recondo_fnc_moduleRWRadio
    Main module initialization - runs on server only
    
    Description:
        Called when the RW Radio module is activated.
        Initializes battery management, triangulation, and enemy spawn systems
        for ACRE radios.
    
    Parameters:
        0: OBJECT - Logic module
        1: ARRAY - Synced units (unused)
        2: BOOL - Is activated
        
    Returns:
        Nothing
*/

params ["_logic", "_units", "_activated"];

// Only run on server
if (!isServer) exitWith {
    diag_log "[RECONDO_RWR] Module attempted to run on non-server. Exiting.";
};

// Get all module attributes
private _settings = createHashMap;

// General Settings
_settings set ["enableBattery", _logic getVariable ["enablebattery", true]];
_settings set ["enableTriangulation", _logic getVariable ["enabletriangulation", true]];
_settings set ["enableEnemySpawn", _logic getVariable ["enableenemyspawn", false]];
_settings set ["enablePersistence", _logic getVariable ["enablepersistence", false]];

// Battery Settings
private _radioClassnamesStr = _logic getVariable ["radioclassnames", "ACRE_PRC77"];
private _radioClassnames = [_radioClassnamesStr] call Recondo_fnc_parseClassnames;
_settings set ["radioClassnames", _radioClassnames];
_settings set ["batteryCapacity", _logic getVariable ["batterycapacity", 360]];
_settings set ["drainRate", _logic getVariable ["drainrate", 1]];
private _batteryItemsStr = _logic getVariable ["batteryitems", ""];
private _batteryItems = [_batteryItemsStr] call Recondo_fnc_parseClassnames;
_settings set ["batteryItems", _batteryItems];
_settings set ["lowBatteryWarning", _logic getVariable ["lowbatterywarning", 20]];

// Triangulation Settings
_settings set ["triangThreshold1", _logic getVariable ["triangthreshold1", 35]];
_settings set ["triangRadius1", _logic getVariable ["triangradius1", 400]];
_settings set ["triangThreshold2", _logic getVariable ["triangthreshold2", 70]];
_settings set ["triangRadius2", _logic getVariable ["triangradius2", 250]];
_settings set ["triangThreshold3", _logic getVariable ["triangthreshold3", 105]];
_settings set ["triangRadius3", _logic getVariable ["triangradius3", 150]];
_settings set ["triangThreshold4", _logic getVariable ["triangthreshold4", 140]];
_settings set ["triangRadius4", _logic getVariable ["triangradius4", 125]];
_settings set ["markerDuration", _logic getVariable ["markerduration", 600]];
_settings set ["markerColor", _logic getVariable ["markercolor", "ColorRed"]];

// Enemy Spawn Settings
_settings set ["spawnThreshold", _logic getVariable ["spawnthreshold", 15]];
private _enemyClassnamesStr = _logic getVariable ["enemyclassnames", ""];
private _enemyClassnames = [_enemyClassnamesStr] call Recondo_fnc_parseClassnames;
_settings set ["enemyClassnames", _enemyClassnames];
private _enemySideNum = _logic getVariable ["enemyside", 0];
private _sideMap = [east, west, independent];
_settings set ["enemySide", _sideMap select _enemySideNum];
_settings set ["enemyMinSize", _logic getVariable ["enemyminsize", 4]];
_settings set ["enemyMaxSize", _logic getVariable ["enemymaxsize", 8]];
_settings set ["spawnDistance", _logic getVariable ["spawndistance", 250]];

// Exemptions
private _exemptGroupsStr = _logic getVariable ["exemptgroups", ""];
private _exemptGroups = [_exemptGroupsStr] call Recondo_fnc_parseClassnames;
_settings set ["exemptGroups", _exemptGroups];
_settings set ["noCountPrefix", _logic getVariable ["nocountprefix", "NO_RADIO_"]];
_settings set ["noCountRadius", _logic getVariable ["nocountradius", 500]];

// Debug
_settings set ["enableDebug", _logic getVariable ["enabledebug", false]];
if (RECONDO_MASTER_DEBUG) then { _settings set ["enableDebug", true]; };

// Store settings globally
RECONDO_RWR_SETTINGS = _settings;
publicVariable "RECONDO_RWR_SETTINGS";

private _debug = _settings get "enableDebug";

// Validate settings
if (count _radioClassnames == 0) exitWith {
    diag_log "[RECONDO_RWR] ERROR: No radio classnames specified. Module disabled.";
};

// Initialize server-side tracking variables
RECONDO_RWR_BATTERY_LEVELS = createHashMap;        // radioId -> remaining seconds
RECONDO_RWR_TRANSMISSION_STARTS = createHashMap;   // radioId -> serverTime when started
RECONDO_RWR_GROUP_TIMES = createHashMap;           // groupId -> cumulative transmission seconds
RECONDO_RWR_GROUP_MARKERS = createHashMap;         // groupId -> [markerName, textMarkerName]
RECONDO_RWR_CALL_COUNT = 0;                        // Global radio call counter for enemy spawn
RECONDO_RWR_LAST_ENEMY_COUNT = 0;                  // Track enemy spawn threshold

// Load from persistence if enabled
private _enablePersistence = _settings get "enablePersistence";
if (_enablePersistence && {!isNil "RECONDO_PERSISTENCE_SETTINGS"}) then {
    private _savedBatteries = ["RWR_Batteries", createHashMap] call Recondo_fnc_getSaveData;
    private _savedGroupTimes = ["RWR_GroupTimes", createHashMap] call Recondo_fnc_getSaveData;
    private _savedCallCount = ["RWR_CallCount", 0] call Recondo_fnc_getSaveData;
    
    RECONDO_RWR_BATTERY_LEVELS = _savedBatteries;
    RECONDO_RWR_GROUP_TIMES = _savedGroupTimes;
    RECONDO_RWR_CALL_COUNT = _savedCallCount;
    
    if (_debug) then {
        diag_log format ["[RECONDO_RWR] Loaded from persistence - Batteries: %1, GroupTimes: %2, CallCount: %3", 
            count keys RECONDO_RWR_BATTERY_LEVELS, count keys RECONDO_RWR_GROUP_TIMES, RECONDO_RWR_CALL_COUNT];
    };
};

// Broadcast tracking variables
publicVariable "RECONDO_RWR_BATTERY_LEVELS";
publicVariable "RECONDO_RWR_GROUP_TIMES";
publicVariable "RECONDO_RWR_CALL_COUNT";

// Debug logging
if (_debug) then {
    diag_log "[RECONDO_RWR] === RW Radio Module Initialized ===";
    diag_log format ["[RECONDO_RWR] Enable Battery: %1", _settings get "enableBattery"];
    diag_log format ["[RECONDO_RWR] Enable Triangulation: %1", _settings get "enableTriangulation"];
    diag_log format ["[RECONDO_RWR] Enable Enemy Spawn: %1", _settings get "enableEnemySpawn"];
    diag_log format ["[RECONDO_RWR] Enable Persistence: %1", _enablePersistence];
    diag_log format ["[RECONDO_RWR] Radio Classnames: %1", _radioClassnames];
    diag_log format ["[RECONDO_RWR] Battery Capacity: %1s", _settings get "batteryCapacity"];
    diag_log format ["[RECONDO_RWR] Drain Rate: %1x", _settings get "drainRate"];
    diag_log format ["[RECONDO_RWR] Battery Items: %1", _batteryItems];
    diag_log format ["[RECONDO_RWR] Exempt Groups: %1", _exemptGroups];
};

// JIP handler - sync state to joining players
addMissionEventHandler ["PlayerConnected", {
    params ["_id", "_uid", "_name", "_jip", "_owner"];
    if (_jip) then {
        // Sync current state to JIP player
        RECONDO_RWR_SETTINGS remoteExec ["", _owner];
        RECONDO_RWR_BATTERY_LEVELS remoteExec ["", _owner];
    };
}];

// Initialize client-side system on all clients with delay to ensure variables are synced
[{
    [] remoteExec ["Recondo_fnc_initRadioClient", 0, true];
}, [], 1] call CBA_fnc_waitAndExecute;

// Auto-save if persistence enabled
if (_enablePersistence && {!isNil "RECONDO_PERSISTENCE_SETTINGS"}) then {
    // Save every 5 minutes
    [{
        if (isNil "RECONDO_RWR_SETTINGS") exitWith {};
        if !(RECONDO_RWR_SETTINGS get "enablePersistence") exitWith {};
        
        ["RWR_Batteries", RECONDO_RWR_BATTERY_LEVELS] call Recondo_fnc_setSaveData;
        ["RWR_GroupTimes", RECONDO_RWR_GROUP_TIMES] call Recondo_fnc_setSaveData;
        ["RWR_CallCount", RECONDO_RWR_CALL_COUNT] call Recondo_fnc_setSaveData;
        saveMissionProfileNamespace;
        
        if (RECONDO_RWR_SETTINGS get "enableDebug") then {
            diag_log "[RECONDO_RWR] Auto-saved battery and triangulation data";
        };
    }, 300, []] call CBA_fnc_addPerFrameHandler;
};

diag_log format ["[RECONDO_RWR] Module initialized. Tracking %1 radio type(s).", count _radioClassnames];
