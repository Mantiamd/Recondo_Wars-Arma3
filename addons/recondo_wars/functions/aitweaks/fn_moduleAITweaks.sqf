/*
    Recondo_fnc_moduleAITweaks
    Main module initialization - runs on server only
    
    Description:
        Called when the AI Tweaks module is activated.
        Reads all module attributes, configures existing units,
        and sets up event handlers for spawned units.
        
        Supports three unit categories:
        - Base: All units of target side (default) - except Elite and AA
        - Elite Soldiers: Specified by classnames, have their own settings
        - AA Gunners: Specified by classnames, have their own settings
    
    Parameters:
        0: OBJECT - Logic module
        1: ARRAY - Synced units (unused)
        2: BOOL - Is activated
        
    Returns:
        Nothing
*/

params ["_logic", "_units", "_activated"];

// Only run on server
if (!isServer) exitWith {
    diag_log "[RECONDO_AITWEAKS] Module attempted to run on non-server. Exiting.";
};

// Check if already initialized (prevent multiple modules)
if (!isNil "RECONDO_AITWEAKS_INITIALIZED") exitWith {
    diag_log "[RECONDO_AITWEAKS] WARNING: Module already initialized. Only one AI Tweaks module should be placed.";
};

RECONDO_AITWEAKS_INITIALIZED = true;

// Get all module attributes and store in hashmap
// NOTE: Eden stores variables with lowercase names
private _settings = createHashMap;

// General
_settings set ["targetSide", _logic getVariable ["targetside", 0]];
_settings set ["enableDebug", _logic getVariable ["enabledebug", false]];

// ========== BASE SETTINGS ==========
_settings set ["enableBaseSkills", _logic getVariable ["enablebaseskills", true]];
// Base Skills
_settings set ["baseAimingAccuracy", _logic getVariable ["base_aimingaccuracy", 0.1]];
_settings set ["baseAimingShake", _logic getVariable ["base_aimingshake", 0.1]];
_settings set ["baseAimingSpeed", _logic getVariable ["base_aimingspeed", 0.1]];
_settings set ["baseSpotDistance", _logic getVariable ["base_spotdistance", 0.1]];
_settings set ["baseSpotTime", _logic getVariable ["base_spottime", 0.1]];
_settings set ["baseCourage", _logic getVariable ["base_courage", 1.0]];
_settings set ["baseCommanding", _logic getVariable ["base_commanding", 1.0]];
_settings set ["baseGeneral", _logic getVariable ["base_general", 0.1]];
_settings set ["baseReloadSpeed", _logic getVariable ["base_reloadspeed", 0.3]];
// Base Behavior
_settings set ["baseForceWalk", _logic getVariable ["base_forcewalk", true]];
_settings set ["baseForceStand", _logic getVariable ["base_forcestand", true]];
_settings set ["baseAnimSpeedCoef", _logic getVariable ["base_animspeedcoef", 1.5]];
// Base AI Features
_settings set ["baseDisableCover", _logic getVariable ["base_disablecover", false]];
_settings set ["baseDisableMineDetection", _logic getVariable ["base_disableminedetection", true]];
_settings set ["baseDisableNVG", _logic getVariable ["base_disablenvg", true]];
_settings set ["baseDisableSuppression", _logic getVariable ["base_disablesuppression", false]];
_settings set ["baseDisableAutoCombat", _logic getVariable ["base_disableautocombat", false]];
// Base Equipment
_settings set ["baseRemoveGrenades", _logic getVariable ["base_removegrenades", true]];
_settings set ["baseGrenadesToRemove", _logic getVariable ["base_grenadestoremove", ""]];
_settings set ["baseEnableFlashlights", _logic getVariable ["base_enableflashlights", false]];
_settings set ["baseFlashlightClass", _logic getVariable ["base_flashlightclass", "acc_flashlight"]];

