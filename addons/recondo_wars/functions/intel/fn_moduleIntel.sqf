/*
    Recondo_fnc_moduleIntel
    Main initialization for Intel System module
    
    Description:
        Central hub for the intel gathering and reveal system.
        Manages registration of intel targets from other modules,
        handles turn-in interactions, and reveals targets to player groups.
        
        Sync to an object or unit to designate it as the intel turn-in point.
    
    Priority: 1 (Core system module - loads early)
    
    Parameters:
        _logic - Module logic object
        _units - Synchronized units/objects (turn-in points)
        _activated - Whether module is activated
*/

params ["_logic", "_units", "_activated"];

// Server-only initialization for core logic
if (!isServer) exitWith {};

// Validate activation
if (!_activated) exitWith {
    diag_log "[RECONDO_INTEL] Module not activated.";
};

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

private _intelItemClassnamesRaw = _logic getVariable ["intelitemclassnames", ""];
private _turnInActionText = _logic getVariable ["turninactiontext", "Turn In Intel"];
private _turnInSuccessText = _logic getVariable ["turninsuccesstext", "Intel Report: Grid %1"];
private _turnInNoIntelText = _logic getVariable ["turninnointeltext", "You have no intel to turn in."];
private _turnInNoTargetsText = _logic getVariable ["turninnotargetstext", "No actionable intelligence at this time."];
private _enablePersistence = _logic getVariable ["enablepersistence", true];
private _debugLogging = _logic getVariable ["debuglogging", false];
if (RECONDO_MASTER_DEBUG) then { _debugLogging = true; };

// ========================================
// PARSE INTEL ITEM CLASSNAMES
// ========================================

private _intelItems = [];
if (_intelItemClassnamesRaw != "") then {
    _intelItems = [_intelItemClassnamesRaw] call Recondo_fnc_parseClassnames;
};
RECONDO_INTEL_ITEMS = _intelItems;
publicVariable "RECONDO_INTEL_ITEMS";

// ========================================
// STORE SETTINGS
// ========================================

RECONDO_INTEL_SETTINGS = createHashMapFromArray [
    ["turnInActionText", _turnInActionText],
    ["turnInSuccessText", _turnInSuccessText],
    ["turnInNoIntelText", _turnInNoIntelText],
    ["turnInNoTargetsText", _turnInNoTargetsText],
    ["enablePersistence", _enablePersistence],
    ["debugLogging", _debugLogging]
];
publicVariable "RECONDO_INTEL_SETTINGS";

// Initialize revealed hashmap (groupId -> [targetIds])
RECONDO_INTEL_REVEALED = createHashMap;
publicVariable "RECONDO_INTEL_REVEALED";

// ========================================
// LOAD PERSISTENCE DATA
// ========================================

if (_enablePersistence) then {
    private _savedRevealed = ["INTEL_REVEALED"] call Recondo_fnc_getSaveData;
    private _savedCompleted = ["INTEL_COMPLETED"] call Recondo_fnc_getSaveData;
    
    if (!isNil "_savedRevealed") then {
        // Convert saved array back to hashmap
        {
            _x params ["_groupId", "_targetIds"];
            RECONDO_INTEL_REVEALED set [_groupId, _targetIds];
        } forEach _savedRevealed;
        publicVariable "RECONDO_INTEL_REVEALED";
        
        if (_debugLogging) then {
            diag_log format ["[RECONDO_INTEL] Loaded %1 revealed intel entries from save", count _savedRevealed];
        };
    };
    
    if (!isNil "_savedCompleted" && {_savedCompleted isEqualType []}) then {
        RECONDO_INTEL_COMPLETED = _savedCompleted;
        publicVariable "RECONDO_INTEL_COMPLETED";
        
        if (_debugLogging) then {
            diag_log format ["[RECONDO_INTEL] Loaded %1 completed targets from save", count _savedCompleted];
        };
    };
    
    // Load intel log history
    private _savedIntelLog = ["INTEL_LOG"] call Recondo_fnc_getSaveData;
    if (!isNil "_savedIntelLog" && {_savedIntelLog isEqualType []}) then {
        RECONDO_INTEL_LOG = _savedIntelLog;
        publicVariable "RECONDO_INTEL_LOG";
        
        if (_debugLogging) then {
            diag_log format ["[RECONDO_INTEL] Loaded %1 intel log entries from save", count _savedIntelLog];
        };
    };
};

// ========================================
// SETUP TURN-IN POINTS
// ========================================

private _syncedObjects = synchronizedObjects _logic;

if (count _syncedObjects == 0) then {
    diag_log "[RECONDO_INTEL] WARNING: No objects synced to Intel module. Turn-in functionality will not work.";
} else {
    // Add ACE interactions to synced objects (with delay to ensure ACE is ready)
    [{
        params ["_syncedObjects"];
        
        {
            [_x] call Recondo_fnc_addIntelTurnIn;
            RECONDO_INTEL_TURNIN_OBJECTS pushBack _x;
        } forEach _syncedObjects;
        
        publicVariable "RECONDO_INTEL_TURNIN_OBJECTS";
        
        diag_log format ["[RECONDO_INTEL] Added turn-in interactions to %1 objects", count _syncedObjects];
    }, [_syncedObjects], 2] call CBA_fnc_waitAndExecute;
};

// ========================================
// LOG INITIALIZATION
// ========================================

if (_debugLogging) then {
    diag_log "[RECONDO_INTEL] === Intel System Module Initialized ===";
    diag_log format ["[RECONDO_INTEL] Intel items: %1", RECONDO_INTEL_ITEMS];
    diag_log format ["[RECONDO_INTEL] Turn-in text: %1", _turnInActionText];
    diag_log format ["[RECONDO_INTEL] Persistence: %1", _enablePersistence];
    diag_log format ["[RECONDO_INTEL] Synced objects: %1", count _syncedObjects];
};

diag_log format ["[RECONDO_INTEL] Module initialized. Turn-in points: %1, Intel items: %2", 
    count _syncedObjects, count RECONDO_INTEL_ITEMS];
