/*
    File: fn_initPickupObject.sqf
    Author: TheDUDE / generated helper

    Initializes an editor-placeable RW object as a pickup. The matching
    CfgMagazines classname is read from the object's rw_inventoryClass
    config property.

    Parameter:
        0: OBJECT - physical CfgVehicles object
*/
params [
    ["_object", objNull, [objNull]]
];

if (isNull _object) exitWith {};

private _inventoryClass = getText (
    configFile >> "CfgVehicles" >> typeOf _object >> "rw_inventoryClass"
);

if (_inventoryClass isEqualTo "") exitWith {
    diag_log format [
        "[RW Objects] No rw_inventoryClass configured for %1",
        typeOf _object
    ];
};

// Prevent duplicate actions if an object's init event runs more than once locally.
if (_object getVariable ["rw_pickupActionInitialized", false]) exitWith {};
_object setVariable ["rw_pickupActionInitialized", true];

private _displayName = getText (
    configFile >> "CfgMagazines" >> _inventoryClass >> "displayName"
);

if (_displayName isEqualTo "") then {
    _displayName = _inventoryClass;
};

private _actionId = _object addAction [
    format ["Take %1", _displayName],
    {
        params ["_target", "_caller", "_actionId", "_arguments"];
        _arguments params ["_inventoryClass"];

        if (isNull _target || {!alive _caller}) exitWith {};

        if !(_caller canAdd _inventoryClass) exitWith {
            hint "Not enough inventory space.";
        };

        _caller addMagazine _inventoryClass;
        [_target] remoteExec ["deleteVehicle", 2];
    },
    [_inventoryClass],
    1.5,
    true,
    true,
    "",
    "alive _target && {_this distance _target <= 3}",
    3,
    false,
    "",
    ""
];

_object setVariable ["rw_pickupActionId", _actionId];
