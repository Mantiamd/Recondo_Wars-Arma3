/*
    Recondo_fnc_processTurnIn
    Server-side processing of intel turn-in
    
    Description:
        Called on server when a player turns in intel.
        Removes the intel item from player inventory,
        reveals a random target, and sends notification via intel card.
        Supports custom message templates, photos, and source-specific messages.
    
    Parameters:
        _player - OBJECT - The player turning in intel
        _source - STRING - Intel source type: "document" or "pow" (default: "document")
    
    Returns:
        Nothing
    
    Example:
        [player, "document"] remoteExec ["Recondo_fnc_processTurnIn", 2];
        [player, "pow"] remoteExec ["Recondo_fnc_processTurnIn", 2];
*/

if (!isServer) exitWith {};

params [
    ["_player", objNull, [objNull]],
    ["_source", "document", [""]]
];

if (isNull _player) exitWith {
    diag_log "[RECONDO_INTEL] ERROR: processTurnIn - Null player";
};

private _debugLogging = if (isNil "RECONDO_INTEL_SETTINGS") then { false } else { RECONDO_INTEL_SETTINGS getOrDefault ["debugLogging", false] };

// Normalize source type
_source = toLower _source;
if !(_source in ["document", "pow"]) then {
    _source = "document";
};

// Find and remove one intel item from player (only for document source)
// Supports both CfgWeapons items and CfgMagazines
if (_source == "document") then {
    private _items = items _player;
    private _mags = magazines _player;
    private _intelItems = if (isNil "RECONDO_INTEL_ITEMS") then { [] } else { RECONDO_INTEL_ITEMS };
    private _removedItem = "";
    private _wasMagazine = false;
    
    if (count _intelItems > 0) then {
        // Check items first (CfgWeapons)
        {
            if (_x in _intelItems) exitWith {
                _removedItem = _x;
                _player removeItem _x;
            };
        } forEach _items;
        
        // Check magazines if not found in items (CfgMagazines)
        if (_removedItem == "") then {
            {
                if (_x in _intelItems) exitWith {
                    _removedItem = _x;
                    _wasMagazine = true;
                    _player removeMagazine _x;
                };
            } forEach _mags;
        };
    } else {
        // Fallback: check for "intel" in classname
        {
            if ((toLower _x) find "intel" != -1) exitWith {
                _removedItem = _x;
                _player removeItem _x;
            };
        } forEach _items;
        
        if (_removedItem == "") then {
            {
                if ((toLower _x) find "intel" != -1) exitWith {
                    _removedItem = _x;
                    _wasMagazine = true;
                    _player removeMagazine _x;
                };
            } forEach _mags;
        };
    };
    
    if (_removedItem == "") exitWith {
        private _noIntelText = if (isNil "RECONDO_INTEL_SETTINGS") then { 
            "You have no intel to turn in." 
        } else { 
            RECONDO_INTEL_SETTINGS getOrDefault ["turnInNoIntelText", "You have no intel to turn in."] 
        };
        
        ["NO INTEL", _noIntelText, 2, 5, "", 3] remoteExec ["Recondo_fnc_showIntelCard", _player];
        
        if (_debugLogging) then {
            diag_log format ["[RECONDO_INTEL] processTurnIn - No intel item found on player %1", name _player];
        };
    };
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_INTEL] processTurnIn - Player %1 turned in intel %2: %3", 
            name _player, if (_wasMagazine) then {"magazine"} else {"item"}, _removedItem];
    };
};

// Attempt to reveal a target
private _result = [_player] call Recondo_fnc_revealIntel;
_result params ["_success", "_targetData"];

