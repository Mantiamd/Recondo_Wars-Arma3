/*
    Recondo_fnc_getIntelBoardData
    Gathers all objective data for the Intel Board display
    
    Description:
        Collects data from all objective modules (HVT, Hostages, Destroy, Hub & Subs, Jammer)
        and formats it for the Intel Board dialog. Returns a hashmap containing
        categorized target data. Categories are grouped by the custom Intel Board Category Name
        set in each objective module, allowing different modules to share categories.
    
    Parameters:
        None
    
    Returns:
        HASHMAP - Contains:
            categories - ARRAY of category hashmaps with:
                name - STRING - Category display name
                type - STRING - Category type identifier
                targets - ARRAY of target hashmaps
            totalTargets - NUMBER - Total target count
            remainingTargets - NUMBER - Remaining (not completed) target count
    
    Example:
        private _data = [] call Recondo_fnc_getIntelBoardData;
*/

private _settings = if (isNil "RECONDO_INTELBOARD_SETTINGS") then { createHashMap } else { RECONDO_INTELBOARD_SETTINGS };

private _enableHVT = _settings getOrDefault ["enableHVT", true];
private _enableHostages = _settings getOrDefault ["enableHostages", true];
private _enableDestroy = _settings getOrDefault ["enableDestroy", true];
private _enableHubSubs = _settings getOrDefault ["enableHubSubs", true];
private _enableJammer = _settings getOrDefault ["enableJammer", true];
private _enablePhotos = _settings getOrDefault ["enablePhotos", true];
private _showRevealedLocations = _settings getOrDefault ["showRevealedLocations", true];
private _debugLogging = _settings getOrDefault ["debugLogging", false];

// Use a hashmap to group targets by category name
private _categoriesMap = createHashMap;
private _totalTargets = 0;
private _remainingTargets = 0;

// Helper function to add a target to a category
private _fnc_addToCategory = {
    params ["_categoryName", "_categoryType", "_targetData"];
    
    private _categoryData = _categoriesMap getOrDefault [_categoryName, nil];
    
    if (isNil "_categoryData") then {
        // Create new category
        _categoryData = createHashMapFromArray [
            ["name", _categoryName],
            ["type", _categoryType],
            ["targets", [_targetData]]
        ];
        _categoriesMap set [_categoryName, _categoryData];
    } else {
        // Add to existing category
        private _targets = _categoryData get "targets";
        _targets pushBack _targetData;
    };
};

// ========================================
// HVT OBJECTIVES
// ========================================

if (_enableHVT && !isNil "RECONDO_HVT_INSTANCES" && {count RECONDO_HVT_INSTANCES > 0}) then {
    {
        private _hvtSettings = _x;
        private _objectiveName = _hvtSettings get "objectiveName";
        private _hvtName = _hvtSettings get "hvtName";
        private _hvtPhoto = _hvtSettings getOrDefault ["hvtPhoto", "\recondo_wars\images\intel\default_photo.paa"];
        private _hvtBackground = _hvtSettings getOrDefault ["hvtBackground", ""];
        private _instanceId = _hvtSettings get "instanceId";
        private _categoryName = _hvtSettings getOrDefault ["intelBoardCategoryName", ""];
        
        // Use default if empty
        if (_categoryName == "") then {
            _categoryName = "HIGH VALUE TARGETS";
        };
        
        // Get capture status
        private _counts = [_objectiveName] call Recondo_fnc_getHVTObjectiveCount;
        _counts params ["_remaining", "_total"];
        private _isCaptured = _remaining == 0;
        
        // Check if location is revealed for the player's group
        private _revealedLocation = "";
        if (_showRevealedLocations && !isNil "RECONDO_INTEL_REVEALED" && !isNil "RECONDO_INTEL_TARGETS") then {
            private _groupId = groupId (group player);
            private _revealedForGroup = RECONDO_INTEL_REVEALED getOrDefault [_groupId, []];
            {
                _x params ["_type", "_id", "_pos", "_data"];
                if (_type == "hvt" && {_id in _revealedForGroup} && {(_data getOrDefault ["hvtName", ""]) == _hvtName}) exitWith {
                    _revealedLocation = [_pos] call Recondo_fnc_posToGrid;
                };
            } forEach RECONDO_INTEL_TARGETS;
        };
        
        private _targetData = createHashMapFromArray [
            ["id", format ["hvt_%1", _forEachIndex]],
            ["type", "hvt"],
            ["name", _hvtName],
            ["displayName", _hvtName],
            ["photo", _hvtPhoto],
            ["background", _hvtBackground],
            ["status", if (_isCaptured) then { "CAPTURED" } else { "AT LARGE" }],
            ["statusColor", if (_isCaptured) then { [1, 0.3, 0.3, 1] } else { [1, 0.8, 0, 1] }],
            ["location", _revealedLocation],
            ["complete", _isCaptured],
            ["objectiveName", _objectiveName]
        ];
        
        [_categoryName, "hvt", _targetData] call _fnc_addToCategory;
        _totalTargets = _totalTargets + 1;
        if (!_isCaptured) then { _remainingTargets = _remainingTargets + 1 };
        
    } forEach RECONDO_HVT_INSTANCES;
};

