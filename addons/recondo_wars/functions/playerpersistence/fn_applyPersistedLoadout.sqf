/*
    Recondo_fnc_applyPersistedLoadout
    Applies a persisted loadout on the owning client

    Description:
        Runs where the unit is local. Before applying, strips any baked ACRE
        radio IDs from the saved loadout via acre_api_fnc_filterUnitLoadout so
        ACRE assigns a FRESH unique id instead of honoring a literal baked id.
        Restoring baked ids (from getUnitLoadout) causes duplicate radio IDs
        and silent receive-death ("can hear some, not others"). Falls back to
        the raw loadout when ACRE isn't present, so non-ACRE missions are
        unaffected.

        Trade-off: a stripped radio returns on its default channel/preset,
        since the baked id was what persisted that radio state.

    Parameters:
        0: OBJECT - Unit to apply the loadout to
        1: ARRAY  - Saved loadout array (from getUnitLoadout)

    Returns:
        Nothing
*/

params [["_unit", objNull, [objNull]], ["_loadout", [], [[]]]];

if (isNull _unit) exitWith {};
if (_loadout isEqualTo []) exitWith {};

// Strip baked ACRE radio ids if ACRE is available (filter mutates in place,
// so pass a deep copy).
if (!isNil "acre_api_fnc_filterUnitLoadout") then {
    _loadout = [+_loadout] call acre_api_fnc_filterUnitLoadout;
};

_unit setUnitLoadout _loadout;
