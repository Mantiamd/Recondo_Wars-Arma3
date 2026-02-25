/*
    Recondo_fnc_restrictGraphics
    Enforces graphics restrictions on client
    
    Description:
        Handles gamma/brightness restrictions, terrain grid enforcement,
        and view distance limitations. Runs on clients with interface.
    
    Parameters:
        None (uses global RECONDO_PLAYEROPTIONS_SETTINGS)
        
    Returns:
        Nothing
*/

if (!hasInterface) exitWith {};

private _settings = RECONDO_PLAYEROPTIONS_SETTINGS;
private _debug = _settings get "enableDebug";

// ===== GAMMA/BRIGHTNESS RESTRICTIONS =====
if (_settings get "enableGammaRestrictions") then {
    private _maxGamma = _settings get "maxGamma";
    
    // Initialize warning state
    RECONDO_PO_GAMMA_WARNED = false;
    
    // Add per-frame handler to monitor gamma
    RECONDO_PO_GAMMA_HANDLER = [{
        params ["_args"];
        _args params ["_maxGamma", "_debug"];
        
        private _gamma = getVideoOptions getOrDefault ["gamma", 1.1];
        private _brightness = getVideoOptions getOrDefault ["brightness", 1.1];
        private _ppBrightness = getVideoOptions getOrDefault ["ppBrightness", 1.1];
        
        private _exceeds = (_gamma > _maxGamma) || (_brightness > _maxGamma) || (_ppBrightness > _maxGamma);
        
        if (_exceeds && !RECONDO_PO_GAMMA_WARNED) then {
            private _msg = format ["Gamma/Brightness cannot exceed %1 for this mission. Please lower your settings.", _maxGamma];
            cutText ["<t font='RobotoCondensedLight' align='center' size='2.3' color='#d6d6d6'>" + _msg + "</t>", "BLACK", -1, true, true];
            RECONDO_PO_GAMMA_WARNED = true;
            
            if (_debug) then {
                diag_log format ["[RECONDO_PLAYEROPTIONS] Gamma exceeded: G=%1 B=%2 PP=%3 (max=%4)", _gamma, _brightness, _ppBrightness, _maxGamma];
            };
        } else {
            if (!_exceeds && RECONDO_PO_GAMMA_WARNED) then {
                cutText ["", "BLACK IN"];
                RECONDO_PO_GAMMA_WARNED = false;
            };
        };
    }, 5, [_maxGamma, _debug]] call CBA_fnc_addPerFrameHandler;
    
    if (_debug) then {
        diag_log format ["[RECONDO_PLAYEROPTIONS] Gamma restrictions active. Max: %1", _maxGamma];
    };
};