// ========================================
// HOSTAGE OBJECTIVES
// ========================================

if (_enableHostages && !isNil "RECONDO_HOSTAGE_INSTANCES" && {count RECONDO_HOSTAGE_INSTANCES > 0}) then {
    {
        private _hostageSettings = _x;
        private _objectiveName = _hostageSettings get "objectiveName";
        private _hostageNames = _hostageSettings get "hostageNames";
        private _hostagePhotos = _hostageSettings getOrDefault ["hostagePhotos", []];
        private _hostageBackgrounds = _hostageSettings getOrDefault ["hostageBackgrounds", []];
        private _instanceId = _hostageSettings get "instanceId";
        private _hostageCount = _hostageSettings get "hostageCount";
        private _categoryName = _hostageSettings getOrDefault ["intelBoardCategoryName", ""];
        
        // Use default if empty
        if (_categoryName == "") then {
            _categoryName = "HOSTAGES";
        };
        
        // Get detailed status
        private _status = [_objectiveName] call Recondo_fnc_getHostageObjectiveStatus;
        private _hostageData = _status getOrDefault ["hostages", []];
        
        // Process each hostage
        {
            private _hostageInfo = _x;
            private _hostageName = _hostageInfo getOrDefault ["name", "Unknown"];
            private _hostageIndex = _hostageInfo getOrDefault ["index", 0];
            private _isRescued = _hostageInfo getOrDefault ["rescued", false];
            private _marker = _hostageInfo getOrDefault ["marker", ""];
            
            // Get photo for this hostage
            private _hostagePhoto = "\recondo_wars\images\intel\default_photo.paa";
            if (_hostageIndex < count _hostagePhotos) then {
                _hostagePhoto = _hostagePhotos select _hostageIndex;
                if (_hostagePhoto == "") then {
                    _hostagePhoto = "\recondo_wars\images\intel\default_photo.paa";
                };
            };
            
            // Get background for this hostage
            private _hostageBackground = "";
            if (_hostageIndex < count _hostageBackgrounds) then {
                _hostageBackground = _hostageBackgrounds select _hostageIndex;
            };
            
            // Check if location is revealed for the player's group
            private _revealedLocation = "";
            if (_showRevealedLocations && _marker != "" && !isNil "RECONDO_INTEL_REVEALED" && !isNil "RECONDO_INTEL_TARGETS") then {
                private _groupId = groupId (group player);
                private _revealedForGroup = RECONDO_INTEL_REVEALED getOrDefault [_groupId, []];
                {
                    _x params ["_type", "_id", "_pos", "_data"];
                    if (_type == "hostage" && {_id in _revealedForGroup} && {_marker == (_data getOrDefault ["marker", ""])}) exitWith {
                        _revealedLocation = [_pos] call Recondo_fnc_posToGrid;
                    };
                } forEach RECONDO_INTEL_TARGETS;
            };
            
            private _targetData = createHashMapFromArray [
                ["id", format ["hostage_%1_%2", _forEachIndex, _hostageIndex]],
                ["type", "hostage"],
                ["name", _hostageName],
                ["displayName", _hostageName],
                ["photo", _hostagePhoto],
                ["background", _hostageBackground],
                ["status", if (_isRescued) then { "RESCUED" } else { "MISSING" }],
                ["statusColor", if (_isRescued) then { [0.5, 0.8, 0.5, 1] } else { [1, 0.5, 0.5, 1] }],
                ["location", _revealedLocation],
                ["complete", _isRescued],
                ["objectiveName", _objectiveName]
            ];
            
            [_categoryName, "hostage", _targetData] call _fnc_addToCategory;
            _totalTargets = _totalTargets + 1;
            if (!_isRescued) then { _remainingTargets = _remainingTargets + 1 };
            
        } forEach _hostageData;
        
    } forEach RECONDO_HOSTAGE_INSTANCES;
};

