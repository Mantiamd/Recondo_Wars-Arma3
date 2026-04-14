/*
    Recondo_fnc_showObjectiveStatus
    Displays objective status with 6-digit grid references via Intel Card
    
    Description:
        Gathers status of all objective types and displays them
        using the Intel Card system. Each site shows its grid
        reference and current status.
    
    Parameters:
        None
    
    Returns:
        Nothing
*/

if (!hasInterface) exitWith {};

// ========================================
// GRID CONVERSION HELPER
// ========================================

private _fnc_posToGrid = {
    params ["_pos"];
    if !(_pos isEqualType []) exitWith { "------" };
    if (_pos isEqualTo [0,0,0]) exitWith { "------" };
    private _grid = mapGridPosition _pos;
    private _half = floor (count _grid / 2);
    private _easting = _grid select [0, 3 min _half];
    private _northing = _grid select [_half, 3 min _half];
    format ["%1 %2", _easting, _northing]
};

private _fnc_markerGrid = {
    params ["_marker"];
    private _pos = getMarkerPos _marker;
    [_pos] call _fnc_posToGrid
};

// ========================================
// GATHER OBJECTIVE DATA
// ========================================

private _statusLines = [];
private _hasObjectives = false;

// ========================================
// OBJECTIVE DESTROY
// ========================================

if (!isNil "RECONDO_OBJDESTROY_INSTANCES" && {count RECONDO_OBJDESTROY_INSTANCES > 0}) then {
    _hasObjectives = true;
    {
        private _settings = _x;
        private _objectiveName = _settings get "objectiveName";
        private _instanceId = _settings get "instanceId";
        
        private _counts = [_objectiveName] call Recondo_fnc_getObjectiveCount;
        _counts params ["_remaining", "_total"];
        
        private _headerText = if (_remaining == 0) then {
            format ["<t color='#88CC88'>%1: COMPLETE (0/%2)</t>", _objectiveName, _total]
        } else {
            format ["<t color='#FFCC00'>%1: %2 of %3 remaining</t>", _objectiveName, _remaining, _total]
        };
        _statusLines pushBack _headerText;
        
        if (!isNil "RECONDO_OBJDESTROY_ACTIVE") then {
            {
                _x params ["_iid", "_markerId", "_compData", "_status"];
                if (_iid == _instanceId) then {
                    private _grid = [_markerId] call _fnc_markerGrid;
                    private _siteText = if (_status == "destroyed") then {
                        format ["<t color='#88CC88' size='0.9'>  [%1] DESTROYED</t>", _grid]
                    } else {
                        format ["<t color='#FF8888' size='0.9'>  [%1] ACTIVE</t>", _grid]
                    };
                    _statusLines pushBack _siteText;
                };
            } forEach RECONDO_OBJDESTROY_ACTIVE;
        };
    } forEach RECONDO_OBJDESTROY_INSTANCES;
};

// ========================================
// HUB & SUBS
// ========================================

if (!isNil "RECONDO_HUBSUBS_INSTANCES" && {count RECONDO_HUBSUBS_INSTANCES > 0}) then {
    _hasObjectives = true;
    {
        private _settings = _x;
        private _objectiveName = _settings get "objectiveName";
        private _instanceId = _settings get "instanceId";
        
        private _counts = [_objectiveName] call Recondo_fnc_getHubObjectiveCount;
        _counts params ["_remaining", "_total"];
        
        private _headerText = if (_remaining == 0) then {
            format ["<t color='#88CC88'>%1: COMPLETE (0/%2)</t>", _objectiveName, _total]
        } else {
            format ["<t color='#FFCC00'>%1: %2 of %3 remaining</t>", _objectiveName, _remaining, _total]
        };
        _statusLines pushBack _headerText;
        
        if (!isNil "RECONDO_HUBSUBS_ACTIVE") then {
            {
                _x params ["_iid", "_hubMarker", "_compData", "_subMarkers", "_isDestroyed"];
                if (_iid == _instanceId) then {
                    private _hubGrid = [_hubMarker] call _fnc_markerGrid;
                    private _hubText = if (_isDestroyed) then {
                        format ["<t color='#88CC88' size='0.9'>  Hub [%1] DESTROYED</t>", _hubGrid]
                    } else {
                        format ["<t color='#FF8888' size='0.9'>  Hub [%1] ACTIVE</t>", _hubGrid]
                    };
                    _statusLines pushBack _hubText;
                    
                    {
                        private _subGrid = [_x] call _fnc_markerGrid;
                        _statusLines pushBack format ["<t color='#AAAAAA' size='0.85'>    Sub [%1]</t>", _subGrid];
                    } forEach _subMarkers;
                };
            } forEach RECONDO_HUBSUBS_ACTIVE;
        };
    } forEach RECONDO_HUBSUBS_INSTANCES;
};

