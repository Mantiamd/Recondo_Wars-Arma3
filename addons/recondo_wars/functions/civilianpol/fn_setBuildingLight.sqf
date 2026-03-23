/*
    Recondo_fnc_setBuildingLight
    Enable or disable a night light on a building
    
    Parameters:
        _building - OBJECT - The building to light
        _lightOn - BOOL - Whether light should be on
    
    Returns:
        OBJECT - The light object (or objNull if turned off)
*/

params [
    ["_building", objNull, [objNull]],
    ["_lightOn", false, [false]]
];

if (isNull _building) exitWith { objNull };

private _existingLight = _building getVariable ["RECONDO_CIVPOL_Light", objNull];

if (_lightOn) then {
    // Create light if doesn't exist
    if (isNull _existingLight) then {
        private _lightBrightnessMin = RECONDO_CIVPOL_SETTINGS getOrDefault ["lightBrightnessMin", 0.02];
        private _lightBrightnessMax = RECONDO_CIVPOL_SETTINGS getOrDefault ["lightBrightnessMax", 0.08];
        
        // Create light at building position
        private _light = "#lightpoint" createVehicle (getPos _building);
        
        // Random warm color and brightness
        private _brightness = _lightBrightnessMin + (random (_lightBrightnessMax - _lightBrightnessMin));
        
        // Warm colors - yellow/orange tones
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
        _building setVariable ["RECONDO_CIVPOL_Light", _light];
        
        // Track globally
        RECONDO_CIVPOL_ACTIVE_LIGHTS pushBack _light;
        
        private _debugLogging = RECONDO_CIVPOL_SETTINGS getOrDefault ["debugLogging", false];
        if (_debugLogging) then {
            diag_log format ["[RECONDO_CIVPOL] Created night light on building at %1", getPos _building];
        };
        
        _light
    } else {
        _existingLight
    };
} else {
    // Remove light if exists
    if (!isNull _existingLight) then {
        // Remove from global tracking
        RECONDO_CIVPOL_ACTIVE_LIGHTS = RECONDO_CIVPOL_ACTIVE_LIGHTS - [_existingLight];
        
        deleteVehicle _existingLight;
        _building setVariable ["RECONDO_CIVPOL_Light", objNull];
        
        private _debugLogging = RECONDO_CIVPOL_SETTINGS getOrDefault ["debugLogging", false];
        if (_debugLogging) then {
            diag_log format ["[RECONDO_CIVPOL] Removed night light from building at %1", getPos _building];
        };
    };
    
    objNull
}
