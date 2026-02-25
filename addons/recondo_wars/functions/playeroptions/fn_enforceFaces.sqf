/*
    Recondo_fnc_enforceFaces
    Forces specific faces on players using specific unit classnames
    
    Description:
        Checks if player's unit classname is in the list of units
        that should have forced faces. If so, applies a random face
        from the configured list. Periodically re-checks to enforce.
    
    Parameters:
        None (uses global RECONDO_PLAYEROPTIONS_SETTINGS)
        
    Returns:
        Nothing
*/

if (!hasInterface) exitWith {};

private _settings = RECONDO_PLAYEROPTIONS_SETTINGS;
private _debug = _settings get "enableDebug";

private _forcedFaceUnits = _settings get "forcedFaceUnitsArray";
private _forcedFaceList = _settings get "forcedFaceListArray";
private _checkInterval = _settings get "faceCheckInterval";

// Validate configuration
if (count _forcedFaceUnits == 0 || count _forcedFaceList == 0) exitWith {
    if (_debug) then {
        diag_log "[RECONDO_PLAYEROPTIONS] Forced faces disabled - no units or faces configured";
    };
};

// Function to check if player should have forced face
RECONDO_PO_fnc_shouldHaveForcedFace = {
    private _unitClass = typeOf player;
    private _forcedUnits = (RECONDO_PLAYEROPTIONS_SETTINGS get "forcedFaceUnitsArray");
    _unitClass in _forcedUnits
};

// Function to apply a random face from the list
RECONDO_PO_fnc_applyForcedFace = {
    private _faceList = (RECONDO_PLAYEROPTIONS_SETTINGS get "forcedFaceListArray");
    private _currentFace = face player;
    
    if (!(_currentFace in _faceList)) then {
        private _randomFace = selectRandom _faceList;
        [player, _randomFace] remoteExec ["setFace", 0, true];
        
        if (RECONDO_PLAYEROPTIONS_SETTINGS get "enableDebug") then {
            diag_log format ["[RECONDO_PLAYEROPTIONS] Applied face %1 to player (was: %2)", _randomFace, _currentFace];
        };
    };
};

// Function to check and enforce face
RECONDO_PO_fnc_checkAndEnforceFace = {
    if (call RECONDO_PO_fnc_shouldHaveForcedFace) then {
        call RECONDO_PO_fnc_applyForcedFace;
    };
};

// Wait for player initialization
[{!isNull player && {alive player}}, {
    params ["_checkInterval", "_debug"];
    
    // Delay initial check slightly
    [{
        // Initial check
        call RECONDO_PO_fnc_checkAndEnforceFace;
        
        if (_this select 1) then {
            diag_log "[RECONDO_PLAYEROPTIONS] Initial face check complete";
        };
    }, [_checkInterval, _debug], 1] call CBA_fnc_waitAndExecute;
    
    // Periodic check loop
    RECONDO_PO_FACE_HANDLER = [{
        call RECONDO_PO_fnc_checkAndEnforceFace;
    }, _checkInterval, []] call CBA_fnc_addPerFrameHandler;
    
    // Re-apply on respawn
    player addEventHandler ["Respawn", {
        [{
            call RECONDO_PO_fnc_checkAndEnforceFace;
        }, [], 1] call CBA_fnc_waitAndExecute;
    }];
    
}, [_checkInterval, _debug]] call CBA_fnc_waitUntilAndExecute;

if (_debug) then {
    diag_log format ["[RECONDO_PLAYEROPTIONS] Face enforcement initialized. Units: %1, Faces: %2, Interval: %3s", 
        count _forcedFaceUnits, count _forcedFaceList, _checkInterval];
};
