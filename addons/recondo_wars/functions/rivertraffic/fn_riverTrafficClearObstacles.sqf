/*
    Recondo_fnc_riverTrafficClearObstacles
    Hides bank vegetation along one river's marker path.

    Description:
        Server-side. Trees/bushes growing into the channel snag boats and break
        the path-following engine. This clears vegetation within a radius of each
        point on a single river's path. It is driven by the map-agnostic marker
        data, so it works on any map with no baked coordinates.

        Called lazily by the scan loop the first time a boat spawns on a given
        river (tracked in RECONDO_RIVERTRAFFIC_CLEANED), mirroring SOG AI's
        jboy_riversCleaned pattern. hideObjectGlobal / enableSimulationGlobal
        reach all clients and are JIP-safe on a dedicated server.

    Parameters:
        0: _positions - ARRAY - the river's ordered path points
        1: _radius    - NUMBER - clear radius around each point (m)
*/

if (!isServer) exitWith {};

params [["_positions", [], [[]]], ["_radius", 8, [0]]];

if (_positions isEqualTo []) exitWith {};

private _cleared = 0;
{
    {
        _x hideObjectGlobal true;
        _x enableSimulationGlobal false;
        _cleared = _cleared + 1;
    } forEach (nearestTerrainObjects [_x, ["Tree", "Bush"], _radius]);
} forEach _positions;

diag_log format ["[RECONDO_RIVERTRAFFIC] Cleared %1 bank obstacles along %2 path points (radius %3m).", _cleared, count _positions, _radius];
