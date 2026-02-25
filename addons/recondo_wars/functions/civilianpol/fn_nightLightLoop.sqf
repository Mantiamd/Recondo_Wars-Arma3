/*
    Recondo_fnc_nightLightLoop
    Background loop that updates night lights across all spawned villages
    
    Description:
        Periodically checks time of day and updates lights for all
        spawned villages. Called from module init.
    
    Parameters:
        None
    
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

// Start per-frame handler to update lights periodically
[{
    if (isNil "RECONDO_CIVPOL_SETTINGS") exitWith {};
    
    private _enableNightLights = RECONDO_CIVPOL_SETTINGS getOrDefault ["enableNightLights", true];
    if (!_enableNightLights) exitWith {};
    
    // Update all spawned villages
    {
        private _markerName = _x;
        private _villageData = _y;
        
        if (_villageData getOrDefault ["spawned", false]) then {
            [_markerName] call Recondo_fnc_updateVillageNightLights;
        };
    } forEach RECONDO_CIVPOL_VILLAGES;
    
}, 30, []] call CBA_fnc_addPerFrameHandler; // Check every 30 seconds
