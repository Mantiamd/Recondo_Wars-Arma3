/*
    Recondo_fnc_dropStabo
    Deploys the STABO rope from a helicopter
    
    Description:
        Server-side function that creates the rope and anchor objects.
        Uses a hidden helper vehicle (Helicopter_Base_F) as the physics
        anchor for reliable rope attachment, and a visible anchor object
        for player interaction.
        
    Parameters:
        0: OBJECT - Helicopter to deploy STABO from
        
    Returns:
        Nothing
        
    Example:
        [_helicopter] call Recondo_fnc_dropStabo;
*/

params ["_helicopter"];

// Only execute on server
if (!isServer) exitWith {
    [_helicopter] remoteExec ["Recondo_fnc_dropStabo", 2];
};

// Check if already deployed
if (_helicopter getVariable ["RECONDO_STABO_Deployed", false]) exitWith {
    diag_log "[RECONDO_STABO] STABO already deployed on this helicopter";
};

// Get settings
private _settings = _helicopter getVariable ["RECONDO_STABO_Settings", RECONDO_STABO_SETTINGS];
if (isNil "_settings") exitWith {
    diag_log "[RECONDO_STABO] ERROR: No settings found for helicopter";
};

private _anchorClassname = _settings get "anchorClassname";
private _ropeLength = _settings get "ropeLength";
private _breakDistance = _settings get "breakDistance";
private _attachDistance = _settings get "attachDistance";
private _maxAttachments = _settings get "maxAttachments";
private _detachDistance = _settings get "detachDistance";
private _debug = _settings get "enableDebug";

// Set deployed state
_helicopter setVariable ["RECONDO_STABO_Deployed", true, true];

// Initialize attached units tracking
// Array of [unit, harness, rope, isBodybag] entries
_helicopter setVariable ["RECONDO_STABO_AttachedUnits", [], true];

// Get position below helicopter
private _pos = getPosATL _helicopter;
_pos set [2, 0];

// Create hidden helper vehicle as physics anchor (guaranteed rope support)
private _helper = "Recondo_STABO_Helper" createVehicle _pos;
[_helper, true] remoteExec ["hideObjectGlobal", 2];
_helper setVariable ["RECONDO_STABO_Helicopter", _helicopter, true];
_helicopter setVariable ["RECONDO_STABO_Helper", _helper, true];

// NOTE: Visible anchor is created AFTER helper lands to prevent "teleport" on dedicated servers

if (_debug) then {
    diag_log format ["[RECONDO_STABO] Created helper at %1, waiting for landing to create visible anchor", _pos];
};

// Create rope connecting helicopter to helper
private _rope = ropeCreate [
    _helicopter,
    [0, 0, -1],
    _helper,
    [0, 0, 0],
    _ropeLength
];

_helicopter setVariable ["RECONDO_STABO_Rope", _rope, true];

if (_debug) then {
    diag_log format ["[RECONDO_STABO] Created rope, length: %1m", _ropeLength];
};

