/*
    Recondo_fnc_deleteSave
    Delete all persistence data for current campaign
    
    Description:
        Clears all saved data from missionProfileNamespace for the current
        campaign ID. Use with caution - this cannot be undone.
    
    Parameters:
        0: BOOL - Confirm deletion (must be true to proceed)
        
    Returns:
        BOOL - True if deletion successful
        
    Example:
        [true] call Recondo_fnc_deleteSave;
*/

params [["_confirm", false, [true]]];

if (!isServer) exitWith {
    diag_log "[RECONDO_PERSISTENCE] deleteSave called on non-server.";
    false
};

if (!_confirm) exitWith {
    diag_log "[RECONDO_PERSISTENCE] deleteSave: Confirmation required. Pass true to confirm deletion.";
    false
};

if (isNil "RECONDO_PERSISTENCE_SETTINGS") exitWith {
    diag_log "[RECONDO_PERSISTENCE] deleteSave: Persistence not initialized.";
    false
};

private _settings = RECONDO_PERSISTENCE_SETTINGS;
private _campaignID = _settings get "campaignID";
private _debug = _settings get "enableDebug";

diag_log format ["[RECONDO_PERSISTENCE] Deleting all save data for campaign: %1", _campaignID];

private _fnc_getTag = {
    params ["_dataType"];
    format ["RECONDO_%1_%2", _campaignID, _dataType]
};

// ========================================
// CORE DATA
// ========================================

private _coreTypes = [
    "metadata",
    "markers",
    "playerstats"
];

{ 
    missionProfileNamespace setVariable [[_x] call _fnc_getTag, nil];
    if (_debug) then { diag_log format ["[RECONDO_PERSISTENCE] Deleted: %1", _x]; };
} forEach _coreTypes;

// ========================================
// FLAT-KEY SYSTEMS
// ========================================

private _flatKeys = [
    "trackers",
    "wiretap",
    "reinforcementwaves",
    "INTEL_REVEALED",
    "INTEL_COMPLETED",
    "INTEL_LOG",
    "RWR_Batteries",
    "RWR_GroupTimes",
    "RWR_CallCount",
    "SENSORS_DEPLOYED",
    "SENSORS_ID_COUNTER",
    "SENSORS_FOOT_COUNT",
    "SENSORS_VEHICLE_COUNT",
    "SENSOR_LOG",
    "DRP_RALLIES",
    "RECONDO_ELDESTSON_CHANCE",
    "civilianpol",
    "reconpoints_data"
];

{
    missionProfileNamespace setVariable [[_x] call _fnc_getTag, nil];
    if (_debug) then { diag_log format ["[RECONDO_PERSISTENCE] Deleted: %1", _x]; };
} forEach _flatKeys;

// ========================================
// PER-INSTANCE SYSTEMS
// ========================================

// SDR
if (!isNil "RECONDO_SDR_SETTINGS") then {
    private _prefix = RECONDO_SDR_SETTINGS getOrDefault ["markerPrefix", ""];
    if (_prefix != "") then {
        missionProfileNamespace setVariable [[format ["SDR_%1", _prefix]] call _fnc_getTag, nil];
        if (_debug) then { diag_log format ["[RECONDO_PERSISTENCE] Deleted: SDR_%1", _prefix]; };
    };
};

// Foot Patrols
if (!isNil "RECONDO_FP_SETTINGS") then {
    private _prefix = RECONDO_FP_SETTINGS getOrDefault ["markerPrefix", ""];
    if (_prefix != "") then {
        missionProfileNamespace setVariable [[format ["FP_%1", _prefix]] call _fnc_getTag, nil];
        if (_debug) then { diag_log format ["[RECONDO_PERSISTENCE] Deleted: FP_%1", _prefix]; };
    };
};

// Objective Destroy
if (!isNil "RECONDO_OBJDESTROY_INSTANCES") then {
    {
        private _name = _x get "objectiveName";
        { missionProfileNamespace setVariable [[_x] call _fnc_getTag, nil]; } forEach [
            format ["OBJDESTROY_%1_ACTIVE", _name],
            format ["OBJDESTROY_%1_COMPMAP", _name],
            format ["OBJDESTROY_%1_DESTROYED", _name]
        ];
        if (_debug) then { diag_log format ["[RECONDO_PERSISTENCE] Deleted: OBJDESTROY_%1", _name]; };
    } forEach RECONDO_OBJDESTROY_INSTANCES;
};

// Hub & Subs
if (!isNil "RECONDO_HUBSUBS_INSTANCES") then {
    {
        private _name = _x get "objectiveName";
        { missionProfileNamespace setVariable [[_x] call _fnc_getTag, nil]; } forEach [
            format ["HUBSUBS_%1_ACTIVE", _name],
            format ["HUBSUBS_%1_COMPMAP", _name],
            format ["HUBSUBS_%1_SUBSITEMAP", _name],
            format ["HUBSUBS_%1_DESTROYED", _name]
        ];
        if (_debug) then { diag_log format ["[RECONDO_PERSISTENCE] Deleted: HUBSUBS_%1", _name]; };
    } forEach RECONDO_HUBSUBS_INSTANCES;
};

