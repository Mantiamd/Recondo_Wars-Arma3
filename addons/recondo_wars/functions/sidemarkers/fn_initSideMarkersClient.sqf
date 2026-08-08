/*
    Recondo_fnc_initSideMarkersClient
    Creates OPFOR Side Markers locally on clients of the viewing side

    Description:
        Called on every client (JIP-safe remoteExec). Waits for the module
        config broadcast and a valid player unit, then - ONLY if the player
        belongs to the configured viewing side - starts a loop that diffs
        the broadcast position list against locally created markers and
        creates the missing ones with createMarkerLocal.

        Players of other sides never create anything: the markers exist
        purely locally on qualifying machines, so there is nothing for
        BLUFOR to see or intercept.

    Parameters:
        None

    Returns:
        Nothing
*/

if (!hasInterface) exitWith {};

[{
    !isNil "RECONDO_SIDEMARKERS_CONFIG" && {!isNull player}
}, {
    if (!isNil "RECONDO_SIDEMARKERS_CLIENT_STARTED") exitWith {};
    RECONDO_SIDEMARKERS_CLIENT_STARTED = true;

    private _cfg = RECONDO_SIDEMARKERS_CONFIG;

    private _viewSide = switch (_cfg getOrDefault ["viewSide", "EAST"]) do {
        case "WEST": { west };
        case "GUER": { independent };
        default { east };
    };

    // playerSide is constant for the mission (unlike side player, it also
    // survives death), so a one-time check is enough
    if (playerSide != _viewSide) exitWith {
        if (RECONDO_MASTER_DEBUG) then {
            diag_log format ["[RECONDO_SIDEMARKERS] Client: player side %1 does not match viewing side %2 - no markers", playerSide, _viewSide];
        };
    };

    RECONDO_SIDEMARKERS_CREATED = [];

    [{
        if (isNil "RECONDO_SIDEMARKERS_DATA") exitWith {};

        private _cfg = RECONDO_SIDEMARKERS_CONFIG;
        {
            _x params ["_uid", "_pos", "_label"];
            if !(_uid in RECONDO_SIDEMARKERS_CREATED) then {
                RECONDO_SIDEMARKERS_CREATED pushBack _uid;

                private _mkr = createMarkerLocal [format ["RECONDO_SM_%1", _uid], _pos];
                _mkr setMarkerShapeLocal "ICON";
                _mkr setMarkerTypeLocal (_cfg getOrDefault ["markerType", "o_unknown"]);
                _mkr setMarkerColorLocal (_cfg getOrDefault ["markerColor", "ColorGreen"]);
                if (_cfg getOrDefault ["showLabels", true]) then {
                    _mkr setMarkerTextLocal _label;
                };
            };
        } forEach RECONDO_SIDEMARKERS_DATA;
    }, 10, []] call CBA_fnc_addPerFrameHandler;

    diag_log format ["[RECONDO_SIDEMARKERS] Client: side marker display active for %1", _viewSide];
}, []] call CBA_fnc_waitUntilAndExecute;
