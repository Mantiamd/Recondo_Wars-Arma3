/*
    Recondo_fnc_spawnHostageComposition
    Spawns composition and hostages at a location (immediate mode)
    
    Description:
        Used for immediate spawn mode. Spawns the composition,
        garrison AI, and hostages at the specified location.
    
    Parameters:
        _settings - HASHMAP - Module settings
        _marker - STRING - Location marker name
        _composition - STRING - Composition name to spawn
        _hostagesAtMarker - ARRAY - Array of [hostageIndex, hostageName] for this location
        _isModPath - BOOL - True to load composition from mod folder
    
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [
    ["_settings", nil, [createHashMap]],
    ["_marker", "", [""]],
    ["_composition", "", [""]],
    ["_hostagesAtMarker", [], [[]]],
    ["_isModPath", true, [false]]
];

if (isNil "_settings" || _marker == "") exitWith {
    diag_log "[RECONDO_HOSTAGE] ERROR: Invalid parameters for spawnHostageComposition";
};

private _debugLogging = _settings get "debugLogging";
private _markerPos = getMarkerPos _marker;

if (_debugLogging) then {
    diag_log format ["[RECONDO_HOSTAGE] Spawning hostage composition at %1 (immediate mode, isModPath: %2)", _marker, _isModPath];
};

// Spawn composition (reuse HVT composition spawner)
[_settings, _marker, _composition, true, _isModPath] call Recondo_fnc_spawnHVTComposition;

// Register buildings for night lights after composition spawns
private _enableNightLights = _settings get "enableNightLights";
if (_enableNightLights) then {
    [{
        params ["_markerPos", "_debugLogging"];
        
        // Find buildings near the marker position
        private _nearObjects = nearestObjects [_markerPos, [], 50];
        private _buildingsFound = 0;
        
        {
            // Check if object is a building (not a unit or vehicle)
            if (!(_x isKindOf "CAManBase") && !(_x isKindOf "LandVehicle") && !(_x isKindOf "Air") && !(_x isKindOf "Ship")) then {
                // Check if object has any building positions
                private _testPos = _x buildingPos 0;
                if !(_testPos isEqualTo [0,0,0]) then {
                    // This object has building positions - register it for night lights
                    if !(_x in RECONDO_HOSTAGE_NIGHT_LIGHT_BUILDINGS) then {
                        RECONDO_HOSTAGE_NIGHT_LIGHT_BUILDINGS pushBack _x;
                        _buildingsFound = _buildingsFound + 1;
                    };
                };
            };
        } forEach _nearObjects;
        
        if (_debugLogging && _buildingsFound > 0) then {
            diag_log format ["[RECONDO_HOSTAGE] Registered %1 buildings for night lights", _buildingsFound];
        };
    }, [_markerPos, _debugLogging], 2] call CBA_fnc_waitAndExecute;
};

// Spawn garrison AI after a short delay (reuse HVT AI spawner)
[{
    params ["_settings", "_marker", "_pos"];
    [_settings, _marker, _pos] call Recondo_fnc_spawnHVTAI;
}, [_settings, _marker, _markerPos], 3] call CBA_fnc_waitAndExecute;

// Spawn hostages after composition is set up
[{
    params ["_settings", "_marker", "_pos", "_hostagesAtMarker"];
    [_settings, _marker, _pos, _hostagesAtMarker] call Recondo_fnc_spawnHostages;
}, [_settings, _marker, _markerPos, _hostagesAtMarker], 5] call CBA_fnc_waitAndExecute;

// Spawn bad civis at real locations
if ((_settings getOrDefault ["badCiviMax", 0]) > 0) then {
    [{
        params ["_settings", "_marker", "_pos"];
        [_settings, _marker, _pos] call Recondo_fnc_spawnBadCivis;
    }, [_settings, _marker, _markerPos], 5] call CBA_fnc_waitAndExecute;
};

// Spawn civilians if enabled
if (_settings get "enableCivilians") then {
    [{
        params ["_settings", "_marker", "_pos"];
        [_settings, _marker, _pos] call Recondo_fnc_spawnHVTCivilians;
    }, [_settings, _marker, _markerPos], 6] call CBA_fnc_waitAndExecute;
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_HOSTAGE] Queued composition, AI, and %1 hostages at %2", count _hostagesAtMarker, _marker];
};
