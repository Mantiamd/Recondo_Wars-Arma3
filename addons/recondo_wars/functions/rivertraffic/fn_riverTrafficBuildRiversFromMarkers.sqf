/*
    Recondo_fnc_riverTrafficBuildRiversFromMarkers
    Builds river path data from invisible Eden markers (map-agnostic).

    Description:
        Replaces the old baked per-map coordinate tables. The mission designer
        places invisible markers (alpha 0) named:

            <prefix><riverId>_<NNN>

        where <prefix> is the module's configurable Marker Prefix (default
        "river_"), <NNN> is a zero-padded sequence index (>= 3 digits) giving
        travel order along the river, and <riverId> identifies one river. A
        <riverId> beginning with "big" enables larger boat classes. All markers
        sharing a <riverId> under the same prefix form one river. Boats spawn at
        a random end of the river and run straight through to the other end.

        Runs on the server (the module is server-only). Eden markers come from
        mission.sqm identically on every machine, so reading them here is
        deterministic and JIP / save-load safe with no publicVariable and no
        runtime marker deletion.

    Parameters:
        0: _prefix - STRING - marker name prefix to match (e.g. "river_")

    Returns:
        Array of rivers, each [riverId, positions]. Empty if no valid rivers.
        Also sets RECONDO_RIVERTRAFFIC_SUPPORTED true if any river was built.
*/

params [["_prefix", "river_", [""]]];

if (_prefix == "") exitWith {
    diag_log "[RECONDO_RIVERTRAFFIC] Empty marker prefix; no rivers built.";
    []
};

private _prefixLen = count _prefix;

// Group marker names by riverId (order preserved for later numeric sort).
private _byRiver = createHashMap;

{
    private _name = _x;
    // Only consider markers that start with the configured prefix.
    if ((_name find _prefix) == 0) then {
        // Everything after the prefix should be "<riverId>_<NNN>".
        private _rest = _name select [_prefixLen];
        private _parts = _rest splitString "_";
        if (count _parts >= 2) then {
            private _seq = _parts select ((count _parts) - 1);
            // riverId is everything before the trailing index, so ids may
            // themselves contain underscores.
            private _riverId = (_parts select [0, (count _parts) - 1]) joinString "_";
            private _list = _byRiver getOrDefault [_riverId, []];
            _list pushBack [parseNumber _seq, _name];
            _byRiver set [_riverId, _list];
        };
    };
} forEach allMapMarkers;

private _rivers = [];

{
    private _riverId = _x;
    private _entries = _byRiver get _riverId;

    // Order by the numeric sequence token so travel order is index 001 -> end.
    _entries sort true;

    // Each entry is [seqNumber, markerName]; take the ordered marker positions.
    private _positions = _entries apply { getMarkerPos (_x select 1) };

    // A route needs a start, an end, and at least one point between them.
    // (The old 11-marker floor came from the baked coordinate tables this
    // system replaced, where points were dense and short segments were noise;
    // with hand-placed markers, marker count says nothing about river length.)
    if (count _positions < 3) then {
        diag_log format ["[RECONDO_RIVERTRAFFIC] Skipping river '%1': only %2 markers (need >= 3).", _riverId, count _positions];
    } else {
        _rivers pushBack [_riverId, _positions];
    };
} forEach (keys _byRiver);

if (count _rivers > 0) then { RECONDO_RIVERTRAFFIC_SUPPORTED = true; };

diag_log format ["[RECONDO_RIVERTRAFFIC] Built %1 river(s) from markers with prefix '%2'.", count _rivers, _prefix];

_rivers
