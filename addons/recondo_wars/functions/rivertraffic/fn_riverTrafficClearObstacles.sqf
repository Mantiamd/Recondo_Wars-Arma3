/*
    Recondo_fnc_riverTrafficClearObstacles
    Hides bank vegetation that blocks river navigation.

    Description:
        Server-side, runs once. Several river bends on vnx_rssz have trees/bushes
        growing into the channel that snag boats and break the path-following
        engine. These clear spots (transcribed from SOG AI's JBOY river system)
        are cleared by hiding the offending vegetation globally and disabling its
        simulation. Uses hideObjectGlobal so the effect reaches all clients and
        is JIP-safe on a dedicated server.
*/

if (!isServer) exitWith {};

private _spots = [];

if (worldName == "vnx_rssz") then {
    _spots = [
        [5383.59,9576.38,-0.67556],[5406.3,9550.06,0.00152427],[15959.7,9014.09,-0.309025],
        [5743.76,9142.77,0],[5708.79,9113.85,0],[5609.65,9121.7,0],[15947.6,8937.35,-0.0722221],
        [5843.35,9069.31,0],[5798.81,9134.22,0],[5743.32,9142.3,0],[5710.12,9112.88,0],
        [4931.67,10965.1,-0.36188],[4941.56,10944.6,-1.72344],[4956.78,10916,-0.771839],
        [4966.92,10896.9,-1.3659],[6635.75,10637.3,-1.29789],[6408.82,10221.7,-1.16195],
        [6587.14,10117.6,-0.731338],[6260.28,10332.1,-0.330425],[6515.97,10153.9,-0.881685],
        [6418.06,10206.7,-1.28038],[6377.18,10226.7,-0.00422056],[6274,10460.3,-1.29158]
    ];
};

if (_spots isEqualTo []) exitWith {};

private _cleared = 0;
{
    {
        _x hideObjectGlobal true;
        _x enableSimulationGlobal false;
        _cleared = _cleared + 1;
    } forEach (nearestTerrainObjects [_x, ["Tree", "Bush"], 20]);
} forEach _spots;

diag_log format ["[RECONDO_RIVERTRAFFIC] Cleared %1 bank obstacles across %2 spots.", _cleared, count _spots];
