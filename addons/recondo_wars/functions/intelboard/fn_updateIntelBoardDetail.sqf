/*
    Recondo_fnc_updateIntelBoardDetail
    Updates the detail panel when a target is selected
    
    Description:
        Called when the user selects an item in the sidebar listbox.
        Updates the right panel with the selected target's details
        including photo, name, status, location, and background.
        Works with dynamically created controls.
    
    Parameters:
        _ctrl - CONTROL - The listbox control
        _index - NUMBER - Selected index
    
    Returns:
        Nothing
    
    Example:
        [_listbox, 3] call Recondo_fnc_updateIntelBoardDetail;
*/

params [["_listbox", controlNull, [controlNull]], ["_selectedIndex", -1, [0]]];

if (isNull _listbox || _selectedIndex < 0) exitWith {};

disableSerialization;

// Get stored data
private _data = _listbox lbData _selectedIndex;

// Get controls from uiNamespace
private _photoFrame = uiNamespace getVariable ["RECONDO_INTELBOARD_PHOTO_FRAME", controlNull];
private _photoCtrl = uiNamespace getVariable ["RECONDO_INTELBOARD_PHOTO", controlNull];
private _nameCtrl = uiNamespace getVariable ["RECONDO_INTELBOARD_NAME", controlNull];
private _statusCtrl = uiNamespace getVariable ["RECONDO_INTELBOARD_STATUS", controlNull];
private _locationCtrl = uiNamespace getVariable ["RECONDO_INTELBOARD_LOCATION", controlNull];
private _backgroundCtrl = uiNamespace getVariable ["RECONDO_INTELBOARD_BACKGROUND", controlNull];

if (isNull _nameCtrl) exitWith {};

// Skip if this is a header
if (_data == "HEADER" || _data == "") exitWith {
    _nameCtrl ctrlSetStructuredText parseText "<t color='#FFFFFF' size='1.4' font='PuristaBold'>Select a target</t>";
    _statusCtrl ctrlSetStructuredText parseText "";
    _locationCtrl ctrlSetStructuredText parseText "";
    _backgroundCtrl ctrlSetStructuredText parseText "<t color='#888888'>Select a target from the sidebar to view detailed information.</t>";
    _photoFrame ctrlShow false;
    _photoCtrl ctrlShow false;
};

// Get target data from stored list
private _targetList = uiNamespace getVariable ["RECONDO_INTELBOARD_TARGETLIST", []];
private _targetIndex = parseNumber _data;

if (_targetIndex < 0 || _targetIndex >= count _targetList) exitWith {};

private _target = _targetList select _targetIndex;
if (isNil "_target") exitWith {};

// Extract target data
private _name = _target getOrDefault ["displayName", "Unknown"];
private _photo = _target getOrDefault ["photo", ""];
private _background = _target getOrDefault ["background", ""];
private _status = _target getOrDefault ["status", ""];
private _statusColor = _target getOrDefault ["statusColor", [1, 1, 1, 1]];
private _location = _target getOrDefault ["location", ""];
private _type = _target getOrDefault ["type", ""];
private _objectiveName = _target getOrDefault ["objectiveName", ""];

// ========================================
// HANDLE INTEL LOG ENTRIES
// ========================================

if (_type == "log") exitWith {
    private _logMessage = _target getOrDefault ["message", ""];
    private _timestamp = _target getOrDefault ["timestamp", ""];
    private _targetType = _target getOrDefault ["targetType", ""];
    private _targetName = _target getOrDefault ["targetName", ""];
    private _grid = _target getOrDefault ["grid", ""];
    private _source = _target getOrDefault ["source", ""];
    
    // Hide photo for log entries
    _photoFrame ctrlShow false;
    _photoCtrl ctrlShow false;
    _photoFrame ctrlCommit 0;
    _photoCtrl ctrlCommit 0;
    
    // Set header
    _nameCtrl ctrlSetStructuredText parseText "<t color='#5599DD' size='1.4' font='PuristaBold'>INTEL LOG ENTRY</t>";
    
    // Set timestamp as status
    _statusCtrl ctrlSetStructuredText parseText format ["<t color='#AAAAAA' size='1.0'>Received: %1 UTC</t>", _timestamp];
    
    // Set location if available
    if (_grid != "") then {
        _locationCtrl ctrlSetStructuredText parseText format ["<t color='#6699FF' size='0.95'>Grid Reference: %1</t>", _grid];
    } else {
        _locationCtrl ctrlSetStructuredText parseText "";
    };
    
    // Build log detail text
    private _detailText = "<t color='#FFFFFF' size='1.1'>Intel Report:</t><br/><br/>";
    
    // Check for sensor full log data
    private _fullLog = _target getOrDefault ["fullLog", ""];
    if (_fullLog != "" && _source == "sensor") then {
        _detailText = _detailText + format ["<t color='#CCCCCC'>%1</t>", _fullLog];
    } else {
        _detailText = _detailText + format ["<t color='#CCCCCC'>%1</t>", _logMessage];
    };
    
    // Add metadata
    if (_targetType != "" || _targetName != "" || _source != "") then {
        _detailText = _detailText + "<br/><br/><t color='#666666'>━━━━━━━━━━━━━━━━━━━━</t><br/><br/>";
        
        if (_targetType != "") then {
            private _typeDisplay = switch (toLower _targetType) do {
                case "hvt": { "High Value Target" };
                case "hostage": { "Hostage" };
                case "cache": { "Supply Cache" };
                case "objective": { "Objective" };
                case "sensor": { "Sensor Data" };
                default { _targetType };
            };
            _detailText = _detailText + format ["<t color='#888888'>Type: %1</t><br/>", _typeDisplay];
        };
        
        if (_targetName != "" && toLower _targetType in ["hvt", "hostage"]) then {
            _detailText = _detailText + format ["<t color='#888888'>Subject: %1</t><br/>", _targetName];
        };
        
        if (_source != "") then {
            private _sourceDisplay = switch (toLower _source) do {
                case "document": { "Document Intel" };
                case "pow": { "Interrogation" };
                case "sensor": { "Sensor Network" };
                default { _source };
            };
            _detailText = _detailText + format ["<t color='#888888'>Source: %1</t>", _sourceDisplay];
        };
    };
    
    _backgroundCtrl ctrlSetStructuredText parseText _detailText;
    
    // Debug logging
    private _settings = if (isNil "RECONDO_INTELBOARD_SETTINGS") then { createHashMap } else { RECONDO_INTELBOARD_SETTINGS };
    private _debugLogging = _settings getOrDefault ["debugLogging", false];
    if (_debugLogging) then {
        diag_log format ["[RECONDO_INTELBOARD] Selected log entry: %1", _timestamp];
    };
};

