/*
    Recondo_fnc_raiseStabo
    Raises the STABO rope and transitions to hanging phase
    
    Description:
        Server-side function that:
        1. Cleans up ground equipment (anchor, helper, ground ropes)
        2. Creates hanging rope from helicopter
        3. Positions all attached players/units below helicopter (3m start, 1m spacing)
        4. Players can look/aim freely but cannot walk while hanging
        5. Starts 30-second timer for auto pull-up into cargo
        6. Handles helicopter destruction (players fall)
        
    Parameters:
        0: OBJECT - Helicopter to raise STABO from
        
    Returns:
        Nothing
        
    Example:
        [_helicopter] call Recondo_fnc_raiseStabo;
*/

params ["_helicopter"];

// Only execute on server
if (!isServer) exitWith {
    [_helicopter] remoteExec ["Recondo_fnc_raiseStabo", 2];
};

private _settings = _helicopter getVariable ["RECONDO_STABO_Settings", RECONDO_STABO_SETTINGS];
private _debug = if (!isNil "_settings") then { _settings getOrDefault ["enableDebug", false] } else { false };

// Get all attached units from ground phase
private _attached = _helicopter getVariable ["RECONDO_STABO_AttachedUnits", []];

if (count _attached == 0) exitWith {
    // No one attached - just clean up and reset
    private _rope = _helicopter getVariable ["RECONDO_STABO_Rope", objNull];
    private _helper = _helicopter getVariable ["RECONDO_STABO_Helper", objNull];
    private _anchor = _helicopter getVariable ["RECONDO_STABO_Anchor", objNull];
    
    if (!isNull _rope) then { ropeDestroy _rope };
    if (!isNull _helper) then { deleteVehicle _helper };
    if (!isNull _anchor) then { deleteVehicle _anchor };
    
    _helicopter setVariable ["RECONDO_STABO_Deployed", false, true];
    _helicopter setVariable ["RECONDO_STABO_Rope", nil, true];
    _helicopter setVariable ["RECONDO_STABO_Helper", nil, true];
    _helicopter setVariable ["RECONDO_STABO_Anchor", nil, true];
    _helicopter setVariable ["RECONDO_STABO_AnchorPos", nil, true];
    
    if (_debug) then {
        diag_log "[RECONDO_STABO] No units attached, STABO retracted";
    };
};

if (_debug) then {
    diag_log format ["[RECONDO_STABO] Raising STABO with %1 attached units", count _attached];
};

// ============================================
// PHASE 1: Clean up ground equipment
// ============================================

// Destroy ground ropes and harnesses
{
    _x params ["_unit", "_harness", "_unitRope", "_isBodybag"];
    
    // Destroy the ground attachment rope
    if (!isNull _unitRope) then {
        ropeDestroy _unitRope;
    };
    
    // Keep the harness - we'll reuse it for hanging
    // But clear the old rope reference
    if (!isNull _unit) then {
        _unit setVariable ["RECONDO_STABO_AttachRope", nil, true];
    };
} forEach _attached;

// Destroy ground equipment
private _groundRope = _helicopter getVariable ["RECONDO_STABO_Rope", objNull];
private _groundHelper = _helicopter getVariable ["RECONDO_STABO_Helper", objNull];
private _groundAnchor = _helicopter getVariable ["RECONDO_STABO_Anchor", objNull];

if (!isNull _groundRope) then { ropeDestroy _groundRope };
if (!isNull _groundHelper) then { deleteVehicle _groundHelper };
if (!isNull _groundAnchor) then { deleteVehicle _groundAnchor };

_helicopter setVariable ["RECONDO_STABO_Rope", nil, true];
_helicopter setVariable ["RECONDO_STABO_Helper", nil, true];
_helicopter setVariable ["RECONDO_STABO_Anchor", nil, true];
_helicopter setVariable ["RECONDO_STABO_AnchorPos", nil, true];

if (_debug) then {
    diag_log "[RECONDO_STABO] Ground equipment cleaned up";
};

// ============================================
// PHASE 2: Create hanging system
// ============================================

// Set helicopter to hanging state
_helicopter setVariable ["RECONDO_STABO_Hanging", true, true];

// Create a new helper vehicle attached to helicopter for rope physics
private _hangingHelper = "Recondo_STABO_Helper" createVehicle (getPosATL _helicopter);
_hangingHelper attachTo [_helicopter, [0, 0, -1]];
[_hangingHelper, true] remoteExec ["hideObjectGlobal", 2];
_helicopter setVariable ["RECONDO_STABO_HangingHelper", _hangingHelper, true];

// Calculate total rope length needed (3m start + 1m per additional unit + 2m buffer)
private _totalUnits = count _attached;
private _ropeLength = 3 + _totalUnits + 2; // First at 3m, then +1m each, plus buffer

