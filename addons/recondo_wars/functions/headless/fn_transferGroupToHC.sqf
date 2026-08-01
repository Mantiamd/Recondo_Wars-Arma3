/*
    Recondo_fnc_transferGroupToHC
    Transfers ownership of an AI group to a connected Headless Client

    Description:
        Picks the least-loaded connected HC and hands the group to it with
        setGroupOwner. Crewed vehicles follow their crew. If no HC is
        connected, the group simply stays on the server and this returns
        false - callers need no fallback logic.

        Every group passed here is also tagged RECONDO_HC_ELIGIBLE and the
        periodic sweep loop is started, so groups are picked up when an HC
        connects late and re-transferred when an HC disconnect returns
        them to the server.

        Only use for waypoint-driven groups. Server-side behavior loops,
        direct AI commands (doMove etc.) and object event handlers added
        on the server stop working for a group after transfer. disableAI
        flags are lost on transfer; re-apply them via a CBA "Local" event
        handler (see fn_preInit.sqf).

        Server-only.

    Parameters:
        0: GROUP - Group to transfer
        1: BOOL - Enable debug logging (optional, default false)

    Returns:
        BOOL - True if the group was handed to an HC
*/

if (!isServer) exitWith { false };

params ["_group", ["_debug", false]];

if (isNull _group || {(units _group) isEqualTo []}) exitWith { false };

// Never transfer groups containing players
if ((units _group) findIf { isPlayer _x } != -1) exitWith { false };

// Smarter AAA steers managed AA gun crews from the server (doWatch/disableAI/
// fire are local-argument commands) - those crews must never move to an HC
if (!isNil "RECONDO_SAAA_INITIALIZED" && {
    (units _group) findIf {
        private _veh = vehicle _x;
        _veh != _x && {_veh isKindOf "StaticWeapon"} && {[_veh] call Recondo_fnc_saaaIsManagedGun}
    } != -1
}) exitWith {
    if (_debug) then {
        diag_log format ["[RECONDO_HC] Group %1 crews a Smarter AAA managed gun - staying on server", _group];
    };
    false
};

// Tag as HC-eligible and make sure the sweep loop is running, so the group
// is picked up later if no HC is connected yet, or re-transferred after an
// HC disconnect returns it to the server.
_group setVariable ["RECONDO_HC_ELIGIBLE", true];
call Recondo_fnc_hcSweepLoop;

private _headlessClients = call Recondo_fnc_getHeadlessClients;
if (_headlessClients isEqualTo []) exitWith {
    if (_debug) then {
        diag_log format ["[RECONDO_HC] No Headless Client connected - group %1 stays on server", _group];
    };
    false
};

// Pick the HC that currently owns the fewest units
private _bestHC = _headlessClients select 0;
private _bestCount = 1e7;
{
    private _hcId = owner _x;
    private _load = { owner _x == _hcId } count allUnits;
    if (_load < _bestCount) then {
        _bestCount = _load;
        _bestHC = _x;
    };
} forEach _headlessClients;

private _hcId = owner _bestHC;
private _transferred = _group setGroupOwner _hcId;

if (_debug) then {
    diag_log format ["[RECONDO_HC] Group %1 (%2 units) transfer to HC %3 (id %4, %5 units owned): %6",
        _group, count units _group, name _bestHC, _hcId, _bestCount, _transferred];
};

_transferred
