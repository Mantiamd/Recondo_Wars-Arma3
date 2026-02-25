/*
    Recondo_fnc_moduleSTABO
    Main initialization function for the STABO module
    
    Description:
        Initializes STABO extraction capability on synced helicopters.
        Stores module settings and broadcasts to clients for ACE interaction setup.
        
    Priority: 5 (Feature module - no dependencies on other modules)
    
    Parameters:
        0: OBJECT - Logic module object
        1: ARRAY - Synced units (unused)
        2: BOOL - Module activated (unused)
        
    Returns:
        Nothing
        
    Example:
        Called automatically by Eden module system
*/

params ["_logic", "_units", "_activated"];

// Only execute on server
if (!isServer) exitWith {};

// Get synced objects (helicopters)
private _syncedObjects = synchronizedObjects _logic;
private _helicopters = _syncedObjects select { _x isKindOf "Helicopter" };

if (count _helicopters == 0) exitWith {
    diag_log "[RECONDO_STABO] WARNING: No helicopters synced to module. Module disabled.";
};

// Read settings from module attributes
private _settings = createHashMap;

// Rope Settings
_settings set ["anchorClassname", _logic getVariable ["anchorclassname", "vn_prop_sandbag_01"]];
_settings set ["ropeLength", _logic getVariable ["ropelength", 40]];
_settings set ["breakDistance", _logic getVariable ["breakdistance", 60]];

// Height Settings
_settings set ["minHeight", _logic getVariable ["minheight", 3]];
_settings set ["maxHeight", _logic getVariable ["maxheight", 35]];

// Interaction Settings
_settings set ["searchRadius", _logic getVariable ["searchradius", 50]];
_settings set ["attachDistance", _logic getVariable ["attachdistance", 6]];
_settings set ["maxAttachments", _logic getVariable ["maxattachments", 8]];
_settings set ["detachDistance", _logic getVariable ["detachdistance", 5]];

// Ground Request Settings (for AI pilots)
_settings set ["groundRequestRadius", _logic getVariable ["groundrequestradius", 50]];
_settings set ["groundRequestMinHeight", _logic getVariable ["groundrequestminheight", 5]];
_settings set ["groundRequestMaxHeight", _logic getVariable ["groundrequestmaxheight", 50]];

// Debug
_settings set ["enableDebug", _logic getVariable ["enabledebug", false]];

private _debug = _settings get "enableDebug";

// Store settings globally
RECONDO_STABO_SETTINGS = _settings;
publicVariable "RECONDO_STABO_SETTINGS";

if (_debug) then {
    diag_log "[RECONDO_STABO] Settings:";
    diag_log format ["  Anchor classname: %1", _settings get "anchorClassname"];
    diag_log format ["  Rope length: %1m", _settings get "ropeLength"];
    diag_log format ["  Break distance: %1m", _settings get "breakDistance"];
    diag_log format ["  Height range: %1-%2m", _settings get "minHeight", _settings get "maxHeight"];
    diag_log format ["  Search radius: %1m", _settings get "searchRadius"];
    diag_log format ["  Attach distance: %1m", _settings get "attachDistance"];
    diag_log format ["  Max attachments: %1", _settings get "maxAttachments"];
    diag_log format ["  Detach distance: %1m", _settings get "detachDistance"];
    diag_log format ["  Ground request radius: %1m", _settings get "groundRequestRadius"];
    diag_log format ["  Ground request height: %1-%2m", _settings get "groundRequestMinHeight", _settings get "groundRequestMaxHeight"];
};

// Enable STABO on each synced helicopter
{
    private _heli = _x;
    
    // Mark helicopter as STABO-enabled
    _heli setVariable ["RECONDO_STABO_Enabled", true, true];
    _heli setVariable ["RECONDO_STABO_Settings", _settings, true];
    _heli setVariable ["RECONDO_STABO_Deployed", false, true];
    
    // Track helicopter
    RECONDO_STABO_HELICOPTERS pushBack _heli;
    
    if (_debug) then {
        diag_log format ["[RECONDO_STABO] Enabled on helicopter: %1", typeOf _heli];
    };
} forEach _helicopters;

// Broadcast helicopter list to clients
publicVariable "RECONDO_STABO_HELICOPTERS";

// Wait for variables to sync before adding ACE actions on clients
// This ensures RECONDO_STABO_Enabled and settings are available
[{
    params ["_helicopters", "_debug"];
    
    // Tell all clients to add ACE actions to STABO helicopters
    [_helicopters, _debug] remoteExec ["Recondo_fnc_addStaboActions", 0, true];
    
    if (_debug) then {
        diag_log "[RECONDO_STABO] ACE actions broadcast to clients";
    };
}, [_helicopters, _debug], 1] call CBA_fnc_waitAndExecute;

diag_log format ["[RECONDO_STABO] Initialized. Enabled STABO on %1 helicopters.", count _helicopters];
