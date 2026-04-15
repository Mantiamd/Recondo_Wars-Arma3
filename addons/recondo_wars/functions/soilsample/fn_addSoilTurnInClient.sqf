/*
    Recondo_fnc_addSoilTurnInClient
    Client-side: Adds ACE turn-in action for soil samples on Intel turn-in objects

    Description:
        Adds "Turn In Soil Sample" ACE interaction to the specified object.
        Condition: player has the reward item AND has pending samples.

    Parameters:
        _object - OBJECT - The Intel turn-in object
        _instanceId - STRING - Soil sample instance ID
*/

if (!hasInterface) exitWith {};

params [
    ["_object", objNull, [objNull]],
    ["_instanceId", "", [""]]
];

if (isNull _object || _instanceId == "") exitWith {};

// Prevent duplicate actions
private _existingActions = _object getVariable ["Recondo_SOIL_TurnInActions", []];
if (_instanceId in _existingActions) exitWith {};

private _action = [
    format ["Recondo_SOIL_TurnIn_%1", _instanceId],
    "Turn In Soil Sample",
    "\a3\ui_f\data\igui\cfg\simpletasks\types\search_ca.paa",
    {
        params ["_target", "_player", "_params"];
        _params params ["_instanceId"];

        [_player] remoteExecCall ["Recondo_fnc_soilSampleTurnIn", 2];
    },
    {
        params ["_target", "_player", "_params"];

        private _settings = missionNamespace getVariable ["RECONDO_SOIL_SETTINGS", nil];
        if (isNil "_settings") exitWith { false };

        private _rewardItem = _settings get "rewardItem";

        // Must have the sample item
        if !([_player, _rewardItem] call BIS_fnc_hasItem) exitWith { false };

        // Must have pending samples to turn in
        private _pending = _player getVariable ["RECONDO_SOIL_PendingSamples", []];
        if (count _pending == 0) exitWith { false };

        // Check that not all objectives are complete
        private _turnedIn = missionNamespace getVariable ["RECONDO_SOIL_TURNED_IN", createHashMap];
        private _settings2 = missionNamespace getVariable ["RECONDO_SOIL_SETTINGS", nil];
        if (isNil "_settings2") exitWith { false };
        private _samplesRequired = _settings2 get "samplesRequired";

        private _anyIncomplete = false;
        {
            private _objData = _y;
            if !(_objData get "complete") exitWith { _anyIncomplete = true; };
        } forEach _turnedIn;

        _anyIncomplete
    },
    {},
    [_instanceId],
    [0, 0, 0],
    2,
    [false, false, false, false, false],
    {}
] call ace_interact_menu_fnc_createAction;

[_object, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;

_existingActions pushBack _instanceId;
_object setVariable ["Recondo_SOIL_TurnInActions", _existingActions, false];
