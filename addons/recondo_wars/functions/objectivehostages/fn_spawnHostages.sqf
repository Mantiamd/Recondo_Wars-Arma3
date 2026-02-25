/*
    Recondo_fnc_spawnHostages
    Spawns hostage units at the specified location
    
    Description:
        Creates hostage civilian units inside building positions
        at the location. Sets up ACE captive state and animations.
        Hostages spawn tied up (ACE handcuffed) in sitting animations.
    
    Parameters:
        _settings - HASHMAP - Module settings
        _marker - STRING - Location marker name
        _pos - ARRAY - Location position
        _hostagesAtMarker - ARRAY - Array of [hostageIndex, hostageName] for this location
    
    Returns:
        ARRAY - Array of spawned hostage units
*/

if (!isServer) exitWith { [] };

params [
    ["_settings", nil, [createHashMap]],
    ["_marker", "", [""]],
    ["_pos", [0,0,0], [[]]],
    ["_hostagesAtMarker", [], [[]]]
];

if (isNil "_settings" || count _hostagesAtMarker == 0) exitWith {
    diag_log "[RECONDO_HOSTAGE] ERROR: Invalid parameters for spawnHostages";
    []
};

private _instanceId = _settings get "instanceId";
private _hostageClassnames = _settings get "hostageClassnames";
private _hostageFaces = _settings getOrDefault ["hostageFaces", []];
private _hostageIdentities = _settings getOrDefault ["hostageIdentities", []];
private _hostageLoadouts = _settings getOrDefault ["hostageLoadouts", []];
private _hostageSpeakers = _settings getOrDefault ["hostageSpeakers", []];
private _animationMode = _settings get "animationMode";
private _hostageAnimation = _settings get "hostageAnimation";
private _debugLogging = _settings get "debugLogging";
private _makeInvincible = _settings getOrDefault ["makeInvincible", false];

// Available captive animations
private _captiveAnimations = [
    "Acts_AidlPsitMstpSsurWnonDnon01",  // Sitting, hands behind back
    "Acts_AidlPsitMstpSsurWnonDnon02",  // Kneeling
    "Acts_AidlPsitMstpSsurWnonDnon05"   // Sitting against wall
];

if (_debugLogging) then {
    diag_log format ["[RECONDO_HOSTAGE] Spawning %1 hostages at %2", count _hostagesAtMarker, _marker];
};

// Find building positions for placement
// Search ALL nearby objects (not just "House"/"Building") because composition-spawned
// objects may use different class types but still have valid building positions
private _nearbyObjects = nearestObjects [_pos, [], 50];
private _buildingPositions = [];

{
    private _obj = _x;
    // Skip units and vehicles - only want static objects
    if (!(_obj isKindOf "CAManBase") && !(_obj isKindOf "LandVehicle") && !(_obj isKindOf "Air") && !(_obj isKindOf "Ship")) then {
        private _i = 0;
        while {true} do {
            private _bPos = _obj buildingPos _i;
            if (_bPos isEqualTo [0,0,0]) exitWith {};
            _buildingPositions pushBack _bPos;
            _i = _i + 1;
        };
    };
} forEach _nearbyObjects;

if (_debugLogging) then {
    diag_log format ["[RECONDO_HOSTAGE] Found %1 building positions from %2 nearby objects", count _buildingPositions, count _nearbyObjects];
};

// Shuffle building positions for variety
_buildingPositions = _buildingPositions call BIS_fnc_arrayShuffle;

private _spawnedHostages = [];
private _posIndex = 0;