// ========== ELITE SETTINGS ==========
_settings set ["eliteClassnames", _logic getVariable ["eliteclassnames", ""]];
_settings set ["enableEliteSkills", _logic getVariable ["enableeliteskills", true]];
// Elite Skills
_settings set ["eliteAimingAccuracy", _logic getVariable ["elite_aimingaccuracy", 0.4]];
_settings set ["eliteAimingShake", _logic getVariable ["elite_aimingshake", 0.3]];
_settings set ["eliteAimingSpeed", _logic getVariable ["elite_aimingspeed", 0.4]];
_settings set ["eliteSpotDistance", _logic getVariable ["elite_spotdistance", 0.5]];
_settings set ["eliteSpotTime", _logic getVariable ["elite_spottime", 0.4]];
_settings set ["eliteCourage", _logic getVariable ["elite_courage", 1.0]];
_settings set ["eliteCommanding", _logic getVariable ["elite_commanding", 0.8]];
_settings set ["eliteGeneral", _logic getVariable ["elite_general", 0.4]];
_settings set ["eliteReloadSpeed", _logic getVariable ["elite_reloadspeed", 0.5]];
// Elite Behavior
_settings set ["eliteForceWalk", _logic getVariable ["elite_forcewalk", false]];
_settings set ["eliteForceStand", _logic getVariable ["elite_forcestand", false]];
_settings set ["eliteAnimSpeedCoef", _logic getVariable ["elite_animspeedcoef", 1.0]];
// Elite AI Features
_settings set ["eliteDisableCover", _logic getVariable ["elite_disablecover", false]];
_settings set ["eliteDisableMineDetection", _logic getVariable ["elite_disableminedetection", true]];
_settings set ["eliteDisableNVG", _logic getVariable ["elite_disablenvg", false]];
_settings set ["eliteDisableSuppression", _logic getVariable ["elite_disablesuppression", false]];
_settings set ["eliteDisableAutoCombat", _logic getVariable ["elite_disableautocombat", false]];
// Elite Equipment
_settings set ["eliteRemoveGrenades", _logic getVariable ["elite_removegrenades", false]];
_settings set ["eliteGrenadesToRemove", _logic getVariable ["elite_grenadestoremove", ""]];
_settings set ["eliteEnableFlashlights", _logic getVariable ["elite_enableflashlights", false]];
_settings set ["eliteFlashlightClass", _logic getVariable ["elite_flashlightclass", "acc_flashlight"]];

// ========== AA SETTINGS ==========
_settings set ["aaClassnames", _logic getVariable ["aagunnerclassnames", ""]];
_settings set ["enableAASkills", _logic getVariable ["enableaaskills", true]];
// AA Skills
_settings set ["aaAimingAccuracy", _logic getVariable ["aa_aimingaccuracy", 0.6]];
_settings set ["aaAimingShake", _logic getVariable ["aa_aimingshake", 0.1]];
_settings set ["aaAimingSpeed", _logic getVariable ["aa_aimingspeed", 0.6]];
_settings set ["aaSpotDistance", _logic getVariable ["aa_spotdistance", 0.9]];
_settings set ["aaSpotTime", _logic getVariable ["aa_spottime", 0.8]];
_settings set ["aaCourage", _logic getVariable ["aa_courage", 1.0]];
_settings set ["aaCommanding", _logic getVariable ["aa_commanding", 0.7]];
_settings set ["aaGeneral", _logic getVariable ["aa_general", 0.1]];
_settings set ["aaReloadSpeed", _logic getVariable ["aa_reloadspeed", 0.3]];
// AA Behavior
_settings set ["aaForceWalk", _logic getVariable ["aa_forcewalk", false]];
_settings set ["aaForceStand", _logic getVariable ["aa_forcestand", false]];
_settings set ["aaAnimSpeedCoef", _logic getVariable ["aa_animspeedcoef", 1.0]];
// AA AI Features
_settings set ["aaDisableCover", _logic getVariable ["aa_disablecover", false]];
_settings set ["aaDisableMineDetection", _logic getVariable ["aa_disableminedetection", true]];
_settings set ["aaDisableNVG", _logic getVariable ["aa_disablenvg", false]];
_settings set ["aaDisableSuppression", _logic getVariable ["aa_disablesuppression", false]];
_settings set ["aaDisableAutoCombat", _logic getVariable ["aa_disableautocombat", false]];
// AA Equipment
_settings set ["aaRemoveGrenades", _logic getVariable ["aa_removegrenades", false]];
_settings set ["aaGrenadesToRemove", _logic getVariable ["aa_grenadestoremove", ""]];
_settings set ["aaEnableFlashlights", _logic getVariable ["aa_enableflashlights", false]];
_settings set ["aaFlashlightClass", _logic getVariable ["aa_flashlightclass", "acc_flashlight"]];

