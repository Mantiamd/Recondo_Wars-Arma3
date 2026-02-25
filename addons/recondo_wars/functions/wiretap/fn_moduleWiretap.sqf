/*
    Recondo_fnc_moduleWiretap
    Main initialization for Wiretap System module
    
    Description:
        Spawns telephone poles at invisible map markers.
        Players with a wiretap item can place and retrieve wiretaps
        to gain intel items.
    
    Parameters:
        _logic - Module logic object
        _units - Synchronized units (unused)
        _activated - Whether module is activated
*/

params ["_logic", "_units", "_activated"];

// Server-only initialization
if (!isServer) exitWith {};

// Validate activation
if (!_activated) exitWith {
    diag_log "[RECONDO_WIRETAP] Module not activated.";
};

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

private _markerPrefix = _logic getVariable ["markerprefix", "WIRETAP_"];
private _spawnPercentage = _logic getVariable ["spawnpercentage", 1];
private _poleClassname = _logic getVariable ["poleclassname", "Land_PowerLine_02_pole_junction_A_F"];

private _climbDuration = _logic getVariable ["climbduration", 5];
private _placeDuration = _logic getVariable ["placeduration", 5];
private _retrievalDelay = _logic getVariable ["retrievaldelay", 5];

private _wiretapItem = _logic getVariable ["wiretapitem", "vn_b_item_wiretap"];
private _rewardItem = _logic getVariable ["rewarditem", ""];

private _poleHeight = _logic getVariable ["poleheight", 8];
private _roadSearchRadius = _logic getVariable ["roadsearchradius", 100];
private _roadOffset = _logic getVariable ["roadoffset", 8];
private _clearRadius = _logic getVariable ["clearradius", 4];
private _disableSimulation = _logic getVariable ["disablesimulation", true];

private _groundWiretapDistance = _logic getVariable ["groundwiretapdistance", 6];
private _groundWiretapClassname = _logic getVariable ["groundwiretapclassname", "vn_b_item_wiretap_gh"];
private _poleGroundObjectClassname = _logic getVariable ["polegroundobjectclassname", "Land_DirtPatch_01_4x4_F"];

private _textPlaced = _logic getVariable ["textplaced", "Wiretap placed"];
private _textRetrieved = _logic getVariable ["textretrieved", "Wiretap retrieved - return intel to base"];
private _textCancelled = _logic getVariable ["textcancelled", "Wiretap cancelled"];
private _textWaitTime = _logic getVariable ["textwaittime", "Wait %1 seconds"];
private _actionPlace = _logic getVariable ["actionplace", "Place Wiretap"];
private _actionRetrieve = _logic getVariable ["actionretrieve", "Retrieve Wiretap"];
private _actionCheckTime = _logic getVariable ["actionchecktime", "Check Time Until Retrieval"];
private _textClimbingUp = _logic getVariable ["textclimbingup", "Climbing pole"];
private _textClimbingDown = _logic getVariable ["textclimbingdown", "Climbing down"];
private _textPlacing = _logic getVariable ["textplacing", "Placing wiretap"];
private _textRetrieving = _logic getVariable ["textretrieving", "Retrieving wiretap"];

private _enableClassRestriction = _logic getVariable ["enableclassrestriction", false];
private _allowedClassnamesRaw = _logic getVariable ["allowedclassnames", ""];
private _restrictedText = _logic getVariable ["restrictedtext", "Only specialized personnel can operate wiretaps"];

private _debugLogging = _logic getVariable ["debuglogging", false];

// Parse allowed classnames
private _allowedClassnames = [];
if (_enableClassRestriction && _allowedClassnamesRaw != "") then {
    _allowedClassnames = ((_allowedClassnamesRaw splitString (toString [10, 13] + ",")) apply { _x trim [" ", 0] }) select { _x != "" };
};

// ========================================
// VALIDATE SETTINGS
// ========================================

