/*
    Recondo_fnc_teleportToBase
    Teleports a player back to base with fade, sound, and grid display
    
    Description:
        Performs teleportation with visual effects:
        1. Fade to black (2 seconds)
        2. Play sound
        3. Move player to base teleporter position
        4. Fade from black (2 seconds)
        5. Show destination name and 6-digit grid
    
    Parameters:
        _player - OBJECT - The player to teleport
        _baseObject - OBJECT - The base teleporter object
        _settings - HASHMAP - Module settings (for return text)
    
    Returns:
        Nothing
    
    Execution: Client only (local to player)
*/

params [
    ["_player", objNull, [objNull]],
    ["_baseObject", objNull, [objNull]],
    ["_settings", createHashMap, [createHashMap]]
];

if (isNull _player || isNull _baseObject) exitWith {
    diag_log "[RECONDO_OUTPOSTTELE] ERROR: Invalid player or base object for return teleport";
};

private _destPos = getPosATL _baseObject;
private _returnText = _settings getOrDefault ["returnText", "Base"];

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
    params ["_player", "_destPos", "_returnText"];
    
    // Full black screen
    cutText ["", "BLACK OUT", 2];
    
    // Wait for black, then teleport
    [{
        params ["_player", "_destPos", "_returnText"];
        
        // Perform teleport (offset slightly from object)
        private _offset = [2, 2, 0];
        private _teleportPos = _destPos vectorAdd _offset;
        _player setPosATL [_teleportPos select 0, _teleportPos select 1, 0];
        
        // Clear blur
        "dynamicBlur" ppEffectAdjust [0];
        "dynamicBlur" ppEffectCommit 0.5;
        
        // Wait a moment, then fade back in
        [{
            params ["_returnText", "_destPos"];
            
            // Fade in from black
            cutText ["", "BLACK IN", 2];
            
            // Get proper grid reference using Arma's built-in function
            private _gridRef = mapGridPosition _destPos;
            
            // Split into easting and northing (grid string is half easting, half northing)
            private _gridLen = count _gridRef;
            private _halfLen = _gridLen / 2;
            
            // Take first 3 digits of each half for 6-digit grid reference
            private _eastingGrid = _gridRef select [0, 3];
            private _northingGrid = _gridRef select [_halfLen, 3];
            
            // Show arrival message after fade in completes
            [{
                params ["_returnText", "_eastingGrid", "_northingGrid"];
                
                hint format ["Returned to Base\nGrid: %1 %2", _eastingGrid, _northingGrid];
                
            }, [_returnText, _eastingGrid, _northingGrid], 2] call CBA_fnc_waitAndExecute;
            
        }, [_returnText, _destPos], 0.5] call CBA_fnc_waitAndExecute;
        
    }, [_player, _destPos, _returnText], 2] call CBA_fnc_waitAndExecute;
    
}, [_player, _destPos, _returnText], 0.5] call CBA_fnc_waitAndExecute;

diag_log format ["[RECONDO_OUTPOSTTELE] Player %1 returning to base", name _player];
