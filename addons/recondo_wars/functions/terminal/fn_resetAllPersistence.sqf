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

private _fnc_getTag = {
    params ["_dataType"];
    format ["RECONDO_%1_%2", _campaignID, _dataType]
};

// ========================================
// CORE PERSISTENCE DATA
// ========================================

missionProfileNamespace setVariable [["playerstats"] call _fnc_getTag, nil];
diag_log "[RECONDO_TERMINAL] Cleared: playerstats";

missionProfileNamespace setVariable [["markers"] call _fnc_getTag, nil];
diag_log "[RECONDO_TERMINAL] Cleared: markers";

missionProfileNamespace setVariable [["metadata"] call _fnc_getTag, nil];
diag_log "[RECONDO_TERMINAL] Cleared: metadata";

// ========================================
// STATIC DEFENSE RANDOMIZED (per-instance by prefix)
// ========================================

if (!isNil "RECONDO_SDR_SETTINGS") then {
    private _prefix = RECONDO_SDR_SETTINGS getOrDefault ["markerPrefix", ""];
    if (_prefix != "") then {
        missionProfileNamespace setVariable [[format ["SDR_%1", _prefix]] call _fnc_getTag, nil];
        diag_log format ["[RECONDO_TERMINAL] Cleared: SDR_%1", _prefix];
    };
};

// ========================================
// FOOT PATROLS (per-instance by prefix)
// ========================================

if (!isNil "RECONDO_FP_SETTINGS") then {
    private _prefix = RECONDO_FP_SETTINGS getOrDefault ["markerPrefix", ""];
    if (_prefix != "") then {
        missionProfileNamespace setVariable [[format ["FP_%1", _prefix]] call _fnc_getTag, nil];
        diag_log format ["[RECONDO_TERMINAL] Cleared: FP_%1", _prefix];
    };
};

// ========================================
// INTEL SYSTEM
// ========================================

missionProfileNamespace setVariable [["INTEL_REVEALED"] call _fnc_getTag, nil];
missionProfileNamespace setVariable [["INTEL_COMPLETED"] call _fnc_getTag, nil];
missionProfileNamespace setVariable [["INTEL_LOG"] call _fnc_getTag, nil];
diag_log "[RECONDO_TERMINAL] Cleared: intel (revealed, completed, log)";

// ========================================
// RW RADIO
// ========================================

missionProfileNamespace setVariable [["RWR_Batteries"] call _fnc_getTag, nil];
missionProfileNamespace setVariable [["RWR_GroupTimes"] call _fnc_getTag, nil];
missionProfileNamespace setVariable [["RWR_CallCount"] call _fnc_getTag, nil];
diag_log "[RECONDO_TERMINAL] Cleared: rwradio (batteries, group times, call count)";

// ========================================
// TRACKERS
// ========================================

missionProfileNamespace setVariable [["trackers"] call _fnc_getTag, nil];
diag_log "[RECONDO_TERMINAL] Cleared: trackers";

// ========================================
// WIRETAP
// ========================================

missionProfileNamespace setVariable [["wiretap"] call _fnc_getTag, nil];
diag_log "[RECONDO_TERMINAL] Cleared: wiretap";

// ========================================
// REINFORCEMENT WAVES
// ========================================

missionProfileNamespace setVariable [["reinforcementwaves"] call _fnc_getTag, nil];
diag_log "[RECONDO_TERMINAL] Cleared: reinforcementwaves";

// ========================================
// SENSORS
// ========================================

missionProfileNamespace setVariable [["SENSORS_DEPLOYED"] call _fnc_getTag, nil];
missionProfileNamespace setVariable [["SENSORS_ID_COUNTER"] call _fnc_getTag, nil];
missionProfileNamespace setVariable [["SENSORS_FOOT_COUNT"] call _fnc_getTag, nil];
missionProfileNamespace setVariable [["SENSORS_VEHICLE_COUNT"] call _fnc_getTag, nil];
missionProfileNamespace setVariable [["SENSOR_LOG"] call _fnc_getTag, nil];
diag_log "[RECONDO_TERMINAL] Cleared: sensors (deployed, counters, log)";

// ========================================
// DEPLOYABLE RALLY POINT
// ========================================

missionProfileNamespace setVariable [["DRP_RALLIES"] call _fnc_getTag, nil];
diag_log "[RECONDO_TERMINAL] Cleared: deployable rally points";

// ========================================
// ELDEST SON
// ========================================

missionProfileNamespace setVariable [["RECONDO_ELDESTSON_CHANCE"] call _fnc_getTag, nil];
diag_log "[RECONDO_TERMINAL] Cleared: eldest son";

// ========================================
// CIVILIAN POL
// ========================================

missionProfileNamespace setVariable [["civilianpol"] call _fnc_getTag, nil];
diag_log "[RECONDO_TERMINAL] Cleared: civilian POL";

// ========================================
// RECON POINTS
// ========================================

missionProfileNamespace setVariable [["reconpoints_data"] call _fnc_getTag, nil];
diag_log "[RECONDO_TERMINAL] Cleared: recon points";

