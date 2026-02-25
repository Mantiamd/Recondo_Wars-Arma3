/*
    Recondo_fnc_enableCarryBodybags
    Player Options - Enable ACE body bag carrying and dragging
    
    Description:
        Makes ACE body bags carryable and draggable when created.
        Uses class event handler so it applies to all body bags automatically.
    
    Returns:
        Nothing
*/

if (!hasInterface) exitWith {};

private _settings = RECONDO_PLAYEROPTIONS_SETTINGS;
private _debug = _settings get "enableDebug";

// Add init handler to ACE body bag class
["ACE_bodyBagObject", "init", {
    params ["_bodyBag"];
    
    // Make body bag draggable
    // Parameters: [object, canDrag, dragPosition, direction]
    [_bodyBag, true, [0, 1.5, 0], 0] call ace_dragging_fnc_setDraggable;
    
    // Make body bag carryable
    // Parameters: [object, canCarry, carryPosition, direction]
    [_bodyBag, true, [0, 1, 1], 90] call ace_dragging_fnc_setCarryable;
    
}, true, [], true] call CBA_fnc_addClassEventHandler;

if (_debug) then {
    diag_log "[RECONDO_PLAYEROPTIONS] ACE body bag carry/drag enabled";
};