// Mine Knowledge (global)
_settings set ["enableMineKnowledge", _logic getVariable ["enablemineknowledge", true]];

// Parse classname lists into arrays
private _eliteClassnamesArray = [_settings get "eliteClassnames"] call Recondo_fnc_parseClassnames;
private _aaClassnamesArray = [_settings get "aaClassnames"] call Recondo_fnc_parseClassnames;

// Parse grenade lists per category
private _baseGrenadesArray = [_settings get "baseGrenadesToRemove"] call Recondo_fnc_parseClassnames;
private _eliteGrenadesArray = [_settings get "eliteGrenadesToRemove"] call Recondo_fnc_parseClassnames;
private _aaGrenadesArray = [_settings get "aaGrenadesToRemove"] call Recondo_fnc_parseClassnames;

_settings set ["eliteClassnamesArray", _eliteClassnamesArray];
_settings set ["aaClassnamesArray", _aaClassnamesArray];
_settings set ["baseGrenadesArray", _baseGrenadesArray];
_settings set ["eliteGrenadesArray", _eliteGrenadesArray];
_settings set ["aaGrenadesArray", _aaGrenadesArray];

// Convert side number to side value
private _sideMap = [east, west, independent, civilian];
private _targetSideValue = _sideMap select (_settings get "targetSide");
_settings set ["targetSideValue", _targetSideValue];

// Store settings globally
RECONDO_AITWEAKS_SETTINGS = _settings;
publicVariable "RECONDO_AITWEAKS_SETTINGS";

// Debug flag for conditional logging
private _debug = _settings get "enableDebug";

if (_debug) then {
    diag_log format ["[RECONDO_AITWEAKS] Target side: %1", _targetSideValue];
    diag_log format ["[RECONDO_AITWEAKS] Elite classnames: %1", _eliteClassnamesArray];
    diag_log format ["[RECONDO_AITWEAKS] AA Gunner classnames: %1", _aaClassnamesArray];
};

// Enable mine knowledge on clients if needed
if (_settings get "enableMineKnowledge") then {
    RECONDO_AITWEAKS_MINE_KNOWLEDGE_ENABLED = true;
    publicVariable "RECONDO_AITWEAKS_MINE_KNOWLEDGE_ENABLED";
    
    // Tell all clients (including JIP) to initialize mine knowledge
    remoteExec ["Recondo_fnc_initMineKnowledge", [0, -2] select isDedicated, "RECONDO_AITWEAKS_MINE_JIP"];
};

// Function to determine unit type: "elite", "aa", or "base"
RECONDO_fnc_getUnitType = {
    params ["_unit"];
    
    private _settings = RECONDO_AITWEAKS_SETTINGS;
    private _unitType = typeOf _unit;
    
    // Check if unit is an AA Gunner first (takes priority)
    private _aaClassnames = _settings get "aaClassnamesArray";
    if (_unitType in _aaClassnames) exitWith { "aa" };
    
    // Check if unit is Elite
    private _eliteClassnames = _settings get "eliteClassnamesArray";
    if (_unitType in _eliteClassnames) exitWith { "elite" };
    
    // Default: Base soldier
    "base"
};