// Wait for helper to reach ground, then set up interactions
[
    {
        params ["_helper"];
        (getPosATL _helper select 2) <= 0.5
    },
    {
        params ["_helper", "_anchorClassname", "_helicopter", "_settings"];
        
        private _attachDistance = _settings get "attachDistance";
        private _breakDistance = _settings get "breakDistance";
        private _maxAttachments = _settings get "maxAttachments";
        private _detachDistance = _settings get "detachDistance";
        private _debug = _settings get "enableDebug";
        
        // Store the grounded position
        private _groundedPos = getPosATL _helper;
        _helicopter setVariable ["RECONDO_STABO_AnchorPos", _groundedPos, true];
        
        // NOW create the visible anchor at the correct grounded position
        // This prevents the "teleport" effect on dedicated servers
        private _visibleAnchor = _anchorClassname createVehicle _groundedPos;
        _visibleAnchor setPosATL _groundedPos;
        _visibleAnchor setVariable ["RECONDO_STABO_Helicopter", _helicopter, true];
        _helicopter setVariable ["RECONDO_STABO_Anchor", _visibleAnchor, true];
        
        // Disable simulation on visible anchor globally (it's just for visuals)
        _visibleAnchor enableSimulationGlobal false;
        
        if (_debug) then {
            diag_log format ["[RECONDO_STABO] Anchor created and grounded at %1", _groundedPos];
        };
        
        // Add ACE interaction to visible anchor for players to attach (on all clients including JIP)
        // Use netId for proper object serialization on dedicated servers
        private _anchorNetId = netId _visibleAnchor;
        [_anchorNetId, _attachDistance, _maxAttachments] remoteExec ["Recondo_fnc_addStaboAnchorAction", 0, true];
        
        if (_debug) then {
            diag_log format ["[RECONDO_STABO] Broadcasting anchor action to clients (netId: %1)", _anchorNetId];
        };
        
        // Start monitoring rope distance and attached units on server
        [
            [_helicopter, _helper, _visibleAnchor, _groundedPos, _breakDistance, _detachDistance, _debug],
            {
                params ["_heli", "_helper", "_visAnchor", "_groundedPos", "_breakDist", "_detachDist", "_debug"];
                
                while {
                    alive _heli &&
                    (_heli getVariable ["RECONDO_STABO_Deployed", false]) &&
                    !isNull (_heli getVariable ["RECONDO_STABO_Rope", objNull])
                } do {
                    // Keep helper at grounded position (prevents drift)
                    if (!isNull _helper && {_helper distance _groundedPos > 0.3}) then {
                        _helper setPosATL _groundedPos;
                    };
                    
                    // Check if helicopter too far from anchor
                    if (_heli distance _groundedPos >= _breakDist) then {
                        if (_debug) then {
                            diag_log format ["[RECONDO_STABO] Break distance exceeded (%1m), raising STABO", round (_heli distance _groundedPos)];
                        };
                        [_heli] call Recondo_fnc_raiseStabo;
                    } else {
                        // Monitor attached units - detach if too far from anchor
                        private _attached = _heli getVariable ["RECONDO_STABO_AttachedUnits", []];
                        private _toRemove = [];
                        
                        {
                            _x params ["_unit", "_harness", "_unitRope", "_isBodybag"];
                            
                            // Check if unit still exists
                            if (isNull _unit) then {
                                _toRemove pushBack _forEachIndex;
                                if (!isNull _unitRope) then { ropeDestroy _unitRope };
                                if (!isNull _harness) then { deleteVehicle _harness };
                            } else {
                                // Check distance from grounded position
                                if (_unit distance _groundedPos > _detachDist) then {
                                    _toRemove pushBack _forEachIndex;
                                    
                                    // Destroy the rope and harness
                                    if (!isNull _unitRope) then { ropeDestroy _unitRope };
                                    if (!isNull _harness) then { deleteVehicle _harness };
                                    
                                    // Clear attached variable on unit
                                    _unit setVariable ["RECONDO_STABO_AttachedTo", nil, true];
                                    _unit setVariable ["RECONDO_STABO_Harness", nil, true];
                                    
                                    if (_debug) then {
                                        diag_log format ["[RECONDO_STABO] Unit %1 detached (too far: %2m)", _unit, round (_unit distance _groundedPos)];
                                    };
                                    
                                    // Notify player if applicable
                                    if (isPlayer _unit) then {
                                        ["Detached from STABO - moved too far"] remoteExec ["hint", _unit];
                                    };
                                };
                            };
                        } forEach _attached;
                        
                        // Remove detached units (iterate backwards to preserve indices)
                        if (count _toRemove > 0) then {
                            reverse _toRemove;
                            { _attached deleteAt _x } forEach _toRemove;
                            _heli setVariable ["RECONDO_STABO_AttachedUnits", _attached, true];
                        };
                    };
                    
                    sleep 0.5;
                };
            }
        ] remoteExec ["spawn", 2];
        
    },
    [_helper, _anchorClassname, _helicopter, _settings]
] call CBA_fnc_waitUntilAndExecute;
