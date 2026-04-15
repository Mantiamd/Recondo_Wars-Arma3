/*
    Recondo_fnc_modulePlayerOptions
    Main module initialization - runs on server only
    
    Description:
        Called when the Player Options module is activated.
        Reads all module attributes and broadcasts to clients.
    
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
    diag_log "[RECONDO_PLAYEROPTIONS] Module attempted to run on non-server. Exiting.";
};

// Check if already initialized
if (!isNil "RECONDO_PLAYEROPTIONS_INITIALIZED") exitWith {
    diag_log "[RECONDO_PLAYEROPTIONS] WARNING: Module already initialized. Only one Player Options module should be placed.";
};

RECONDO_PLAYEROPTIONS_INITIALIZED = true;

// Create settings hashmap
private _settings = createHashMap;

// Debug
_settings set ["enableDebug", _logic getVariable ["enabledebug", false]];
if (RECONDO_MASTER_DEBUG) then { _settings set ["enableDebug", true]; };
private _debug = _settings get "enableDebug";

// Graphics Restrictions
_settings set ["enableGammaRestrictions", _logic getVariable ["enablegammarestrictions", true]];
_settings set ["maxGamma", _logic getVariable ["maxgamma", 1.05]];
_settings set ["enableTerrainGrid", _logic getVariable ["enableterraingrid", true]];
_settings set ["terrainGridValue", _logic getVariable ["terraingridvalue", 3.125]];

// View Distance
_settings set ["enableVDRestrictions", _logic getVariable ["enablevdrestrictions", true]];
_settings set ["maxViewDistance", _logic getVariable ["maxviewdistance", 8000]];
_settings set ["maxObjectViewDistance", _logic getVariable ["maxobjectviewdistance", 8000]];
_settings set ["exemptClassnames", _logic getVariable ["exemptclassnames", ""]];

// Parse exempt classnames into array (using shared parseClassnames function)
private _exemptClassnamesArray = [_settings get "exemptClassnames"] call Recondo_fnc_parseClassnames;
_settings set ["exemptClassnamesArray", _exemptClassnamesArray];

// Player Traits
_settings set ["enableTraits", _logic getVariable ["enabletraits", true]];
_settings set ["camouflageCoef", _logic getVariable ["camouflagecoef", 0.6]];
_settings set ["audibleCoef", _logic getVariable ["audiblecoef", 0.6]];

// Forced Faces
_settings set ["enableForcedFaces", _logic getVariable ["enableforcedfaces", false]];
_settings set ["forcedFaceUnits", _logic getVariable ["forcedfaceunits", ""]];
_settings set ["forcedFaceList", _logic getVariable ["forcedfacelist", ""]];
_settings set ["faceCheckInterval", _logic getVariable ["facecheckinterval", 300]];

// Parse face settings into arrays
private _forcedFaceUnitsArray = [_settings get "forcedFaceUnits"] call Recondo_fnc_parseClassnames;
private _forcedFaceListArray = [_settings get "forcedFaceList"] call Recondo_fnc_parseClassnames;
_settings set ["forcedFaceUnitsArray", _forcedFaceUnitsArray];
_settings set ["forcedFaceListArray", _forcedFaceListArray];

// ACE Rations
_settings set ["enableDisableRations", _logic getVariable ["enabledisablerations", false]];
_settings set ["rationsExemptUnits", _logic getVariable ["rationsexemptunits", ""]];

// Parse rations exempt units
private _rationsExemptUnitsArray = [_settings get "rationsExemptUnits"] call Recondo_fnc_parseClassnames;
_settings set ["rationsExemptUnitsArray", _rationsExemptUnitsArray];

// Pilot Restrictions
_settings set ["enablePilotRestrictions", _logic getVariable ["enablepilotrestrictions", false]];
_settings set ["restrictedAircraft", _logic getVariable ["restrictedaircraft", ""]];
_settings set ["allowedPilots", _logic getVariable ["allowedpilots", ""]];

// Parse pilot restriction arrays
private _restrictedAircraftArray = [_settings get "restrictedAircraft"] call Recondo_fnc_parseClassnames;
private _allowedPilotsArray = [_settings get "allowedPilots"] call Recondo_fnc_parseClassnames;
_settings set ["restrictedAircraftArray", _restrictedAircraftArray];
_settings set ["allowedPilotsArray", _allowedPilotsArray];

// Sound Settings
_settings set ["enableLimitPainSounds", _logic getVariable ["enablelimitpainsounds", true]];

// Body Bags
_settings set ["enableCarryBodybags", _logic getVariable ["enablecarrybodybags", true]];

// Store settings globally and broadcast to clients
RECONDO_PLAYEROPTIONS_SETTINGS = _settings;
publicVariable "RECONDO_PLAYEROPTIONS_SETTINGS";

if (_debug) then {
    diag_log "[RECONDO_PLAYEROPTIONS] === MODULE SETTINGS ===";
    diag_log format ["[RECONDO_PLAYEROPTIONS] Gamma Restrictions: %1 (max: %2)", _settings get "enableGammaRestrictions", _settings get "maxGamma"];
    diag_log format ["[RECONDO_PLAYEROPTIONS] Terrain Grid: %1 (value: %2)", _settings get "enableTerrainGrid", _settings get "terrainGridValue"];
    diag_log format ["[RECONDO_PLAYEROPTIONS] VD Restrictions: %1 (max: %2/%3)", _settings get "enableVDRestrictions", _settings get "maxViewDistance", _settings get "maxObjectViewDistance"];
    diag_log format ["[RECONDO_PLAYEROPTIONS] Exempt Classnames: %1", _exemptClassnamesArray];
    diag_log format ["[RECONDO_PLAYEROPTIONS] Traits: %1 (camo: %2, audible: %3)", _settings get "enableTraits", _settings get "camouflageCoef", _settings get "audibleCoef"];
    diag_log format ["[RECONDO_PLAYEROPTIONS] Forced Faces: %1 (units: %2, faces: %3)", _settings get "enableForcedFaces", _forcedFaceUnitsArray, _forcedFaceListArray];
    diag_log format ["[RECONDO_PLAYEROPTIONS] Disable Rations: %1 (units: %2)", _settings get "enableDisableRations", _rationsExemptUnitsArray];
    diag_log format ["[RECONDO_PLAYEROPTIONS] Pilot Restrictions: %1 (aircraft: %2, pilots: %3)", _settings get "enablePilotRestrictions", _restrictedAircraftArray, _allowedPilotsArray];
    diag_log format ["[RECONDO_PLAYEROPTIONS] Limit Pain Sounds: %1", _settings get "enableLimitPainSounds"];
    diag_log format ["[RECONDO_PLAYEROPTIONS] Carry Bodybags: %1", _settings get "enableCarryBodybags"];
};

diag_log "[RECONDO_PLAYEROPTIONS] Module initialized. Settings broadcast to clients.";
