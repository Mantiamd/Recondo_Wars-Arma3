/*
    Recondo_fnc_moduleNearAmbush
    Main initialization for Near Ambush module

    Description:
        OPFOR AI ambushes against BLUFOR players on foot. Invisible map
        markers with a configurable prefix are the candidate ambush sites;
        a configurable percentage of them is randomly active each mission
        (no persistence - re-rolled every mission start).

        When a BLUFOR player on foot comes within the trigger radius of an
        active site, an OPFOR group spawns at the required staging marker
        (out of sight), goes prone, then teleports into a hold-fire line
        formation - either across the players' path ahead of them, or
        parallel to their path off to one side - and springs (crouch + open
        fire) when the players walk into the kill zone or make early
        contact (ambusher hit, or a BLUFOR shot lands nearby).

        Sprung sites are spent for the rest of the mission. If the players
        leave the area before the ambush springs, the group despawns and
        the site re-arms.

        Ambush groups stay server-local on purpose: the spring logic runs
        on the server and the groups are short-lived, so they are not
        tagged for Headless Client transfer.

    Priority: 5 (Feature module)

    Parameters:
        _logic - Module logic object
        _units - Synchronized units (unused)
        _activated - Whether module is activated
*/

params ["_logic", "_units", "_activated"];

if (!isServer) exitWith {};

if (!_activated) exitWith {
    diag_log "[RECONDO_NEARAMBUSH] Module not activated.";
};

if (!isNil "RECONDO_NEARAMBUSH_INITIALIZED") exitWith {
    diag_log "[RECONDO_NEARAMBUSH] WARNING: Module already initialized. Skipping duplicate.";
};
RECONDO_NEARAMBUSH_INITIALIZED = true;

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

private _unitClassnamesRaw = _logic getVariable ["unitclassnames", ""];
private _autoRifleClassnamesRaw = _logic getVariable ["autorifleclassnames", ""];
// Fallback matches the Eden default (defaults are not stored in mission.sqm)
private _tripFlareClassname = _logic getVariable ["tripflareclassname", "ACE_FlareTripMineRed"];
private _minGroupSize = _logic getVariable ["mingroupsize", 4];
private _maxGroupSize = _logic getVariable ["maxgroupsize", 6];
private _markerPrefix = _logic getVariable ["markerprefix", "AMBUSH_"];
// Fallback matches the Eden default: attributes equal to the config default
// are not stored in mission.sqm
private _stagingMarker = _logic getVariable ["stagingmarker", "STAGING"];
private _activationChance = _logic getVariable ["activationchance", 0.5];
private _triggerRadius = _logic getVariable ["triggerradius", 150];

private _debugMarkers = _logic getVariable ["debugmarkers", false];
private _debugLogging = _logic getVariable ["debuglogging", false];
if (RECONDO_MASTER_DEBUG) then { _debugLogging = true; };

// ========================================
// VALIDATE
// ========================================

private _unitClassnames = [_unitClassnamesRaw] call Recondo_fnc_parseClassnames;
if (_unitClassnames isEqualTo []) exitWith {
    diag_log "[RECONDO_NEARAMBUSH] ERROR: No OPFOR unit classnames specified. Module disabled.";
};

// Optional: empty list disables the overhead suppressive fire feature
private _autoRifleClassnames = [_autoRifleClassnamesRaw] call Recondo_fnc_parseClassnames;

// Ambush squads spawn at the staging marker, go prone out of sight, and are
// teleported into the line already flat. Without it no AI would look right,
// so the module refuses to run
if (_stagingMarker == "") exitWith {
    diag_log "[RECONDO_NEARAMBUSH] ERROR: No staging marker specified. Module disabled.";
};
private _stagingIdx = allMapMarkers findIf { (toUpper _x) == (toUpper _stagingMarker) };
if (_stagingIdx == -1) exitWith {
    diag_log format ["[RECONDO_NEARAMBUSH] ERROR: Staging marker '%1' not found on the map. Module disabled.", _stagingMarker];
};
private _stagingPos = getMarkerPos (allMapMarkers select _stagingIdx);

_minGroupSize = _minGroupSize max 1;
_maxGroupSize = _maxGroupSize max _minGroupSize;
_activationChance = (_activationChance max 0) min 1;
_triggerRadius = _triggerRadius max 50;

// ========================================
// STORE SETTINGS
// ========================================