// Create main visual hanging rope
private _hangingRope = ropeCreate [
    _helicopter,
    [0, 0, -1],
    _ropeLength
];
_helicopter setVariable ["RECONDO_STABO_HangingRope", _hangingRope, true];

if (_debug) then {
    diag_log format ["[RECONDO_STABO] Created hanging rope, length: %1m for %2 units", _ropeLength, _totalUnits];
};

// ============================================
// PHASE 3: Position units below helicopter
// ============================================

private _hangingUnits = [];
private _positionIndex = 3; // First unit at 3m below helicopter

{
    _x params ["_unit", "_harness", "_oldRope", "_isBodybag"];
    
    if (isNull _unit) then { continue };
    
    // Calculate offset below helicopter (first attached = 3m, then 4m, 5m, etc.)
    private _offset = [0, 0, -_positionIndex];
    
    // Store hanging position for this unit
    _unit setVariable ["RECONDO_STABO_HangingOffset", _offset, true];
    _unit setVariable ["RECONDO_STABO_IsHanging", true, true];
    _unit setVariable ["RECONDO_STABO_HangingHeli", _helicopter, true];
    
    // Make unit invincible while hanging (prevents damage during extraction)
    // allowDamage has local argument - must execute where unit is local
    [_unit, false] remoteExec ["allowDamage", _unit];
    _unit setVariable ["RECONDO_STABO_Invincible", true, true];
    
    if (_debug) then {
        diag_log format ["[RECONDO_STABO] Made %1 invincible for extraction", _unit];
    };
    
    // Set initial position (don't use attachTo - we'll use PFH for free rotation)
    private _heliPos = getPosASL _helicopter;
    private _unitPos = [_heliPos select 0, _heliPos select 1, (_heliPos select 2) + (_offset select 2)];
    _unit setPosASL _unitPos;
    
    // Create individual rope from helper to harness for visual effect
    private _unitRope = objNull;
    if (!isNull _harness) then {
        // Reattach harness to unit (it may have been disrupted)
        _harness attachTo [_unit, [0, 0, 0], "pelvis"];
        
        _unitRope = ropeCreate [
            _hangingHelper,
            [0, 0, 0],
            _harness,
            [0, 0, 0],
            _positionIndex + 1 // Rope length to reach this unit
        ];
    };
    
    // Block movement for players (not AI/bodybags) but allow aiming
    if (isPlayer _unit && !_isBodybag) then {
        // Use ACE if available to block walking
        if (!isNil "ace_common_fnc_statusEffect_set") then {
            [_unit, "blockMovement", "RECONDO_STABO", true] remoteExec ["ace_common_fnc_statusEffect_set", _unit];
        };
        
        // Notify player
        ["Hanging below helicopter - extraction in 30 seconds"] remoteExec ["hint", _unit];
    };
    
    // Store updated entry [unit, harness, rope, isBodybag, offset]
    _hangingUnits pushBack [_unit, _harness, _unitRope, _isBodybag, _offset];
    
    if (_debug) then {
        diag_log format ["[RECONDO_STABO] Positioned %1 at offset %2 (position %3m below)", 
            if (_isBodybag) then {"bodybag"} else {str _unit}, _offset, _positionIndex];
    };
    
    _positionIndex = _positionIndex + 1;
} forEach _attached;

// Update attached units list with hanging data
_helicopter setVariable ["RECONDO_STABO_HangingUnits", _hangingUnits, true];
_helicopter setVariable ["RECONDO_STABO_AttachedUnits", [], true]; // Clear ground list

if (_debug) then {
    diag_log format ["[RECONDO_STABO] %1 units now hanging below helicopter", count _hangingUnits];
};

// ============================================
// PHASE 3.5: Start Per-Frame Handler for position tracking
// ============================================
// This allows players to rotate/aim freely while following helicopter movement

private _pfhId = [
    {
        params ["_args", "_handle"];
        _args params ["_heli", "_dbg"];
        
        // Stop if helicopter dead or not in hanging state
        if (!alive _heli || !(_heli getVariable ["RECONDO_STABO_Hanging", false])) exitWith {
            [_handle] call CBA_fnc_removePerFrameHandler;
            if (_dbg) then {
                diag_log "[RECONDO_STABO] Position tracking PFH stopped";
            };
        };
        
        private _hangingUnits = _heli getVariable ["RECONDO_STABO_HangingUnits", []];
        private _heliPosASL = getPosASL _heli;
        
        {
            _x params ["_unit", "_harness", "_unitRope", "_isBodybag", "_offset"];
            
            if (isNull _unit) then { continue };
            if (!(_unit getVariable ["RECONDO_STABO_IsHanging", false])) then { continue };
            
            // Calculate new position based on helicopter position + offset
            private _newPos = [
                _heliPosASL select 0,
                _heliPosASL select 1,
                (_heliPosASL select 2) + (_offset select 2)
            ];
            
            // Update unit position (setPosASL allows unit to keep their rotation)
            _unit setPosASL _newPos;
            
        } forEach _hangingUnits;
    },
    0.05, // Run every 0.05 seconds (20 FPS) for smooth movement
    [_helicopter, _debug]
] call CBA_fnc_addPerFrameHandler;