{
    _x params ["_hostageIndex", "_hostageName"];
    
    // Create unique hostage ID
    private _hostageId = format ["%1_hostage_%2", _instanceId, _hostageIndex];
    
    // Skip if already rescued
    if (_hostageId in RECONDO_HOSTAGE_RESCUED) then {
        if (_debugLogging) then {
            diag_log format ["[RECONDO_HOSTAGE] Skipping already rescued hostage: %1", _hostageName];
        };
    } else {
        // Find spawn position
        private _spawnPos = [];
        if (_posIndex < count _buildingPositions) then {
            _spawnPos = _buildingPositions select _posIndex;
            _posIndex = _posIndex + 1;
        } else {
            // Fallback to random position near center
            _spawnPos = _pos findEmptyPosition [2, 15, "CAManBase"];
            if (count _spawnPos == 0) then {
                _spawnPos = _pos getPos [3 + (random 5), random 360];
            };
        };
        
        // Select classname by index (keeps names, classnames, photos in sync)
        private _classname = _hostageClassnames select (_hostageIndex min (count _hostageClassnames - 1));
        
        // Create hostage group (civilian side)
        private _hostageGroup = createGroup [civilian, true];
        
        // Create the hostage unit
        private _hostage = _hostageGroup createUnit [_classname, _spawnPos, [], 0, "NONE"];
        _hostage setPosATL _spawnPos;
        
        // Disable all AI
        _hostage disableAI "MOVE";
        _hostage disableAI "PATH";
        _hostage disableAI "FSM";
        _hostage disableAI "ANIM";
        _hostage disableAI "TARGET";
        _hostage disableAI "AUTOTARGET";
        _hostage setUnitPos "DOWN";
        _hostage setBehaviour "CARELESS";
        _hostage allowFleeing 0;
        
        // ========================================
        // APPLY LOADOUT AND IDENTITY
        // ========================================
        
        // Get profile data for this hostage
        private _hostageLoadout = if (_hostageIndex < count _hostageLoadouts) then {
            _hostageLoadouts select _hostageIndex
        } else {
            []
        };
        private _hostageIdentity = if (_hostageIndex < count _hostageIdentities) then {
            _hostageIdentities select _hostageIndex
        } else {
            ""
        };
        private _hostageFace = if (_hostageIndex < count _hostageFaces) then {
            _hostageFaces select _hostageIndex
        } else {
            ""
        };
        private _hostageSpeaker = if (_hostageIndex < count _hostageSpeakers) then {
            _hostageSpeakers select _hostageIndex
        } else {
            ""
        };
        
        // Apply loadout if defined in profile (with delay for unit initialization)
        if (count _hostageLoadout > 0) then {
            if (_debugLogging) then {
                diag_log format ["[RECONDO_HOSTAGE] Scheduling loadout for hostage '%1' - %2 elements in array", _hostageName, count _hostageLoadout];
            };
            
            // Schedule loadout application after unit fully initializes
            [_hostage, _hostageLoadout, _hostageName, _debugLogging] spawn {
                params ["_unit", "_loadout", "_name", "_debug"];
                sleep 3;  // Wait for unit to fully initialize
                
                if (!isNull _unit && alive _unit) then {
                    _unit setUnitLoadout _loadout;
                    
                    if (_debug) then {
                        diag_log format ["[RECONDO_HOSTAGE] Applied profile loadout to hostage '%1' (delayed)", _name];
                    };
                };
            };
        } else {
            // Fallback: Strip to basic captive appearance (original behavior)
            removeAllWeapons _hostage;
            removeAllItems _hostage;
            removeAllAssignedItems _hostage;
            removeVest _hostage;
            removeBackpack _hostage;
            removeHeadgear _hostage;
            removeGoggles _hostage;
            
            // Add basic uniform if removed
            if (uniform _hostage == "") then {
                _hostage forceAddUniform "U_C_Poloshirt_stripped";
            };
            
            if (_debugLogging) then {
                diag_log "[RECONDO_HOSTAGE] No profile loadout - using default stripped loadout";
            };
        };
        
        // Apply identity if defined in profile (handles face, voice, name)
        if (_hostageIdentity != "") then {
            [_hostage, _hostageIdentity, ""] call BIS_fnc_setIdentity;
            
            if (_debugLogging) then {
                diag_log format ["[RECONDO_HOSTAGE] Applied identity '%1' to hostage '%2'", _hostageIdentity, _hostageName];
            };
        } else {
            // Use individual face/speaker when no identity class
            if (_hostageFace != "") then {
                _hostage setFace _hostageFace;
            };
            
            if (_hostageSpeaker != "") then {
                _hostage setSpeaker _hostageSpeaker;
            };
            
            if (_debugLogging && (_hostageFace != "" || _hostageSpeaker != "")) then {
                diag_log format ["[RECONDO_HOSTAGE] Applied face '%1' speaker '%2' to hostage '%3'", _hostageFace, _hostageSpeaker, _hostageName];
            };
        };
        
        // Select animation based on mode
        private _selectedAnim = switch (toLower _animationMode) do {
            case "random": { selectRandom _captiveAnimations };
            case "specific": { _hostageAnimation };
            default { selectRandom _captiveAnimations };
        };
        
        // Apply captive animation
        [_hostage, _selectedAnim] remoteExec ["switchMove", 0, true];
        
        // Set ACE captive state (handcuffed)
        _hostage setVariable ["ACE_captive", true, true];
        _hostage setVariable ["ace_captives_isHandcuffed", true, true];
        
        // Store hostage data
        _hostage setVariable ["RECONDO_HOSTAGE_marker", _marker, true];
        _hostage setVariable ["RECONDO_HOSTAGE_instanceId", _instanceId, true];
        _hostage setVariable ["RECONDO_HOSTAGE_hostageId", _hostageId, true];
        _hostage setVariable ["RECONDO_HOSTAGE_hostageIndex", _hostageIndex, true];
        _hostage setVariable ["RECONDO_HOSTAGE_isHostage", true, true];
        
        // Apply invincibility if enabled
        if (_makeInvincible) then {
            _hostage allowDamage false;
            if (_debugLogging) then {
                diag_log format ["[RECONDO_HOSTAGE] Hostage '%1' set to invincible", _hostageName];
            };
        };
        
        // Set hostage name (override any identity-set name)
        _hostage setName _hostageName;
        
        // Add to spawned list
        _spawnedHostages pushBack _hostage;
        
        if (_debugLogging) then {
            private _identityInfo = if (_hostageIdentity != "") then { _hostageIdentity } else {
                if (_hostageFace != "") then { _hostageFace } else { "default" }
            };
            diag_log format ["[RECONDO_HOSTAGE] Spawned hostage '%1' (ID: %2) at %3, animation: %4, identity: %5", 
                _hostageName, _hostageId, _spawnPos, _selectedAnim, _identityInfo];
        };
    };
} forEach _hostagesAtMarker;

// Store spawned hostages in global tracking
private _existingUnits = RECONDO_HOSTAGE_UNITS getOrDefault [_instanceId, []];
_existingUnits append _spawnedHostages;
RECONDO_HOSTAGE_UNITS set [_instanceId, _existingUnits];
publicVariable "RECONDO_HOSTAGE_UNITS";

if (_debugLogging) then {
    diag_log format ["[RECONDO_HOSTAGE] Spawned %1 hostages at %2", count _spawnedHostages, _marker];
};

_spawnedHostages