// Convert status color array to hex
private _statusColorHex = format ["#%1%2%3",
    ([round ((_statusColor select 0) * 255)] call BIS_fnc_decimalToHex) select [0, 2],
    ([round ((_statusColor select 1) * 255)] call BIS_fnc_decimalToHex) select [0, 2],
    ([round ((_statusColor select 2) * 255)] call BIS_fnc_decimalToHex) select [0, 2]
];

// Set target name
_nameCtrl ctrlSetStructuredText parseText format ["<t color='#FFFFFF' size='1.4' font='PuristaBold'>%1</t>", toUpper _name];

// Set status
_statusCtrl ctrlSetStructuredText parseText format ["<t color='%1' size='1.1'>Status: %2</t>", _statusColorHex, _status];

// Set location
if (_location != "") then {
    _locationCtrl ctrlSetStructuredText parseText format ["<t color='#6699FF' size='0.95'>Last Known Location: Grid %1</t>", _location];
} else {
    _locationCtrl ctrlSetStructuredText parseText "<t color='#888888' size='0.95'>Location: Unknown</t>";
};

// Set photo using RscPicture (scales image to fit control)
if (_photo != "" && _type in ["hvt", "hostage"]) then {
    _photoCtrl ctrlSetText _photo;
    _photoFrame ctrlShow true;
    _photoCtrl ctrlShow true;
    _photoFrame ctrlCommit 0;
    _photoCtrl ctrlCommit 0;
} else {
    _photoCtrl ctrlSetText "";
    _photoFrame ctrlShow false;
    _photoCtrl ctrlShow false;
    _photoFrame ctrlCommit 0;
    _photoCtrl ctrlCommit 0;
};

// Build background text
private _backgroundText = "";

// Add type-specific header
switch (_type) do {
    case "hvt": {
        _backgroundText = "<t color='#FFCC00' size='1.1'>HIGH VALUE TARGET DOSSIER</t><br/><br/>";
    };
    case "hostage": {
        _backgroundText = "<t color='#FF8888' size='1.1'>HOSTAGE FILE</t><br/><br/>";
    };
    case "destroy": {
        _backgroundText = "<t color='#88CCFF' size='1.1'>DESTRUCTION OBJECTIVE</t><br/><br/>";
    };
    case "hubsubs": {
        _backgroundText = "<t color='#88CCFF' size='1.1'>HUB & SUBS TARGET</t><br/><br/>";
    };
};

// Add objective name if different
if (_objectiveName != _name && _objectiveName != "") then {
    _backgroundText = _backgroundText + format ["<t color='#AAAAAA'>Objective: %1</t><br/><br/>", _objectiveName];
};

// Add background info
if (_background != "") then {
    _backgroundText = _backgroundText + format ["<t color='#CCCCCC'>%1</t>", _background];
} else {
    private _defaultText = switch (_type) do {
        case "hvt": { "No additional intelligence available on this target." };
        case "hostage": { "No additional information available on this individual." };
        case "destroy": { "Destroy all designated targets to complete this objective." };
        case "hubsubs": { "Eliminate hub and subsidiary targets to complete this objective." };
        default { "No additional information available." };
    };
    _backgroundText = _backgroundText + format ["<t color='#888888'>%1</t>", _defaultText];
};

_backgroundCtrl ctrlSetStructuredText parseText _backgroundText;

// Debug logging
private _settings = if (isNil "RECONDO_INTELBOARD_SETTINGS") then { createHashMap } else { RECONDO_INTELBOARD_SETTINGS };
private _debugLogging = _settings getOrDefault ["debugLogging", false];
if (_debugLogging) then {
    diag_log format ["[RECONDO_INTELBOARD] Selected target: %1 (%2)", _name, _type];
};
