/*
    Recondo_fnc_initSoilSampleClient
    Client-side: Adds ACE self-action for collecting soil samples

    Description:
        Adds an ACE self-interaction that appears when the player
        has the required item and is near a road.
        Runs on each client.
*/

if (!hasInterface) exitWith {};

private _settings = missionNamespace getVariable ["RECONDO_SOIL_SETTINGS", nil];
if (isNil "_settings") exitWith {
    [{!isNil {missionNamespace getVariable "RECONDO_SOIL_SETTINGS"}}, {
        [] call Recondo_fnc_initSoilSampleClient;
    }, []] call CBA_fnc_waitUntilAndExecute;
};

private _action = [
    "RECONDO_CollectSoilSample",
    "Collect Soil Sample",
    "\a3\ui_f\data\igui\cfg\simpletasks\types\search_ca.paa",
    {
        [] call Recondo_fnc_collectSoilSample;
    },
    {
        private _settings = missionNamespace getVariable ["RECONDO_SOIL_SETTINGS", nil];
        if (isNil "_settings") exitWith { false };

        private _requiredItem = _settings get "requiredItem";
        private _roadDistance = _settings get "roadDistance";
        private _cooldownSeconds = _settings get "cooldownSeconds";
        private _markerPrefix = _settings get "markerPrefix";
        private _markerAreas = _settings get "markerAreas";

        // Must have required item
        private _hasItem = [player, _requiredItem] call BIS_fnc_hasItem;
        if (!_hasItem) exitWith { false };

        // Must not be in a vehicle
        if !(isNull objectParent player) exitWith { false };

        // Must be near a road
        private _roads = (getPosATL player) nearRoads _roadDistance;
        if (count _roads == 0) exitWith { false };

        // Check cooldown (-99999 default so first collection is always allowed)
        private _lastCollect = player getVariable ["RECONDO_SOIL_LastCollect", -99999];
        if (time - _lastCollect < _cooldownSeconds) exitWith { false };

        // Check marker area restriction (if configured)
        if (_markerPrefix != "" && count _markerAreas > 0) then {
            private _inArea = false;
            private _playerPos = getPosATL player;
            {
                if (_playerPos inArea _x) exitWith { _inArea = true; };
            } forEach _markerAreas;
            _inArea
        } else {
            true
        };
    }
] call ace_interact_menu_fnc_createAction;

["Man", 1, ["ACE_SelfActions"], _action, true] call ace_interact_menu_fnc_addActionToClass;

private _debugLogging = _settings getOrDefault ["debugLogging", false];
if (_debugLogging) then {
    diag_log "[RECONDO_SOIL] Client: ACE self-action initialized";
};
