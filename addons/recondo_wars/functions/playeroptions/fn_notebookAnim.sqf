/*
    Recondo_fnc_notebookAnim
    Soft-dependency "reading" pose for the notebook, reusing TSP Animate's
    map gesture and an unfolded-map prop.

    Fired on every machine via CBA_fnc_globalEvent so nearby players see the
    pose. Simple objects are always local, so each machine plays the gesture
    on its own copy of the unit and owns its own prop. No-ops cleanly when TSP
    Animate is not loaded, leaving the notebook fully functional standalone.

    Params:
        _unit  - unit using the notebook
        _start - true to begin the pose, false to end it
*/

params [["_unit", objNull, [objNull]], ["_start", false, [false]]];

if (isNull _unit) exitWith {};

// Bail out unless TSP Animate's gesture engine and map states are present.
if (isNil "tsp_fnc_gesture_play" || {isNil "tsp_fnc_gesture_stop"}) exitWith {};
if !(isClass (configFile >> "CfgGesturesMale" >> "States" >> "tsp_animate_map_loop")) exitWith {};

if (_start) exitWith {
    // Upper-body map-reading pose (intro then looped hold). Interrupt + instant
    // so it shows immediately regardless of the unit's current gesture.
    [_unit, "tsp_animate_map_in", "tsp_animate_map_loop", "tsp_common_stop", true, true] spawn tsp_fnc_gesture_play;

    private _prop = createSimpleObject ["\A3\Structures_F\Items\Documents\Map_unfolded_F.p3d", [0, 0, 0], false];
    _unit setVariable ["Recondo_notebookProp", _prop];
    _prop attachTo [_unit, [-0.01, 0.01, -0.01], "leftHand", true];

    // tsp_fnc_rotate orients objects attached via attachTo (vanilla setDir won't).
    if (!isNil "tsp_fnc_rotate") then {
        [_prop, [50, 170, -90]] call tsp_fnc_rotate;
    };
};

// Stop path: end the looped gesture and remove this machine's prop.
[_unit] call tsp_fnc_gesture_stop;

private _prop = _unit getVariable ["Recondo_notebookProp", objNull];
if (!isNull _prop) then {
    detach _prop;
    deleteVehicle _prop;
};
_unit setVariable ["Recondo_notebookProp", objNull];
