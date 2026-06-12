/*
    Recondo_fnc_teleportToOutpost
    Teleports a player to an outpost with fade, sound, and grid display
    
    Description:
        Performs teleportation with visual effects:
        1. Fade to black (2 seconds)
        2. Play sound
        3. Move player to outpost position
        4. Fade from black (2 seconds)
        5. Show destination name and 8-digit grid
    
    Parameters:
        _player - OBJECT - The player to teleport
        _outpostData - HASHMAP - Outpost data containing position, displayName, etc.
    
    Returns:
        Nothing
    
    Execution: Client only (local to player)
*/

params [
    ["_player", objNull, [objNull]],
    ["_outpostData", createHashMap, [createHashMap]]
];

if (isNull _player || count _outpostData == 0) exitWith {
    diag_log "[RECONDO_OUTPOSTTELE] ERROR: Invalid player or outpost data for teleport";
};

private _destPos = _outpostData get "position";
private _displayName = _outpostData get "displayName";

if (isNil "_destPos" || _destPos isEqualTo [0,0,0]) exitWith {
    hint "Error: Invalid outpost position!";
    diag_log format ["[RECONDO_OUTPOSTTELE] ERROR: Invalid destination position for outpost: %1", _displayName];
};

// ========================================
// TELEPORT SEQUENCE
// ========================================

// Play sound immediately
playSoundUI ["Transition1", 1];

// Start fade to black
"dynamicBlur" ppEffectEnable true;
"dynamicBlur" ppEffectAdjust [6];
"dynamicBlur" ppEffectCommit 0.5;

// Wait for blur, then fade to black
[{
    params ["_player", "_destPos", "_displayName"];
    
    // Full black screen
    cutText ["", "BLACK OUT", 2];
    
    // Wait for black, then teleport
    [{
        params ["_player", "_destPos", "_displayName"];
        
        // Perform teleport
        _player setPosATL [_destPos select 0, _destPos select 1, 0];
        
        // Clear blur
        "dynamicBlur" ppEffectAdjust [0];
        "dynamicBlur" ppEffectCommit 0.5;
        
        // Wait a moment, then fade back in
        [{
            params ["_displayName", "_destPos"];
            
            // Fade in from black
            cutText ["", "BLACK IN", 2];
            
            // Get proper grid reference using Arma's built-in function
            private _gridRef = mapGridPosition _destPos;
            private _gridDigits = (_gridRef splitString " ") joinString "";
            
            // Split normalized grid digits into easting/northing halves
            private _gridLen = count _gridDigits;
            private _halfLen = floor (_gridLen / 2);
            private _digitsPerHalf = (4 min _halfLen) max 1;
            
            // Use up to 4 digits per half (8-digit when available)
            private _eastingGrid = _gridDigits select [0, _digitsPerHalf];
            private _northingGrid = _gridDigits select [_halfLen, _digitsPerHalf];
            
            // Show arrival message after fade in completes
            [{
                params ["_displayName", "_eastingGrid", "_northingGrid"];
                
                hint format ["Arrived at %1\nGrid: %2 %3", _displayName, _eastingGrid, _northingGrid];
                
            }, [_displayName, _eastingGrid, _northingGrid], 2] call CBA_fnc_waitAndExecute;
            
        }, [_displayName, _destPos], 0.5] call CBA_fnc_waitAndExecute;
        
    }, [_player, _destPos, _displayName], 2] call CBA_fnc_waitAndExecute;
    
}, [_player, _destPos, _displayName], 0.5] call CBA_fnc_waitAndExecute;

diag_log format ["[RECONDO_OUTPOSTTELE] Player %1 teleporting to outpost: %2", name _player, _displayName];
