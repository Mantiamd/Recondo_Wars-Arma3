/*
    Recondo_fnc_initPhotoCamera
    Client-side initialization for the photo camera system
    
    Description:
        Registers camera detection on each client using two methods:
        1. Fired EH on vn_camera_01 (reliable, works on all SOG PF versions)
        2. vn_photoCamera_pictureTaken scripted event (newer SOG PF versions)
        Both trigger the same validation handler.
    
    Parameters:
        _settings - HASHMAP - Module settings (first instance that initializes)
    
    Returns:
        Nothing
*/

if (!hasInterface) exitWith {};

params [["_settings", nil, [createHashMap]]];

if (isNil "_settings") exitWith {};

if (!isNil "RECONDO_PHOTO_CAMERA_INITIALIZED" && {RECONDO_PHOTO_CAMERA_INITIALIZED}) exitWith {};
RECONDO_PHOTO_CAMERA_INITIALIZED = true;

RECONDO_PHOTO_BB_CACHE = createHashMap;

// Debounce flag to prevent double-firing from both methods
RECONDO_PHOTO_LAST_FIRE_TIME = -1;

// Primary method: Fired EH on the SOG PF camera weapon
player addEventHandler ["Fired", {
    params ["_unit", "_weapon"];
    if (_weapon == "vn_camera_01") then {
        private _now = time;
        if (_now - RECONDO_PHOTO_LAST_FIRE_TIME < 1) exitWith {};
        RECONDO_PHOTO_LAST_FIRE_TIME = _now;
        [{call Recondo_fnc_handlePhotoTaken;}, [], 0.15] call CBA_fnc_waitAndExecute;
    };
}];

// Secondary method: SOG PF scripted event (newer versions)
[true, "vn_photoCamera_pictureTaken", {
    private _now = time;
    if (_now - RECONDO_PHOTO_LAST_FIRE_TIME < 1) exitWith {};
    RECONDO_PHOTO_LAST_FIRE_TIME = _now;
    [] call Recondo_fnc_handlePhotoTaken;
}] call BIS_fnc_addScriptedEventHandler;

private _debugLogging = _settings getOrDefault ["debugLogging", false];
if (_debugLogging) then {
    diag_log "[RECONDO_PHOTO] Client: Camera event handlers registered (Fired EH + scripted event)";
};