// ========================================
// DESTROY OBJECTIVES
// ========================================

if (_enableDestroy && !isNil "RECONDO_OBJDESTROY_INSTANCES" && {count RECONDO_OBJDESTROY_INSTANCES > 0}) then {
    {
        private _destroySettings = _x;
        private _objectiveName = _destroySettings get "objectiveName";
        private _objectiveDescription = _destroySettings getOrDefault ["objectiveDescription", ""];
        private _categoryName = _destroySettings getOrDefault ["intelBoardCategoryName", ""];
        
        // Use default if empty
        if (_categoryName == "") then {
            _categoryName = "DESTROY OBJECTIVES";
        };
        
        // Get counts
        private _counts = [_objectiveName] call Recondo_fnc_getObjectiveCount;
        _counts params ["_remaining", "_total"];
        private _isComplete = _remaining == 0;
        
        private _targetData = createHashMapFromArray [
            ["id", format ["destroy_%1", _forEachIndex]],
            ["type", "destroy"],
            ["name", _objectiveName],
            ["displayName", _objectiveName],
            ["photo", ""],
            ["background", _objectiveDescription],
            ["status", if (_isComplete) then { format ["DESTROYED (%1/%1)", _total] } else { format ["%1/%2 REMAINING", _remaining, _total] }],
            ["statusColor", if (_isComplete) then { [0.5, 0.8, 0.5, 1] } else { [1, 0.8, 0, 1] }],
            ["location", ""],
            ["complete", _isComplete],
            ["objectiveName", _objectiveName]
        ];
        
        [_categoryName, "destroy", _targetData] call _fnc_addToCategory;
        _totalTargets = _totalTargets + 1;
        if (!_isComplete) then { _remainingTargets = _remainingTargets + 1 };
        
    } forEach RECONDO_OBJDESTROY_INSTANCES;
};

// ========================================
// HUB & SUBS OBJECTIVES
// ========================================

if (_enableHubSubs && !isNil "RECONDO_HUBSUBS_INSTANCES" && {count RECONDO_HUBSUBS_INSTANCES > 0}) then {
    {
        private _hubSettings = _x;
        private _objectiveName = _hubSettings get "objectiveName";
        private _objectiveDescription = _hubSettings getOrDefault ["objectiveDescription", ""];
        private _categoryName = _hubSettings getOrDefault ["intelBoardCategoryName", ""];
        
        // Use default if empty
        if (_categoryName == "") then {
            _categoryName = "HUB & SUBS";
        };
        
        // Get counts
        private _counts = [_objectiveName] call Recondo_fnc_getHubObjectiveCount;
        _counts params ["_remaining", "_total"];
        private _isComplete = _remaining == 0;
        
        private _targetData = createHashMapFromArray [
            ["id", format ["hubsubs_%1", _forEachIndex]],
            ["type", "hubsubs"],
            ["name", _objectiveName],
            ["displayName", _objectiveName],
            ["photo", ""],
            ["background", _objectiveDescription],
            ["status", if (_isComplete) then { format ["DESTROYED (%1/%1)", _total] } else { format ["%1/%2 REMAINING", _remaining, _total] }],
            ["statusColor", if (_isComplete) then { [0.5, 0.8, 0.5, 1] } else { [1, 0.8, 0, 1] }],
            ["location", ""],
            ["complete", _isComplete],
            ["objectiveName", _objectiveName]
        ];
        
        [_categoryName, "hubsubs", _targetData] call _fnc_addToCategory;
        _totalTargets = _totalTargets + 1;
        if (!_isComplete) then { _remainingTargets = _remainingTargets + 1 };
        
    } forEach RECONDO_HUBSUBS_INSTANCES;
};

// ========================================
// JAMMER OBJECTIVES
// ========================================

