/*
    Recondo_fnc_moduleAITweaks
    Main module initialization - runs on server only
    
    Description:
        Called when the AI Tweaks module is activated.
        Reads all module attributes, configures existing units,
        and sets up event handlers for spawned units.
        
        Supports multiple instances targeting different sides.
        
        Supports three unit categories per instance:
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

if (!isServer) exitWith {
    diag_log "[RECONDO_AITWEAKS] Module attempted to run on non-server. Exiting.";
};

// Check if this side already has an instance
private _requestedSide = _logic getVariable ["targetside", 0];
private _sideMap = [east, west, independent, civilian];
private _requestedSideValue = _sideMap select _requestedSide;

{
    if ((_x get "targetSideValue") isEqualTo _requestedSideValue) exitWith {
        diag_log format ["[RECONDO_AITWEAKS] WARNING: An AI Tweaks module for side %1 is already active. Ignoring duplicate.", _requestedSideValue];
        _requestedSideValue = nil;
    };
} forEach RECONDO_AITWEAKS_INSTANCES;

if (isNil "_requestedSideValue") exitWith {};

// Get all module attributes and store in hashmap
private _settings = createHashMap;

// General
_settings set ["targetSide", _requestedSide];
_settings set ["enableDebug", _logic getVariable ["enabledebug", false]];
if (RECONDO_MASTER_DEBUG) then { _settings set ["enableDebug", true]; };

// ========== BASE SETTINGS ==========
_settings set ["enableBaseSkills", _logic getVariable ["enablebaseskills", true]];
_settings set ["baseAimingAccuracy", _logic getVariable ["base_aimingaccuracy", 0.1]];
_settings set ["baseAimingShake", _logic getVariable ["base_aimingshake", 0.1]];
_settings set ["baseAimingSpeed", _logic getVariable ["base_aimingspeed", 0.1]];
_settings set ["baseSpotDistance", _logic getVariable ["base_spotdistance", 0.1]];
_settings set ["baseSpotTime", _logic getVariable ["base_spottime", 0.1]];
_settings set ["baseCourage", _logic getVariable ["base_courage", 1.0]];
_settings set ["baseCommanding", _logic getVariable ["base_commanding", 1.0]];
_settings set ["baseGeneral", _logic getVariable ["base_general", 0.1]];
_settings set ["baseReloadSpeed", _logic getVariable ["base_reloadspeed", 0.3]];
_settings set ["baseForceWalk", _logic getVariable ["base_forcewalk", true]];
_settings set ["baseForceStand", _logic getVariable ["base_forcestand", true]];
_settings set ["baseAnimSpeedCoef", _logic getVariable ["base_animspeedcoef", 1.5]];
_settings set ["baseDisableCover", _logic getVariable ["base_disablecover", false]];
_settings set ["baseDisableMineDetection", _logic getVariable ["base_disableminedetection", true]];
_settings set ["baseDisableNVG", _logic getVariable ["base_disablenvg", true]];
_settings set ["baseDisableSuppression", _logic getVariable ["base_disablesuppression", false]];
_settings set ["baseDisableAutoCombat", _logic getVariable ["base_disableautocombat", false]];
_settings set ["baseRemoveGrenades", _logic getVariable ["base_removegrenades", true]];
_settings set ["baseGrenadesToRemove", _logic getVariable ["base_grenadestoremove", ""]];
_settings set ["baseEnableFlashlights", _logic getVariable ["base_enableflashlights", false]];
_settings set ["baseFlashlightClass", _logic getVariable ["base_flashlightclass", "acc_flashlight"]];

// ========== ELITE SETTINGS ==========
_settings set ["eliteClassnames", _logic getVariable ["eliteclassnames", ""]];
_settings set ["enableEliteSkills", _logic getVariable ["enableeliteskills", true]];
_settings set ["eliteAimingAccuracy", _logic getVariable ["elite_aimingaccuracy", 0.4]];
_settings set ["eliteAimingShake", _logic getVariable ["elite_aimingshake", 0.3]];
_settings set ["eliteAimingSpeed", _logic getVariable ["elite_aimingspeed", 0.4]];
_settings set ["eliteSpotDistance", _logic getVariable ["elite_spotdistance", 0.5]];
_settings set ["eliteSpotTime", _logic getVariable ["elite_spottime", 0.4]];
_settings set ["eliteCourage", _logic getVariable ["elite_courage", 1.0]];
_settings set ["eliteCommanding", _logic getVariable ["elite_commanding", 0.8]];
_settings set ["eliteGeneral", _logic getVariable ["elite_general", 0.4]];
_settings set ["eliteReloadSpeed", _logic getVariable ["elite_reloadspeed", 0.5]];
_settings set ["eliteForceWalk", _logic getVariable ["elite_forcewalk", false]];
_settings set ["eliteForceStand", _logic getVariable ["elite_forcestand", false]];
_settings set ["eliteAnimSpeedCoef", _logic getVariable ["elite_animspeedcoef", 1.0]];
_settings set ["eliteDisableCover", _logic getVariable ["elite_disablecover", false]];
_settings set ["eliteDisableMineDetection", _logic getVariable ["elite_disableminedetection", true]];
_settings set ["eliteDisableNVG", _logic getVariable ["elite_disablenvg", false]];
_settings set ["eliteDisableSuppression", _logic getVariable ["elite_disablesuppression", false]];
_settings set ["eliteDisableAutoCombat", _logic getVariable ["elite_disableautocombat", false]];
_settings set ["eliteRemoveGrenades", _logic getVariable ["elite_removegrenades", false]];
_settings set ["eliteGrenadesToRemove", _logic getVariable ["elite_grenadestoremove", ""]];
_settings set ["eliteEnableFlashlights", _logic getVariable ["elite_enableflashlights", false]];
_settings set ["eliteFlashlightClass", _logic getVariable ["elite_flashlightclass", "acc_flashlight"]];

// ========== AA SETTINGS ==========
_settings set ["aaClassnames", _logic getVariable ["aagunnerclassnames", ""]];
_settings set ["enableAASkills", _logic getVariable ["enableaaskills", true]];
_settings set ["aaAimingAccuracy", _logic getVariable ["aa_aimingaccuracy", 0.6]];
_settings set ["aaAimingShake", _logic getVariable ["aa_aimingshake", 0.1]];
_settings set ["aaAimingSpeed", _logic getVariable ["aa_aimingspeed", 0.6]];
_settings set ["aaSpotDistance", _logic getVariable ["aa_spotdistance", 0.9]];
_settings set ["aaSpotTime", _logic getVariable ["aa_spottime", 0.8]];
_settings set ["aaCourage", _logic getVariable ["aa_courage", 1.0]];
_settings set ["aaCommanding", _logic getVariable ["aa_commanding", 0.7]];
_settings set ["aaGeneral", _logic getVariable ["aa_general", 0.1]];
_settings set ["aaReloadSpeed", _logic getVariable ["aa_reloadspeed", 0.3]];
_settings set ["aaForceWalk", _logic getVariable ["aa_forcewalk", false]];
_settings set ["aaForceStand", _logic getVariable ["aa_forcestand", false]];
_settings set ["aaAnimSpeedCoef", _logic getVariable ["aa_animspeedcoef", 1.0]];
_settings set ["aaDisableCover", _logic getVariable ["aa_disablecover", false]];
_settings set ["aaDisableMineDetection", _logic getVariable ["aa_disableminedetection", true]];
_settings set ["aaDisableNVG", _logic getVariable ["aa_disablenvg", false]];
_settings set ["aaDisableSuppression", _logic getVariable ["aa_disablesuppression", false]];
_settings set ["aaDisableAutoCombat", _logic getVariable ["aa_disableautocombat", false]];
_settings set ["aaRemoveGrenades", _logic getVariable ["aa_removegrenades", false]];
_settings set ["aaGrenadesToRemove", _logic getVariable ["aa_grenadestoremove", ""]];
_settings set ["aaEnableFlashlights", _logic getVariable ["aa_enableflashlights", false]];
_settings set ["aaFlashlightClass", _logic getVariable ["aa_flashlightclass", "acc_flashlight"]];

// Mine Knowledge (global)
_settings set ["enableMineKnowledge", _logic getVariable ["enablemineknowledge", true]];

// Parse classname lists into arrays
private _eliteClassnamesArray = [_settings get "eliteClassnames"] call Recondo_fnc_parseClassnames;
private _aaClassnamesArray = [_settings get "aaClassnames"] call Recondo_fnc_parseClassnames;

private _baseGrenadesArray = [_settings get "baseGrenadesToRemove"] call Recondo_fnc_parseClassnames;
private _eliteGrenadesArray = [_settings get "eliteGrenadesToRemove"] call Recondo_fnc_parseClassnames;
private _aaGrenadesArray = [_settings get "aaGrenadesToRemove"] call Recondo_fnc_parseClassnames;

_settings set ["eliteClassnamesArray", _eliteClassnamesArray];
_settings set ["aaClassnamesArray", _aaClassnamesArray];
_settings set ["baseGrenadesArray", _baseGrenadesArray];
_settings set ["eliteGrenadesArray", _eliteGrenadesArray];
_settings set ["aaGrenadesArray", _aaGrenadesArray];

_settings set ["targetSideValue", _requestedSideValue];

// Store in instances array
RECONDO_AITWEAKS_INSTANCES pushBack _settings;
publicVariable "RECONDO_AITWEAKS_INSTANCES";

private _debug = _settings get "enableDebug";

if (_debug) then {
    diag_log format ["[RECONDO_AITWEAKS] Instance %1: Target side: %2", count RECONDO_AITWEAKS_INSTANCES, _requestedSideValue];
    diag_log format ["[RECONDO_AITWEAKS] Elite classnames: %1", _eliteClassnamesArray];
    diag_log format ["[RECONDO_AITWEAKS] AA Gunner classnames: %1", _aaClassnamesArray];
};

// Enable mine knowledge on clients if needed (only once globally)
if (_settings get "enableMineKnowledge") then {
    if (isNil "RECONDO_AITWEAKS_MINE_KNOWLEDGE_ENABLED") then {
        RECONDO_AITWEAKS_MINE_KNOWLEDGE_ENABLED = true;
        publicVariable "RECONDO_AITWEAKS_MINE_KNOWLEDGE_ENABLED";
        remoteExec ["Recondo_fnc_initMineKnowledge", [0, -2] select isDedicated, "RECONDO_AITWEAKS_MINE_JIP"];
    };
};

// Configure existing units for this instance
private _configuredBase = 0;
private _configuredElite = 0;
private _configuredAA = 0;
{
    private _unit = _x;
    if (!(_unit isKindOf "CAManBase")) then { continue };
    if (isPlayer _unit) then { continue };
    if (side _unit != _requestedSideValue) then { continue };
    if (_unit getVariable ["RECONDO_AI_CONFIGURED", false]) then { continue };
    
    private _unitType = [_unit, _settings] call Recondo_fnc_getAITweaksUnitType;
    [_unit, _unitType, _settings] call Recondo_fnc_configureUnit;
    
    switch (_unitType) do {
        case "base": { _configuredBase = _configuredBase + 1; };
        case "elite": { _configuredElite = _configuredElite + 1; };
        case "aa": { _configuredAA = _configuredAA + 1; };
    };
} forEach allUnits;

// Register shared EntityCreated handler (only once, handles all instances)
if (!RECONDO_AITWEAKS_EH_REGISTERED) then {
    RECONDO_AITWEAKS_EH_REGISTERED = true;
    
    addMissionEventHandler ["EntityCreated", {
        params ["_entity"];
        
        [{
            params ["_unit"];
            if (!(_unit isKindOf "CAManBase")) exitWith {};
            if (isPlayer _unit) exitWith {};
            if (_unit getVariable ["RECONDO_AI_CONFIGURED", false]) exitWith {};
            
            private _unitSide = side _unit;
            
            {
                private _instanceSettings = _x;
                if (_unitSide == (_instanceSettings get "targetSideValue")) exitWith {
                    private _unitType = [_unit, _instanceSettings] call Recondo_fnc_getAITweaksUnitType;
                    [_unit, _unitType, _instanceSettings] call Recondo_fnc_configureUnit;
                };
            } forEach RECONDO_AITWEAKS_INSTANCES;
        }, [_entity], 0.1] call CBA_fnc_waitAndExecute;
    }];
};

// Flashlight monitoring loop (shared across instances, only started once)
if (isNil "RECONDO_AITWEAKS_FLASHLIGHT_LOOP_STARTED") then {
    private _anyFlashlightsEnabled = false;
    {
        private _s = _x;
        if ((_s get "baseEnableFlashlights") || (_s get "eliteEnableFlashlights") || (_s get "aaEnableFlashlights")) exitWith {
            _anyFlashlightsEnabled = true;
        };
    } forEach RECONDO_AITWEAKS_INSTANCES;
    
    if (_anyFlashlightsEnabled) then {
        RECONDO_AITWEAKS_FLASHLIGHT_LOOP_STARTED = true;
        
        [] spawn {
            private _lastState = sunOrMoon < 0.5;
            
            while {true} do {
                sleep 30;
                
                private _isDark = sunOrMoon < 0.5;
                
                if (_isDark != _lastState) then {
                    private _mode = if (_isDark) then {"forceOn"} else {"forceOff"};
                    private _count = 0;
                    
                    {
                        if (_x getVariable ["RECONDO_AITWEAKS_hasFlashlight", false]) then {
                            _x enableGunLights _mode;
                            _count = _count + 1;
                        };
                    } forEach allUnits;
                    
                    _lastState = _isDark;
                };
            };
        };
    };
} else {
    // Loop already running; check if this new instance enables flashlights
    private _thisFlashlights = (_settings get "baseEnableFlashlights") || 
                               (_settings get "eliteEnableFlashlights") || 
                               (_settings get "aaEnableFlashlights");
    if (_thisFlashlights && isNil "RECONDO_AITWEAKS_FLASHLIGHT_LOOP_STARTED") then {
        RECONDO_AITWEAKS_FLASHLIGHT_LOOP_STARTED = true;
        [] spawn {
            private _lastState = sunOrMoon < 0.5;
            while {true} do {
                sleep 30;
                private _isDark = sunOrMoon < 0.5;
                if (_isDark != _lastState) then {
                    private _mode = if (_isDark) then {"forceOn"} else {"forceOff"};
                    { if (_x getVariable ["RECONDO_AITWEAKS_hasFlashlight", false]) then { _x enableGunLights _mode; }; } forEach allUnits;
                    _lastState = _isDark;
                };
            };
        };
    };
};

// Final log
diag_log format ["[RECONDO_AITWEAKS] Instance %1 initialized for side %2. Configured %3 Base, %4 Elite, %5 AA.", 
    count RECONDO_AITWEAKS_INSTANCES, _requestedSideValue, _configuredBase, _configuredElite, _configuredAA];