// ========================================
// HVT (all locations shown, no real/decoy distinction)
// ========================================

if (!isNil "RECONDO_HVT_INSTANCES" && {count RECONDO_HVT_INSTANCES > 0}) then {
    _hasObjectives = true;
    {
        private _settings = _x;
        private _objectiveName = _settings get "objectiveName";
        private _instanceId = _settings get "instanceId";
        private _hvtName = _settings get "hvtName";
        private _hvtBackground = _settings getOrDefault ["hvtBackground", ""];
        
        private _counts = [_objectiveName] call Recondo_fnc_getHVTObjectiveCount;
        _counts params ["_remaining", "_total"];
        
        private _isCaptured = false;
        if (!isNil "RECONDO_HVT_CAPTURED") then {
            _isCaptured = _instanceId in RECONDO_HVT_CAPTURED;
        };
        
        private _headerText = if (_isCaptured) then {
            format ["<t color='#88CC88'>%1 (%2): CAPTURED</t>", _objectiveName, _hvtName]
        } else {
            format ["<t color='#FFCC00'>%1 (%2): AT LARGE</t>", _objectiveName, _hvtName]
        };
        _statusLines pushBack _headerText;
        
        if (_hvtBackground != "") then {
            _statusLines pushBack format ["<t color='#AAAAAA' size='0.9'>  %1</t>", _hvtBackground];
        };
        
        if (!isNil "RECONDO_HVT_LOCATIONS") then {
            private _locData = RECONDO_HVT_LOCATIONS getOrDefault [_instanceId, []];
            if (count _locData >= 2) then {
                private _hvtMarker = _locData select 0;
                private _decoyMarkers = _locData select 1;
                
                // Combine all markers without revealing which is real
                private _allMarkers = [_hvtMarker] + _decoyMarkers;
                _allMarkers = _allMarkers call BIS_fnc_arrayShuffle;
                
                _statusLines pushBack "<t size='0.9'>  Possible Locations:</t>";
                {
                    private _grid = [_x] call _fnc_markerGrid;
                    _statusLines pushBack format ["<t color='#AAAAAA' size='0.85'>    [%1]</t>", _grid];
                } forEach _allMarkers;
            };
        };
    } forEach RECONDO_HVT_INSTANCES;
};

// ========================================
// HOSTAGES
// ========================================

