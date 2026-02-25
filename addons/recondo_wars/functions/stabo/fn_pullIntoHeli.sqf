/*
    Recondo_fnc_pullIntoHeli
    Pulls all hanging units into helicopter cargo
    
    Description:
        Server-side function that:
        1. Moves all hanging players/unconscious units into helicopter cargo
        2. Deletes all bodybags (simulating secured)
        3. Destroys hanging ropes and harnesses
        4. Re-enables player movement
        5. Resets helicopter state for next STABO operation
        
        Units are boarded one at a time with 1.5 second gaps to prevent
        seat conflicts when multiple players try to board simultaneously.
        
    Parameters:
        0: OBJECT - Helicopter to pull units into
        
    Returns:
        Nothing
        
    Example:
        [_helicopter] call Recondo_fnc_pullIntoHeli;
*/

params ["_helicopter"];

// Only execute on server
if (!isServer) exitWith {
    [_helicopter] remoteExec ["Recondo_fnc_pullIntoHeli", 2];
};

// Check if helicopter is alive and in hanging state
if (!alive _helicopter) exitWith {
    diag_log "[RECONDO_STABO] Cannot pull into destroyed helicopter";
};

if !(_helicopter getVariable ["RECONDO_STABO_Hanging", false]) exitWith {
    diag_log "[RECONDO_STABO] Helicopter not in hanging state";
};

private _settings = _helicopter getVariable ["RECONDO_STABO_Settings", RECONDO_STABO_SETTINGS];
private _debug = if (!isNil "_settings") then { _settings getOrDefault ["enableDebug", false] } else { false };

// Get all hanging units
private _hangingUnits = _helicopter getVariable ["RECONDO_STABO_HangingUnits", []];

if (_debug) then {
    diag_log format ["[RECONDO_STABO] Pulling %1 hanging units into helicopter", count _hangingUnits];
};

// ============================================
// Separate bodybags from live units
// Bodybags can be processed immediately, live units need staggered boarding
// ============================================

private _liveUnits = [];
private _bodybagCount = 0;

{
    _x params ["_unit", "_harness", "_unitRope", "_isBodybag", "_offset"];
    
    if (_isBodybag) then {
        // Process bodybags immediately - no seat conflict issues
        
        // Destroy the hanging rope
        if (!isNull _unitRope) then {
            ropeDestroy _unitRope;
        };
        
        // Delete the harness object
        if (!isNull _harness) then {
            deleteVehicle _harness;
        };
        
        // Delete bodybag (simulating it being secured in helicopter)
        if (!isNull _unit) then {
            deleteVehicle _unit;
            _bodybagCount = _bodybagCount + 1;
            
            if (_debug) then {
                diag_log "[RECONDO_STABO] Bodybag secured and deleted";
            };
        };
    } else {
        // Queue live units for staggered boarding
        _liveUnits pushBack _x;
    };
} forEach _hangingUnits;

// ============================================
// Process live units with staggered delays
// Keep PFH running until all units are boarded
// ============================================

private _totalLiveUnits = count _liveUnits;
private _boardingDelay = 1.5; // Seconds between each unit boarding

