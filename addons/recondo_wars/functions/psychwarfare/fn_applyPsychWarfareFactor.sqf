/*
    Recondo_fnc_applyPsychWarfareFactor
    Recomputes a side's demoralization factor and applies it to its units

    Description:
        Derives the courage/commanding multiplier from the side's accumulated
        item count and publishes it to RECONDO_PSYWAR_FACTORS. Then re-applies
        skills so the change takes effect on living units:
          - If AI Tweaks owns the unit, it stays the only skill writer:
            fn_applySkills is re-run and reads the factor internally.
          - Otherwise (standalone), this captures each unit's baseline
            courage/commanding once and sets baseline * factor directly.

        Below the configured minimum threshold the factor stays at 1.0, so the
        AI Tweaks (or engine default) values remain untouched.

    Parameters:
        0: SIDE  - Target side value
        1: ARRAY - Optional unit list to restrict to (default: all units)

    Returns:
        SCALAR - The computed factor
*/

params [["_sideValue", sideUnknown, [east]], ["_unitList", [], [[]]]];

private _settings = nil;
{
    if ((_x get "targetSideValue") isEqualTo _sideValue) exitWith { _settings = _x; };
} forEach RECONDO_PSYWAR_INSTANCES;
if (isNil "_settings") exitWith { 1 };

private _items = RECONDO_PSYWAR_ITEMS getOrDefault [_sideValue, 0];
private _minThreshold = _settings get "minThreshold";
private _reductionPerItem = _settings get "reductionPerItem";
private _floorFactor = _settings get "floorFactor";

private _factor = 1;
if (_items >= _minThreshold) then {
    // First effective step occurs AT the threshold, then scales per item.
    private _effective = _items - _minThreshold + 1;
    _factor = (1 - (_effective * _reductionPerItem)) max _floorFactor;
};

RECONDO_PSYWAR_FACTORS set [_sideValue, _factor];

// Publish a client-readable readout (intel board); only broadcasts on change.
[_settings get "targetSideNum", _factor, _floorFactor, _settings get "readings"] call Recondo_fnc_updatePsychWarfareReadout;

// Locate this side's AI Tweaks instance (if any) so configured units keep a
// single skill authority.
private _aiInst = nil;
if (!isNil "RECONDO_AITWEAKS_INSTANCES") then {
    {
        if ((_x get "targetSideValue") isEqualTo _sideValue) exitWith { _aiInst = _x; };
    } forEach RECONDO_AITWEAKS_INSTANCES;
};

private _targets = _unitList;
if (_targets isEqualTo []) then { _targets = allUnits; };

{
    private _unit = _x;
    if (isNull _unit) then { continue };
    if (!alive _unit) then { continue };
    if (isPlayer _unit) then { continue };
    if (!((side _unit) isEqualTo _sideValue)) then { continue };
    if (!local _unit) then { continue };

    if ((_unit getVariable ["RECONDO_AI_CONFIGURED", false]) && {!isNil "_aiInst"}) then {
        // AI Tweaks remains the writer; it multiplies by the factor we just set.
        private _unitType = [_unit, _aiInst] call Recondo_fnc_getAITweaksUnitType;
        [_unit, _unitType, _aiInst] call Recondo_fnc_applySkills;
    } else {
        // Standalone: capture original values once, then scale them.
        private _baseCourage = _unit getVariable ["RECONDO_PSYWAR_BASE_COURAGE", -1];
        if (_baseCourage < 0) then {
            _baseCourage = _unit skill "courage";
            _unit setVariable ["RECONDO_PSYWAR_BASE_COURAGE", _baseCourage];
        };
        private _baseCommanding = _unit getVariable ["RECONDO_PSYWAR_BASE_COMMANDING", -1];
        if (_baseCommanding < 0) then {
            _baseCommanding = _unit skill "commanding";
            _unit setVariable ["RECONDO_PSYWAR_BASE_COMMANDING", _baseCommanding];
        };
        _unit setSkill ["courage", _baseCourage * _factor];
        _unit setSkill ["commanding", _baseCommanding * _factor];
    };
} forEach _targets;

_factor
