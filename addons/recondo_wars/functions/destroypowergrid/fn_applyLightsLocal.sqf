/*
    Recondo_fnc_applyLightsLocal
    Applies light state changes to all objects within radius on the local machine

    Description:
        Executed on every client (and server) via remoteExec with a
        JIP ticket so late joiners receive the correct light state.
        Searches both regular objects and terrain objects. Applies
        switchLight to all objects and setDamage to lamp-type objects
        as a fallback for lamps that don't respond to switchLight.

    Parameters:
        _pos - ARRAY - Center position
        _radius - NUMBER - Effect radius in meters
        _state - STRING - "OFF" or "ON"
        _additionalClassnames - ARRAY - Extra classnames to damage

    Execution:
        All machines (called via remoteExec from server)
*/

params [
    ["_pos", [0,0,0], [[]]],
    ["_radius", 300, [0]],
    ["_state", "OFF", [""]],
    ["_additionalClassnames", [], [[]]]
];

private _lampClasses = ["Lamps_Base_F", "PowerLines_base_F", "Land_PowerPoleWooden_L_F"];
_lampClasses append _additionalClassnames;

// Collect all objects: regular (Eden/scripted) + terrain (map-placed)
private _objects = nearestObjects [_pos, [], _radius];
_objects append (nearestTerrainObjects [_pos, [], _radius, false, true]);

// Apply switchLight to everything (harmless on objects without lights)
{ _x switchLight _state } forEach _objects;

// Fallback: setDamage on lamp-type objects for lamps that ignore switchLight
private _damageValue = if (_state == "OFF") then { 0.95 } else { 0 };
{
    private _obj = _x;
    {
        if (_obj isKindOf _x) exitWith {
            _obj setDamage _damageValue;
        };
    } forEach _lampClasses;
} forEach _objects;
