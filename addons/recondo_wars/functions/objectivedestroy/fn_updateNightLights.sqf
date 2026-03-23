/*
    Recondo_fnc_updateObjDestroyNightLights
    Background loop that updates night lights for Objective Destroy composition buildings
    
    Description:
        Periodically checks time of day (sunOrMoon) and enables/disables
        lights in all registered Objective Destroy composition buildings.
        Uses same warm light colors as civilian POL system.
    
    Parameters:
        None
    
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

// Prevent multiple loops
if (!RECONDO_OBJDESTROY_NIGHT_LIGHTS_ENABLED) exitWith {
    diag_log "[RECONDO_OBJDESTROY] Night lights disabled - not starting loop";
};

diag_log "[RECONDO_OBJDESTROY] Starting night lights update loop";

// Start per-frame handler to update lights periodically
[{
    // Exit if night lights are disabled
    if (!RECONDO_OBJDESTROY_NIGHT_LIGHTS_ENABLED) exitWith {};
    
    // No buildings registered yet
    if (count RECONDO_OBJDESTROY_NIGHT_LIGHT_BUILDINGS == 0) exitWith {};
    
    // ========================================
    // DETERMINE IF LIGHTS SHOULD BE ON
    // ========================================
    
    // Use sunOrMoon for dynamic sunrise/sunset detection
    // sunOrMoon < 0.5 means it's dark outside (night time)
    private _shouldLightsBeOn = (sunOrMoon < 0.5);
    
    // ========================================
    // UPDATE LIGHTS FOR EACH BUILDING
    // ========================================
    
    {
        private _building = _x;
        
        if (!isNull _building) then {
            private _existingLight = _building getVariable ["RECONDO_OBJDESTROY_Light", objNull];
            
            if (_shouldLightsBeOn) then {
                // Create light if doesn't exist
                if (isNull _existingLight) then {
                    // Light brightness settings (same as civilian POL)
                    private _lightBrightnessMin = 0.02;
                    private _lightBrightnessMax = 0.08;
                    
                    // Create light at building position
                    private _light = "#lightpoint" createVehicle (getPos _building);
                    
                    // Random warm color and brightness
                    private _brightness = _lightBrightnessMin + (random (_lightBrightnessMax - _lightBrightnessMin));
                    
                    // Warm colors - yellow/orange tones (same as civilian POL)
                    private _colors = [
                        [255, 217, 100],  // Warm yellow
                        [255, 200, 80],   // Golden
                        [255, 180, 60],   // Orange-yellow
                        [230, 200, 120]   // Soft white
                    ];
                    private _color = selectRandom _colors;
                    
                    _light setLightBrightness _brightness;
                    _light setLightColor _color;
                    _light setLightAmbient _color;
                    _light setLightAttenuation [0, 0, 0, 1, 10, 20];
                    
                    // Attach to building, offset upward into the structure
                    _light lightAttachObject [_building, [0, 0, 2.5]];
                    
                    // Store reference
                    _building setVariable ["RECONDO_OBJDESTROY_Light", _light];
                    
                    // Track globally
                    RECONDO_OBJDESTROY_ACTIVE_LIGHTS pushBack _light;
                };
            } else {
                // Remove light if exists (daytime)
                if (!isNull _existingLight) then {
                    // Remove from global tracking
                    RECONDO_OBJDESTROY_ACTIVE_LIGHTS = RECONDO_OBJDESTROY_ACTIVE_LIGHTS - [_existingLight];
                    
                    deleteVehicle _existingLight;
                    _building setVariable ["RECONDO_OBJDESTROY_Light", objNull];
                };
            };
        };
    } forEach RECONDO_OBJDESTROY_NIGHT_LIGHT_BUILDINGS;
    
}, 30, []] call CBA_fnc_addPerFrameHandler; // Check every 30 seconds
