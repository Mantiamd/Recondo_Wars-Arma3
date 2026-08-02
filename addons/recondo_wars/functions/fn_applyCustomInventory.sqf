/*
    Recondo_fnc_applyCustomInventory
    Replaces an object's cargo with a user-defined list of classnames

    Description:
        Clears all cargo (weapons, magazines, items, backpacks) from the
        object and adds one of each classname in the list. Repeat a
        classname in the list to add multiple copies.

        Called on the server; uses the ...CargoGlobal commands so the
        result is synced to all clients including JIP.

        Does nothing when the classname list is empty, so target objects
        keep their default inventory unless the mission maker opts in.

    Parameters:
        0: OBJECT - Object whose inventory is replaced
        1: ARRAY  - Item classnames to add (strings)
        2: STRING - Log prefix for warnings (optional, default "RECONDO")

    Returns:
        Nothing

    Example:
        [_crate, ["vn_m16", "vn_m16_mag", "vn_m16_mag"], "RECONDO_OBJDESTROY"] call Recondo_fnc_applyCustomInventory;
*/

params [["_object", objNull, [objNull]], ["_classnames", [], [[]]], ["_logPrefix", "RECONDO", [""]]];

if (isNull _object || {_classnames isEqualTo []}) exitWith {};

clearWeaponCargoGlobal _object;
clearMagazineCargoGlobal _object;
clearItemCargoGlobal _object;
clearBackpackCargoGlobal _object;

private _added = 0;
{
    private _class = _x;
    // Resolves which config the classname lives in, so each entry can be
    // routed to the matching cargo command
    (_class call BIS_fnc_itemType) params ["_category", "_type"];

    switch (true) do {
        case (_category == "Weapon"): {
            _object addWeaponCargoGlobal [_class, 1];
            _added = _added + 1;
        };
        case (_category in ["Magazine", "Mine"]): {
            _object addMagazineCargoGlobal [_class, 1];
            _added = _added + 1;
        };
        case (_category == "Equipment" && {_type == "Backpack"}): {
            _object addBackpackCargoGlobal [_class, 1];
            _added = _added + 1;
        };
        case (_category != ""): {
            _object addItemCargoGlobal [_class, 1];
            _added = _added + 1;
        };
        default {
            diag_log format ["[%1] WARNING: Custom inventory classname '%2' not found in any config - skipped", _logPrefix, _class];
        };
    };
} forEach _classnames;

if (RECONDO_MASTER_DEBUG) then {
    diag_log format ["[%1] Replaced inventory of %2: %3 of %4 entries added", _logPrefix, typeOf _object, _added, count _classnames];
};