if (!isNil "RECONDO_HOSTAGE_INSTANCES" && {count RECONDO_HOSTAGE_INSTANCES > 0}) then {
    _hasObjectives = true;
    {
        private _settings = _x;
        private _objectiveName = _settings get "objectiveName";
        private _instanceId = _settings get "instanceId";
        private _hostageBackgrounds = _settings getOrDefault ["hostageBackgrounds", []];
        
        private _status = [_objectiveName] call Recondo_fnc_getHostageObjectiveStatus;
        
        private _total = _status get "total";
        private _rescued = _status get "rescued";
        private _complete = _status get "complete";
        private _hostageData = _status getOrDefault ["hostages", []];
        
        private _headerText = if (_complete) then {
            format ["<t color='#88CC88'>%1: COMPLETE (%2 rescued)</t>", _objectiveName, _total]
        } else {
            format ["<t color='#FFCC00'>%1: %2/%3 rescued</t>", _objectiveName, _rescued, _total]
        };
        _statusLines pushBack _headerText;
        
        // Hostage detail lines
        {
            private _hostageInfo = _x;
            private _hostageName = _hostageInfo getOrDefault ["name", "Unknown"];
            private _hostageIndex = _hostageInfo getOrDefault ["index", -1];
            private _isRescued = _hostageInfo getOrDefault ["rescued", false];
            
            private _background = "";
            if (_hostageIndex >= 0 && _hostageIndex < count _hostageBackgrounds) then {
                _background = _hostageBackgrounds select _hostageIndex;
            };
            
            private _hostageStatus = if (_isRescued) then {
                format ["<t color='#88CC88' size='0.9'>  - %1: RESCUED</t>", _hostageName]
            } else {
                format ["<t color='#FF8888' size='0.9'>  - %1: MISSING</t>", _hostageName]
            };
            
            if (_background != "" && !_isRescued) then {
                _hostageStatus = format ["%1<br/><t color='#AAAAAA' size='0.85'>    %2</t>", _hostageStatus, _background];
            };
            
            _statusLines pushBack _hostageStatus;
        } forEach _hostageData;
        
        // Location grids (all markers combined, no distinction)
        if (!isNil "RECONDO_HOSTAGE_LOCATIONS") then {
            private _locData = RECONDO_HOSTAGE_LOCATIONS getOrDefault [_instanceId, []];
            if (count _locData >= 2) then {
                private _hostageMarkers = _locData select 0;
                private _decoyMarkers = _locData select 1;
                
                private _allMarkers = _hostageMarkers + _decoyMarkers;
                _allMarkers = _allMarkers call BIS_fnc_arrayShuffle;
                
                _statusLines pushBack "<t size='0.9'>  Known Locations:</t>";
                {
                    private _grid = [_x] call _fnc_markerGrid;
                    _statusLines pushBack format ["<t color='#AAAAAA' size='0.85'>    [%1]</t>", _grid];
                } forEach _allMarkers;
            };
        };
    } forEach RECONDO_HOSTAGE_INSTANCES;
};

// ========================================
// POO SITE HUNT
// ========================================

if (!isNil "RECONDO_POO_INSTANCES" && {count RECONDO_POO_INSTANCES > 0}) then {
    _hasObjectives = true;
    {
        private _settings = _x;
        private _objectiveName = _settings get "objectiveName";
        private _instanceId = _settings get "instanceId";
        
        private _activeCount = 0;
        private _destroyedCount = 0;
        private _siteLines = [];
        
        if (!isNil "RECONDO_POO_ACTIVE") then {
            {
                _x params ["_iid", "_markerId", "_targetMarker", "_siteStatus"];
                if (_iid == _instanceId) then {
                    private _grid = [_markerId] call _fnc_markerGrid;
                    if (_markerId in (missionNamespace getVariable ["RECONDO_POO_DESTROYED", []])) then {
                        _destroyedCount = _destroyedCount + 1;
                        _siteLines pushBack format ["<t color='#88CC88' size='0.9'>  [%1] DESTROYED</t>", _grid];
                    } else {
                        _activeCount = _activeCount + 1;
                        _siteLines pushBack format ["<t color='#FF8888' size='0.9'>  [%1] ACTIVE</t>", _grid];
                    };
                };
            } forEach RECONDO_POO_ACTIVE;
        };
        
        private _totalSites = _activeCount + _destroyedCount;
        private _headerText = if (_activeCount == 0 && _totalSites > 0) then {
            format ["<t color='#88CC88'>%1: COMPLETE (%2 destroyed)</t>", _objectiveName, _totalSites]
        } else {
            format ["<t color='#FFCC00'>%1: %2 of %3 remaining</t>", _objectiveName, _activeCount, _totalSites]
        };
        _statusLines pushBack _headerText;
        { _statusLines pushBack _x } forEach _siteLines;
    } forEach RECONDO_POO_INSTANCES;
};

// ========================================
// JAMMER
// ========================================

