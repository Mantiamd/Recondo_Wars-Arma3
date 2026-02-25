/*
    Recondo_fnc_moduleIntelBoard
    Main initialization for Intel Board module
    
    Description:
        Creates an Intel Board interface on synchronized objects.
        Players can access via ACE interaction to view mission
        target information including HVTs, Hostages, and other objectives.
    
    Parameters:
        _logic - Module logic object
        _units - Synchronized units (unused)
        _activated - Whether module is activated
*/

params ["_logic", "_units", "_activated"];

// Server-only initialization
if (!isServer) exitWith {};

// Validate activation
if (!_activated) exitWith {
    diag_log "[RECONDO_INTELBOARD] Module not activated.";
};

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

// General
private _boardName = _logic getVariable ["boardname", "MISSION INTEL"];
private _aceActionName = _logic getVariable ["aceactionname", "View Intel Board"];

// Display options
private _enableHVT = _logic getVariable ["enablehvt", true];
private _enableHostages = _logic getVariable ["enablehostages", true];
private _enableDestroy = _logic getVariable ["enabledestroy", true];
private _enableHubSubs = _logic getVariable ["enablehubsubs", true];
private _enableJammer = _logic getVariable ["enablejammer", true];
private _showRevealedLocations = _logic getVariable ["showrevealedlocations", true];

// Debug
private _debugLogging = _logic getVariable ["debuglogging", false];

// ========================================
// STORE SETTINGS GLOBALLY
// ========================================

if (isNil "RECONDO_INTELBOARD_SETTINGS") then {
    RECONDO_INTELBOARD_SETTINGS = createHashMap;
    publicVariable "RECONDO_INTELBOARD_SETTINGS";
};

RECONDO_INTELBOARD_SETTINGS set ["boardName", _boardName];
RECONDO_INTELBOARD_SETTINGS set ["aceActionName", _aceActionName];
RECONDO_INTELBOARD_SETTINGS set ["enableHVT", _enableHVT];
RECONDO_INTELBOARD_SETTINGS set ["enableHostages", _enableHostages];
RECONDO_INTELBOARD_SETTINGS set ["enableDestroy", _enableDestroy];
RECONDO_INTELBOARD_SETTINGS set ["enableHubSubs", _enableHubSubs];
RECONDO_INTELBOARD_SETTINGS set ["enableJammer", _enableJammer];
RECONDO_INTELBOARD_SETTINGS set ["showRevealedLocations", _showRevealedLocations];
RECONDO_INTELBOARD_SETTINGS set ["debugLogging", _debugLogging];
publicVariable "RECONDO_INTELBOARD_SETTINGS";

if (_debugLogging) then {
    diag_log format ["[RECONDO_INTELBOARD] Module initialized - Board Name: %1", _boardName];
};

// ========================================
// FIND SYNCHRONIZED OBJECTS
// ========================================

private _syncedObjects = synchronizedObjects _logic;

if (count _syncedObjects == 0) then {
    diag_log "[RECONDO_INTELBOARD] WARNING: No objects synchronized to Intel Board module.";
} else {
    if (_debugLogging) then {
        diag_log format ["[RECONDO_INTELBOARD] Found %1 synchronized objects", count _syncedObjects];
    };
};

// ========================================
// ADD ACE ACTIONS TO SYNCED OBJECTS
// ========================================

{
    private _object = _x;
    
    // Skip non-objects
    if (isNull _object) then { continue };
    
    // Add ACE action
    [_object, _aceActionName] call Recondo_fnc_addIntelBoardAction;
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_INTELBOARD] Added Intel Board action to: %1 (%2)", _object, typeOf _object];
    };
} forEach _syncedObjects;

if (_debugLogging) then {
    diag_log "[RECONDO_INTELBOARD] Module initialization complete.";
};
