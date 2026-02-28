/*
    Recondo_fnc_updateCustomSiteNightLights
    Background loop that updates night lights for Custom Site Spawn buildings
    
    Description:
        Periodically checks time of day and enables/disables lights
        in all registered Custom Site composition buildings.
    
    Parameters:
        None
    
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

if (!RECONDO_CSS_NIGHT_LIGHTS_ENABLED) exitWith {
    diag_log "[RECONDO_CSS] Night lights disabled - not starting loop";
};

diag_log "[RECONDO_CSS] Starting night lights update loop";

[{
    if (!RECONDO_CSS_NIGHT_LIGHTS_ENABLED) exitWith {};
    if (count RECONDO_CSS_NIGHT_LIGHT_BUILDINGS == 0) exitWith {};
    
    private _shouldLightsBeOn = (sunOrMoon < 0.5);
    
    {
        private _building = _x;
        
        if (!isNull _building) then {
            private _existingLight = _building getVariable ["RECONDO_CSS_Light", objNull];
            
            if (_shouldLightsBeOn) then {
                if (isNull _existingLight) then {
                    private _lightBrightnessMin = 0.02;
                    private _lightBrightnessMax = 0.08;
                    
                    private _light = "#lightpoint" createVehicle (getPos _building);
                    
                    private _brightness = _lightBrightnessMin + (random (_lightBrightnessMax - _lightBrightnessMin));
                    
                    private _colors = [
                        [255, 217, 100],
                        [255, 200, 80],
                        [255, 180, 60],
                        [230, 200, 120]
                    ];
                    private _color = selectRandom _colors;
                    
                    _light setLightBrightness _brightness;
                    _light setLightColor _color;
                    _light setLightAmbient _color;
                    _light setLightAttenuation [0, 0, 0, 1, 10, 20];
                    
                    _light lightAttachObject [_building, [0, 0, 2.5]];
                    
                    _building setVariable ["RECONDO_CSS_Light", _light, true];
                    
                    RECONDO_CSS_ACTIVE_LIGHTS pushBack _light;
                };
            } else {
                if (!isNull _existingLight) then {
                    RECONDO_CSS_ACTIVE_LIGHTS = RECONDO_CSS_ACTIVE_LIGHTS - [_existingLight];
                    
                    deleteVehicle _existingLight;
                    _building setVariable ["RECONDO_CSS_Light", objNull, true];
                };
            };
        };
    } forEach RECONDO_CSS_NIGHT_LIGHT_BUILDINGS;
    
}, 30, []] call CBA_fnc_addPerFrameHandler;
