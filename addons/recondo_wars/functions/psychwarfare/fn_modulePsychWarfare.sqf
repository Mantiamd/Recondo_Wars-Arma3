/*
    Recondo_fnc_modulePsychWarfare
    Main initialization for Psychological Warfare module

    Description:
        Mirrors Eldest Son's body-scan mechanic, but instead of sabotaging
        ammunition it demoralizes the enemy: planted "psy-op" items found in
        dead bodies accumulate and, once a minimum threshold is reached,
        progressively lower the target side's COURAGE and COMMANDING skills.

        Coexistence with AI Tweaks is conflict-free because only ONE system
        writes skills at any time. The reduction is published as a per-side
        factor (RECONDO_PSYWAR_FACTORS) that AI Tweaks' fn_applySkills reads
        when it sets courage/commanding. If no AI Tweaks instance exists for
        the side, this module applies the reduction directly instead.

    Priority: 5 (consumes AI Tweaks instances + persistence; must run after them)

    Parameters:
        0: OBJECT - Logic module
        1: ARRAY  - Synced units (unused)
        2: BOOL   - Is activated
*/

params ["_logic", "_units", "_activated"];

if (!isServer) exitWith {};

if (!_activated) exitWith {
    diag_log "[RECONDO_PSYWAR] Module not activated.";
};

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

private _debug = _logic getVariable ["enabledebug", false];
if (RECONDO_MASTER_DEBUG) then { _debug = true; };

private _sideNum = _logic getVariable ["targetside", 0];
private _sideValue = switch (_sideNum) do {
    case 0: { east };
    case 1: { west };
    case 2: { independent };
    case 3: { civilian };
    default { east };
};

// Per-side dedup: only one Psychological Warfare instance per side.
{
    if ((_x get "targetSideValue") isEqualTo _sideValue) exitWith {
        diag_log format ["[RECONDO_PSYWAR] WARNING: An instance for side %1 already exists. Ignoring duplicate.", _sideValue];
        _sideValue = nil;
    };
} forEach RECONDO_PSYWAR_INSTANCES;

if (isNil "_sideValue") exitWith {};

// Reduction applied per item (percentage of configured skill), as a fraction.
private _reductionPerItem = (_logic getVariable ["reductionperitem", 10]);
_reductionPerItem = ((_reductionPerItem max 0.1) min 100) / 100;

// Minimum number of planted items before ANY reduction takes effect.
private _minThreshold = round (_logic getVariable ["minthreshold", 3]);
_minThreshold = _minThreshold max 1;

// Floor: lowest the factor may reach (percentage of configured skill), as a fraction.
private _floorFactor = (_logic getVariable ["floorpercent", 25]);
_floorFactor = ((_floorFactor max 0) min 100) / 100;

private _scanInterval = _logic getVariable ["scaninterval", 60];
_scanInterval = (_scanInterval max 5) min 600;

private _psyItemsRaw = _logic getVariable ["psyitems", ""];
private _psyItems = [_psyItemsRaw] call Recondo_fnc_parseClassnames;

// Intel board status readings per tier: [dormant, rattled, broken].
private _readings = [
    _logic getVariable ["readingdormant", "Your unit has not yet drawn the enemy's attention."],
    _logic getVariable ["readingrattled", "The jungle carries rumors faster than the radios do."],
    _logic getVariable ["readingbroken", "The enemy fears the Men with Green Faces"]
];

// ========================================
// VALIDATE
// ========================================

if (count _psyItems == 0) exitWith {
    diag_log "[RECONDO_PSYWAR] WARNING: No psy-op item classnames configured. Module disabled.";
};

// ========================================
// STORE SETTINGS
// ========================================

// Item count at which the factor bottoms out at the floor (so we stop counting).
// factor = 1 - (items - minThreshold + 1) * reductionPerItem, clamped to floor.
private _stepsToFloor = ceil ((1 - _floorFactor) / _reductionPerItem);
private _maxItems = _minThreshold - 1 + _stepsToFloor;

