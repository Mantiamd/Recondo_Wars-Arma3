/*
    Recondo_fnc_gatherCustomProfiles
    Collects custom HVT/Hostage profiles from synced profile modules.

    Description:
        Mission makers can place a "Custom HVT Profile" or "Custom Hostage
        Profile" module and sync it to a core Objective module. This reads
        those synced modules and builds profile hashmaps directly from their
        attributes (same shape Recondo_fnc_loadProfiles returns), so they can
        join the core module's profile pool alongside the built-in profiles.

        Each profile is keyed by a stable token "CUSTOM::<id>" where <id> is the
        module's Eden Variable Name. The token (not the profile data) is what
        gets persisted by the core module; the data is re-read fresh from the
        synced module on every mission load.

    Parameters:
        0: OBJECT - The core module logic whose synced objects are scanned
        1: STRING - Custom profile module class to match (e.g. "Recondo_Module_CustomHVTProfile")
        2: BOOL   - Debug logging

    Returns:
        ARRAY - [tokens, map]
            tokens: ARRAY of STRING - stable tokens, sorted for deterministic order
            map:    HASHMAP - token -> profile hashmap

    Example:
        ([_logic, "Recondo_Module_CustomHVTProfile", _debug] call Recondo_fnc_gatherCustomProfiles) params ["_tokens", "_map"];
*/

params [
    ["_logic", objNull, [objNull]],
    ["_moduleClass", "", [""]],
    ["_debugLogging", false, [false]]
];

private _map = createHashMap;
private _tokens = [];

if (isNull _logic || {_moduleClass == ""}) exitWith { [_tokens, _map] };

{
    if (typeOf _x == _moduleClass) then {
        private _enabled = _x getVariable ["customprofileenabled", true];
        if (_enabled) then {
            // Prefer the Eden Variable Name as a stable persistence ID.
            private _id = vehicleVarName _x;
            if (_id == "") then {
                // Fall back to the profile name, then map grid, and warn:
                // without a Variable Name the persisted selection cannot be
                // matched reliably across restarts.
                _id = _x getVariable ["name", ""];
                if (_id == "") then { _id = mapGridPosition _x; };
                diag_log format ["[RECONDO_PROFILES] WARNING: Custom profile module (%1) has no Variable Name; using fallback ID '%2'. Set a Variable Name for reliable persistence.", _moduleClass, _id];
            };

            private _token = format ["CUSTOM::%1", _id];

            // Loadout is pasted as an SQF array literal; compile it safely.
            private _loadoutRaw = _x getVariable ["loadoutdata", ""];
            private _loadout = [];
            if (_loadoutRaw != "") then {
                private _compiled = call compile _loadoutRaw;
                if (!isNil "_compiled" && {_compiled isEqualType []}) then {
                    _loadout = _compiled;
                } else {
                    diag_log format ["[RECONDO_PROFILES] WARNING: Custom profile '%1' has invalid loadout text; ignoring it.", _id];
                };
            };

            private _profile = createHashMapFromArray [
                ["name", _x getVariable ["name", "Unknown Target"]],
                ["classname", _x getVariable ["classname", "C_man_1"]],
                ["photo", _x getVariable ["photo", ""]],
                ["background", _x getVariable ["background", ""]],
                ["face", _x getVariable ["face", ""]],
                ["identity", ""],
                ["speaker", _x getVariable ["speaker", ""]],
                ["loadout", _loadout],
                ["profileFile", _token]
            ];

            _map set [_token, _profile];
            _tokens pushBackUnique _token;

            if (_debugLogging) then {
                diag_log format ["[RECONDO_PROFILES] Gathered custom profile: %1 -> %2", _token, _profile getOrDefault ["name", "?"]];
            };
        };
    };
} forEach (synchronizedObjects _logic);

_tokens sort true;

[_tokens, _map]
