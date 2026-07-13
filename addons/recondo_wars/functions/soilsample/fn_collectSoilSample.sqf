/*
    Recondo_fnc_collectSoilSample
    Client-side: Performs the soil sample collection with ACE progress bar

    Description:
        Shows an ACE progress bar, then consumes the required item
        and gives the reward item. Sets cooldown timer on the player.
        Registers the collection with the server for objective tracking.
*/

if (!hasInterface) exitWith {};

private _settings = missionNamespace getVariable ["RECONDO_SOIL_SETTINGS", nil];
if (isNil "_settings") exitWith {};

private _requiredItem = _settings get "requiredItem";
private _rewardItem = _settings get "rewardItem";
private _collectDuration = _settings get "collectDuration";
private _cooldownSeconds = _settings get "cooldownSeconds";
private _markerPrefix = _settings get "markerPrefix";
private _markerAreas = _settings get "markerAreas";
private _debugLogging = _settings getOrDefault ["debugLogging", false];

// Final validation
if !(_requiredItem in (itemsWithMagazines player)) exitWith {
    hint "You don't have the required item.";
};

private _lastCollect = player getVariable ["RECONDO_SOIL_LastCollect", -99999];
if (time - _lastCollect < _cooldownSeconds) exitWith {
    private _remaining = round (_cooldownSeconds - (time - _lastCollect));
    hint format ["You must wait %1 seconds before collecting another sample.", _remaining];
};

// Determine which marker area the player is in (if applicable).
// Entries are [markerName, [center, sizeX, sizeZ, angle, isRectangle]].
private _collectionMarker = "__GLOBAL__";
if (_markerPrefix != "" && count _markerAreas > 0) then {
    private _playerPos = getPosATL player;
    {
        if (_playerPos inArea (_x select 1)) exitWith { _collectionMarker = _x select 0; };
    } forEach _markerAreas;
};

// ACE progress bar
[
    _collectDuration,
    [_requiredItem, _rewardItem, _cooldownSeconds, _debugLogging, _collectionMarker],
    {
        params ["_args"];
        _args params ["_requiredItem", "_rewardItem", "_cooldownSeconds", "_debugLogging", "_collectionMarker"];

        if !(_requiredItem in (itemsWithMagazines player)) exitWith {};

        private _isMag = isClass (configFile >> "CfgMagazines" >> _requiredItem);
        if (_isMag) then { player removeMagazine _requiredItem; } else { player removeItem _requiredItem; };

        private _rewardIsMag = isClass (configFile >> "CfgMagazines" >> _rewardItem);
        if (_rewardIsMag) then { player addMagazine _rewardItem; } else { player addItem _rewardItem; };
        player setVariable ["RECONDO_SOIL_LastCollect", time];

        // Register collection with server for objective tracking
        [getPlayerUID player, _collectionMarker] remoteExecCall ["Recondo_fnc_registerSoilCollection", 2];

        hint "Soil sample collected.";

        if (_debugLogging) then {
            diag_log format ["[RECONDO_SOIL] %1 collected soil sample at %2 (marker: %3)", name player, getPosATL player, _collectionMarker];
        };
    },
    {
        hint "Collection cancelled.";
    },
    "Collecting soil sample...",
    {
        private _requiredItem = (_this select 0) select 0;
        (_requiredItem in (itemsWithMagazines player)) && (isNull objectParent player)
    },
    ["isnotinside", "isnotswimming"]
] call ace_common_fnc_progressBar;

player playMoveNow "AinvPknlMstpSnonWnonDnon_medic_1";