_helicopter setVariable ["RECONDO_STABO_PositionPFH", _pfhId, true];

if (_debug) then {
    diag_log format ["[RECONDO_STABO] Position tracking PFH started (ID: %1)", _pfhId];
};

// ============================================
// PHASE 4: Add helicopter destroyed handler
// ============================================

private _deathEH = _helicopter addEventHandler ["Killed", {
    params ["_vehicle", "_killer", "_instigator", "_useEffects"];
    
    private _hangingUnits = _vehicle getVariable ["RECONDO_STABO_HangingUnits", []];
    private _debug = _vehicle getVariable ["RECONDO_STABO_Debug", false];
    
    if (_debug) then {
        diag_log format ["[RECONDO_STABO] Helicopter destroyed with %1 hanging units!", count _hangingUnits];
    };
    
    // Stop the position tracking PFH
    private _pfhId = _vehicle getVariable ["RECONDO_STABO_PositionPFH", -1];
    if (_pfhId >= 0) then {
        [_pfhId] call CBA_fnc_removePerFrameHandler;
    };
    
    // Detach all hanging units - they will fall
    {
        _x params ["_unit", "_harness", "_unitRope", "_isBodybag", "_offset"];
        
        if (!isNull _unit) then {
            // Destroy rope
            if (!isNull _unitRope) then { ropeDestroy _unitRope };
            
            // Delete harness
            if (!isNull _harness) then { deleteVehicle _harness };
            
            // Clear variables
            _unit setVariable ["RECONDO_STABO_IsHanging", false, true];
            _unit setVariable ["RECONDO_STABO_HangingOffset", nil, true];
            _unit setVariable ["RECONDO_STABO_HangingHeli", nil, true];
            _unit setVariable ["RECONDO_STABO_AttachedTo", nil, true];
            _unit setVariable ["RECONDO_STABO_Harness", nil, true];
            
            // Remove invincibility - unit will now take fall damage
            if (_unit getVariable ["RECONDO_STABO_Invincible", false]) then {
                [_unit, true] remoteExec ["allowDamage", _unit];
                _unit setVariable ["RECONDO_STABO_Invincible", false, true];
            };
            
            // Unblock movement for players
            if (isPlayer _unit && !_isBodybag) then {
                if (!isNil "ace_common_fnc_statusEffect_set") then {
                    [_unit, "blockMovement", "RECONDO_STABO", false] remoteExec ["ace_common_fnc_statusEffect_set", _unit];
                };
                ["Helicopter destroyed - falling!"] remoteExec ["hint", _unit];
            };
        };
    } forEach _hangingUnits;
    
    // Clean up helicopter variables
    _vehicle setVariable ["RECONDO_STABO_HangingUnits", [], true];
    _vehicle setVariable ["RECONDO_STABO_Hanging", false, true];
    _vehicle setVariable ["RECONDO_STABO_PositionPFH", -1, true];
    
    // Destroy hanging rope
    private _hangingRope = _vehicle getVariable ["RECONDO_STABO_HangingRope", objNull];
    if (!isNull _hangingRope) then { ropeDestroy _hangingRope };
    
    // Delete hanging helper
    private _hangingHelper = _vehicle getVariable ["RECONDO_STABO_HangingHelper", objNull];
    if (!isNull _hangingHelper) then { deleteVehicle _hangingHelper };
}];

_helicopter setVariable ["RECONDO_STABO_DeathEH", _deathEH, true];

// ============================================
// PHASE 5: Start 30-second countdown
// ============================================

if (_debug) then {
    diag_log "[RECONDO_STABO] Starting 30-second countdown for auto pull-up";
};

// Schedule automatic pull into helicopter after 30 seconds
[
    {
        params ["_heli"];
        
        // Check if still in hanging state
        if !(_heli getVariable ["RECONDO_STABO_Hanging", false]) exitWith {};
        if (!alive _heli) exitWith {};
        
        // Pull everyone into helicopter
        [_heli] call Recondo_fnc_pullIntoHeli;
    },
    [_helicopter],
    30
] call CBA_fnc_waitAndExecute;

// Log summary
diag_log format ["[RECONDO_STABO] STABO raised on %1. %2 units hanging, auto pull-up in 30 seconds", 
    typeOf _helicopter, count _hangingUnits];
