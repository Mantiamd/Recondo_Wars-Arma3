/*
    Recondo_fnc_resetAllPersistence
    Resets all persistence data
    
    Description:
        Server-side function that clears all persistence data
        from missionProfileNamespace. Changes take effect on
        next mission restart.
    
    Parameters:
        None (called via remoteExec from client)
    
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

private _caller = remoteExecutedOwner;
private _callerName = "Unknown";

// Get caller name if possible
{
    if (owner _x == _caller) exitWith {
        _callerName = name _x;
    };
} forEach allPlayers;

diag_log format ["[RECONDO_TERMINAL] Reset persistence requested by: %1 (owner: %2)", _callerName, _caller];

// ========================================
// GET PERSISTENCE SETTINGS
// ========================================

private _campaignName = "Unknown";
private _campaignID = format ["%1_%2", missionName, worldName];
_campaignID = _campaignID regexReplace ["[^a-zA-Z0-9_]", "_"];

if (!isNil "RECONDO_PERSISTENCE_SETTINGS") then {
    _campaignName = RECONDO_PERSISTENCE_SETTINGS getOrDefault ["campaignName", _campaignName];
    _campaignID = RECONDO_PERSISTENCE_SETTINGS getOrDefault ["campaignID", _campaignID];
};

// ========================================
// CLEAR ALL PERSISTENCE DATA
// ========================================

// Helper to build proper save tag
private _fnc_getTag = {
    params ["_dataType"];
    format ["RECONDO_%1_%2", _campaignID, _dataType]
};

// Clear player stats
missionProfileNamespace setVariable [["playerstats"] call _fnc_getTag, nil];
diag_log "[RECONDO_TERMINAL] Cleared: playerstats";

// Clear map markers
missionProfileNamespace setVariable [["markers"] call _fnc_getTag, nil];
diag_log "[RECONDO_TERMINAL] Cleared: markers";

// Clear SDR (Static Defense Randomized)
missionProfileNamespace setVariable [["sdr"] call _fnc_getTag, nil];
diag_log "[RECONDO_TERMINAL] Cleared: sdr";

// Clear Foot Patrols
missionProfileNamespace setVariable [["footpatrols"] call _fnc_getTag, nil];
diag_log "[RECONDO_TERMINAL] Cleared: footpatrols";

// Clear Path Patrols
missionProfileNamespace setVariable [["pathpatrols"] call _fnc_getTag, nil];
diag_log "[RECONDO_TERMINAL] Cleared: pathpatrols";

// Clear Intel system data
missionProfileNamespace setVariable [["intel_revealed"] call _fnc_getTag, nil];
missionProfileNamespace setVariable [["intel_completed"] call _fnc_getTag, nil];
diag_log "[RECONDO_TERMINAL] Cleared: intel";

// Clear Tracker data
missionProfileNamespace setVariable [["trackers"] call _fnc_getTag, nil];
diag_log "[RECONDO_TERMINAL] Cleared: trackers";

// Clear RW Radio battery data
missionProfileNamespace setVariable [["rwradio"] call _fnc_getTag, nil];
diag_log "[RECONDO_TERMINAL] Cleared: rwradio";

// Clear Wiretap data
missionProfileNamespace setVariable [["wiretap"] call _fnc_getTag, nil];
diag_log "[RECONDO_TERMINAL] Cleared: wiretap";

// Clear objective persistence for all Objective Destroy instances
if (!isNil "RECONDO_OBJDESTROY_INSTANCES") then {
    {
        private _settings = _x;
        private _objectiveName = _settings get "objectiveName";
        
        // Key format matches fn_moduleObjectiveDestroy: "OBJDESTROY_[name]_[suffix]"
        missionProfileNamespace setVariable [[format ["OBJDESTROY_%1_ACTIVE", _objectiveName]] call _fnc_getTag, nil];
        missionProfileNamespace setVariable [[format ["OBJDESTROY_%1_COMPMAP", _objectiveName]] call _fnc_getTag, nil];
        missionProfileNamespace setVariable [[format ["OBJDESTROY_%1_DESTROYED", _objectiveName]] call _fnc_getTag, nil];
        
        diag_log format ["[RECONDO_TERMINAL] Cleared persistence for objective: %1", _objectiveName];
    } forEach RECONDO_OBJDESTROY_INSTANCES;
};

// Clear Hub & Subs persistence for all instances
if (!isNil "RECONDO_HUBSUBS_INSTANCES") then {
    {
        private _settings = _x;
        private _objectiveName = _settings get "objectiveName";
        
        // Key format matches fn_moduleObjectiveHubSubs: "HUBSUBS_[name]_[suffix]"
        missionProfileNamespace setVariable [[format ["HUBSUBS_%1_ACTIVE", _objectiveName]] call _fnc_getTag, nil];
        missionProfileNamespace setVariable [[format ["HUBSUBS_%1_COMPMAP", _objectiveName]] call _fnc_getTag, nil];
        missionProfileNamespace setVariable [[format ["HUBSUBS_%1_SUBSITEMAP", _objectiveName]] call _fnc_getTag, nil];
        missionProfileNamespace setVariable [[format ["HUBSUBS_%1_DESTROYED", _objectiveName]] call _fnc_getTag, nil];
        
        diag_log format ["[RECONDO_TERMINAL] Cleared persistence for hub objective: %1", _objectiveName];
    } forEach RECONDO_HUBSUBS_INSTANCES;
};

// Clear HVT persistence for all instances
if (!isNil "RECONDO_HVT_INSTANCES") then {
    {
        private _settings = _x;
        private _objectiveName = _settings get "objectiveName";
        
        // Key format matches fn_moduleObjectiveHVT: "HVT_[name]_[suffix]"
        missionProfileNamespace setVariable [[format ["HVT_%1_HVTMARKER", _objectiveName]] call _fnc_getTag, nil];
        missionProfileNamespace setVariable [[format ["HVT_%1_DECOYMARKERS", _objectiveName]] call _fnc_getTag, nil];
        missionProfileNamespace setVariable [[format ["HVT_%1_COMPOSITIONS", _objectiveName]] call _fnc_getTag, nil];
        missionProfileNamespace setVariable [[format ["HVT_%1_CAPTURED", _objectiveName]] call _fnc_getTag, nil];
        
        diag_log format ["[RECONDO_TERMINAL] Cleared persistence for HVT objective: %1", _objectiveName];
    } forEach RECONDO_HVT_INSTANCES;
};

// Clear Reinforcement Waves
missionProfileNamespace setVariable [["reinforcementwaves"] call _fnc_getTag, nil];
diag_log "[RECONDO_TERMINAL] Cleared: reinforcementwaves";

// Set flag to show notification on next mission start
missionProfileNamespace setVariable [["RESET_PENDING"] call _fnc_getTag, true];

// Save changes
saveMissionProfileNamespace;

diag_log "[RECONDO_TERMINAL] All persistence data cleared. Changes will take effect on next mission restart.";

// ========================================
// NOTIFY CALLER
// ========================================

private _message = format ["All mission persistence data has been reset.<br/><br/>Campaign: %1<br/><br/>Restart the mission for changes to take effect.", _campaignName];

// Show Intel Card to caller
["DATA CLEARED", _message, 0, 30, "", 2] remoteExec ["Recondo_fnc_showIntelCard", _caller];

// Also notify in system chat
private _chatMsg = format ["[TERMINAL] %1 has reset all mission persistence data.", _callerName];
_chatMsg remoteExec ["systemChat", 0];
