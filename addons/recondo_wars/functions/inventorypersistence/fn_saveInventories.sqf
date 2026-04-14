/*
    Recondo_fnc_saveInventories
    Save full cargo contents of tracked containers

    Description:
        For each registered container, snapshots weapons, magazines,
        items, and backpacks. Skips destroyed containers.
*/

if (!isServer) exitWith {};
if (count RECONDO_INVENTORY_PERSISTENCE_CONTAINERS == 0) exitWith {};

private _debug = RECONDO_INVENTORY_PERSISTENCE_DEBUG;
private _saveData = [];

{
    private _container = _x;
    private _containerID = _container getVariable ["RECONDO_InventoryID", ""];

    if (_containerID == "") then { continue };
    if (!alive _container) then { continue };

    private _weaponCargo = getWeaponCargo _container;
    private _magazineCargo = getMagazineCargo _container;
    private _itemCargo = getItemCargo _container;
    private _backpackCargo = getBackpackCargo _container;

    private _entry = createHashMapFromArray [
        ["id", _containerID],
        ["type", typeOf _container],
        ["weapons", _weaponCargo],
        ["magazines", _magazineCargo],
        ["items", _itemCargo],
        ["backpacks", _backpackCargo]
    ];

    _saveData pushBack _entry;

    if (_debug) then {
        private _totalItems = 0;
        if (count _weaponCargo > 1) then { { _totalItems = _totalItems + _x } forEach (_weaponCargo select 1) };
        if (count _magazineCargo > 1) then { { _totalItems = _totalItems + _x } forEach (_magazineCargo select 1) };
        if (count _itemCargo > 1) then { { _totalItems = _totalItems + _x } forEach (_itemCargo select 1) };
        if (count _backpackCargo > 1) then { { _totalItems = _totalItems + _x } forEach (_backpackCargo select 1) };
        diag_log format ["[RECONDO_INVPERSIST] Saved inventory for %1 (%2): %3 total items", _containerID, typeOf _container, _totalItems];
    };
} forEach RECONDO_INVENTORY_PERSISTENCE_CONTAINERS;

["INVENTORY_PERSIST_DATA", _saveData] call Recondo_fnc_setSaveData;

if (_debug) then {
    diag_log format ["[RECONDO_INVPERSIST] Save complete. %1 container inventories saved.", count _saveData];
};
