/*
    Recondo_fnc_assignDogBulletMagnet
    Creates an invisible target attached to the dog
    
    Description:
        Creates an invisible unit attached to the dog that makes the target side's AI
        detect and shoot at the dog, while the tracker side ignores it.
    
    Parameters:
        _dog - The dog unit to attach bullet magnet to
    
    Returns:
        Bullet magnet object or objNull if failed
*/

if (!isServer) exitWith { objNull };

params ["_dog"];

// Defensive check - ensure settings are initialized
if (isNil "RECONDO_TRACKERS_SETTINGS") exitWith {
    diag_log "[RECONDO_TRACKERS] ERROR: Settings not initialized when assigning bullet magnet";
    objNull
};

private _settings = RECONDO_TRACKERS_SETTINGS;
private _trackerSide = _settings get "trackerSide";
private _debugLogging = _settings get "debugLogging";

if (isNull _dog) exitWith {
    if (_debugLogging) then {
        diag_log "[RECONDO_TRACKERS] ERROR: Null dog provided to bullet magnet function";
    };
    objNull
};

// Create group for the bullet magnet (same side as trackers)
// This makes target side see it as enemy, tracker side sees it as friendly
private _magnetGroup = createGroup [_trackerSide, true];
if (isNull _magnetGroup) exitWith {
    if (_debugLogging) then {
        diag_log "[RECONDO_TRACKERS] ERROR: Failed to create bullet magnet group";
    };
    objNull
};

// Create invisible VR unit as bullet magnet
private _bulletMagnet = _magnetGroup createUnit ["C_Soldier_VR_F", [0, 0, 0], [], 0, "FORM"];
if (isNull _bulletMagnet) exitWith {
    deleteGroup _magnetGroup;
    if (_debugLogging) then {
        diag_log "[RECONDO_TRACKERS] ERROR: Failed to create bullet magnet unit";
    };
    objNull
};

// Make the bullet magnet invisible
for "_i" from 0 to 5 do {
    _bulletMagnet setObjectTextureGlobal [_i, ""];
    _bulletMagnet setObjectMaterialGlobal [_i, ""];
};

// Configure bullet magnet
_bulletMagnet setCaptive false;          // Not captive so AI will engage
_bulletMagnet allowDamage false;         // Invulnerable - damage goes to dog
_bulletMagnet setDamage 0;
_bulletMagnet addEventHandler ["HandleDamage", {0}]; // Extra protection
_bulletMagnet setBehaviour "CARELESS";
_bulletMagnet setUnitPos "MIDDLE";
_bulletMagnet setSpeaker "NoVoice";
_bulletMagnet disableAI "MOVE";
_bulletMagnet disableAI "TARGET";
_bulletMagnet disableAI "AUTOTARGET";
_bulletMagnet setVariable ["vn_sam_disable_death_noise", true, true];

// Enable collisions
_bulletMagnet enableCollisionWith _dog;

// Attach to dog (slightly above so bullets can hit)
_bulletMagnet attachTo [_dog, [0, 0, 0.2]];
_bulletMagnet setObjectScale 0.6; // Smaller hitbox

// Final safety settings
_bulletMagnet allowDamage false;
_bulletMagnet setDamage 0;
_bulletMagnet enableSimulation true;

// Store reference on dog for cleanup
_dog setVariable ["RECONDO_TRACKERS_bulletMagnet", _bulletMagnet, true];

if (_debugLogging) then {
    diag_log format ["[RECONDO_TRACKERS] Bullet magnet assigned to dog %1 (side: %2)", _dog, side _bulletMagnet];
};

_bulletMagnet