if (_rewardItem == "") then {
    diag_log "[RECONDO_WIRETAP] WARNING: No reward item configured. Wiretaps will not give intel.";
};

// ========================================
// STORE SETTINGS
// ========================================

RECONDO_WIRETAP_SETTINGS = createHashMapFromArray [
    ["markerPrefix", _markerPrefix],
    ["spawnPercentage", _spawnPercentage],
    ["poleClassname", _poleClassname],
    ["climbDuration", _climbDuration],
    ["placeDuration", _placeDuration],
    ["retrievalDelay", _retrievalDelay],
    ["wiretapItem", _wiretapItem],
    ["rewardItem", _rewardItem],
    ["poleHeight", _poleHeight],
    ["roadSearchRadius", _roadSearchRadius],
    ["roadOffset", _roadOffset],
    ["clearRadius", _clearRadius],
    ["disableSimulation", _disableSimulation],
    ["groundWiretapDistance", _groundWiretapDistance],
    ["groundWiretapClassname", _groundWiretapClassname],
    ["poleGroundObjectClassname", _poleGroundObjectClassname],
    ["textPlaced", _textPlaced],
    ["textRetrieved", _textRetrieved],
    ["textCancelled", _textCancelled],
    ["textWaitTime", _textWaitTime],
    ["actionPlace", _actionPlace],
    ["actionRetrieve", _actionRetrieve],
    ["actionCheckTime", _actionCheckTime],
    ["textClimbingUp", _textClimbingUp],
    ["textClimbingDown", _textClimbingDown],
    ["textPlacing", _textPlacing],
    ["textRetrieving", _textRetrieving],
    ["enableClassRestriction", _enableClassRestriction],
    ["allowedClassnames", _allowedClassnames],
    ["restrictedText", _restrictedText],
    ["debugLogging", _debugLogging]
];
publicVariable "RECONDO_WIRETAP_SETTINGS";

// ========================================
// FIND MARKERS
// ========================================

private _prefixLength = count _markerPrefix;
private _allMarkers = [];

{
    if ((_x select [0, _prefixLength]) == _markerPrefix) then {
        _allMarkers pushBack _x;
    };
} forEach allMapMarkers;

if (count _allMarkers == 0) exitWith {
    diag_log format ["[RECONDO_WIRETAP] ERROR: No markers found with prefix '%1'", _markerPrefix];
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_WIRETAP] Found %1 markers with prefix '%2': %3", count _allMarkers, _markerPrefix, _allMarkers];
};

// ========================================
// SELECT MARKERS BASED ON PERCENTAGE
// ========================================

private _numToSelect = round ((count _allMarkers) * _spawnPercentage);
_numToSelect = _numToSelect max 1; // At least 1

private _selectedMarkers = [];
private _availableMarkers = +_allMarkers; // Copy

while {count _selectedMarkers < _numToSelect && count _availableMarkers > 0} do {
    private _randomMarker = selectRandom _availableMarkers;
    _availableMarkers = _availableMarkers - [_randomMarker];
    _selectedMarkers pushBack _randomMarker;
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_WIRETAP] Selected %1 of %2 markers (%3%): %4", 
        count _selectedMarkers, count _allMarkers, round(_spawnPercentage * 100), _selectedMarkers];
};

// ========================================
// SPAWN POLES
// ========================================

{
    private _markerPos = getMarkerPos _x;
    [_x, _markerPos] call Recondo_fnc_spawnWiretapPole;
} forEach _selectedMarkers;

// ========================================
// CONNECT POLES WITH ROPES (Pole-to-Pole or Ground)
// ========================================