if (!isNil "RECONDO_JAMMER_INSTANCES" && {count RECONDO_JAMMER_INSTANCES > 0}) then {
    _hasObjectives = true;
    {
        private _settings = _x;
        private _objectiveName = _settings get "objectiveName";
        private _instanceId = _settings get "instanceId";
        
        private _activeCount = 0;
        private _destroyedCount = 0;
        private _siteLines = [];
        
        if (!isNil "RECONDO_JAMMER_ACTIVE") then {
            {
                _x params ["_iid", "_markerId", "_compData", "_siteStatus"];
                if (_iid == _instanceId) then {
                    private _grid = [_markerId] call _fnc_markerGrid;
                    if (_siteStatus == "destroyed") then {
                        _destroyedCount = _destroyedCount + 1;
                        _siteLines pushBack format ["<t color='#88CC88' size='0.9'>  [%1] DESTROYED</t>", _grid];
                    } else {
                        _activeCount = _activeCount + 1;
                        _siteLines pushBack format ["<t color='#FF8888' size='0.9'>  [%1] ACTIVE</t>", _grid];
                    };
                };
            } forEach RECONDO_JAMMER_ACTIVE;
        };
        
        private _totalSites = _activeCount + _destroyedCount;
        private _headerText = if (_activeCount == 0 && _totalSites > 0) then {
            format ["<t color='#88CC88'>%1: COMPLETE (%2 destroyed)</t>", _objectiveName, _totalSites]
        } else {
            format ["<t color='#FFCC00'>%1: %2 of %3 remaining</t>", _objectiveName, _activeCount, _totalSites]
        };
        _statusLines pushBack _headerText;
        { _statusLines pushBack _x } forEach _siteLines;
    } forEach RECONDO_JAMMER_INSTANCES;
};

// ========================================
// PHOTOGRAPHS
// ========================================

if (!isNil "RECONDO_PHOTO_INSTANCES" && {count RECONDO_PHOTO_INSTANCES > 0}) then {
    _hasObjectives = true;
    {
        private _settings = _x;
        private _objectiveName = _settings get "objectiveName";
        private _instanceId = _settings get "instanceId";
        
        private _activeCount = 0;
        private _completedCount = 0;
        private _siteLines = [];
        
        if (!isNil "RECONDO_PHOTO_ACTIVE") then {
            {
                _x params ["_iid", "_markerId", "_compData", "_siteStatus"];
                if (_iid == _instanceId) then {
                    private _grid = [_markerId] call _fnc_markerGrid;
                    if (_siteStatus == "completed") then {
                        _completedCount = _completedCount + 1;
                        _siteLines pushBack format ["<t color='#88CC88' size='0.9'>  [%1] COMPLETE</t>", _grid];
                    } else {
                        _activeCount = _activeCount + 1;
                        _siteLines pushBack format ["<t color='#FF8888' size='0.9'>  [%1] ACTIVE</t>", _grid];
                    };
                };
            } forEach RECONDO_PHOTO_ACTIVE;
        };
        
        private _totalSites = _activeCount + _completedCount;
        private _headerText = if (_activeCount == 0 && _totalSites > 0) then {
            format ["<t color='#88CC88'>%1: COMPLETE (%2 photographed)</t>", _objectiveName, _totalSites]
        } else {
            format ["<t color='#FFCC00'>%1: %2 of %3 remaining</t>", _objectiveName, _activeCount, _totalSites]
        };
        _statusLines pushBack _headerText;
        { _statusLines pushBack _x } forEach _siteLines;
    } forEach RECONDO_PHOTO_INSTANCES;
};

// ========================================
// NO OBJECTIVES FALLBACK
// ========================================

if (!_hasObjectives) then {
    _statusLines pushBack "No objectives configured.";
};

// ========================================
// DISPLAY
// ========================================

private _bodyText = _statusLines joinString "<br/>";

if (_bodyText == "") then {
    _bodyText = "No objective data available.";
};

["MISSION STATUS", _bodyText, 0, 30, "", 1] call Recondo_fnc_showIntelCard;

private _debugLogging = if (isNil "RECONDO_TERMINAL_SETTINGS") then { false } else { RECONDO_TERMINAL_SETTINGS getOrDefault ["debugLogging", false] };
if (_debugLogging) then {
    diag_log format ["[RECONDO_TERMINAL] Displayed objective status: %1 lines", count _statusLines];
};
