/*
    Recondo_fnc_outpostQRFLoad
    Server-side: spawns garrison-type AI into helicopter cargo

    Parameters:
        _helo - OBJECT - The helicopter to load units into
*/

if (!isServer) exitWith {};

params [["_helo", objNull, [objNull]]];

if (isNull _helo || !alive _helo) exitWith {};

if (_helo getVariable ["RECONDO_OUTPOST_QRF_LOADED", false]) exitWith {};

private _qrfSettings = _helo getVariable ["RECONDO_OUTPOST_QRF_SETTINGS", nil];
if (isNil "_qrfSettings") exitWith {
    diag_log "[RECONDO_OUTPOST] ERROR: QRF Load called on helicopter with no QRF settings.";
};

private _garrisonClassnames = _qrfSettings get "garrisonClassnames";
private _qrfTeamSize        = _qrfSettings get "qrfTeamSize";
private _outpostName        = _qrfSettings get "outpostName";
private _debugLogging       = _qrfSettings get "debugLogging";

if (count _garrisonClassnames == 0) exitWith {
    diag_log format ["[RECONDO_OUTPOST] '%1' QRF Load failed: no garrison classnames configured.", _outpostName];
};

private _side = side (driver _helo);
if (_side == civilian) then { _side = west; };

private _grp = createGroup [_side, true];
private _loadedUnits = [];
private _cargoSeats = _helo emptyPositions "cargo";
private _toLoad = _qrfTeamSize min _cargoSeats;

if (_toLoad < 1) exitWith {
    if (_debugLogging) then {
        diag_log format ["[RECONDO_OUTPOST] '%1' QRF Load: no cargo seats available in %2.", _outpostName, typeOf _helo];
    };
    deleteGroup _grp;
};

for "_i" from 1 to _toLoad do {
    private _classname = selectRandom _garrisonClassnames;
    private _unit = _grp createUnit [_classname, [0, 0, 0], [], 0, "NONE"];
    _unit allowDamage false;
    _unit moveInCargo _helo;
    _loadedUnits pushBack _unit;
};

_helo setVariable ["RECONDO_OUTPOST_QRF_UNITS", _loadedUnits, true];
_helo setVariable ["RECONDO_OUTPOST_QRF_LOADED", true, true];

if (_debugLogging) then {
    diag_log format ["[RECONDO_OUTPOST] '%1' QRF loaded %2 units into %3.", _outpostName, count _loadedUnits, typeOf _helo];
};
