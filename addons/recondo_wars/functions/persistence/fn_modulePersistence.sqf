/*
    Recondo_fnc_modulePersistence
    Main module initialization - runs on server only
    
    Description:
        Called when the Persistence module is activated.
        Reads all module attributes, initializes persistence system,
        sets up auto-save loop, and optionally loads existing save data.
    
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
    diag_log "[RECONDO_PERSISTENCE] Module attempted to run on non-server. Exiting.";
};

// Check if already initialized (prevent multiple modules)
if (!isNil "RECONDO_PERSISTENCE_INITIALIZED") exitWith {
    diag_log "[RECONDO_PERSISTENCE] WARNING: Module already initialized. Only one Persistence module should be placed.";
};

RECONDO_PERSISTENCE_INITIALIZED = true;

// Get all module attributes and store in hashmap
private _settings = createHashMap;

// Campaign Settings
private _campaignID = _logic getVariable ["campaignid", ""];
if (_campaignID == "") then {
    // Auto-generate campaign ID from mission name and world
    _campaignID = format ["%1_%2", missionName, worldName];
    // Clean the string of invalid characters
    _campaignID = _campaignID regexReplace ["[^a-zA-Z0-9_]", "_"];
};
_settings set ["campaignID", _campaignID];
_settings set ["loadOnStart", _logic getVariable ["loadonstart", true]];

// Auto-Save Settings
_settings set ["enableAutoSave", _logic getVariable ["enableautosave", true]];
_settings set ["autoSaveInterval", _logic getVariable ["autosaveinterval", 15]];
_settings set ["saveWarningTime", _logic getVariable ["savewarningtime", 10]];

// Marker Settings
_settings set ["saveMarkers", _logic getVariable ["savemarkers", true]];

// Player Stats Settings
_settings set ["savePlayerStats", _logic getVariable ["saveplayerstats", true]];
_settings set ["trackAIKills", _logic getVariable ["trackaikills", true]];
_settings set ["trackPlayerKills", _logic getVariable ["trackplayerkills", true]];

// Debug
_settings set ["enableDebug", _logic getVariable ["enabledebug", false]];
if (RECONDO_MASTER_DEBUG) then { _settings set ["enableDebug", true]; };

// Store settings globally
RECONDO_PERSISTENCE_SETTINGS = _settings;
publicVariable "RECONDO_PERSISTENCE_SETTINGS";

private _debug = _settings get "enableDebug";

if (_debug) then {
    diag_log format ["[RECONDO_PERSISTENCE] Campaign ID: %1", _campaignID];
    diag_log format ["[RECONDO_PERSISTENCE] Auto-Save: %1, Interval: %2 min", _settings get "enableAutoSave", _settings get "autoSaveInterval"];
    diag_log format ["[RECONDO_PERSISTENCE] Save Markers: %1, Save Player Stats: %2", _settings get "saveMarkers", _settings get "savePlayerStats"];
};

// Initialize player stats tracking if enabled
if (_settings get "savePlayerStats") then {
    [] call Recondo_fnc_trackPlayerStats;
};

// Load existing save data if enabled
if (_settings get "loadOnStart") then {
    [] call Recondo_fnc_loadMission;
};

// Set up auto-save loop if enabled
if (_settings get "enableAutoSave") then {
    private _intervalSeconds = (_settings get "autoSaveInterval") * 60;
    
    // Schedule first auto-save
    RECONDO_PERSISTENCE_NEXT_SAVE = time + _intervalSeconds;
    
    // Auto-save loop
    [{
        private _settings = RECONDO_PERSISTENCE_SETTINGS;
        if (isNil "_settings") exitWith {};
        
        private _intervalSeconds = (_settings get "autoSaveInterval") * 60;
        private _warningTime = _settings get "saveWarningTime";
        
        // Check if it's time to save
        if (time >= RECONDO_PERSISTENCE_NEXT_SAVE) then {
            // Show warning to all players
            if (_warningTime > 0) then {
                private _warningMsg = format ["Auto-save in %1 seconds...", _warningTime];
                _warningMsg remoteExec ["systemChat", 0, false];
                
                // Delay the actual save
                [{
                    [false] call Recondo_fnc_saveMission;
                }, [], _warningTime] call CBA_fnc_waitAndExecute;
            } else {
                // Save immediately
                [false] call Recondo_fnc_saveMission;
            };
            
            // Schedule next save
            RECONDO_PERSISTENCE_NEXT_SAVE = time + _intervalSeconds;
        };
    }, 10, []] call CBA_fnc_addPerFrameHandler;
    
    if (_debug) then {
        diag_log format ["[RECONDO_PERSISTENCE] Auto-save loop started. First save in %1 minutes.", _settings get "autoSaveInterval"];
    };
};

// Final log
diag_log format ["[RECONDO_PERSISTENCE] Initialized. Campaign: %1", _campaignID];

// ========================================
// CHECK FOR PERSISTENCE RESET
// ========================================
// If persistence was reset in a previous session, show notification

private _resetPendingTag = format ["RECONDO_%1_RESET_PENDING", _campaignID];
private _resetPending = missionProfileNamespace getVariable [_resetPendingTag, false];

if (_resetPending) then {
    // Clear the flag
    missionProfileNamespace setVariable [_resetPendingTag, nil];
    saveMissionProfileNamespace;
    
    diag_log "[RECONDO_PERSISTENCE] Reset detected - showing reroll notification to players";
    
    // Build detailed message about what was rerolled
    // Wait a moment for all modules to finish initializing before showing
    [{
        private _details = [];
        
        // Check which objective systems are active (use count > 0 since arrays are initialized empty)
        if (count RECONDO_OBJDESTROY_INSTANCES > 0) then {
            _details pushBack "• Destroy Objectives";
        };
        if (count RECONDO_HUBSUBS_INSTANCES > 0) then {
            _details pushBack "• Hub & Sub-Sites";
        };
        if (count RECONDO_HVT_INSTANCES > 0) then {
            _details pushBack "• High Value Targets";
        };
        if (!isNil "RECONDO_HOSTAGE_INSTANCES" && {count RECONDO_HOSTAGE_INSTANCES > 0}) then {
            _details pushBack "• Hostage Locations";
        };
        if (count RECONDO_INTEL_TARGETS > 0) then {
            _details pushBack "• Intel Targets";
        };
        if (count RECONDO_WIRETAP_POLES > 0) then {
            _details pushBack "• Wiretap Locations";
        };
        if (count RECONDO_SDR_SPAWNED_STATICS > 0) then {
            _details pushBack "• Static Defenses";
        };
        if (count RECONDO_FP_SPAWNED_GROUPS > 0) then {
            _details pushBack "• Foot Patrols";
        };
        if (count RECONDO_PP_SPAWNED_GROUPS > 0) then {
            _details pushBack "• Path Patrols";
        };
        if (count RECONDO_TRACKERS_ENABLED_MARKERS > 0) then {
            _details pushBack "• Tracker Markers";
        };
        
        private _detailText = if (count _details > 0) then {
            "The following have been randomized:<br/><br/>" + (_details joinString "<br/>")
        } else {
            "All persistent objectives have been randomized."
        };
        
        private _message = format [
            "Persistence data was reset. All objectives have been rerolled for this session.<br/><br/>%1",
            _detailText
        ];
        
        // Show Intel Card to all players
        ["REROLL COMPLETE", _message, 0, 45, "", 2] remoteExec ["Recondo_fnc_showIntelCard", 0];
        
        diag_log "[RECONDO_PERSISTENCE] Reroll notification sent to all players";
    }, [], 3] call CBA_fnc_waitAndExecute;
};