// Function to check if unit should be configured
RECONDO_fnc_shouldConfigureUnit = {
    params ["_unit"];
    
    private _settings = RECONDO_AITWEAKS_SETTINGS;
    
    // Must be infantry
    if (!(_unit isKindOf "CAManBase")) exitWith { false };
    
    // Must not be player
    if (isPlayer _unit) exitWith { false };
    
    // Must be correct side
    if (side _unit != (_settings get "targetSideValue")) exitWith { false };
    
    // Must not already be configured
    if (_unit getVariable ["RECONDO_AI_CONFIGURED", false]) exitWith { false };
    
    true
};

// Configure existing units
private _configuredBase = 0;
private _configuredElite = 0;
private _configuredAA = 0;
{
    if ([_x] call RECONDO_fnc_shouldConfigureUnit) then {
        private _unitType = [_x] call RECONDO_fnc_getUnitType;
        [_x, _unitType] call Recondo_fnc_configureUnit;
        
        switch (_unitType) do {
            case "base": { _configuredBase = _configuredBase + 1; };
            case "elite": { _configuredElite = _configuredElite + 1; };
            case "aa": { _configuredAA = _configuredAA + 1; };
        };
    };
} forEach allUnits;

// Add event handler for spawned units
RECONDO_AITWEAKS_ENTITY_EH = addMissionEventHandler ["EntityCreated", {
    params ["_entity"];
    
    // Delay slightly to ensure unit is fully initialized
    [{
        params ["_unit"];
        if ([_unit] call RECONDO_fnc_shouldConfigureUnit) then {
            private _unitType = [_unit] call RECONDO_fnc_getUnitType;
            [_unit, _unitType] call Recondo_fnc_configureUnit;
        };
    }, [_entity], 0.1] call CBA_fnc_waitAndExecute;
}];

// Flashlight monitoring loop - toggles lights based on time of day
// Only starts if any flashlight setting is enabled
private _anyFlashlightsEnabled = (_settings get "baseEnableFlashlights") || 
                                  (_settings get "eliteEnableFlashlights") || 
                                  (_settings get "aaEnableFlashlights");

if (_anyFlashlightsEnabled) then {
    [] spawn {
        private _lastState = sunOrMoon < 0.5;  // true = dark (lights on)
        private _debug = RECONDO_AITWEAKS_SETTINGS get "enableDebug";
        
        if (_debug) then {
            diag_log format ["[RECONDO_AITWEAKS] Flashlight monitoring loop started. Initial state: %1", ["DAY", "NIGHT"] select _lastState];
        };
        
        while {true} do {
            sleep 30;  // Check every 30 seconds
            
            private _isDark = sunOrMoon < 0.5;
            
            // Only update if state changed (day->night or night->day)
            if (_isDark != _lastState) then {
                private _mode = if (_isDark) then {"forceOn"} else {"forceOff"};
                private _count = 0;
                
                {
                    if (_x getVariable ["RECONDO_AITWEAKS_hasFlashlight", false]) then {
                        _x enableGunLights _mode;
                        _count = _count + 1;
                    };
                } forEach allUnits;
                
                if (_debug) then {
                    diag_log format ["[RECONDO_AITWEAKS] Light state changed to %1. Toggled flashlights %2 for %3 units.", 
                        ["DAY", "NIGHT"] select _isDark, _mode, _count];
                };
                
                _lastState = _isDark;
            };
        };
    };
    
    if (_debug) then {
        diag_log "[RECONDO_AITWEAKS] Flashlight monitoring enabled";
    };
};

// Final log (always shown - minimal info)
diag_log format ["[RECONDO_AITWEAKS] Initialized. Configured %1 Base, %2 Elite, %3 AA for side %4.", _configuredBase, _configuredElite, _configuredAA, _targetSideValue];
