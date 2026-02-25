/*
    Recondo_fnc_handleDecoyTriggerActivation
    Handles activation of decoy location trigger
    
    Description:
        Called when players enter the decoy trigger radius.
        Spawns composition and optionally AI based on chance.
    
    Parameters:
        _trigger - OBJECT - The activated trigger
        _settings - HASHMAP - Module settings
        _marker - STRING - Location marker name
        _composition - STRING - Composition name
        _isModPath - BOOL - True to load composition from mod folder
    
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [
    ["_trigger", objNull, [objNull]],
    ["_settings", nil, [createHashMap]],
    ["_marker", "", [""]],
    ["_composition", "", [""]],
    ["_isModPath", true, [false]]
];

if (isNull _trigger || isNil "_settings" || _marker == "") exitWith {
    diag_log "[RECONDO_HVT] ERROR: Invalid parameters for handleDecoyTriggerActivation";
};

private _debugLogging = _settings get "debugLogging";
private _decoyAIChance = _settings get "decoyAIChance";

if (_debugLogging) then {
    diag_log format ["[RECONDO_HVT] Decoy trigger activated at %1", _marker];
};

// Delete the trigger
deleteVehicle _trigger;

// Spawn composition
[_settings, _marker, _composition, false, _isModPath] call Recondo_fnc_spawnHVTComposition;

// Get position
private _pos = getMarkerPos _marker;

// Roll for decoy AI spawn
if (random 1 < _decoyAIChance) then {
    if (_debugLogging) then {
        diag_log format ["[RECONDO_HVT] Decoy AI spawn chance succeeded at %1", _marker];
    };
    
    // Spawn garrison AI after composition has time to spawn
    [{
        params ["_settings", "_marker", "_pos"];
        [_settings, _marker, _pos] call Recondo_fnc_spawnHVTAI;
    }, [_settings, _marker, _pos], 5] call CBA_fnc_waitAndExecute;
    
    // Spawn roving sentry if enabled
    if (_settings get "enableRovingSentry") then {
        [{
            params ["_settings", "_marker", "_pos"];
            [_settings, _marker, _pos] call Recondo_fnc_spawnHVTRovingSentry;
        }, [_settings, _marker, _pos], 6] call CBA_fnc_waitAndExecute;
    };
} else {
    if (_debugLogging) then {
        diag_log format ["[RECONDO_HVT] Decoy AI spawn chance failed at %1 (chance: %2)", _marker, _decoyAIChance];
    };
};

// Spawn civilians if enabled (same chance mechanic as HVT location)
if (_settings get "enableCivilians") then {
    [{
        params ["_settings", "_marker", "_pos"];
        [_settings, _marker, _pos] call Recondo_fnc_spawnHVTCivilians;
    }, [_settings, _marker, _pos], 6] call CBA_fnc_waitAndExecute;
};

// Spawn animals if enabled
if (_settings get "enableAnimals") then {
    [{
        params ["_settings", "_marker", "_pos"];
        [_settings, _marker, _pos] call Recondo_fnc_spawnHVTAnimals;
    }, [_settings, _marker, _pos], 6] call CBA_fnc_waitAndExecute;
};
