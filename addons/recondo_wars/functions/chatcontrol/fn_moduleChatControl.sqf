/*
    Recondo_fnc_moduleChatControl
    Side Chat and Marker Control - Module initialization
    
    Description:
        Server-side module that reads chat control settings from Eden
        and broadcasts them to all clients. Clients then apply restrictions
        based on their side.
        
        Text, Markers, and Voice are all independently controlled:
        - Text: Suppressed via HandleChatMessage event handler
        - Markers: Blocked via MarkerCreated event handler
        - Voice: Disabled via enableChannel command
    
    Parameters:
        _logic - OBJECT - The module logic object
        _units - ARRAY - Synced units (not used)
        _activated - BOOL - Whether the module was activated
    
    Returns:
        Nothing
    
    Execution: Server only
*/

params [
    ["_logic", objNull, [objNull]],
    ["_units", [], [[]]],
    ["_activated", true, [true]]
];

// Only run on server
if (!isServer) exitWith {};

// Only run if activated
if (!_activated) exitWith {};

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

private _debugLogging = _logic getVariable ["debuglogging", false];
if (RECONDO_MASTER_DEBUG) then { _debugLogging = true; };

// Channel names for logging
private _channelNames = ["Global", "Side", "Command", "Group", "Vehicle", "Direct"];

// Build settings hashmap for each side
// Sides: east (OPFOR), west (BLUFOR), independent, civilian

// ========================================
// TEXT SETTINGS
// ========================================

private _textSettings = createHashMapFromArray [
    ["east", [
        _logic getVariable ["textopfor_global", false],
        _logic getVariable ["textopfor_side", false],
        _logic getVariable ["textopfor_command", false],
        _logic getVariable ["textopfor_group", false],
        _logic getVariable ["textopfor_vehicle", false],
        _logic getVariable ["textopfor_direct", false]
    ]],
    ["west", [
        _logic getVariable ["textblufor_global", false],
        _logic getVariable ["textblufor_side", false],
        _logic getVariable ["textblufor_command", false],
        _logic getVariable ["textblufor_group", false],
        _logic getVariable ["textblufor_vehicle", false],
        _logic getVariable ["textblufor_direct", false]
    ]],
    ["independent", [
        _logic getVariable ["textindependent_global", false],
        _logic getVariable ["textindependent_side", false],
        _logic getVariable ["textindependent_command", false],
        _logic getVariable ["textindependent_group", false],
        _logic getVariable ["textindependent_vehicle", false],
        _logic getVariable ["textindependent_direct", false]
    ]],
    ["civilian", [
        _logic getVariable ["textcivilian_global", false],
        _logic getVariable ["textcivilian_side", false],
        _logic getVariable ["textcivilian_command", false],
        _logic getVariable ["textcivilian_group", false],
        _logic getVariable ["textcivilian_vehicle", false],
        _logic getVariable ["textcivilian_direct", false]
    ]]
];

// ========================================
// MARKER SETTINGS
// ========================================

private _markerSettings = createHashMapFromArray [
    ["east", [
        _logic getVariable ["markersopfor_global", false],
        _logic getVariable ["markersopfor_side", false],
        _logic getVariable ["markersopfor_command", false],
        _logic getVariable ["markersopfor_group", false],
        _logic getVariable ["markersopfor_vehicle", false],
        _logic getVariable ["markersopfor_direct", false]
    ]],
    ["west", [
        _logic getVariable ["markersblufor_global", false],
        _logic getVariable ["markersblufor_side", false],
        _logic getVariable ["markersblufor_command", false],
        _logic getVariable ["markersblufor_group", false],
        _logic getVariable ["markersblufor_vehicle", false],
        _logic getVariable ["markersblufor_direct", false]
    ]],
    ["independent", [
        _logic getVariable ["markersindependent_global", false],
        _logic getVariable ["markersindependent_side", false],
        _logic getVariable ["markersindependent_command", false],
        _logic getVariable ["markersindependent_group", false],
        _logic getVariable ["markersindependent_vehicle", false],
        _logic getVariable ["markersindependent_direct", false]
    ]],
    ["civilian", [
        _logic getVariable ["markerscivilian_global", false],
        _logic getVariable ["markerscivilian_side", false],
        _logic getVariable ["markerscivilian_command", false],
        _logic getVariable ["markerscivilian_group", false],
        _logic getVariable ["markerscivilian_vehicle", false],
        _logic getVariable ["markerscivilian_direct", false]
    ]]
];