if (_totalLiveUnits == 0) then {
    // No live units - just do cleanup immediately
    [_helicopter, _debug, 0, _bodybagCount] call Recondo_fnc_pullIntoHeli_cleanup;
} else {
    // Process each live unit with staggered timing
    {
        _x params ["_unit", "_harness", "_unitRope", "_isBodybag", "_offset"];
        
        private _delay = _forEachIndex * _boardingDelay;
        private _isLast = (_forEachIndex == (_totalLiveUnits - 1));
        
        [
            {
                params ["_unit", "_harness", "_unitRope", "_helicopter", "_debug", "_isLast", "_totalLiveUnits", "_bodybagCount"];
                
                // Verify helicopter is still alive
                if (!alive _helicopter) exitWith {
                    if (_debug) then {
                        diag_log "[RECONDO_STABO] Helicopter destroyed during boarding sequence";
                    };
                };
                
                // Destroy the hanging rope for this unit
                if (!isNull _unitRope) then {
                    ropeDestroy _unitRope;
                };
                
                // Delete the harness object
                if (!isNull _harness) then {
                    deleteVehicle _harness;
                };
                
                // Clear hanging variables
                if (!isNull _unit) then {
                    _unit setVariable ["RECONDO_STABO_IsHanging", false, true];
                    _unit setVariable ["RECONDO_STABO_HangingOffset", nil, true];
                    _unit setVariable ["RECONDO_STABO_HangingHeli", nil, true];
                    _unit setVariable ["RECONDO_STABO_AttachedTo", nil, true];
                    _unit setVariable ["RECONDO_STABO_Harness", nil, true];
                    _unit setVariable ["RECONDO_STABO_AttachRope", nil, true];
                };
                
                // Move player/unit into helicopter cargo
                if (!isNull _unit && alive _unit) then {
                    // Delay invincibility removal by 10 seconds after entering cargo
                    // This protects against any residual damage from the extraction process
                    if (_unit getVariable ["RECONDO_STABO_Invincible", false]) then {
                        [{
                            params ["_unit", "_debug"];
                            if (isNull _unit) exitWith {};
                            if (_unit getVariable ["RECONDO_STABO_Invincible", false]) then {
                                [_unit, true] remoteExec ["allowDamage", _unit];
                                _unit setVariable ["RECONDO_STABO_Invincible", false, true];
                                
                                if (_debug) then {
                                    diag_log format ["[RECONDO_STABO] Removed invincibility from %1 (10s delay)", _unit];
                                };
                            };
                        }, [_unit, _debug], 10] call CBA_fnc_waitAndExecute;
                    };
                    
                    // Unblock movement for players
                    if (isPlayer _unit) then {
                        if (!isNil "ace_common_fnc_statusEffect_set") then {
                            [_unit, "blockMovement", "RECONDO_STABO", false] remoteExec ["ace_common_fnc_statusEffect_set", _unit];
                        };
                    };
                    
                    // Check if there's space in cargo
                    private _emptyPositions = _helicopter emptyPositions "cargo";
                    
                    if (_emptyPositions > 0) then {
                        // Move unit to cargo (execute where unit is local)
                        [_unit, _helicopter] remoteExec ["moveInCargo", _unit];
                        
                        if (_debug) then {
                            diag_log format ["[RECONDO_STABO] Moved %1 into helicopter cargo", _unit];
                        };
                        
                        // Notify player
                        if (isPlayer _unit) then {
                            ["Pulled into helicopter - extraction complete!"] remoteExec ["hint", _unit];
                        };
                    } else {
                        // No space - place unit on ground below helicopter
                        private _groundPos = getPosATL _helicopter;
                        _groundPos set [2, 0];
                        _unit setPosATL _groundPos;
                        
                        if (_debug) then {
                            diag_log format ["[RECONDO_STABO] No cargo space for %1, placed on ground", _unit];
                        };
                        
                        if (isPlayer _unit) then {
                            ["No cargo space - placed on ground"] remoteExec ["hint", _unit];
                        };
                    };
                };
                
                // If this is the last unit, do final cleanup
                if (_isLast) then {
                    [_helicopter, _debug, _totalLiveUnits, _bodybagCount] call Recondo_fnc_pullIntoHeli_cleanup;
                };
            },
            [_unit, _harness, _unitRope, _helicopter, _debug, _isLast, _totalLiveUnits, _bodybagCount],
            _delay
        ] call CBA_fnc_waitAndExecute;
        
        if (_debug) then {
            diag_log format ["[RECONDO_STABO] Scheduled %1 for boarding in %2 seconds (isLast: %3)", _unit, _delay, _isLast];
        };
        
    } forEach _liveUnits;
};

// ============================================
// Cleanup function (called after last unit boards)
// ============================================

Recondo_fnc_pullIntoHeli_cleanup = {
    params ["_helicopter", "_debug", "_movedCount", "_bodybagCount"];
    
    // Stop the position tracking PFH
    private _pfhId = _helicopter getVariable ["RECONDO_STABO_PositionPFH", -1];
    if (_pfhId >= 0) then {
        [_pfhId] call CBA_fnc_removePerFrameHandler;
        if (_debug) then {
            diag_log "[RECONDO_STABO] Position tracking PFH stopped";
        };
    };
    
    // Clear hanging units list
    _helicopter setVariable ["RECONDO_STABO_HangingUnits", [], true];
    
    // Destroy main hanging rope
    private _hangingRope = _helicopter getVariable ["RECONDO_STABO_HangingRope", objNull];
    if (!isNull _hangingRope) then {
        ropeDestroy _hangingRope;
        if (_debug) then {
            diag_log "[RECONDO_STABO] Hanging rope destroyed";
        };
    };
    
    // Delete hanging helper
    private _hangingHelper = _helicopter getVariable ["RECONDO_STABO_HangingHelper", objNull];
    if (!isNull _hangingHelper) then {
        deleteVehicle _hangingHelper;
        if (_debug) then {
            diag_log "[RECONDO_STABO] Hanging helper deleted";
        };
    };
    
    // Remove death event handler
    private _deathEH = _helicopter getVariable ["RECONDO_STABO_DeathEH", -1];
    if (_deathEH >= 0) then {
        _helicopter removeEventHandler ["Killed", _deathEH];
    };
    
    // Reset helicopter state - ready for next STABO operation
    _helicopter setVariable ["RECONDO_STABO_Hanging", false, true];
    _helicopter setVariable ["RECONDO_STABO_Deployed", false, true];
    _helicopter setVariable ["RECONDO_STABO_HangingRope", nil, true];
    _helicopter setVariable ["RECONDO_STABO_HangingHelper", nil, true];
    _helicopter setVariable ["RECONDO_STABO_DeathEH", nil, true];
    _helicopter setVariable ["RECONDO_STABO_PositionPFH", -1, true];
    
    if (_debug) then {
        diag_log format ["[RECONDO_STABO] Pull-up complete. Extracted %1 units, secured %2 bodybags", _movedCount, _bodybagCount];
    };
    
    // Log summary
    diag_log format ["[RECONDO_STABO] Pull-up on %1 complete. Extracted: %2, Bodybags: %3", 
        typeOf _helicopter, _movedCount, _bodybagCount];
};
