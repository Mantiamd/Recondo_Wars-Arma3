/*
    Recondo_fnc_moduleArsenalArea
    ACE Arsenal Area Module - Server-side initialization
    
    Description:
        Reads module attributes and broadcasts arsenal area configuration to all clients.
        Multiple modules can be placed to create multiple arsenal areas.
    
    Parameters:
        0: OBJECT - Logic module
        1: ARRAY - Synchronized units (unused)
        2: BOOL - Module activated
    
    Returns:
        Nothing
*/

params [["_logic", objNull, [objNull]], ["_units", [], [[]]], ["_activated", true, [true]]];

// Only run on server
if (!isServer) exitWith {};

// Check if module is activated
if (!_activated) exitWith {
    diag_log "[RECONDO_ARSENALAREA] Module placed but not activated.";
};

// Get debug setting
private _debug = _logic getVariable ["enabledebug", false];

if (_debug) then {
    diag_log "[RECONDO_ARSENALAREA] Module initializing...";
};

// Get module position and direction
private _pos = getPosATL _logic;
private _dir = getDir _logic;

// Read module attributes - Arsenal Area
private _areaWidth = _logic getVariable ["areawidth", 50];
private _areaLength = _logic getVariable ["arealength", 50];
private _areaHeight = _logic getVariable ["areaheight", 25];
private _referenceBoxVar = _logic getVariable ["referenceboxvar", ""];
private _allowedClassnamesRaw = _logic getVariable ["allowedclassnames", ""];

// Read module attributes - Cleanup
private _enableCleanup = _logic getVariable ["enablecleanup", false];
private _cleanupWidth = _logic getVariable ["cleanupwidth", 100];
private _cleanupLength = _logic getVariable ["cleanuplength", 100];
private _cleanupHeight = _logic getVariable ["cleanupheight", 25];

// Parse allowed classnames
private _allowedClassnames = [_allowedClassnamesRaw] call Recondo_fnc_parseClassnames;

// Validate reference box variable name
if (_referenceBoxVar == "") exitWith {
    diag_log "[RECONDO_ARSENALAREA] ERROR: No reference box variable name specified!";
};

// Create arsenal area data entry
private _areaData = createHashMap;
_areaData set ["position", _pos];
_areaData set ["direction", _dir];
_areaData set ["width", _areaWidth];
_areaData set ["length", _areaLength];
_areaData set ["height", _areaHeight];
_areaData set ["referenceBoxVar", _referenceBoxVar];
_areaData set ["allowedClassnames", _allowedClassnames];
_areaData set ["debug", _debug];
_areaData set ["enableCleanup", _enableCleanup];
_areaData set ["cleanupWidth", _cleanupWidth];
_areaData set ["cleanupLength", _cleanupLength];
_areaData set ["cleanupHeight", _cleanupHeight];

// Add to global array
RECONDO_ARSENALAREAS pushBack _areaData;
publicVariable "RECONDO_ARSENALAREAS";

if (_debug) then {
    diag_log format ["[RECONDO_ARSENALAREA] Area registered at %1", _pos];
    diag_log format ["[RECONDO_ARSENALAREA]   Arsenal Dimensions: %1 x %2 x %3", _areaWidth, _areaLength, _areaHeight];
    diag_log format ["[RECONDO_ARSENALAREA]   Direction: %1", _dir];
    diag_log format ["[RECONDO_ARSENALAREA]   Reference Box: %1", _referenceBoxVar];
    diag_log format ["[RECONDO_ARSENALAREA]   Allowed Classnames: %1", _allowedClassnames];
    diag_log format ["[RECONDO_ARSENALAREA]   Cleanup Enabled: %1", _enableCleanup];
    if (_enableCleanup) then {
        diag_log format ["[RECONDO_ARSENALAREA]   Cleanup Dimensions: %1 x %2 x %3", _cleanupWidth, _cleanupLength, _cleanupHeight];
    };
    diag_log format ["[RECONDO_ARSENALAREA]   Total areas registered: %1", count RECONDO_ARSENALAREAS];
};

// Start litter cleanup loop if enabled (server-side only)
if (_enableCleanup) then {
    // Cleanup function for this specific area
    private _cleanupCode = {
        params ["_pos", "_dir", "_width", "_length", "_height", "_debug"];
        
        // Find all ground items in the area
        private _searchRadius = (_width max _length) / 2 + 10; // Add buffer
        private _nearObjects = [];
        
        {
            _nearObjects append (_pos nearObjects [_x, _searchRadius]);
        } forEach [
            "GroundWeaponHolder",
            "WeaponHolderSimulated",
            "WeaponHolder"
        ];
        
        private _deletedCount = 0;
        
        {
            private _objPos = getPosATL _x;
            
            // Calculate relative position accounting for area rotation
            private _relX = (_objPos select 0) - (_pos select 0);
            private _relY = (_objPos select 1) - (_pos select 1);
            private _relZ = (_objPos select 2) - (_pos select 2);
            
            // Rotate relative position to align with area direction
            private _dirRad = -_dir * (pi / 180);
            private _rotX = _relX * cos(_dirRad) - _relY * sin(_dirRad);
            private _rotY = _relX * sin(_dirRad) + _relY * cos(_dirRad);
            
            // Check if within bounds (centered on module position)
            private _halfWidth = _width / 2;
            private _halfLength = _length / 2;
            
            if (abs(_rotX) <= _halfWidth && abs(_rotY) <= _halfLength && _relZ >= 0 && _relZ <= _height) then {
                deleteVehicle _x;
                _deletedCount = _deletedCount + 1;
            };
        } forEach _nearObjects;
        
        if (_debug && _deletedCount > 0) then {
            diag_log format ["[RECONDO_ARSENALAREA] Cleanup: Deleted %1 ground items at %2", _deletedCount, _pos];
        };
    };
    
    // Start repeating cleanup loop (every 600 seconds = 10 minutes)
    [{
        params ["_args", "_handle"];
        _args call (_args select 6);
    }, 600, [_pos, _dir, _cleanupWidth, _cleanupLength, _cleanupHeight, _debug, _cleanupCode]] call CBA_fnc_addPerFrameHandler;
    
    if (_debug) then {
        diag_log "[RECONDO_ARSENALAREA] Litter cleanup started. Interval: 600 seconds (10 minutes)";
    };
};

diag_log format ["[RECONDO_ARSENALAREA] Arsenal area initialized. Reference: %1", _referenceBoxVar];
