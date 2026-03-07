/*
    Recondo_fnc_updatePhotoNightLights
    Updates night lighting for photo objective buildings
    
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

private _isNight = (sunOrMoon < 0.5);

if (_isNight && !RECONDO_PHOTO_NIGHT_LIGHTS_ENABLED) then {
    RECONDO_PHOTO_NIGHT_LIGHTS_ENABLED = true;
    {
        if (!isNull _x && alive _x) then {
            private _light = "#lightpoint" createVehicle (getPosATL _x);
            _light setLightBrightness 0.3;
            _light setLightAmbient [1.0, 0.8, 0.5];
            _light setLightColor [1.0, 0.8, 0.5];
            _light setLightAttenuation [2, 0, 0.3, 0.3];
            _light attachTo [_x, [0, 0, 2]];
            RECONDO_PHOTO_ACTIVE_LIGHTS pushBack _light;
        };
    } forEach RECONDO_PHOTO_NIGHT_LIGHT_BUILDINGS;
} else {
    if (!_isNight && RECONDO_PHOTO_NIGHT_LIGHTS_ENABLED) then {
        RECONDO_PHOTO_NIGHT_LIGHTS_ENABLED = false;
        { deleteVehicle _x; } forEach RECONDO_PHOTO_ACTIVE_LIGHTS;
        RECONDO_PHOTO_ACTIVE_LIGHTS = [];
    };
};

[{ [] call Recondo_fnc_updatePhotoNightLights; }, [], 60] call CBA_fnc_waitAndExecute;