// ========================================
// VOICE CHAT SETTINGS
// ========================================

private _voiceSettings = createHashMapFromArray [
    ["east", [
        _logic getVariable ["voiceopfor_global", false],
        _logic getVariable ["voiceopfor_side", false],
        _logic getVariable ["voiceopfor_command", false],
        _logic getVariable ["voiceopfor_group", false],
        _logic getVariable ["voiceopfor_vehicle", false],
        _logic getVariable ["voiceopfor_direct", false]
    ]],
    ["west", [
        _logic getVariable ["voiceblufor_global", false],
        _logic getVariable ["voiceblufor_side", false],
        _logic getVariable ["voiceblufor_command", false],
        _logic getVariable ["voiceblufor_group", false],
        _logic getVariable ["voiceblufor_vehicle", false],
        _logic getVariable ["voiceblufor_direct", false]
    ]],
    ["independent", [
        _logic getVariable ["voiceindependent_global", false],
        _logic getVariable ["voiceindependent_side", false],
        _logic getVariable ["voiceindependent_command", false],
        _logic getVariable ["voiceindependent_group", false],
        _logic getVariable ["voiceindependent_vehicle", false],
        _logic getVariable ["voiceindependent_direct", false]
    ]],
    ["civilian", [
        _logic getVariable ["voicecivilian_global", false],
        _logic getVariable ["voicecivilian_side", false],
        _logic getVariable ["voicecivilian_command", false],
        _logic getVariable ["voicecivilian_group", false],
        _logic getVariable ["voicecivilian_vehicle", false],
        _logic getVariable ["voicecivilian_direct", false]
    ]]
];

// ========================================
// STORE SETTINGS GLOBALLY
// ========================================

RECONDO_CHATCONTROL_TEXT = _textSettings;
RECONDO_CHATCONTROL_MARKERS = _markerSettings;
RECONDO_CHATCONTROL_VOICE = _voiceSettings;
RECONDO_CHATCONTROL_DEBUG = _debugLogging;

publicVariable "RECONDO_CHATCONTROL_TEXT";
publicVariable "RECONDO_CHATCONTROL_MARKERS";
publicVariable "RECONDO_CHATCONTROL_VOICE";
publicVariable "RECONDO_CHATCONTROL_DEBUG";

// ========================================
// DEBUG LOGGING
// ========================================

if (_debugLogging) then {
    diag_log "[RECONDO_CHATCONTROL] === Module Settings ===";
    
    {
        private _sideName = _x;
        private _textArr = _textSettings get _sideName;
        private _markerArr = _markerSettings get _sideName;
        private _voiceArr = _voiceSettings get _sideName;
        
        diag_log format ["[RECONDO_CHATCONTROL] Side: %1", toUpper _sideName];
        
        {
            private _channelName = _channelNames select _forEachIndex;
            private _textDisabled = _textArr select _forEachIndex;
            private _markerDisabled = _markerArr select _forEachIndex;
            private _voiceDisabled = _voiceArr select _forEachIndex;
            
            if (_textDisabled || _markerDisabled || _voiceDisabled) then {
                diag_log format ["[RECONDO_CHATCONTROL]   %1: Text=%2, Markers=%3, Voice=%4", 
                    _channelName, 
                    ["Enabled", "DISABLED"] select _textDisabled,
                    ["Enabled", "DISABLED"] select _markerDisabled,
                    ["Enabled", "DISABLED"] select _voiceDisabled
                ];
            };
        } forEach _textArr;
    } forEach ["east", "west", "independent", "civilian"];
};

// ========================================
// APPLY SETTINGS TO ALL CLIENTS
// ========================================

// Apply to all current clients
[] remoteExecCall ["Recondo_fnc_applyChatSettings", 0, true];

diag_log "[RECONDO_CHATCONTROL] Module initialized - settings broadcast to clients";