// Wait a frame to ensure all poles are spawned and tracked
[{
    params ["_poleHeight", "_prefixLength", "_debugLogging", "_poleGroundObjectClassname"];
    
    // Get all spawned poles
    private _poles = RECONDO_WIRETAP_POLES;
    
    // Initialize global arrays for rope tracking
    RECONDO_WIRETAP_POLE_ROPES = [];
    RECONDO_WIRETAP_GROUND_ROPES = [];
    
    if (count _poles == 0) exitWith {
        if (_debugLogging) then {
            diag_log "[RECONDO_WIRETAP] No poles spawned, skipping connections";
        };
    };
    
    // Helper function to create a ground rope from pole
    private _fnc_createGroundRope = {
        params ["_pole", "_polePos", "_poleHeight", "_groundDir", "_groundObjectClass", "_debug", "_side"];
        
        // Calculate ground position 6m from pole base in the specified direction
        private _groundPos = [_polePos select 0, _polePos select 1, 0] getPos [6, _groundDir];
        _groundPos set [2, 0];
        
        // Create the ground object (dirt patch)
        private _groundObject = _groundObjectClass createVehicle _groundPos;
        _groundObject setPosATL _groundPos;
        _groundObject setDir _groundDir;
        
        // Create hidden helper at pole top
        private _topHelper = "Recondo_STABO_Helper" createVehicle [0, 0, 0];
        _topHelper setPosATL [_polePos select 0, _polePos select 1, _poleHeight];
        [_topHelper, true] remoteExec ["hideObjectGlobal", 2];
        _topHelper allowDamage false;
        
        // Create hidden helper at ground
        private _bottomHelper = "Recondo_STABO_Helper" createVehicle [0, 0, 0];
        _bottomHelper setPosATL _groundPos;
        [_bottomHelper, true] remoteExec ["hideObjectGlobal", 2];
        _bottomHelper allowDamage false;
        
        // Calculate rope length
        private _ropeLength = _poleHeight + 5;
        
        // Create rope
        private _rope = ropeCreate [_topHelper, [0, 0, 0], _bottomHelper, [0, 0, 0], _ropeLength];
        
        // Store for tracking
        RECONDO_WIRETAP_GROUND_ROPES pushBack [_rope, _topHelper, _bottomHelper, _groundObject, _pole, _side];
        
        if (_debug) then {
            private _markerName = _pole getVariable ["RECONDO_WIRETAP_markerName", ""];
            diag_log format ["[RECONDO_WIRETAP] Created %1 ground rope for %2 at dir %3", _side, _markerName, round _groundDir];
        };
    };
    
    // Helper function to create pole-to-pole rope
    private _fnc_createPoleToPoleRope = {
        params ["_pole1", "_pole2", "_poleHeight", "_debug"];
        
        private _pos1 = getPosATL _pole1;
        private _pos2 = getPosATL _pole2;
        private _topPos1 = [_pos1 select 0, _pos1 select 1, _poleHeight];
        private _topPos2 = [_pos2 select 0, _pos2 select 1, _poleHeight];
        
        private _distance = _topPos1 distance _topPos2;
        private _ropeLength = _distance + 2;
        
        // Create helpers
        private _helper1 = "Recondo_STABO_Helper" createVehicle [0, 0, 0];
        _helper1 setPosATL _topPos1;
        [_helper1, true] remoteExec ["hideObjectGlobal", 2];
        _helper1 allowDamage false;
        
        private _helper2 = "Recondo_STABO_Helper" createVehicle [0, 0, 0];
        _helper2 setPosATL _topPos2;
        [_helper2, true] remoteExec ["hideObjectGlobal", 2];
        _helper2 allowDamage false;
        
        // Create rope
        private _rope = ropeCreate [_helper1, [0, 0, 0], _helper2, [0, 0, 0], _ropeLength];
        
        private _marker1 = _pole1 getVariable ["RECONDO_WIRETAP_markerName", ""];
        private _marker2 = _pole2 getVariable ["RECONDO_WIRETAP_markerName", ""];
        
        RECONDO_WIRETAP_POLE_ROPES pushBack [_rope, _helper1, _helper2, _marker1, _marker2];
        
        if (_debug) then {
            diag_log format ["[RECONDO_WIRETAP] Connected %1 to %2 (distance: %3m)", _marker1, _marker2, round _distance];
        };
        
        _distance
    };
    
    // Create array of [markerNumber, pole, markerName] for sorting
    private _polesWithNumbers = [];
    {
        private _pole = _x;
        private _markerName = _pole getVariable ["RECONDO_WIRETAP_markerName", ""];
        private _numberStr = _markerName select [_prefixLength];
        private _number = parseNumber _numberStr;
        _polesWithNumbers pushBack [_number, _pole, _markerName];
    } forEach _poles;
    
    // Sort by marker number (ascending)
    _polesWithNumbers sort true;
    
    if (_debugLogging) then {
        private _sortedNames = _polesWithNumbers apply { _x select 2 };
        diag_log format ["[RECONDO_WIRETAP] Pole connection order: %1", _sortedNames];
    };
    
    // Handle single pole case
    if (count _polesWithNumbers == 1) exitWith {
        private _poleData = _polesWithNumbers select 0;
        private _pole = _poleData select 1;
        private _markerName = _poleData select 2;
        private _polePos = getPosATL _pole;
        private _dirToRoad = _pole getVariable ["RECONDO_WIRETAP_dirToRoad", 0];
        private _dirParallel = _dirToRoad - 90;
        
        // Single pole gets ground ropes on both sides
        [_pole, _polePos, _poleHeight, _dirParallel, _poleGroundObjectClassname, _debugLogging, "backward"] call _fnc_createGroundRope;
        [_pole, _polePos, _poleHeight, _dirParallel + 180, _poleGroundObjectClassname, _debugLogging, "forward"] call _fnc_createGroundRope;
        
        diag_log format ["[RECONDO_WIRETAP] Single pole %1 - created ground ropes on both sides", _markerName];
    };
    
    // Track which poles need ground ropes
    private _needsBackwardGround = []; // Poles that need ground rope toward "previous" direction
    private _needsForwardGround = [];  // Poles that need ground rope toward "next" direction
    
    // First pole always needs backward ground rope
    _needsBackwardGround pushBack (_polesWithNumbers select 0 select 1);
    
    // Last pole always needs forward ground rope
    _needsForwardGround pushBack (_polesWithNumbers select (count _polesWithNumbers - 1) select 1);
    
    // Process consecutive pole pairs
    private _maxPoleConnectionDistance = 50; // Hardcoded 50m threshold
    
    for "_i" from 0 to (count _polesWithNumbers - 2) do {
        private _currentData = _polesWithNumbers select _i;
        private _nextData = _polesWithNumbers select (_i + 1);
        
        private _currentPole = _currentData select 1;
        private _nextPole = _nextData select 1;
        
        private _currentPos = getPosATL _currentPole;
        private _nextPos = getPosATL _nextPole;
        private _distance = _currentPos distance _nextPos;
        
        if (_distance <= _maxPoleConnectionDistance) then {
            // Close enough - create pole-to-pole rope
            [_currentPole, _nextPole, _poleHeight, _debugLogging] call _fnc_createPoleToPoleRope;
        } else {
            // Too far apart - both poles get ground ropes
            _needsForwardGround pushBackUnique _currentPole;
            _needsBackwardGround pushBackUnique _nextPole;
            
            if (_debugLogging) then {
                private _currentMarker = _currentData select 2;
                private _nextMarker = _nextData select 2;
                diag_log format ["[RECONDO_WIRETAP] Distance %1m > 50m between %2 and %3 - using ground ropes", 
                    round _distance, _currentMarker, _nextMarker];
            };
        };
    };
    
    // Create ground ropes for poles that need them
    {
        private _pole = _x;
        private _polePos = getPosATL _pole;
        private _dirToRoad = _pole getVariable ["RECONDO_WIRETAP_dirToRoad", 0];
        private _dirParallel = _dirToRoad - 90; // Direction parallel to road
        
        // Find the index of this pole to determine direction
        private _poleIndex = -1;
        {
            if (_x select 1 == _pole) exitWith { _poleIndex = _forEachIndex; };
        } forEach _polesWithNumbers;
        
        // Backward direction: toward previous pole, or opposite of forward if first
        private _backwardDir = _dirParallel;
        if (_poleIndex > 0) then {
            private _prevPole = (_polesWithNumbers select (_poleIndex - 1)) select 1;
            private _prevPos = getPosATL _prevPole;
            _backwardDir = _polePos getDir _prevPos;
        } else {
            // First pole - backward is opposite of forward (toward next pole)
            if (_poleIndex < (count _polesWithNumbers - 1)) then {
                private _nextPole = (_polesWithNumbers select (_poleIndex + 1)) select 1;
                private _nextPos = getPosATL _nextPole;
                _backwardDir = (_polePos getDir _nextPos) + 180;
            };
        };
        
        [_pole, _polePos, _poleHeight, _backwardDir, _poleGroundObjectClassname, _debugLogging, "backward"] call _fnc_createGroundRope;
    } forEach _needsBackwardGround;
    
    {
        private _pole = _x;
        private _polePos = getPosATL _pole;
        private _dirToRoad = _pole getVariable ["RECONDO_WIRETAP_dirToRoad", 0];
        private _dirParallel = _dirToRoad - 90;
        
        // Find the index of this pole
        private _poleIndex = -1;
        {
            if (_x select 1 == _pole) exitWith { _poleIndex = _forEachIndex; };
        } forEach _polesWithNumbers;
        
        // Forward direction: toward next pole, or opposite of backward if last
        private _forwardDir = _dirParallel + 180;
        if (_poleIndex < (count _polesWithNumbers - 1)) then {
            private _nextPole = (_polesWithNumbers select (_poleIndex + 1)) select 1;
            private _nextPos = getPosATL _nextPole;
            _forwardDir = _polePos getDir _nextPos;
        } else {
            // Last pole - forward is opposite of backward (toward prev pole)
            if (_poleIndex > 0) then {
                private _prevPole = (_polesWithNumbers select (_poleIndex - 1)) select 1;
                private _prevPos = getPosATL _prevPole;
                _forwardDir = (_polePos getDir _prevPos) + 180;
            };
        };
        
        [_pole, _polePos, _poleHeight, _forwardDir, _poleGroundObjectClassname, _debugLogging, "forward"] call _fnc_createGroundRope;
    } forEach _needsForwardGround;
    
    diag_log format ["[RECONDO_WIRETAP] Created %1 pole-to-pole ropes and %2 ground ropes", 
        count RECONDO_WIRETAP_POLE_ROPES, count RECONDO_WIRETAP_GROUND_ROPES];
    
}, [_poleHeight, _prefixLength, _debugLogging, _poleGroundObjectClassname]] call CBA_fnc_execNextFrame;

// ========================================
// LOG INITIALIZATION
// ========================================

diag_log format ["[RECONDO_WIRETAP] Module initialized. Spawned %1 poles from %2 markers (%3%)",
    count _selectedMarkers, count _allMarkers, round(_spawnPercentage * 100)];

if (_debugLogging) then {
    diag_log "[RECONDO_WIRETAP] === Wiretap Module Settings ===";
    diag_log format ["[RECONDO_WIRETAP] Wiretap Item: %1", _wiretapItem];
    diag_log format ["[RECONDO_WIRETAP] Reward Item: %1", _rewardItem];
    diag_log format ["[RECONDO_WIRETAP] Retrieval Delay: %1s", _retrievalDelay];
    diag_log format ["[RECONDO_WIRETAP] Pole Height: %1m", _poleHeight];
    diag_log format ["[RECONDO_WIRETAP] Class Restriction: %1", _enableClassRestriction];
    if (_enableClassRestriction) then {
        diag_log format ["[RECONDO_WIRETAP] Allowed Classnames: %1", _allowedClassnames];
    };
};