// ===== TERRAIN GRID ENFORCEMENT =====
if (_settings get "enableTerrainGrid") then {
    private _terrainGridValue = _settings get "terrainGridValue";
    
    // Set initial value
    setTerrainGrid _terrainGridValue;
    
    // Initialize states
    RECONDO_PO_TERRAIN_BLACKOUT = false;
    RECONDO_PO_TERRAIN_GRACE = true;  // First violation is forgiven (mission load)
    RECONDO_PO_IN_VEHICLE = false;    // Track vehicle state
    RECONDO_PO_VEHICLE_GRACE = false; // Grace period after vehicle state change
    
    // Add per-frame handler to maintain terrain grid with blackout punishment
    RECONDO_PO_TERRAIN_HANDLER = [{
        params ["_args"];
        _args params ["_terrainGridValue", "_debug"];
        
        // Skip check if currently blacked out
        if (RECONDO_PO_TERRAIN_BLACKOUT) exitWith {};
        
        // Track vehicle state changes - entering/exiting vehicles can cause false positives
        private _inVehicle = vehicle player != player;
        if (_inVehicle != RECONDO_PO_IN_VEHICLE) then {
            RECONDO_PO_IN_VEHICLE = _inVehicle;
            RECONDO_PO_VEHICLE_GRACE = true;
            
            if (_debug) then {
                diag_log format ["[RECONDO_PLAYEROPTIONS] Vehicle state changed (in vehicle: %1). Grace period active.", _inVehicle];
            };
            
            // Reset vehicle grace after 3 seconds
            [{
                RECONDO_PO_VEHICLE_GRACE = false;
            }, [], 3] call CBA_fnc_waitAndExecute;
        };
        
        // Skip punishment during vehicle grace period (still enforce setting)
        if (RECONDO_PO_VEHICLE_GRACE) exitWith {
            if (getTerrainGrid != _terrainGridValue) then {
                setTerrainGrid _terrainGridValue;
            };
        };
        
        if (getTerrainGrid != _terrainGridValue) then {
            // If in grace period, silently fix and disable grace
            if (RECONDO_PO_TERRAIN_GRACE) then {
                setTerrainGrid _terrainGridValue;
                RECONDO_PO_TERRAIN_GRACE = false;
                if (_debug) then {
                    diag_log "[RECONDO_PLAYEROPTIONS] Terrain grid set during grace period (mission load).";
                };
            } else {
                // Violation detected - apply blackout punishment
                RECONDO_PO_TERRAIN_BLACKOUT = true;
                
                // Immediately reset terrain grid
                setTerrainGrid _terrainGridValue;
                
                // Black out screen with message
                cutText ["<t size='1.5' color='#ffffff' align='center'>This server's terrain/graphics settings are locked.<br/>You cannot adjust them.</t>", "BLACK OUT", 0.1, true, true];
                
                if (_debug) then {
                    diag_log "[RECONDO_PLAYEROPTIONS] Terrain grid violation detected. Blackout applied for 5 seconds.";
                };
                
                // Fade back in after 5 seconds
                [{
                    cutText ["", "BLACK IN", 1];
                    RECONDO_PO_TERRAIN_BLACKOUT = false;
                }, [], 5] call CBA_fnc_waitAndExecute;
            };
        } else {
            // Terrain grid matches - disable grace period (settings applied successfully)
            RECONDO_PO_TERRAIN_GRACE = false;
        };
    }, 2, [_terrainGridValue, _debug]] call CBA_fnc_addPerFrameHandler;
    
    if (_debug) then {
        diag_log format ["[RECONDO_PLAYEROPTIONS] Terrain grid enforced: %1 (per-frame check with blackout)", _terrainGridValue];
    };
};

// ===== VIEW DISTANCE RESTRICTIONS =====
if (_settings get "enableVDRestrictions") then {
    private _maxVD = _settings get "maxViewDistance";
    private _maxOVD = _settings get "maxObjectViewDistance";
    private _exemptClassnames = _settings get "exemptClassnamesArray";
    
    // Wait for player to be fully initialized
    [{!isNull player}, {
        params ["_maxVD", "_maxOVD", "_exemptClassnames", "_debug"];
        
        private _playerClass = typeOf player;
        private _isExempt = _playerClass in _exemptClassnames;
        
        if (_isExempt) then {
            if (_debug) then {
                diag_log format ["[RECONDO_PLAYEROPTIONS] Player exempt from VD restrictions (classname: %1)", _playerClass];
            };
        } else {
            // Apply view distance restrictions
            if (viewDistance > _maxVD) then {
                setViewDistance _maxVD;
            };
            
            if ((getObjectViewDistance select 0) > _maxOVD) then {
                setObjectViewDistance _maxOVD;
            };
            
            // Add handler to maintain restrictions
            RECONDO_PO_VD_HANDLER = [{
                params ["_args"];
                _args params ["_maxVD", "_maxOVD"];
                
                if (viewDistance > _maxVD) then {
                    setViewDistance _maxVD;
                };
                
                if ((getObjectViewDistance select 0) > _maxOVD) then {
                    setObjectViewDistance _maxOVD;
                };
            }, 30, [_maxVD, _maxOVD]] call CBA_fnc_addPerFrameHandler;
            
            if (_debug) then {
                diag_log format ["[RECONDO_PLAYEROPTIONS] View distance restricted to %1/%2", _maxVD, _maxOVD];
            };
        };
    }, [_maxVD, _maxOVD, _exemptClassnames, _debug]] call CBA_fnc_waitUntilAndExecute;
};

if (_debug) then {
    diag_log "[RECONDO_PLAYEROPTIONS] Graphics restrictions initialized";
};
