/*
    Recondo_fnc_configureUnit
    Applies all configured tweaks to a unit based on its category
    
    Description:
        Main function that applies all enabled tweaks to a single unit.
        Called for existing units and newly spawned units.
        Applies different settings based on unit type (base, elite, aa).
    
    Parameters:
        0: OBJECT - Unit to configure
        1: STRING - Unit type: "base", "elite", or "aa"
        2: HASHMAP - Settings hashmap for the instance
        
    Returns:
        Nothing
        
    Example:
        [_unit, "base", _settings] call Recondo_fnc_configureUnit;
*/

params [["_unit", objNull, [objNull]], ["_unitType", "base", [""]], ["_settings", createHashMap, [createHashMap]]];

if (isNull _unit) exitWith {};

private _debug = _settings get "enableDebug";

if (_debug) then {
    diag_log format ["[RECONDO_AITWEAKS] Configuring unit: %1 (%2) as %3 for side %4", _unit, typeOf _unit, _unitType, _settings get "targetSideValue"];
};

// Apply skills based on unit type
private _enableSkills = switch (_unitType) do {
    case "elite": { _settings get "enableEliteSkills" };
    case "aa": { _settings get "enableAASkills" };
    default { _settings get "enableBaseSkills" };
};

if (_enableSkills) then {
    [_unit, _unitType, _settings] call Recondo_fnc_applySkills;
};

// Apply behavior settings
[_unit, _unitType, _settings] call Recondo_fnc_setupBehavior;

// Remove items if enabled for this category
private _removeGrenades = switch (_unitType) do {
    case "elite": { _settings get "eliteRemoveGrenades" };
    case "aa": { _settings get "aaRemoveGrenades" };
    default { _settings get "baseRemoveGrenades" };
};

if (_removeGrenades) then {
    [_unit, _unitType, _settings] call Recondo_fnc_removeItems;
};

// Disable AI features based on category
private _disableCover = switch (_unitType) do {
    case "elite": { _settings get "eliteDisableCover" };
    case "aa": { _settings get "aaDisableCover" };
    default { _settings get "baseDisableCover" };
};
if (_disableCover) then { _unit disableAI "COVER"; };

private _disableMineDetection = switch (_unitType) do {
    case "elite": { _settings get "eliteDisableMineDetection" };
    case "aa": { _settings get "aaDisableMineDetection" };
    default { _settings get "baseDisableMineDetection" };
};
if (_disableMineDetection) then { _unit disableAI "MINEDETECTION"; };

private _disableNVG = switch (_unitType) do {
    case "elite": { _settings get "eliteDisableNVG" };
    case "aa": { _settings get "aaDisableNVG" };
    default { _settings get "baseDisableNVG" };
};
if (_disableNVG) then { _unit disableAI "NVG"; };

private _disableSuppression = switch (_unitType) do {
    case "elite": { _settings get "eliteDisableSuppression" };
    case "aa": { _settings get "aaDisableSuppression" };
    default { _settings get "baseDisableSuppression" };
};
if (_disableSuppression) then { _unit disableAI "SUPPRESSION"; };

private _disableAutoCombat = switch (_unitType) do {
    case "elite": { _settings get "eliteDisableAutoCombat" };
    case "aa": { _settings get "aaDisableAutoCombat" };
    default { _settings get "baseDisableAutoCombat" };
};
if (_disableAutoCombat) then { _unit disableAI "AUTOCOMBAT"; };

// Apply flashlights if enabled
private _enableFlashlights = switch (_unitType) do {
    case "elite": { _settings get "eliteEnableFlashlights" };
    case "aa": { _settings get "aaEnableFlashlights" };
    default { _settings get "baseEnableFlashlights" };
};

if (_debug) then {
    diag_log format ["[RECONDO_AITWEAKS] Flashlight check for %1 - enabled setting: %2, sunOrMoon: %3", 
        _unit, _enableFlashlights, sunOrMoon];
};

if (_enableFlashlights) then {
    private _flashlightClass = switch (_unitType) do {
        case "elite": { _settings get "eliteFlashlightClass" };
        case "aa": { _settings get "aaFlashlightClass" };
        default { _settings get "baseFlashlightClass" };
    };
    
    private _primaryWeapon = primaryWeapon _unit;
    if (_primaryWeapon == "") then {
        if (_debug) then {
            diag_log format ["[RECONDO_AITWEAKS] Flashlight skipped for %1 - no primary weapon", _unit];
        };
    } else {
        _unit addPrimaryWeaponItem _flashlightClass;
        _unit setVariable ["RECONDO_AITWEAKS_hasFlashlight", true];
        
        private _isDark = sunOrMoon < 0.5;
        if (_isDark) then {
            _unit enableGunLights "forceOn";
        } else {
            _unit enableGunLights "forceOff";
        };
        
        if (_debug) then {
            diag_log format ["[RECONDO_AITWEAKS] Flashlight added to %1: %2 on weapon %3 (light %4)", 
                _unit, _flashlightClass, _primaryWeapon, ["OFF - daytime", "ON - nighttime"] select _isDark];
        };
    };
};

// Mark as configured (broadcast to all machines)
_unit setVariable ["RECONDO_AI_CONFIGURED", true];
_unit setVariable ["RECONDO_AI_TYPE", _unitType];
RECONDO_AITWEAKS_CONFIGURED_UNITS pushBack _unit;

// Cleanup when unit is deleted
_unit addEventHandler ["Deleted", {
    params ["_unit"];
    RECONDO_AITWEAKS_CONFIGURED_UNITS = RECONDO_AITWEAKS_CONFIGURED_UNITS - [_unit];
}];

if (_debug) then {
    diag_log format ["[RECONDO_AITWEAKS] Unit configured successfully: %1 as %2", _unit, _unitType];
};