if (_enableJammer && !isNil "RECONDO_JAMMER_INSTANCES" && {count RECONDO_JAMMER_INSTANCES > 0}) then {
    {
        private _jammerSettings = _x;
        private _objectiveName = _jammerSettings get "objectiveName";
        private _objectiveDescription = _jammerSettings getOrDefault ["objectiveDesc", "ACRE Radio Jamming Installation"];
        private _categoryName = _jammerSettings getOrDefault ["intelBoardCategoryName", ""];
        
        // Use default if empty
        if (_categoryName == "") then {
            _categoryName = "JAMMER INSTALLATIONS";
        };
        
        // Get counts using the jammer-specific function
        private _counts = [_objectiveName] call Recondo_fnc_getJammerCount;
        _counts params ["_remaining", "_total"];
        private _isComplete = _remaining == 0;
        
        private _targetData = createHashMapFromArray [
            ["id", format ["jammer_%1", _forEachIndex]],
            ["type", "jammer"],
            ["name", _objectiveName],
            ["displayName", _objectiveName],
            ["photo", ""],
            ["background", _objectiveDescription],
            ["status", if (_isComplete) then { format ["DESTROYED (%1/%1)", _total] } else { format ["%1/%2 ACTIVE", _remaining, _total] }],
            ["statusColor", if (_isComplete) then { [0.5, 0.8, 0.5, 1] } else { [1, 0.5, 0.5, 1] }],
            ["location", ""],
            ["complete", _isComplete],
            ["objectiveName", _objectiveName]
        ];
        
        [_categoryName, "jammer", _targetData] call _fnc_addToCategory;
        _totalTargets = _totalTargets + 1;
        if (!_isComplete) then { _remainingTargets = _remainingTargets + 1 };
        
    } forEach RECONDO_JAMMER_INSTANCES;
};

// ========================================
// PHOTOGRAPH OBJECTIVES
// ========================================

if (_enablePhotos && !isNil "RECONDO_PHOTO_INSTANCES" && {count RECONDO_PHOTO_INSTANCES > 0}) then {
    {
        private _photoSettings = _x;
        private _objectiveName = _photoSettings get "objectiveName";
        private _objectiveDescription = _photoSettings getOrDefault ["objectiveDesc", ""];
        private _categoryName = _photoSettings getOrDefault ["intelBoardCategoryName", ""];
        private _instanceId = _photoSettings get "instanceId";
        
        if (_categoryName == "") then {
            _categoryName = "RECONNAISSANCE PHOTOS";
        };
        
        private _counts = [_objectiveName] call Recondo_fnc_getPhotoObjectiveCount;
        _counts params ["_remaining", "_total"];
        private _isComplete = _remaining == 0;
        
        private _revealedLocation = "";
        if (_showRevealedLocations && !isNil "RECONDO_INTEL_REVEALED" && !isNil "RECONDO_INTEL_TARGETS") then {
            private _groupId = groupId (group player);
            private _revealedForGroup = RECONDO_INTEL_REVEALED getOrDefault [_groupId, []];
            {
                _x params ["_type", "_id", "_pos", "_data"];
                if (_type == "photograph" && {_id in _revealedForGroup} && {(_data getOrDefault ["name", ""]) == _objectiveName}) exitWith {
                    _revealedLocation = [_pos] call Recondo_fnc_posToGrid;
                };
            } forEach RECONDO_INTEL_TARGETS;
        };
        
        private _targetData = createHashMapFromArray [
            ["id", format ["photo_%1", _forEachIndex]],
            ["type", "photograph"],
            ["name", _objectiveName],
            ["displayName", _objectiveName],
            ["photo", ""],
            ["background", _objectiveDescription],
            ["status", if (_isComplete) then { format ["COMPLETE (%1/%1)", _total] } else { format ["%1/%2 REMAINING", _remaining, _total] }],
            ["statusColor", if (_isComplete) then { [0.5, 0.8, 0.5, 1] } else { [1, 0.8, 0, 1] }],
            ["location", _revealedLocation],
            ["complete", _isComplete],
            ["objectiveName", _objectiveName]
        ];
        
        [_categoryName, "photograph", _targetData] call _fnc_addToCategory;
        _totalTargets = _totalTargets + 1;
        if (!_isComplete) then { _remainingTargets = _remainingTargets + 1 };
        
    } forEach RECONDO_PHOTO_INSTANCES;
};

// ========================================
// SOIL SAMPLE OBJECTIVES
// ========================================

private _enableSoilSample = _settings getOrDefault ["enableSoilSample", true];