if (!_success) then {
    private _noTargetsText = if (isNil "RECONDO_INTEL_SETTINGS") then { 
        "No actionable intelligence at this time." 
    } else { 
        RECONDO_INTEL_SETTINGS getOrDefault ["turnInNoTargetsText", "No actionable intelligence at this time."] 
    };
    
    ["NO TARGETS REMAIN", _noTargetsText, 1, 60, "", 0] remoteExec ["Recondo_fnc_showIntelCard", _player];
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_INTEL] processTurnIn - No targets available for player %1", name _player];
    };
    
    // Still award points for turning in intel even if no targets remain
    if (!isNil "RECONDO_RP_SETTINGS" && _source == "document") then {
        ["intel", _player] call Recondo_fnc_rpAwardPoints;
    };
} else {
    // Successfully revealed a target
    _targetData params ["_type", "_id", "_pos", "_data", "_weight"];
    
    // Convert position to 4-digit grid
    private _grid = [_pos] call Recondo_fnc_posToGrid;
    
    // Extract data from target
    private _name = if (_data isEqualType createHashMap) then { _data getOrDefault ["name", "Unknown"] } else { "Unknown" };
    private _photoPath = "";
    private _background = "";
    private _revealMessages = [];
    private _confirmMessage = "";
    
    // Get type-specific data
    if (_data isEqualType createHashMap) then {
        switch (toLower _type) do {
            case "hvt": {
                _name = _data getOrDefault ["hvtName", _name];
                _photoPath = _data getOrDefault ["hvtPhoto", ""];
                _background = _data getOrDefault ["hvtBackground", ""];
            };
            case "hostage": {
                // For hostages, use first hostage's info for the intel card
                private _hostageNames = _data getOrDefault ["hostageNames", []];
                private _hostagePhotos = _data getOrDefault ["hostagePhotos", []];
                private _hostageBackgrounds = _data getOrDefault ["hostageBackgrounds", []];
                
                if (count _hostageNames > 0) then {
                    _name = _hostageNames select 0;
                    if (count _hostageNames > 1) then {
                        _name = format ["%1 and %2 others", _name, (count _hostageNames) - 1];
                    };
                };
                if (count _hostagePhotos > 0) then {
                    _photoPath = _hostagePhotos select 0;
                };
                if (count _hostageBackgrounds > 0) then {
                    _background = _hostageBackgrounds select 0;
                };
            };
        };
        
        // Get reveal messages based on source
        if (_source == "pow") then {
            _revealMessages = _data getOrDefault ["revealMessagesPOW", []];
        } else {
            _revealMessages = _data getOrDefault ["revealMessagesDoc", []];
        };
        
        _confirmMessage = _data getOrDefault ["confirmMessage", ""];
    };
    
    // Build the message
    private _message = "";
    
    if (count _revealMessages > 0) then {
        // Use custom message template
        _message = selectRandom _revealMessages;
        
        // Replace placeholders
        _message = _message regexReplace ["%GRID%", _grid];
        _message = _message regexReplace ["%NAME%", _name];
        _message = _message regexReplace ["%OBJECTIVE%", _data getOrDefault ["name", "objective"]];
    } else {
        // Use default message based on type
        private _typeText = switch (toLower _type) do {
            case "hvt": { format ["Intel indicates %1 was spotted near grid %2.", _name, _grid] };
            case "hostage": { format ["Intel indicates hostages may be held near grid %1.", _grid] };
            case "cache": { format ["Supply cache identified near grid %1.", _grid] };
            case "objective": { format ["%1 reported near grid %2.", _name, _grid] };
            default { format ["Target position acquired: grid %1.", _grid] };
        };
        _message = _typeText;
    };
    
    // Add background info if available
    if (_background != "") then {
        _message = format ["%1<br/><br/><t color='#AAAAAA'>%2</t>", _message, _background];
    };
    
    // Determine card title based on source
    private _cardTitle = if (_source == "pow") then {
        "INTERROGATION INTEL"
    } else {
        "INTEL RECEIVED"
    };
    
    // Send notification to player's group with photo
    private _group = group _player;
    {
        if (isPlayer _x) then {
            [_cardTitle, _message, 0, 30, "", 2, _photoPath] remoteExec ["Recondo_fnc_showIntelCard", _x];
        };
    } forEach (units _group);
    
    // ========================================
    // ADD TO INTEL LOG (Global History)
    // ========================================
    
    // Build clean log message (without HTML formatting)
    private _logMessage = switch (toLower _type) do {
        case "hvt": { format ["Intel indicates %1 was spotted near grid %2.", _name, _grid] };
        case "hostage": { format ["Intel indicates hostages may be held near grid %1.", _grid] };
        case "cache": { format ["Supply cache identified near grid %1.", _grid] };
        case "objective": { format ["%1 reported near grid %2.", _name, _grid] };
        default { format ["Target position acquired: grid %1.", _grid] };
    };
    
    // Get real-world timestamp
    private _timeArray = systemTimeUTC;
    private _timestamp = format ["%1-%2-%3 %4:%5",
        _timeArray select 0,
        ([_timeArray select 1] call {
            params ["_n"];
            if (_n < 10) then { format ["0%1", _n] } else { str _n }
        }),
        ([_timeArray select 2] call {
            params ["_n"];
            if (_n < 10) then { format ["0%1", _n] } else { str _n }
        }),
        ([_timeArray select 3] call {
            params ["_n"];
            if (_n < 10) then { format ["0%1", _n] } else { str _n }
        }),
        ([_timeArray select 4] call {
            params ["_n"];
            if (_n < 10) then { format ["0%1", _n] } else { str _n }
        })
    ];
    
    // Create log entry
    private _logEntry = createHashMapFromArray [
        ["message", _logMessage],
        ["timestamp", _timestamp],
        ["targetType", _type],
        ["targetName", _name],
        ["grid", _grid],
        ["source", _source]
    ];
    
    // Add to global log (newest first)
    RECONDO_INTEL_LOG insert [0, [_logEntry]];
    publicVariable "RECONDO_INTEL_LOG";
    
    // Save to persistence
    private _enablePersistence = if (isNil "RECONDO_INTEL_SETTINGS") then { false } else { RECONDO_INTEL_SETTINGS getOrDefault ["enablePersistence", true] };
    if (_enablePersistence) then {
        ["INTEL_LOG", RECONDO_INTEL_LOG] call Recondo_fnc_setSaveData;
    };
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_INTEL] processTurnIn - Revealed %1 target %2 at grid %3 to group %4 (source: %5)", 
            _type, _id, _grid, groupId _group, _source];
        diag_log format ["[RECONDO_INTEL] Added to intel log: %1", _logMessage];
    };
    
    // Award Recon Points for successful intel turn-in
    if (!isNil "RECONDO_RP_SETTINGS" && _source == "document") then {
        ["intel", _player] call Recondo_fnc_rpAwardPoints;
    };
};