private _settings = createHashMap;
_settings set ["targetSideValue", _sideValue];
_settings set ["targetSideNum", _sideNum];
_settings set ["reductionPerItem", _reductionPerItem];
_settings set ["minThreshold", _minThreshold];
_settings set ["floorFactor", _floorFactor];
_settings set ["scanInterval", _scanInterval];
_settings set ["psyItems", _psyItems];
_settings set ["maxItems", _maxItems];
_settings set ["readings", _readings];
_settings set ["enableDebug", _debug];

RECONDO_PSYWAR_INSTANCES pushBack _settings;

// ========================================
// PERSISTENCE LOAD (item count only; the factor is derived from it)
// ========================================

private _persistKey = "RECONDO_PSYWAR_ITEMS_" + str _sideNum;
private _savedItems = 0;
if (!isNil "RECONDO_PERSISTENCE_SETTINGS") then {
    private _loaded = [_persistKey] call Recondo_fnc_getSaveData;
    if (!isNil "_loaded" && {_loaded isEqualType 0}) then { _savedItems = _loaded; };
};
_savedItems = (round _savedItems) max 0 min _maxItems;
RECONDO_PSYWAR_ITEMS set [_sideValue, _savedItems];

if (_debug) then {
    diag_log "[RECONDO_PSYWAR] === MODULE SETTINGS ===";
    diag_log format ["[RECONDO_PSYWAR] Side: %1 | Reduction/item: %2 | MinThreshold: %3 | Floor: %4 | MaxItems: %5", _sideValue, _reductionPerItem, _minThreshold, _floorFactor, _maxItems];
    diag_log format ["[RECONDO_PSYWAR] Psy items (%1): %2", count _psyItems, _psyItems];
    diag_log format ["[RECONDO_PSYWAR] Loaded item count: %1", _savedItems];
};

// ========================================
// TAG EXISTING UNITS (stores side for dead-body scanning)
// ========================================

{
    if ((side _x) isEqualTo _sideValue && {alive _x} && {!isPlayer _x}) then {
        [_x, _settings] call Recondo_fnc_initPsychWarfareUnit;
    };
} forEach allUnits;

// Apply the initial factor only if the loaded count already crosses the
// threshold; otherwise leave configured (AI Tweaks/default) skills untouched.
// Either way, publish a readout so the intel board shows this side immediately.
if (_savedItems >= _minThreshold) then {
    [_sideValue] call Recondo_fnc_applyPsychWarfareFactor;
} else {
    [_sideNum, 1, _floorFactor, _readings] call Recondo_fnc_updatePsychWarfareReadout;
};

// ========================================
// SHARED ENTITYCREATED HANDLER (registered once for all instances)
// ========================================

if (!RECONDO_PSYWAR_EH_REGISTERED) then {
    RECONDO_PSYWAR_EH_REGISTERED = true;

    addMissionEventHandler ["EntityCreated", {
        params ["_entity"];
        if (!(_entity isKindOf "CAManBase")) exitWith {};

        // Delay so AI Tweaks (0.1s) configures the unit first; then PsyWar
        // tops up the reduction if a factor is active for this side.
        [{
            params ["_unit"];
            if (!alive _unit) exitWith {};
            if (isPlayer _unit) exitWith {};

            private _sideValue = side _unit;
            private _settings = nil;
            {
                if ((_x get "targetSideValue") isEqualTo _sideValue) exitWith { _settings = _x; };
            } forEach RECONDO_PSYWAR_INSTANCES;
            if (isNil "_settings") exitWith {};

            [_unit, _settings] call Recondo_fnc_initPsychWarfareUnit;

            private _factor = RECONDO_PSYWAR_FACTORS getOrDefault [_sideValue, 1];
            if (_factor < 1) then {
                [_sideValue, [_unit]] call Recondo_fnc_applyPsychWarfareFactor;
            };
        }, [_entity], 0.6] call CBA_fnc_waitAndExecute;
    }];
};

// ========================================
// START SCANNER
// ========================================

[_settings] spawn Recondo_fnc_scanPsychWarfareBodies;

diag_log format ["[RECONDO_PSYWAR] Module initialized for side %1. %2 psy item(s), threshold %3, item count %4.", _sideValue, count _psyItems, _minThreshold, _savedItems];
