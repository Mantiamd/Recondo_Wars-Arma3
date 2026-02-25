/*
    Recondo_fnc_applyChatSettings
    Side Chat and Marker Control - Client-side settings application
    
    Description:
        Applies independent text, marker, and voice restrictions based on player's side.
        
        - Text: Suppressed via HandleChatMessage event handler (allows markers to still work)
        - Markers: Blocked via MarkerCreated event handler
        - Voice: Disabled via enableChannel command
    
    Parameters:
        None
    
    Returns:
        Nothing
    
    Execution: Client only (called via remoteExec/BIS_fnc_MP)
*/

// Only run on clients with interface
if (!hasInterface) exitWith {};

// Wait for settings to be available
[{
    !isNil "RECONDO_CHATCONTROL_TEXT" &&
    !isNil "RECONDO_CHATCONTROL_MARKERS" &&
    !isNil "RECONDO_CHATCONTROL_VOICE" &&
    !isNull player
}, {
    // Get player's side as string
    private _playerSide = switch (side player) do {
        case east: { "east" };
        case west: { "west" };
        case independent: { "independent" };
        case civilian: { "civilian" };
        default { "civilian" };
    };
    
    private _debugLogging = RECONDO_CHATCONTROL_DEBUG;
    
    // Get settings for this side
    private _textSettings = RECONDO_CHATCONTROL_TEXT getOrDefault [_playerSide, [false, false, false, false, false, false]];
    private _markerSettings = RECONDO_CHATCONTROL_MARKERS getOrDefault [_playerSide, [false, false, false, false, false, false]];
    private _voiceSettings = RECONDO_CHATCONTROL_VOICE getOrDefault [_playerSide, [false, false, false, false, false, false]];
    
    private _channelNames = ["Global", "Side", "Command", "Group", "Vehicle", "Direct"];
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_CHATCONTROL] Applying settings for side: %1", _playerSide];
    };
    
    // ========================================
    // STORE SETTINGS ON PLAYER FOR EVENT HANDLERS
    // ========================================
    
    player setVariable ["RECONDO_CHATCONTROL_TEXT_SETTINGS", _textSettings];
    player setVariable ["RECONDO_CHATCONTROL_MARKER_SETTINGS", _markerSettings];
    
    // ========================================
    // APPLY TEXT RESTRICTIONS (HandleChatMessage)
    // ========================================
    
    // Check if any text channels are restricted
    private _anyTextRestricted = false;
    {
        if (_x) exitWith { _anyTextRestricted = true };
    } forEach _textSettings;
    
    if (_anyTextRestricted) then {
        // Remove existing handler if present
        private _existingTextEH = missionNamespace getVariable ["RECONDO_CHATCONTROL_TEXT_EH", -1];
        if (_existingTextEH >= 0) then {
            removeMissionEventHandler ["HandleChatMessage", _existingTextEH];
        };
        
        // Add chat message handler to suppress text on restricted channels
        private _textEH = addMissionEventHandler ["HandleChatMessage", {
            params ["_channel", "_owner", "_from", "_text", "_person", "_name", "_strID", "_forcedDisplay", "_isPlayerMessage", "_sentenceType", "_chatMessageType"];
            
            // Get text settings for this player
            private _textSettings = player getVariable ["RECONDO_CHATCONTROL_TEXT_SETTINGS", []];
            
            if (count _textSettings == 0) exitWith { false };
            
            // Check if this channel is restricted
            if (_channel >= 0 && _channel <= 5) then {
                private _isRestricted = _textSettings select _channel;
                
                if (_isRestricted) then {
                    if (RECONDO_CHATCONTROL_DEBUG) then {
                        private _channelNames = ["Global", "Side", "Command", "Group", "Vehicle", "Direct"];
                        diag_log format ["[RECONDO_CHATCONTROL] Suppressed text on channel %1 (%2) from %3", _channel, _channelNames select _channel, _from];
                    };
                    
                    true  // Return true to suppress the message
                } else {
                    false  // Show the message
                };
            } else {
                false  // Unknown channel, show it
            };
        }];
        
        missionNamespace setVariable ["RECONDO_CHATCONTROL_TEXT_EH", _textEH];
        
        if (_debugLogging) then {
            diag_log "[RECONDO_CHATCONTROL] Text suppression event handler added";
        };
    };
    
    // ========================================
    // APPLY MARKER RESTRICTIONS (MarkerCreated)
    // ========================================
    
    // Check if any markers are restricted
    private _anyMarkersRestricted = false;
    {
        if (_x) exitWith { _anyMarkersRestricted = true };
    } forEach _markerSettings;
    
    if (_anyMarkersRestricted) then {
        // Remove existing handler if present
        private _existingMarkerEH = player getVariable ["RECONDO_CHATCONTROL_MARKER_EH", -1];
        if (_existingMarkerEH >= 0) then {
            removeMissionEventHandler ["MarkerCreated", _existingMarkerEH];
        };
        
        // Add marker creation event handler
        private _markerEH = addMissionEventHandler ["MarkerCreated", {
            params ["_marker", "_channelNumber", "_owner", "_local"];
            
            // Only check local markers (placed by this client)
            if (!_local) exitWith {};
            
            // Get marker settings for this player
            private _markerSettings = player getVariable ["RECONDO_CHATCONTROL_MARKER_SETTINGS", []];
            
            if (count _markerSettings == 0) exitWith {};
            
            // Check if this channel's markers are restricted
            if (_channelNumber >= 0 && _channelNumber <= 5) then {
                private _isRestricted = _markerSettings select _channelNumber;
                
                if (_isRestricted) then {
                    // Delete the marker
                    deleteMarkerLocal _marker;
                    
                    private _channelNames = ["Global", "Side", "Command", "Group", "Vehicle", "Direct"];
                    hint format ["Markers are not allowed on %1 channel.", _channelNames select _channelNumber];
                    
                    if (RECONDO_CHATCONTROL_DEBUG) then {
                        diag_log format ["[RECONDO_CHATCONTROL] Blocked marker on channel %1 (%2)", _channelNumber, _channelNames select _channelNumber];
                    };
                };
            };
        }];
        
        player setVariable ["RECONDO_CHATCONTROL_MARKER_EH", _markerEH];
        
        if (_debugLogging) then {
            diag_log "[RECONDO_CHATCONTROL] Marker restriction event handler added";
        };
    };
    
    // ========================================
    // APPLY VOICE RESTRICTIONS (enableChannel)
    // ========================================
    
    // enableChannel format: channelNumber enableChannel [textEnabled, voipEnabled]
    // We keep text ALWAYS enabled (true) so markers work
    // Only control voice via the second parameter
    
    for "_i" from 0 to 5 do {
        private _voiceDisabled = _voiceSettings select _i;
        
        // Text always enabled (true), voice controlled by settings
        private _voiceEnabled = !_voiceDisabled;
        
        _i enableChannel [true, _voiceEnabled];
        
        if (_debugLogging && _voiceDisabled) then {
            diag_log format ["[RECONDO_CHATCONTROL] Channel %1 (%2): Voice=DISABLED", 
                _i, 
                _channelNames select _i
            ];
        };
    };
    
    // ========================================
    // DEBUG SUMMARY
    // ========================================
    
    if (_debugLogging) then {
        for "_i" from 0 to 5 do {
            private _textDisabled = _textSettings select _i;
            private _markerDisabled = _markerSettings select _i;
            private _voiceDisabled = _voiceSettings select _i;
            
            if (_textDisabled || _markerDisabled || _voiceDisabled) then {
                diag_log format ["[RECONDO_CHATCONTROL] Channel %1 (%2): Text=%3, Markers=%4, Voice=%5", 
                    _i, 
                    _channelNames select _i,
                    ["Enabled", "DISABLED"] select _textDisabled,
                    ["Enabled", "DISABLED"] select _markerDisabled,
                    ["Enabled", "DISABLED"] select _voiceDisabled
                ];
            };
        };
        
        diag_log "[RECONDO_CHATCONTROL] Client settings applied";
    };
    
}, []] call CBA_fnc_waitUntilAndExecute;