// Geometry is hardcoded by design (clarity over configurability):
// FRONT mode blocks the path 50m ahead; PARALLEL mode lines the path
// 35m to one side, centered 50m ahead so the players walk across it.
RECONDO_NEARAMBUSH_SETTINGS = createHashMapFromArray [
    ["unitClassnames", _unitClassnames],
    ["autoRifleClassnames", _autoRifleClassnames],
    ["tripFlareClassname", _tripFlareClassname],
    ["minGroupSize", _minGroupSize],
    ["maxGroupSize", _maxGroupSize],
    ["markerPrefix", toUpper _markerPrefix],
    ["stagingPos", _stagingPos],
    ["activationChance", _activationChance],
    ["triggerRadius", _triggerRadius],

    // Hardcoded geometry
    ["frontDistance", 50],       // FRONT: line center this far ahead of players
    ["parallelAhead", 50],       // PARALLEL: line center this far ahead along the path
    ["parallelOffset", 35],      // PARALLEL: line offset this far off the path
    ["unitSpacing", 3],          // Meters between ambushers in the line
    ["springDistance", 25],      // FRONT: spring when a player is this close to the line
    ["proximitySpring", 15],     // Failsafe: spring when a player is this close to any ambusher
    ["rearmRadius", _triggerRadius + 100], // Despawn + re-arm when no player is within this of the site
    ["suppressHeight", 3],       // Overhead fire: aim point this far above the target's head
    ["suppressDuration", 5],     // Overhead fire: seconds of full auto before joining the fight

    // Debug
    ["debugMarkers", _debugMarkers],
    ["debugLogging", _debugLogging]
];

// ========================================
// SELECT ACTIVE AMBUSH SITES
// ========================================

private _markerPrefixUpper = toUpper _markerPrefix;
private _candidates = 0;

RECONDO_NEARAMBUSH_ACTIVE = [];

{
    private _markerName = _x;
    if ((toUpper _markerName) find _markerPrefixUpper == 0) then {
        _candidates = _candidates + 1;

        if (random 1 < _activationChance) then {
            RECONDO_NEARAMBUSH_ACTIVE pushBack [_markerName, getMarkerPos _markerName];

            if (_debugMarkers) then {
                private _dbg = createMarker ["RECONDO_NEARAMBUSH_DBG_" + _markerName, getMarkerPos _markerName];
                _dbg setMarkerType "mil_ambush";
                _dbg setMarkerColor "ColorGreen";
                _dbg setMarkerText "Ambush (armed)";
            };

            if (_debugLogging) then {
                diag_log format ["[RECONDO_NEARAMBUSH] Site %1 active", _markerName];
            };
        };
    };
} forEach allMapMarkers;

// ========================================
// WATCH LOOP
// ========================================

// Server-side loop: when a BLUFOR player on foot comes within the trigger
// radius of an armed site, the site spawns its ambush and is removed from
// the armed list (fn_spawnNearAmbush re-arms it if the ambush despawns
// without springing).
[] spawn {
    private _settings = RECONDO_NEARAMBUSH_SETTINGS;
    private _triggerRadius = _settings get "triggerRadius";
    private _debugLogging = _settings get "debugLogging";

    sleep 5;

    while {true} do {
        private _footPlayers = allPlayers select {
            alive _x && {side _x == west} && {isNull objectParent _x}
        };

        if (_footPlayers isNotEqualTo [] && {RECONDO_NEARAMBUSH_ACTIVE isNotEqualTo []}) then {
            // Iterate a copy - triggered sites are removed from the live array
            {
                _x params ["_markerName", "_markerPos"];

                private _trigger = objNull;
                {
                    if (_x distance2D _markerPos < _triggerRadius) exitWith { _trigger = _x; };
                } forEach _footPlayers;

                if (!isNull _trigger) then {
                    RECONDO_NEARAMBUSH_ACTIVE deleteAt (RECONDO_NEARAMBUSH_ACTIVE findIf { (_x select 0) == _markerName });

                    if (_debugLogging) then {
                        diag_log format ["[RECONDO_NEARAMBUSH] Site %1 triggered by %2", _markerName, name _trigger];
                    };

                    [_markerName, _markerPos, _trigger] call Recondo_fnc_spawnNearAmbush;
                };
            } forEach +RECONDO_NEARAMBUSH_ACTIVE;
        };

        sleep 3;
    };
};

// ========================================
// FINAL LOG
// ========================================

diag_log format ["[RECONDO_NEARAMBUSH] Module initialized. %1 of %2 sites active at prefix '%3', trigger radius %4m.",
    count RECONDO_NEARAMBUSH_ACTIVE, _candidates, _markerPrefix, _triggerRadius];
