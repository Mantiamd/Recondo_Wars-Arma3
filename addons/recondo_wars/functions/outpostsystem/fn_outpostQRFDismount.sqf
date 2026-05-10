/*
    Recondo_fnc_outpostQRFDismount
    Server-side: dismounts QRF team from helicopter

    Parameters:
        _helo - OBJECT - The helicopter to dismount units from
*/

if (!isServer) exitWith {};

params [["_helo", objNull, [objNull]]];

if (isNull _helo || !alive _helo) exitWith {};

if !(_helo getVariable ["RECONDO_OUTPOST_QRF_LOADED", false]) exitWith {};

private _qrfSettings = _helo getVariable ["RECONDO_OUTPOST_QRF_SETTINGS", nil];
private _outpostName = if (!isNil "_qrfSettings") then { _qrfSettings get "outpostName" } else { "Unknown" };
private _debugLogging = if (!isNil "_qrfSettings") then { _qrfSettings get "debugLogging" } else { false };

private _loadedUnits = _helo getVariable ["RECONDO_OUTPOST_QRF_UNITS", []];

private _dismountedCount = 0;
{
    if (alive _x && {vehicle _x == _helo}) then {
        unassignVehicle _x;
        _x action ["Eject", _helo];
        _dismountedCount = _dismountedCount + 1;
    };
} forEach _loadedUnits;

_helo setVariable ["RECONDO_OUTPOST_QRF_UNITS", [], true];
_helo setVariable ["RECONDO_OUTPOST_QRF_LOADED", false, true];

if (_debugLogging) then {
    diag_log format ["[RECONDO_OUTPOST] '%1' QRF dismounted %2 units from %3.", _outpostName, _dismountedCount, typeOf _helo];
};

// Re-enable damage after 30 seconds
[{
    params ["_units", "_debugLogging", "_outpostName"];
    {
        if (alive _x) then {
            _x allowDamage true;
        };
    } forEach _units;
    if (_debugLogging) then {
        diag_log format ["[RECONDO_OUTPOST] '%1' QRF team damage protection removed.", _outpostName];
    };
}, [_loadedUnits, _debugLogging, _outpostName], 30] call CBA_fnc_waitAndExecute;
