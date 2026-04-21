/*
    Recondo_fnc_loadOPORDDisplay
    Server-side: Attempts to load an external OPORD SQF file
    from the mission folder. If found, stores the text globally.
*/

params [
    ["_filename", "recondo_opord.sqf", [""]],
    ["_debug", false, [false]]
];

if (!isServer) exitWith {};

if (_filename == "") exitWith {
    if (_debug) then { diag_log "[RECONDO_OPORD] No OPORD filename configured."; };
};

if (fileExists _filename) then {
    private _result = call compile preprocessFileLineNumbers _filename;

    if (isNil "_result") exitWith {
        diag_log format ["[RECONDO_OPORD] ERROR: OPORD file '%1' returned nil. Ensure it returns a string or hashmap.", _filename];
    };

    // Support both plain string and hashmap format
    if (_result isEqualType "") then {
        RECONDO_OPORD_TEXT = _result;
        publicVariable "RECONDO_OPORD_TEXT";
        diag_log format ["[RECONDO_OPORD] Loaded OPORD from '%1' (%2 characters)", _filename, count _result];
    } else {
        if (_result isEqualType createHashMap) then {
            RECONDO_OPORD_TEXT = _result;
            publicVariable "RECONDO_OPORD_TEXT";
            diag_log format ["[RECONDO_OPORD] Loaded OPORD (hashmap) from '%1' (%2 sections)", _filename, count _result];
        } else {
            diag_log format ["[RECONDO_OPORD] ERROR: OPORD file '%1' returned unexpected type. Expected string or hashmap.", _filename];
        };
    };
} else {
    if (_debug) then {
        diag_log format ["[RECONDO_OPORD] OPORD file '%1' not found in mission. OPORD display will be unavailable.", _filename];
    };
};
