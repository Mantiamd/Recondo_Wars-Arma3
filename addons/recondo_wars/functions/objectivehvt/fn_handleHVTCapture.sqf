/*
    Recondo_fnc_handleHVTCapture
    Handles the capture of an HVT
    
    Description:
        Called on server when a player turns over the HVT.
        Marks as captured, saves to persistence, notifies players,
        and integrates with Intel system.
    
    Parameters:
        _instanceId - STRING - HVT instance ID
        _hvt - OBJECT - The HVT unit being captured
    
    Returns:
        BOOL - True if capture was successful
*/

if (!isServer) exitWith { false };

params [
    ["_instanceId", "", [""]],
    ["_hvt", objNull, [objNull]]
];

// Validate parameters
if (_instanceId == "") exitWith {
    diag_log "[RECONDO_HVT] ERROR: Empty instance ID in handleHVTCapture";
    false
};

// Check if already captured
if (_instanceId in RECONDO_HVT_CAPTURED) exitWith {
    diag_log format ["[RECONDO_HVT] HVT %1 already marked as captured", _instanceId];
    false
};

// Verify this is the HVT
if (!isNull _hvt && {!(_hvt getVariable ["RECONDO_HVT_isHVT", false])}) exitWith {
    diag_log "[RECONDO_HVT] ERROR: Unit passed to handleHVTCapture is not the HVT";
    false
};

diag_log format ["[RECONDO_HVT] Processing HVT capture for %1", _instanceId];

// Find settings for this instance
private _settings = nil;
private _hvtName = "Unknown Target";
private _objectiveName = "High Value Target";
private _hvtMarker = "";

{
    if ((_x get "instanceId") == _instanceId) exitWith {
        _settings = _x;
        _hvtName = _x get "hvtName";
        _objectiveName = _x get "objectiveName";
    };
} forEach RECONDO_HVT_INSTANCES;

// Get HVT marker from locations
private _locData = RECONDO_HVT_LOCATIONS getOrDefault [_instanceId, ["", []]];
_hvtMarker = _locData select 0;

// Mark as captured
RECONDO_HVT_CAPTURED pushBack _instanceId;
publicVariable "RECONDO_HVT_CAPTURED";

// Clear HVT unit reference
RECONDO_HVT_UNITS set [_instanceId, objNull];
publicVariable "RECONDO_HVT_UNITS";

// Save to persistence
if (!isNil "_settings") then {
    private _markerPrefix = _settings getOrDefault ["markerPrefix", "HVT_"];
    private _persistenceKey = format ["HVT_%1_%2", _markerPrefix, _objectiveName];
    [_persistenceKey + "_CAPTURED", true] call Recondo_fnc_setSaveData;
    saveMissionProfileNamespace;
    
    private _debugLogging = _settings getOrDefault ["debugLogging", false];
    if (_debugLogging) then {
        diag_log format ["[RECONDO_HVT] Saved capture state for '%1'", _hvtName];
    };
};

// Complete Intel target
if (_hvtMarker != "") then {
    private _targetId = format ["%1_%2", _instanceId, _hvtMarker];
    [_targetId] call Recondo_fnc_completeIntelTarget;
    
    diag_log format ["[RECONDO_HVT] Completed intel target: %1", _targetId];
};

// Notify all players
private _captureMsg = format ["%1 has been captured!", _hvtName];
[_captureMsg] remoteExec ["systemChat", 0];

// Show visual notification
private _titleText = format [
    "<t size='1.5' color='#00ff00'>%1 Captured!</t><br/><t size='1'>The target has been secured.</t>",
    _hvtName
];
[_titleText, "PLAIN", 3, true, true] remoteExec ["titleText", 0];

// Mark HVT as captured (unit left as-is)
if (!isNull _hvt) then {
    _hvt setVariable ["RECONDO_HVT_captured", true, true];
    diag_log format ["[RECONDO_HVT] HVT unit marked as captured, left in place"];
};

// Award Recon Points to the capturing player's group
if (!isNil "RECONDO_RP_SETTINGS") then {
    // Find the player who captured the HVT by checking nearby players or last interaction
    private _capturingPlayer = _hvt getVariable ["RECONDO_HVT_capturedBy", objNull];
    if (!isNull _capturingPlayer && isPlayer _capturingPlayer) then {
        private _capturingGroup = group _capturingPlayer;
        ["hvt", _capturingGroup, 0, format ["HVT %1 captured!", _hvtName]] call Recondo_fnc_rpAwardPoints;
    };
};

diag_log format ["[RECONDO_HVT] HVT '%1' capture complete", _hvtName];

true
