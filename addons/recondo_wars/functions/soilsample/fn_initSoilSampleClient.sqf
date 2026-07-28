/*
    Recondo_fnc_initSoilSampleClient
    Client-side: Adds ACE self-action for collecting soil samples

    Description:
        Adds an ACE self-interaction that appears when the player
        has the required item and is near a road.
        Runs on each client.
*/

if (!hasInterface) exitWith {};

// Guard against double-add (e.g., broadcast fired both live and via JIP queue)
if (missionNamespace getVariable ["RECONDO_SOIL_CLIENT_INIT", false]) exitWith {};

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

        // Must have required item (magazine-safe; cheap enough for a menu condition)
        if !(_requiredItem in (itemsWithMagazines player)) exitWith { false };

        // Must not be in a vehicle
        if !(isNull objectParent player) exitWith { false };

        // Must be on or near a road/trail. isOnRoad catches being on the road
        // surface regardless of how sparsely road segment centers are spaced.
        private _onRoad = isOnRoad player;
        if (!_onRoad) then { _onRoad = count ((getPosATL player) nearRoads _roadDistance) > 0; };
        if (!_onRoad) exitWith { false };

        // Check cooldown (-99999 default so first collection is always allowed)
        private _lastCollect = player getVariable ["RECONDO_SOIL_LastCollect", -99999];
        if (time - _lastCollect < _cooldownSeconds) exitWith { false };

        // Check marker area restriction (if configured).
        // Entries are [markerName, [center, sizeX, sizeZ, angle, isRectangle]].
        if (_markerPrefix != "" && count _markerAreas > 0) then {
            private _inArea = false;
            private _playerPos = getPosATL player;
            {
                if (_playerPos inArea (_x select 1)) exitWith { _inArea = true; };
            } forEach _markerAreas;
            _inArea
        } else {
            true
        };
    }
] call ace_interact_menu_fnc_createAction;

["Man", 1, ["ACE_SelfActions"], _action, true] call ace_interact_menu_fnc_addActionToClass;

RECONDO_SOIL_CLIENT_INIT = true;

private _debugLogging = _settings getOrDefault ["debugLogging", false];
if (_debugLogging) then {
    diag_log "[RECONDO_SOIL] Client: ACE self-action initialized";
};