if (_enableSoilSample && !isNil "RECONDO_SOIL_INSTANCES" && {count RECONDO_SOIL_INSTANCES > 0}) then {
    {
        private _soilSettings = _x;
        private _objectiveName = _soilSettings get "objectiveName";
        private _objectiveDescription = _soilSettings getOrDefault ["objectiveDescription", ""];
        private _categoryName = _soilSettings getOrDefault ["intelBoardCategoryName", ""];
        private _samplesRequired = _soilSettings get "samplesRequired";
        private _markerAreas = _soilSettings getOrDefault ["markerAreas", []];

        if (_categoryName == "") then {
            _categoryName = "SOIL SAMPLES";
        };

        private _turnedIn = missionNamespace getVariable ["RECONDO_SOIL_TURNED_IN", createHashMap];

        if (count _markerAreas > 0) then {
            {
                private _markerName = _x;
                private _objData = _turnedIn getOrDefault [_markerName, createHashMapFromArray [["turnedIn", 0], ["complete", false], ["grid", ""], ["position", [0,0,0]]]];
                private _count = _objData get "turnedIn";
                private _isComplete = _objData get "complete";
                private _grid = _objData get "grid";

                private _displayName = if (_grid != "") then {
                    format ["Collect soil sample from GRID %1", _grid]
                } else {
                    format ["Collect soil sample (%1)", _markerName]
                };

                private _targetData = createHashMapFromArray [
                    ["id", format ["soil_%1_%2", _forEachIndex, _markerName]],
                    ["type", "soilsample"],
                    ["name", _displayName],
                    ["displayName", _displayName],
                    ["photo", ""],
                    ["background", _objectiveDescription],
                    ["status", if (_isComplete) then { format ["COMPLETE (%1/%1)", _samplesRequired] } else { format ["%1/%2 COLLECTED", _count, _samplesRequired] }],
                    ["statusColor", if (_isComplete) then { [0.5, 0.8, 0.5, 1] } else { [1, 0.8, 0, 1] }],
                    ["location", ""],
                    ["complete", _isComplete],
                    ["objectiveName", _objectiveName]
                ];

                [_categoryName, "soilsample", _targetData] call _fnc_addToCategory;
                _totalTargets = _totalTargets + 1;
                if (!_isComplete) then { _remainingTargets = _remainingTargets + 1 };
            } forEach _markerAreas;
        } else {
            private _objData = _turnedIn getOrDefault ["__GLOBAL__", createHashMapFromArray [["turnedIn", 0], ["complete", false]]];
            private _count = _objData get "turnedIn";
            private _isComplete = _objData get "complete";

            private _displayName = "Collect soil sample from road";

            private _targetData = createHashMapFromArray [
                ["id", format ["soil_%1_global", _forEachIndex]],
                ["type", "soilsample"],
                ["name", _displayName],
                ["displayName", _displayName],
                ["photo", ""],
                ["background", _objectiveDescription],
                ["status", if (_isComplete) then { format ["COMPLETE (%1/%1)", _samplesRequired] } else { format ["%1/%2 COLLECTED", _count, _samplesRequired] }],
                ["statusColor", if (_isComplete) then { [0.5, 0.8, 0.5, 1] } else { [1, 0.8, 0, 1] }],
                ["location", ""],
                ["complete", _isComplete],
                ["objectiveName", _objectiveName]
            ];

            [_categoryName, "soilsample", _targetData] call _fnc_addToCategory;
            _totalTargets = _totalTargets + 1;
            if (!_isComplete) then { _remainingTargets = _remainingTargets + 1 };
        };
    } forEach RECONDO_SOIL_INSTANCES;
};

// ========================================
// CONVERT CATEGORIES MAP TO ARRAY
// ========================================

private _categories = values _categoriesMap;

// ========================================
// SORT CATEGORIES BY PRIORITY
// ========================================
// Priority: HVT first, Hostages second, then others alphabetically

private _typePriority = createHashMapFromArray [
    ["hvt", 1],
    ["hostage", 2],
    ["photograph", 3],
    ["soilsample", 4]
];

_categories = [_categories, [], {
    private _type = _x get "type";
    private _name = _x get "name";
    private _priority = _typePriority getOrDefault [_type, 100];
    // Return array for multi-level sort: priority first, then name
    [_priority, _name]
}, "ASCEND"] call BIS_fnc_sortBy;

// ========================================
// RETURN DATA
// ========================================

// ========================================
// GET INTEL LOG
// ========================================

private _intelLog = if (isNil "RECONDO_INTEL_LOG") then { [] } else { RECONDO_INTEL_LOG };

if (_debugLogging) then {
    diag_log format ["[RECONDO_INTELBOARD] getIntelBoardData - Categories: %1, Total: %2, Remaining: %3, Log entries: %4", 
        count _categories, _totalTargets, _remainingTargets, count _intelLog];
};

createHashMapFromArray [
    ["categories", _categories],
    ["totalTargets", _totalTargets],
    ["remainingTargets", _remainingTargets],
    ["intelLog", _intelLog]
]
