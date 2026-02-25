/*
    Recondo_fnc_showObjectiveStatus
    Displays objective status via Intel Card
    
    Description:
        Gathers status of all objective types from RECONDO_OBJDESTROY_INSTANCES
        and RECONDO_HUBSUBS_INSTANCES, displays them using the Intel Card system.
    
    Parameters:
        None
    
    Returns:
        Nothing
*/

if (!hasInterface) exitWith {};

// Gather objective data
private _statusLines = [];
private _hasObjectives = false;

// Process Objective Destroy instances
if (!isNil "RECONDO_OBJDESTROY_INSTANCES" && {count RECONDO_OBJDESTROY_INSTANCES > 0}) then {
    _hasObjectives = true;
    {
        private _settings = _x;
        private _objectiveName = _settings get "objectiveName";
        
        // Get count for this objective type
        private _counts = [_objectiveName] call Recondo_fnc_getObjectiveCount;
        _counts params ["_remaining", "_total"];
        
        private _statusText = if (_remaining == 0) then {
            format ["%1: COMPLETE (0/%2)", _objectiveName, _total]
        } else {
            format ["%1: %2 of %3 remaining", _objectiveName, _remaining, _total]
        };
        
        _statusLines pushBack _statusText;
    } forEach RECONDO_OBJDESTROY_INSTANCES;
};

// Process Hub & Subs instances
if (!isNil "RECONDO_HUBSUBS_INSTANCES" && {count RECONDO_HUBSUBS_INSTANCES > 0}) then {
    _hasObjectives = true;
    {
        private _settings = _x;
        private _objectiveName = _settings get "objectiveName";
        
        // Get count for this objective type
        private _counts = [_objectiveName] call Recondo_fnc_getHubObjectiveCount;
        _counts params ["_remaining", "_total"];
        
        private _statusText = if (_remaining == 0) then {
            format ["%1: COMPLETE (0/%2)", _objectiveName, _total]
        } else {
            format ["%1: %2 of %3 remaining", _objectiveName, _remaining, _total]
        };
        
        _statusLines pushBack _statusText;
    } forEach RECONDO_HUBSUBS_INSTANCES;
};

// Process HVT instances
if (!isNil "RECONDO_HVT_INSTANCES" && {count RECONDO_HVT_INSTANCES > 0}) then {
    _hasObjectives = true;
    {
        private _settings = _x;
        private _objectiveName = _settings get "objectiveName";
        private _hvtName = _settings get "hvtName";
        private _hvtBackground = _settings getOrDefault ["hvtBackground", ""];
        
        // Get count for this objective type
        private _counts = [_objectiveName] call Recondo_fnc_getHVTObjectiveCount;
        _counts params ["_remaining", "_total"];
        
        private _statusText = if (_remaining == 0) then {
            format ["<t color='#88CC88'>%1 (%2): CAPTURED</t>", _objectiveName, _hvtName]
        } else {
            format ["<t color='#FFCC00'>%1 (%2): AT LARGE</t>", _objectiveName, _hvtName]
        };
        
        // Add background info if available
        if (_hvtBackground != "") then {
            _statusText = format ["%1<br/><t color='#AAAAAA' size='0.9'>  %2</t>", _statusText, _hvtBackground];
        };
        
        _statusLines pushBack _statusText;
    } forEach RECONDO_HVT_INSTANCES;
};

// Process Hostage instances
if (!isNil "RECONDO_HOSTAGE_INSTANCES" && {count RECONDO_HOSTAGE_INSTANCES > 0}) then {
    _hasObjectives = true;
    {
        private _settings = _x;
        private _objectiveName = _settings get "objectiveName";
        private _hostageBackgrounds = _settings getOrDefault ["hostageBackgrounds", []];
        
        // Get comprehensive status using hashmap approach
        private _status = [_objectiveName] call Recondo_fnc_getHostageObjectiveStatus;
        
        private _total = _status get "total";
        private _rescued = _status get "rescued";
        private _remaining = _status get "remaining";
        private _complete = _status get "complete";
        private _hostageData = _status getOrDefault ["hostages", []];
        
        private _statusText = if (_complete) then {
            format ["<t color='#88CC88'>%1: COMPLETE (%2 rescued)</t>", _objectiveName, _total]
        } else {
            format ["<t color='#FFCC00'>%1: %2/%3 rescued</t>", _objectiveName, _rescued, _total]
        };
        
        // Build detailed hostage list
        private _hostageLines = [];
        {
            private _hostageInfo = _x;
            private _hostageName = _hostageInfo getOrDefault ["name", "Unknown"];
            private _hostageIndex = _hostageInfo getOrDefault ["index", -1];
            private _isRescued = _hostageInfo getOrDefault ["rescued", false];
            
            // Get background for this hostage
            private _background = "";
            if (_hostageIndex >= 0 && _hostageIndex < count _hostageBackgrounds) then {
                _background = _hostageBackgrounds select _hostageIndex;
            };
            
            private _hostageStatus = if (_isRescued) then {
                format ["<t color='#88CC88'>  - %1: RESCUED</t>", _hostageName]
            } else {
                format ["<t color='#FF8888'>  - %1: MISSING</t>", _hostageName]
            };
            
            // Add background if available
            if (_background != "" && !_isRescued) then {
                _hostageStatus = format ["%1<br/><t color='#AAAAAA' size='0.85'>    %2</t>", _hostageStatus, _background];
            };
            
            _hostageLines pushBack _hostageStatus;
        } forEach _hostageData;
        
        if (count _hostageLines > 0) then {
            _statusText = format ["%1<br/>%2", _statusText, _hostageLines joinString "<br/>"];
        };
        
        _statusLines pushBack _statusText;
    } forEach RECONDO_HOSTAGE_INSTANCES;
};

if (!_hasObjectives) then {
    _statusLines pushBack "No objectives configured.";
};

// Build display text
private _bodyText = _statusLines joinString "<br/>";

if (_bodyText == "") then {
    _bodyText = "No objective data available.";
};

// Show Intel Card
// Parameters: [title, body, priority, duration, sound, color]
// Colors: 0 = orange, 1 = blue, 2 = green, 3 = red
["MISSION STATUS", _bodyText, 0, 30, "", 1] call Recondo_fnc_showIntelCard;

private _debugLogging = if (isNil "RECONDO_TERMINAL_SETTINGS") then { false } else { RECONDO_TERMINAL_SETTINGS getOrDefault ["debugLogging", false] };
if (_debugLogging) then {
    diag_log format ["[RECONDO_TERMINAL] Displayed objective status: %1", _statusLines];
};
