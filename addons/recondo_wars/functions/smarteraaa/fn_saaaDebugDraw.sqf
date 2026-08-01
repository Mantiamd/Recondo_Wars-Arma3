/*
    Recondo_fnc_saaaDebugDraw
    Dev visualization - one local map marker per managed gun

    Description:
        The arrow shows the turret's ACTUAL weapon bearing (weaponDirection),
        not the target bearing - so the map is ground truth: you can watch
        doWatch slew the turret, and vanilla residual aiming shows honestly.
        White = IDLE, yellow = PREPPED, orange = BLINDFIRE, pink = AIMEDFIRE,
        red = ENGAGING, black = OFF (A/B vanilla).
        Markers are LOCAL to the machine running the script (the server), so
        they are only visible in SP/hosted testing - not to clients of a
        dedicated server. Rebuilt every tick, cheap at dev scale.

    Parameters:
        None

    Returns:
        Nothing
*/

{ deleteMarkerLocal _x } forEach RECONDO_SAAA_DBG_MARKERS;
RECONDO_SAAA_DBG_MARKERS = [];

{
    private _gun = _x;
    private _state = _gun getVariable ["RECONDO_SAAA_state", "IDLE"];
    private _target = _gun getVariable ["RECONDO_SAAA_target", objNull];

    // Actual turret bearing from the gunner turret's first weapon
    private _brg = getDir _gun;
    private _wpn = (_gun weaponsTurret [0]) param [0, ""];
    if (_wpn != "") then {
        private _vec = _gun weaponDirection _wpn;
        _brg = (_vec select 0) atan2 (_vec select 1);
        if (_brg < 0) then { _brg = _brg + 360 };
    };

    private _mk = createMarkerLocal [format ["RECONDO_SAAA_dbg_%1", _forEachIndex], getPos _gun];
    _mk setMarkerTypeLocal "mil_arrow";
    _mk setMarkerSizeLocal [0.8, 0.8];
    _mk setMarkerDirLocal _brg;
    _mk setMarkerColorLocal (
        switch (_state) do {
            case "PREPPED":   { "ColorYellow" };
            case "BLINDFIRE": { "ColorOrange" };  // sound-directed fire through canopy
            case "AIMEDFIRE": { "ColorPink" };    // visible target, engine unwilling
            case "ENGAGING":  { "ColorRed" };
            case "OFF":       { "ColorBlack" };   // A/B toggle: vanilla behavior
            default           { "ColorWhite" };
        }
    );

    if (isNull _target) then {
        _mk setMarkerTextLocal _state;
    } else {
        // Why-silent gate flags: L = crew line of sight (canSee, from prep tick),
        // E = inside the engine AI's real willingness range, V = turret can elevate
        private _dist = _gun distance _target;
        private _seenVar = _gun getVariable "RECONDO_SAAA_dbgSeen";
        private _l = if (isNil "_seenVar") then { "?" } else { ["-", "+"] select _seenVar };
        private _e = ["-", "+"] select
            (_dist <= (([_gun] call Recondo_fnc_saaaEngineMaxRange) * RECONDO_SAAA_WILLING_FACTOR));
        private _lims = RECONDO_SAAA_ELEV_CACHE getOrDefault [typeOf _gun, [-20, 40]];
        private _dz = ((getPosASL _target) select 2) - ((getPosASL _gun) select 2);
        private _elevNeeded = asin ((_dz / (_dist max 1)) max -1 min 1);
        private _v = ["-", "+"] select
            ((_elevNeeded <= (_lims select 1) - 2) && {_elevNeeded >= (_lims select 0) + 2});
        _mk setMarkerTextLocal format ["%1 %2m L%3 E%4 V%5", _state, round _dist, _l, _e, _v];
    };

    RECONDO_SAAA_DBG_MARKERS pushBack _mk;
} forEach RECONDO_SAAA_GUNS;