// HVT
if (!isNil "RECONDO_HVT_INSTANCES") then {
    {
        private _name = _x get "objectiveName";
        { missionProfileNamespace setVariable [[_x] call _fnc_getTag, nil]; } forEach [
            format ["HVT_%1_PROFILE", _name],
            format ["HVT_%1_HVTMARKER", _name],
            format ["HVT_%1_DECOYMARKERS", _name],
            format ["HVT_%1_COMPOSITIONS", _name],
            format ["HVT_%1_CAPTURED", _name]
        ];
        if (_debug) then { diag_log format ["[RECONDO_PERSISTENCE] Deleted: HVT_%1", _name]; };
    } forEach RECONDO_HVT_INSTANCES;
};

// Hostages
if (!isNil "RECONDO_HOSTAGE_INSTANCES") then {
    {
        private _name = _x get "objectiveName";
        { missionProfileNamespace setVariable [[_x] call _fnc_getTag, nil]; } forEach [
            format ["HOSTAGE_%1_HOSTAGEMARKERS", _name],
            format ["HOSTAGE_%1_DECOYMARKERS", _name],
            format ["HOSTAGE_%1_COMPOSITIONS", _name],
            format ["HOSTAGE_%1_ASSIGNMENTS", _name],
            format ["HOSTAGE_%1_RESCUED", _name]
        ];
        if (_debug) then { diag_log format ["[RECONDO_PERSISTENCE] Deleted: HOSTAGE_%1", _name]; };
    } forEach RECONDO_HOSTAGE_INSTANCES;
};

// Jammer
if (!isNil "RECONDO_JAMMER_INSTANCES") then {
    {
        private _name = _x get "objectiveName";
        { missionProfileNamespace setVariable [[_x] call _fnc_getTag, nil]; } forEach [
            format ["JAMMER_%1_ACTIVE", _name],
            format ["JAMMER_%1_COMPMAP", _name],
            format ["JAMMER_%1_DESTROYED", _name]
        ];
        if (_debug) then { diag_log format ["[RECONDO_PERSISTENCE] Deleted: JAMMER_%1", _name]; };
    } forEach RECONDO_JAMMER_INSTANCES;
};

// Outpost Tele
if (!isNil "RECONDO_OUTPOSTTELE_INSTANCES") then {
    {
        private _id = _x get "instanceId";
        private _key = format ["OUTPOSTTELE_%1", _id];
        { missionProfileNamespace setVariable [[_x] call _fnc_getTag, nil]; } forEach [
            _key + "_MARKERS",
            _key + "_COMPOSITIONS",
            _key + "_DESTROYED"
        ];
        if (_debug) then { diag_log format ["[RECONDO_PERSISTENCE] Deleted: %1", _key]; };
    } forEach RECONDO_OUTPOSTTELE_INSTANCES;
};

// Custom Site Spawn
if (!isNil "RECONDO_CSS_INSTANCES") then {
    {
        private _siteName = _x getOrDefault ["siteName", ""];
        private _key = format ["CSS_%1", _siteName];
        { missionProfileNamespace setVariable [[_x] call _fnc_getTag, nil]; } forEach [
            _key + "_MARKERS",
            _key + "_COMPMAP"
        ];
        if (_debug) then { diag_log format ["[RECONDO_PERSISTENCE] Deleted: %1", _key]; };
    } forEach RECONDO_CSS_INSTANCES;
};

// POO Site Hunt
if (!isNil "RECONDO_POO_INSTANCES") then {
    {
        private _name = _x get "objectiveName";
        { missionProfileNamespace setVariable [[_x] call _fnc_getTag, nil]; } forEach [
            format ["POO_%1_ACTIVE", _name],
            format ["POO_%1_TARGETS", _name],
            format ["POO_%1_DESTROYED", _name]
        ];
        if (_debug) then { diag_log format ["[RECONDO_PERSISTENCE] Deleted: POO_%1", _name]; };
    } forEach RECONDO_POO_INSTANCES;
};

// Destroy Powergrid
if (!isNil "RECONDO_POWERGRID_INSTANCES") then {
    {
        private _id = _x get "instanceId";
        missionProfileNamespace setVariable [[format ["POWERGRID_%1_DESTROYED", _id]] call _fnc_getTag, nil];
        if (_debug) then { diag_log format ["[RECONDO_PERSISTENCE] Deleted: POWERGRID_%1", _id]; };
    } forEach RECONDO_POWERGRID_INSTANCES;
};

// ========================================
// FINALIZE
// ========================================

saveMissionProfileNamespace;

RECONDO_PERSISTENCE_PLAYER_STATS = createHashMap;
publicVariable "RECONDO_PERSISTENCE_PLAYER_STATS";

diag_log format ["[RECONDO_PERSISTENCE] All save data deleted for campaign: %1", _campaignID];

format ["Save data deleted for campaign: %1", _campaignID] remoteExec ["systemChat", 0, false];

true
