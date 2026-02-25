/*
    Recondo_fnc_loadComposition
    Loads and spawns a composition from .sqe file
    
    Description:
        Reads a composition file in .sqe format (array of [classname, pos, dir])
        and spawns objects at the specified position with rotation.
        Supports loading from both mod folder and mission folder.
    
    Parameters:
        _compositionPath - STRING - Folder path (relative to mission root, or mod path)
        _compositionName - STRING - Name of composition file (with or without .sqe)
        _position - ARRAY - World position [x, y, z] for composition center
        _direction - NUMBER - Direction/rotation for composition
        _debugLogging - BOOL - Enable debug logging
        _isModPath - BOOL - If true, load from mod folder (\recondo_wars\compositions\)
    
    Returns:
        ARRAY - [spawnedObjects, targetObject (or objNull if not identified)]
    
    Examples:
        // Load from mission folder
        ["compositions", "cache_small.sqe", getMarkerPos "marker1", 45, false, false] call Recondo_fnc_loadComposition;
        
        // Load from mod folder (default compositions)
        ["", "HVTBASE_comp_1.sqe", getMarkerPos "marker1", 45, false, true] call Recondo_fnc_loadComposition;
*/

if (!isServer) exitWith { [[], objNull] };

params [
    ["_compositionPath", "compositions", [""]],
    ["_compositionName", "", [""]],
    ["_position", [0,0,0], [[]]],
    ["_direction", 0, [0]],
    ["_debugLogging", false, [false]],
    ["_isModPath", false, [false]]
];

if (_compositionName == "") exitWith {
    diag_log "[RECONDO] ERROR: No composition name specified";
    [[], objNull]
};

// Strip .sqe extension if present (we'll add it back)
private _compNameClean = _compositionName;
if (_compNameClean select [count _compNameClean - 4, 4] == ".sqe") then {
    _compNameClean = _compNameClean select [0, count _compNameClean - 4];
};

// Build file path based on source
private _filePath = "";
if (_isModPath) then {
    // Load from mod's compositions folder
    _filePath = format ["\recondo_wars\compositions\%1.sqe", _compNameClean];
} else {
    // Load from mission folder
    if (_compositionPath != "") then {
        _filePath = format ["%1\%2.sqe", _compositionPath, _compNameClean];
    } else {
        _filePath = format ["%1.sqe", _compNameClean];
    };
};

if (_debugLogging) then {
    diag_log format ["[RECONDO] Loading composition from: %1 (isModPath: %2)", _filePath, _isModPath];
};

// Check if file exists
if (!fileExists _filePath) exitWith {
    diag_log format ["[RECONDO] ERROR: Composition file not found: %1", _filePath];
    [[], objNull]
};

// Load file content
private _fileContent = loadFile _filePath;

if (_fileContent == "") exitWith {
    diag_log format ["[RECONDO] ERROR: Empty composition file: %1", _filePath];
    [[], objNull]
};

// Parse composition data
private _compositionData = [];
try {
    _compositionData = call compile _fileContent;
} catch {
    diag_log format ["[RECONDO] ERROR: Failed to parse composition file %1: %2", _filePath, _exception];
};

if (count _compositionData == 0) exitWith {
    diag_log format ["[RECONDO] ERROR: No objects in composition: %1", _filePath];
    [[], objNull]
};

// Create anchor for positioning
private _anchor = createVehicle ["Land_HelipadEmpty_F", _position, [], 0, "CAN_COLLIDE"];
_anchor setPosATL [_position select 0, _position select 1, 0];
_anchor setDir _direction;

private _spawnedObjects = [];
private _targetObject = objNull;

// Spawn each object
{
    if (_x isEqualType [] && {count _x >= 3}) then {
        private _classname = _x select 0;
        private _relPos = _x select 1;
        private _objDir = _x select 2;
        
        if (_classname isEqualType "" && {_classname != ""}) then {
            // Validate classname exists
            if (isClass (configFile >> "CfgVehicles" >> _classname)) then {
                // Create object
                private _obj = createVehicle [_classname, [0,0,0], [], 0, "CAN_COLLIDE"];
                
                // Attach to anchor for relative positioning
                _obj attachTo [_anchor, _relPos];
                
                // Detach and set final position
                detach _obj;
                
                // Get world position and set ATL
                private _worldPos = _obj modelToWorld [0,0,0];
                _obj setPosATL [_worldPos select 0, _worldPos select 1, 0];
                _obj setDir (_objDir + _direction);
                _obj setVectorUp [0, 0, 1];
                
                _spawnedObjects pushBack _obj;
                
                if (_debugLogging) then {
                    diag_log format ["[RECONDO] Spawned: %1 at %2", _classname, getPosATL _obj];
                };
            } else {
                diag_log format ["[RECONDO] WARNING: Invalid classname in composition: %1", _classname];
            };
        };
    };
} forEach _compositionData;

// Delete anchor
deleteVehicle _anchor;

if (_debugLogging) then {
    diag_log format ["[RECONDO] Loaded composition %1: %2 objects", _compNameClean, count _spawnedObjects];
};

[_spawnedObjects, _targetObject]