// ========================================
// OBJECTIVE DESTROY (per-instance)
// ========================================

if (!isNil "RECONDO_OBJDESTROY_INSTANCES") then {
    {
        private _objectiveName = _x get "objectiveName";
        missionProfileNamespace setVariable [[format ["OBJDESTROY_%1_ACTIVE", _objectiveName]] call _fnc_getTag, nil];
        missionProfileNamespace setVariable [[format ["OBJDESTROY_%1_COMPMAP", _objectiveName]] call _fnc_getTag, nil];
        missionProfileNamespace setVariable [[format ["OBJDESTROY_%1_DESTROYED", _objectiveName]] call _fnc_getTag, nil];
        diag_log format ["[RECONDO_TERMINAL] Cleared: objective destroy '%1'", _objectiveName];
    } forEach RECONDO_OBJDESTROY_INSTANCES;
};

// ========================================
// OBJECTIVE HUB & SUBS (per-instance)
// ========================================

if (!isNil "RECONDO_HUBSUBS_INSTANCES") then {
    {
        private _objectiveName = _x get "objectiveName";
        missionProfileNamespace setVariable [[format ["HUBSUBS_%1_ACTIVE", _objectiveName]] call _fnc_getTag, nil];
        missionProfileNamespace setVariable [[format ["HUBSUBS_%1_COMPMAP", _objectiveName]] call _fnc_getTag, nil];
        missionProfileNamespace setVariable [[format ["HUBSUBS_%1_SUBSITEMAP", _objectiveName]] call _fnc_getTag, nil];
        missionProfileNamespace setVariable [[format ["HUBSUBS_%1_DESTROYED", _objectiveName]] call _fnc_getTag, nil];
        diag_log format ["[RECONDO_TERMINAL] Cleared: hub & subs '%1'", _objectiveName];
    } forEach RECONDO_HUBSUBS_INSTANCES;
};

// ========================================
// OBJECTIVE HVT (per-instance)
// ========================================

if (!isNil "RECONDO_HVT_INSTANCES") then {
    {
        private _objectiveName = _x get "objectiveName";
        missionProfileNamespace setVariable [[format ["HVT_%1_PROFILE", _objectiveName]] call _fnc_getTag, nil];
        missionProfileNamespace setVariable [[format ["HVT_%1_HVTMARKER", _objectiveName]] call _fnc_getTag, nil];
        missionProfileNamespace setVariable [[format ["HVT_%1_DECOYMARKERS", _objectiveName]] call _fnc_getTag, nil];
        missionProfileNamespace setVariable [[format ["HVT_%1_COMPOSITIONS", _objectiveName]] call _fnc_getTag, nil];
        missionProfileNamespace setVariable [[format ["HVT_%1_CAPTURED", _objectiveName]] call _fnc_getTag, nil];
        diag_log format ["[RECONDO_TERMINAL] Cleared: HVT objective '%1'", _objectiveName];
    } forEach RECONDO_HVT_INSTANCES;
};

// ========================================
// OBJECTIVE HOSTAGES (per-instance)
// ========================================

if (!isNil "RECONDO_HOSTAGE_INSTANCES") then {
    {
        private _objectiveName = _x get "objectiveName";
        missionProfileNamespace setVariable [[format ["HOSTAGE_%1_HOSTAGEMARKERS", _objectiveName]] call _fnc_getTag, nil];
        missionProfileNamespace setVariable [[format ["HOSTAGE_%1_DECOYMARKERS", _objectiveName]] call _fnc_getTag, nil];
        missionProfileNamespace setVariable [[format ["HOSTAGE_%1_COMPOSITIONS", _objectiveName]] call _fnc_getTag, nil];
        missionProfileNamespace setVariable [[format ["HOSTAGE_%1_ASSIGNMENTS", _objectiveName]] call _fnc_getTag, nil];
        missionProfileNamespace setVariable [[format ["HOSTAGE_%1_RESCUED", _objectiveName]] call _fnc_getTag, nil];
        diag_log format ["[RECONDO_TERMINAL] Cleared: hostage objective '%1'", _objectiveName];
    } forEach RECONDO_HOSTAGE_INSTANCES;
};

// ========================================
// OBJECTIVE JAMMER (per-instance)
// ========================================

if (!isNil "RECONDO_JAMMER_INSTANCES") then {
    {
        private _objectiveName = _x get "objectiveName";
        missionProfileNamespace setVariable [[format ["JAMMER_%1_ACTIVE", _objectiveName]] call _fnc_getTag, nil];
        missionProfileNamespace setVariable [[format ["JAMMER_%1_COMPMAP", _objectiveName]] call _fnc_getTag, nil];
        missionProfileNamespace setVariable [[format ["JAMMER_%1_DESTROYED", _objectiveName]] call _fnc_getTag, nil];
        diag_log format ["[RECONDO_TERMINAL] Cleared: jammer objective '%1'", _objectiveName];
    } forEach RECONDO_JAMMER_INSTANCES;
};

// ========================================
// OUTPOST TELE (per-instance)
// ========================================

