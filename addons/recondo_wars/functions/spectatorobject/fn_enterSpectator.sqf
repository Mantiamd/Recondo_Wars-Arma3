/*
    Recondo_fnc_enterSpectator
    ACE Spectator Object - Enter spectator mode with configured settings
    
    Description:
        Configures ACE Spectator based on module settings and opens spectator.
        Adds ESC key handler to exit spectator mode.
    
    Parameters:
        0: HASHMAP - Spectator settings from module
    
    Returns:
        Nothing
*/

params [["_settings", createHashMap, [createHashMap]]];

if (!hasInterface) exitWith {};

private _debug = _settings get "enableDebug";

if (_debug) then {
    diag_log "[RECONDO_SPECTATOR] Entering spectator mode...";
};

// === CONFIGURE CAMERA MODES ===
// Modes: 0=Free, 1=First Person, 2=Third Person
private _addModes = [];
private _removeModes = [];

if (_settings get "allowFreeCam") then {
    _addModes pushBack 0;
} else {
    _removeModes pushBack 0;
};

if (_settings get "allowFirstPerson") then {
    _addModes pushBack 1;
} else {
    _removeModes pushBack 1;
};

if (_settings get "allowThirdPerson") then {
    _addModes pushBack 2;
} else {
    _removeModes pushBack 2;
};

[_addModes, _removeModes] call ace_spectator_fnc_updateCameraModes;

if (_debug) then {
    diag_log format ["[RECONDO_SPECTATOR] Camera modes - Add: %1, Remove: %2", _addModes, _removeModes];
};

// === CONFIGURE VISION MODES ===
// -2=NVG, -1=Normal, 0-7=Thermal modes
private _addVision = [];
private _removeVision = [];

// Always allow normal vision
_addVision pushBack -1;

if (_settings get "allowNVG") then {
    _addVision pushBack -2;
} else {
    _removeVision pushBack -2;
};

if (_settings get "allowThermal") then {
    // Add thermal modes 0-7
    _addVision append [0, 1, 2, 3, 4, 5, 6, 7];
} else {
    // Remove thermal modes
    _removeVision append [0, 1, 2, 3, 4, 5, 6, 7];
};

[_addVision, _removeVision] call ace_spectator_fnc_updateVisionModes;

if (_debug) then {
    diag_log format ["[RECONDO_SPECTATOR] Vision modes - Add: %1, Remove: %2", _addVision, _removeVision];
};

// === CONFIGURE SIDES ===
// Sides: 0=EAST, 1=WEST, 2=INDEPENDENT, 3=CIVILIAN
if (_settings get "restrictToOwnSide") then {
    // Only allow viewing player's own side
    private _playerSide = side player;
    private _sideNum = switch (_playerSide) do {
        case east: { 0 };
        case west: { 1 };
        case independent: { 2 };
        case civilian: { 3 };
        default { 1 };  // Default to WEST
    };
    
    // Add player's side, remove all others
    private _allSides = [0, 1, 2, 3];
    private _removeSides = _allSides - [_sideNum];
    
    [[_sideNum], _removeSides] call ace_spectator_fnc_updateSides;
    
    if (_debug) then {
        diag_log format ["[RECONDO_SPECTATOR] Side restriction - Player side: %1 (%2)", _playerSide, _sideNum];
    };
} else {
    // Allow all sides
    [[0, 1, 2, 3], []] call ace_spectator_fnc_updateSides;
    
    if (_debug) then {
        diag_log "[RECONDO_SPECTATOR] Side restriction - All sides allowed";
    };
};

// === CONFIGURE UNITS ===
if (_settings get "playersOnly") then {
    // Only show player-controlled units
    // Get all players and set them as the only spectatable units
    private _allPlayers = allPlayers - [player];
    
    // If side restricted, filter to player's side
    if (_settings get "restrictToOwnSide") then {
        private _playerSide = side player;
        _allPlayers = _allPlayers select { side _x == _playerSide };
    };
    
    // Update spectatable units - add players, remove everyone else (empty array = use whitelist mode)
    [_allPlayers, []] call ace_spectator_fnc_updateUnits;
    
    if (_debug) then {
        diag_log format ["[RECONDO_SPECTATOR] Players only - %1 units available", count _allPlayers];
    };
};

// === OPEN SPECTATOR ===
// Parameters: [isSpectator, forceInterface]
[true, true] call ace_spectator_fnc_setSpectator;

// === ADD ESC KEY HANDLER TO EXIT ===
// Wait for spectator display to be created, then add key handler
[{
    !isNull (uiNamespace getVariable ["ace_spectator_display", displayNull])
}, {
    params ["_debug"];
    
    private _display = uiNamespace getVariable ["ace_spectator_display", displayNull];
    
    if (!isNull _display) then {
        // Add keydown handler for ESC (key code 1)
        _display displayAddEventHandler ["KeyDown", {
            params ["_display", "_key", "_shift", "_ctrl", "_alt"];
            
            // ESC key = 1
            if (_key == 1) then {
                // Exit spectator mode
                [false] call ace_spectator_fnc_setSpectator;
                true  // Consume the key event
            } else {
                false  // Don't consume other keys
            };
        }];
        
        if (_debug) then {
            diag_log "[RECONDO_SPECTATOR] ESC key handler added to exit spectator";
        };
    };
}, [_debug], 5] call CBA_fnc_waitUntilAndExecute;

if (_debug) then {
    diag_log "[RECONDO_SPECTATOR] Spectator mode opened";
};
