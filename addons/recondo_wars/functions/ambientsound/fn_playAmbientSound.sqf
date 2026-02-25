/*
    Recondo_fnc_playAmbientSound
    Plays a 3D positioned ambient sound
    
    Description:
        Plays a sound at the specified position. Can use either
        default mod sounds or custom mission sounds.
    
    Parameters:
        _pos - ARRAY - Position to play sound at [x, y, z]
        _settings - HASHMAP - Module settings
    
    Returns:
        Nothing
    
    Example:
        [_pos, _settings] call Recondo_fnc_playAmbientSound;
*/

if (!isServer) exitWith {};

params [
    ["_pos", [0,0,0], [[]]],
    ["_settings", nil, [createHashMap]]
];

if (isNil "_settings") exitWith {
    diag_log "[RECONDO_AMBIENT] ERROR: No settings for playAmbientSound";
};

private _soundMode = _settings get "soundMode";
private _soundCategory = _settings get "soundCategory";
private _singleSound = _settings get "singleSound";
private _customSoundsPath = _settings get "customSoundsPath";
private _customSoundsList = _settings get "customSoundsList";
private _soundDistance = _settings get "soundDistance";
private _soundVolume = _settings get "soundVolume";
private _debugLogging = _settings get "debugLogging";

private _soundFile = "";

// Determine which sound to play
if (_customSoundsPath != "" && _customSoundsList != "") then {
    // Custom mission sounds
    private _sounds = _customSoundsList splitString ",";
    _sounds = _sounds apply { _x trim [" ", 0] };
    _sounds = _sounds select { _x != "" };
    
    if (count _sounds > 0) then {
        if (_soundMode == 0) then {
            // Single mode - use first sound or specified sound
            _soundFile = format ["%1\%2", _customSoundsPath, _sounds select 0];
        } else {
            // Pool mode - random selection
            _soundFile = format ["%1\%2", _customSoundsPath, selectRandom _sounds];
        };
    };
} else {
    // Default mod sounds
    private _availableSounds = [_soundCategory] call Recondo_fnc_getAmbientSounds;
    
    if (count _availableSounds > 0) then {
        if (_soundMode == 0 && _singleSound != "") then {
            // Single mode with specified sound
            _soundFile = _singleSound;
        } else {
            if (_soundMode == 0) then {
                // Single mode - use first available
                _soundFile = _availableSounds select 0;
            } else {
                // Pool mode - random selection
                _soundFile = selectRandom _availableSounds;
            };
        };
    };
};

if (_soundFile == "") exitWith {
    if (_debugLogging) then {
        diag_log "[RECONDO_AMBIENT] WARNING: No sound file available to play";
    };
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_AMBIENT] Playing sound '%1' at %2, volume: %3, distance: %4m",
        _soundFile, _pos, _soundVolume, _soundDistance];
};

// Play the 3D sound
// playSound3D [sound, source, isInside, position, volume, pitch, distance, offset, local]
playSound3D [_soundFile, objNull, false, _pos, _soundVolume, 1, _soundDistance, 0, false];
