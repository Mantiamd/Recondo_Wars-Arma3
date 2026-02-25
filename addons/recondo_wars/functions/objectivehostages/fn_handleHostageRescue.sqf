/*
    Recondo_fnc_handleHostageRescue
    Handles the rescue of an individual hostage
    
    Description:
        Called on server when a player turns over a hostage.
        Marks as rescued, saves to persistence, notifies players,
        and integrates with Intel system if all hostages at a
        location are rescued.
    
    Parameters:
        _instanceId - STRING - Hostage module instance ID
        _hostageId - STRING - Unique hostage ID
        _hostage - OBJECT - The hostage unit being rescued
    
    Returns:
        BOOL - True if rescue was successful
*/

if (!isServer) exitWith { false };

params [
    ["_instanceId", "", [""]],
    ["_hostageId", "", [""]],
    ["_hostage", objNull, [objNull]]
];

// Validate parameters
if (_instanceId == "" || _hostageId == "") exitWith {
    diag_log "[RECONDO_HOSTAGE] ERROR: Empty instance ID or hostage ID in handleHostageRescue";
    false
};

// Check if already rescued
if (_hostageId in RECONDO_HOSTAGE_RESCUED) exitWith {
    diag_log format ["[RECONDO_HOSTAGE] Hostage %1 already marked as rescued", _hostageId];
    false
};

// Verify this is a hostage
if (!isNull _hostage && {!(_hostage getVariable ["RECONDO_HOSTAGE_isHostage", false])}) exitWith {
    diag_log "[RECONDO_HOSTAGE] ERROR: Unit passed to handleHostageRescue is not a hostage";
    false
};

diag_log format ["[RECONDO_HOSTAGE] Processing hostage rescue for %1", _hostageId];

// Find settings for this instance
private _settings = nil;
private _objectiveName = "Hostage Rescue";
private _hostageNames = [];
private _hostageCount = 0;

{
    if ((_x get "instanceId") == _instanceId) exitWith {
        _settings = _x;
        _objectiveName = _x get "objectiveName";
        _hostageNames = _x get "hostageNames";
        _hostageCount = _x get "hostageCount";
    };
} forEach RECONDO_HOSTAGE_INSTANCES;

// Get hostage name
private _hostageName = if (!isNull _hostage) then {
    name _hostage
} else {
    private _hostageIndex = _hostage getVariable ["RECONDO_HOSTAGE_hostageIndex", 0];
    _hostageNames select (_hostageIndex min (count _hostageNames - 1))
};

// Mark as rescued
RECONDO_HOSTAGE_RESCUED pushBack _hostageId;
publicVariable "RECONDO_HOSTAGE_RESCUED";

// Save to persistence
if (!isNil "_settings") then {
    private _persistenceKey = format ["HOSTAGE_%1", _objectiveName];
    [_persistenceKey + "_RESCUED", RECONDO_HOSTAGE_RESCUED] call Recondo_fnc_setSaveData;
    saveMissionProfileNamespace;
    
    private _debugLogging = _settings getOrDefault ["debugLogging", false];
    if (_debugLogging) then {
        diag_log format ["[RECONDO_HOSTAGE] Saved rescue state for '%1'", _hostageName];
    };
};

// Count rescued hostages for this instance
private _rescuedCount = 0;
for "_i" from 0 to (_hostageCount - 1) do {
    private _checkId = format ["%1_hostage_%2", _instanceId, _i];
    if (_checkId in RECONDO_HOSTAGE_RESCUED) then {
        _rescuedCount = _rescuedCount + 1;
    };
};

// Check if all hostages rescued
private _allRescued = _rescuedCount >= _hostageCount;

// Notify all players
private _rescueMsg = if (_allRescued) then {
    format ["%1 rescued! All hostages have been saved! (%2/%3)", _hostageName, _rescuedCount, _hostageCount]
} else {
    format ["%1 has been rescued! (%2/%3 hostages saved)", _hostageName, _rescuedCount, _hostageCount]
};
[_rescueMsg] remoteExec ["systemChat", 0];

// Show visual notification
private _titleText = if (_allRescued) then {
    format [
        "<t size='1.5' color='#00ff00'>All Hostages Rescued!</t><br/><t size='1'>%1 hostages have been saved.</t>",
        _hostageCount
    ]
} else {
    format [
        "<t size='1.5' color='#00ff00'>%1 Rescued!</t><br/><t size='1'>%2 of %3 hostages saved.</t>",
        _hostageName, _rescuedCount, _hostageCount
    ]
};
[_titleText, "PLAIN", 3, true, true] remoteExec ["titleText", 0];

// If all hostages at a location are rescued, complete the Intel target for that location
if (!isNil "_settings") then {
    private _locationData = RECONDO_HOSTAGE_LOCATIONS getOrDefault [_instanceId, [[], [], createHashMap]];
    _locationData params ["_hostageMarkers", "_decoyMarkers", "_hostageAssignments"];
    
    // Check each location to see if all hostages there are rescued
    {
        private _marker = _x;
        private _hostagesAtMarker = _hostageAssignments getOrDefault [_marker, []];
        
        private _allAtLocationRescued = true;
        {
            _x params ["_hostageIndex", "_name"];
            private _checkId = format ["%1_hostage_%2", _instanceId, _hostageIndex];
            if !(_checkId in RECONDO_HOSTAGE_RESCUED) exitWith {
                _allAtLocationRescued = false;
            };
        } forEach _hostagesAtMarker;
        
        if (_allAtLocationRescued && count _hostagesAtMarker > 0) then {
            private _targetId = format ["%1_%2", _instanceId, _marker];
            [_targetId] call Recondo_fnc_completeIntelTarget;
            
            private _debugLogging = _settings getOrDefault ["debugLogging", false];
            if (_debugLogging) then {
                diag_log format ["[RECONDO_HOSTAGE] Completed intel target for location: %1", _marker];
            };
        };
    } forEach _hostageMarkers;
};

// Mark hostage unit as rescued (leave in place)
if (!isNull _hostage) then {
    _hostage setVariable ["RECONDO_HOSTAGE_rescued", true, true];
    
    // Release from captive state
    _hostage setVariable ["ACE_captive", false, true];
    _hostage setVariable ["ace_captives_isHandcuffed", false, true];
    
    diag_log format ["[RECONDO_HOSTAGE] Hostage unit marked as rescued"];
};

// Award Recon Points to the rescuing player's group
if (!isNil "RECONDO_RP_SETTINGS") then {
    private _rescuingPlayer = _hostage getVariable ["RECONDO_HOSTAGE_rescuedBy", objNull];
    if (!isNull _rescuingPlayer && isPlayer _rescuingPlayer) then {
        private _rescuingGroup = group _rescuingPlayer;
        ["hostage", _rescuingGroup, 0, format ["Hostage %1 rescued!", _hostageName]] call Recondo_fnc_rpAwardPoints;
    };
};

diag_log format ["[RECONDO_HOSTAGE] Hostage '%1' rescue complete (%2/%3)", _hostageName, _rescuedCount, _hostageCount];

true
