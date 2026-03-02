/*
    Recondo_fnc_validateModules
    Validates module configurations and warns about common issues
    
    Runs on server, sends warnings to all connected players via systemChat.
*/

if (!isServer) exitWith {};

private _warnings = [];

private _fnc_warn = {
    params ["_module", "_msg"];
    _warnings pushBack format ["[Recondo Wars] %1: %2", _module, _msg];
};

// Check marker-based modules for missing markers
{
    _x params ["_globalVar", "_settingsKey", "_moduleName", "_prefixKey"];
    
    if (!isNil _globalVar) then {
        private _instances = missionNamespace getVariable [_globalVar, []];
        {
            private _settings = _x;
            if (_settings isEqualType createHashMap) then {
                private _prefix = _settings getOrDefault [_prefixKey, ""];
                if (_prefix != "") then {
                    private _found = allMapMarkers select { (_x find _prefix) == 0 };
                    if (count _found == 0) then {
                        [_moduleName, format ["No markers found with prefix '%1'. Place markers named %1_1, %1_2, etc.", _prefix]] call _fnc_warn;
                    };
                };
            };
        } forEach _instances;
    };
} forEach [
    ["RECONDO_OBJDESTROY_INSTANCES", "markerPrefix", "Objective Destroy", "markerPrefix"],
    ["RECONDO_HUBSUBS_INSTANCES", "markerPrefix", "Objective Hub & Subs", "markerPrefix"],
    ["RECONDO_JAMMER_INSTANCES", "markerPrefix", "Objective Jammer", "markerPrefix"],
    ["RECONDO_CAMPSRANDOM_INSTANCES", "markerPrefix", "Camps Random", "markerPrefix"],
    ["RECONDO_POO_INSTANCES", "markerPrefix", "POO Site Hunt", "markerPrefix"]
];

// Check HVT instances
if (count RECONDO_HVT_INSTANCES > 0) then {
    {
        private _settings = _x;
        if (_settings isEqualType createHashMap) then {
            private _prefix = _settings getOrDefault ["markerPrefix", ""];
            if (_prefix != "") then {
                private _found = allMapMarkers select { (_x find _prefix) == 0 };
                if (count _found == 0) then {
                    ["Objective HVT", format ["No markers found with prefix '%1'.", _prefix]] call _fnc_warn;
                };
            };
        };
    } forEach RECONDO_HVT_INSTANCES;
};

// Check Hostage instances
if (!isNil "RECONDO_HOSTAGE_LOCATIONS" && count keys RECONDO_HOSTAGE_LOCATIONS == 0) then {
    private _hasModule = false;
    {
        if (typeOf _x == "Recondo_Module_ObjectiveHostages") then { _hasModule = true; };
    } forEach (allMissionObjects "Logic");
    if (_hasModule) then {
        ["Objective Hostages", "Module placed but no hostage locations were set up. Check marker prefix and hostage definitions."] call _fnc_warn;
    };
};

// Send warnings to all players
if (count _warnings > 0) then {
    diag_log format ["[RECONDO_WARS] Module validation found %1 warning(s)", count _warnings];
    
    ["[Recondo Wars] Module validation warnings:"] remoteExec ["systemChat", 0];
    {
        [_x] remoteExec ["systemChat", 0];
        diag_log _x;
    } forEach _warnings;
} else {
    diag_log "[RECONDO_WARS] Module validation passed - no warnings.";
};