if (!isNil "RECONDO_OUTPOSTTELE_INSTANCES") then {
    {
        private _instanceId = _x get "instanceId";
        private _persistenceKey = format ["OUTPOSTTELE_%1", _instanceId];
        missionProfileNamespace setVariable [[_persistenceKey + "_MARKERS"] call _fnc_getTag, nil];
        missionProfileNamespace setVariable [[_persistenceKey + "_COMPOSITIONS"] call _fnc_getTag, nil];
        missionProfileNamespace setVariable [[_persistenceKey + "_DESTROYED"] call _fnc_getTag, nil];
        diag_log format ["[RECONDO_TERMINAL] Cleared: outpost tele '%1'", _instanceId];
    } forEach RECONDO_OUTPOSTTELE_INSTANCES;
};

// ========================================
// CUSTOM SITE SPAWN (per-instance)
// ========================================

if (!isNil "RECONDO_CSS_INSTANCES") then {
    {
        private _siteName = _x getOrDefault ["siteName", ""];
        private _instanceId = _x getOrDefault ["instanceId", ""];
        private _persistenceKey = format ["CSS_%1", _siteName];
        missionProfileNamespace setVariable [[_persistenceKey + "_MARKERS"] call _fnc_getTag, nil];
        missionProfileNamespace setVariable [[_persistenceKey + "_COMPMAP"] call _fnc_getTag, nil];
        diag_log format ["[RECONDO_TERMINAL] Cleared: custom site spawn '%1'", _instanceId];
    } forEach RECONDO_CSS_INSTANCES;
};

// ========================================
// POO SITE HUNT (per-instance)
// ========================================

if (!isNil "RECONDO_POO_INSTANCES") then {
    {
        private _objectiveName = _x get "objectiveName";
        missionProfileNamespace setVariable [[format ["POO_%1_ACTIVE", _objectiveName]] call _fnc_getTag, nil];
        missionProfileNamespace setVariable [[format ["POO_%1_TARGETS", _objectiveName]] call _fnc_getTag, nil];
        missionProfileNamespace setVariable [[format ["POO_%1_DESTROYED", _objectiveName]] call _fnc_getTag, nil];
        diag_log format ["[RECONDO_TERMINAL] Cleared: POO site hunt '%1'", _objectiveName];
    } forEach RECONDO_POO_INSTANCES;
};

// ========================================
// DESTROY POWERGRID (per-instance)
// ========================================

if (!isNil "RECONDO_POWERGRID_INSTANCES") then {
    {
        private _instanceId = _x get "instanceId";
        missionProfileNamespace setVariable [[format ["POWERGRID_%1_DESTROYED", _instanceId]] call _fnc_getTag, nil];
        diag_log format ["[RECONDO_TERMINAL] Cleared: powergrid '%1'", _instanceId];
    } forEach RECONDO_POWERGRID_INSTANCES;
};

// ========================================
// HANOI HANNAH (per-instance by prefix)
// ========================================

if (!isNil "RECONDO_HANNAH_SETTINGS") then {
    private _prefix = RECONDO_HANNAH_SETTINGS getOrDefault ["markerPrefix", ""];
    if (_prefix != "") then {
        private _hannahKey = format ["HANNAH_%1", _prefix];
        missionProfileNamespace setVariable [[_hannahKey + "_SELECTED"] call _fnc_getTag, nil];
        missionProfileNamespace setVariable [[_hannahKey + "_DISABLED"] call _fnc_getTag, nil];
        diag_log format ["[RECONDO_TERMINAL] Cleared: hanoi hannah '%1'", _prefix];
    };
};

// ========================================
// PLAYER PERSISTENCE
// ========================================

missionProfileNamespace setVariable [["PLAYER_PERSIST_DATA"] call _fnc_getTag, nil];
diag_log "[RECONDO_TERMINAL] Cleared: player persistence data";

// ========================================
// VEHICLE PERSISTENCE
// ========================================

missionProfileNamespace setVariable [["VEHICLE_PERSIST_DATA"] call _fnc_getTag, nil];
diag_log "[RECONDO_TERMINAL] Cleared: vehicle persistence data";

// ========================================
// INVENTORY PERSISTENCE
// ========================================

missionProfileNamespace setVariable [["INVENTORY_PERSIST_DATA"] call _fnc_getTag, nil];
diag_log "[RECONDO_TERMINAL] Cleared: inventory persistence data";

// ========================================
// FINALIZE
// ========================================

missionProfileNamespace setVariable [["RESET_PENDING"] call _fnc_getTag, true];

saveMissionProfileNamespace;

diag_log "[RECONDO_TERMINAL] All persistence data cleared. Changes will take effect on next mission restart.";

// ========================================
// NOTIFY CALLER
// ========================================

private _message = format ["All mission persistence data has been reset.<br/><br/>Campaign: %1<br/><br/>Restart the mission for changes to take effect.", _campaignName];

["DATA CLEARED", _message, 0, 30, "", 2] remoteExec ["Recondo_fnc_showIntelCard", _caller];

private _chatMsg = format ["[TERMINAL] %1 has reset all mission persistence data.", _callerName];
_chatMsg remoteExec ["systemChat", 0];
