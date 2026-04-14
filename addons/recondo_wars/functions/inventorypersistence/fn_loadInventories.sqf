/*
    Recondo_fnc_loadInventories
    Load and restore cargo contents on tracked containers

    Description:
        Waits for containers to register, then clears default
        inventory and repopulates from saved data. Uses Global
        command variants for dedicated server compatibility.
*/

if (!isServer) exitWith {};

private _savedData = ["INVENTORY_PERSIST_DATA", []] call Recondo_fnc_getSaveData;

if (count _savedData == 0) exitWith {
    diag_log "[RECONDO_INVPERSIST] No saved inventory data found.";
};

private _debug = RECONDO_INVENTORY_PERSISTENCE_DEBUG;

[{
    count RECONDO_INVENTORY_PERSISTENCE_CONTAINERS > 0 || time > 30
}, {
    params ["_savedData", "_debug"];

    {
        private _entry = _x;
        private _savedID = _entry get "id";
        private _savedWeapons = _entry getOrDefault ["weapons", []];
        private _savedMagazines = _entry getOrDefault ["magazines", []];
        private _savedItems = _entry getOrDefault ["items", []];
        private _savedBackpacks = _entry getOrDefault ["backpacks", []];

        private _container = objNull;
        {
            if ((_x getVariable ["RECONDO_InventoryID", ""]) == _savedID) exitWith {
                _container = _x;
            };
        } forEach RECONDO_INVENTORY_PERSISTENCE_CONTAINERS;

        if (isNull _container || !alive _container) then {
            if (_debug) then {
                diag_log format ["[RECONDO_INVPERSIST] Container %1 not found or destroyed. Skipping.", _savedID];
            };
            continue;
        };

        clearWeaponCargoGlobal _container;
        clearMagazineCargoGlobal _container;
        clearItemCargoGlobal _container;
        clearBackpackCargoGlobal _container;

        if (count _savedWeapons >= 2) then {
            private _classes = _savedWeapons select 0;
            private _counts = _savedWeapons select 1;
            {
                _container addWeaponCargoGlobal [_x, _counts select _forEachIndex];
            } forEach _classes;
        };

        if (count _savedMagazines >= 2) then {
            private _classes = _savedMagazines select 0;
            private _counts = _savedMagazines select 1;
            {
                _container addMagazineCargoGlobal [_x, _counts select _forEachIndex];
            } forEach _classes;
        };

        if (count _savedItems >= 2) then {
            private _classes = _savedItems select 0;
            private _counts = _savedItems select 1;
            {
                _container addItemCargoGlobal [_x, _counts select _forEachIndex];
            } forEach _classes;
        };

        if (count _savedBackpacks >= 2) then {
            private _classes = _savedBackpacks select 0;
            private _counts = _savedBackpacks select 1;
            {
                _container addBackpackCargoGlobal [_x, _counts select _forEachIndex];
            } forEach _classes;
        };

        if (_debug) then {
            diag_log format ["[RECONDO_INVPERSIST] Restored inventory for %1 (%2)", _savedID, typeOf _container];
        };

    } forEach _savedData;

    diag_log format ["[RECONDO_INVPERSIST] Load complete. %1 container entries.", count _savedData];

}, [_savedData, _debug], 30] call CBA_fnc_waitUntilAndExecute;
