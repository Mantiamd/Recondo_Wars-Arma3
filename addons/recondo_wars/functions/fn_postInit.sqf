/*
    Recondo_fnc_postInit
    Post-initialization for Recondo Wars addon
    
    Description:
        Handles client-side initialization after mission start.
*/

// AI Tweaks: Mine knowledge system needs to run on clients with interface
if (hasInterface && {!isNil "RECONDO_AITWEAKS_MINE_KNOWLEDGE_ENABLED"} && {RECONDO_AITWEAKS_MINE_KNOWLEDGE_ENABLED}) then {
    call Recondo_fnc_initMineKnowledge;
};

// Player Options: Wait for settings to be available and apply client-side effects
if (hasInterface) then {
    [{
        !isNil "RECONDO_PLAYEROPTIONS_SETTINGS"
    }, {
        // Exit if settings never arrived (module not placed)
        if (isNil "RECONDO_PLAYEROPTIONS_SETTINGS") exitWith {
            diag_log "[RECONDO_PLAYEROPTIONS] No Player Options module placed.";
        };
        
        private _settings = RECONDO_PLAYEROPTIONS_SETTINGS;
        
        // Apply graphics restrictions
        if (_settings get "enableGammaRestrictions" || _settings get "enableTerrainGrid" || _settings get "enableVDRestrictions") then {
            [] call Recondo_fnc_restrictGraphics;
        };
        
        // Apply player traits
        if (_settings get "enableTraits") then {
            [] call Recondo_fnc_adjustTraits;
        };
        
        // Apply forced faces
        if (_settings get "enableForcedFaces") then {
            [] call Recondo_fnc_enforceFaces;
        };
        
        // Disable ACE rations if enabled
        if (_settings get "enableDisableRations") then {
            [] call Recondo_fnc_disableRations;
        };
        
        // Apply pilot restrictions
        if (_settings get "enablePilotRestrictions") then {
            [] call Recondo_fnc_restrictPilots;
        };
        
        // Apply pain sound limiter
        if (_settings get "enableLimitPainSounds") then {
            [] call Recondo_fnc_limitPainSounds;
        };
        
        // Enable body bag carry/drag
        if (_settings get "enableCarryBodybags") then {
            [] call Recondo_fnc_enableCarryBodybags;
        };
        
        if (_settings get "enableDebug") then {
            diag_log "[RECONDO_PLAYEROPTIONS] Client settings applied";
        };
    }, [], 30] call CBA_fnc_waitUntilAndExecute;
    
    // Initialize ACE Arsenal Areas (client-side)
    [] call Recondo_fnc_initArsenalAreas;
    
    // Initialize Disable ACE Rations Areas (client-side)
    [] call Recondo_fnc_initDisableRationsAreas;
    
    // Initialize JIP to Group Leader Areas (client-side)
    [] call Recondo_fnc_initJIPAreas;
    
    // Initialize ACE Spectator Objects (client-side)
    [] call Recondo_fnc_initSpectatorObjects;
    
    // Initialize Base to Outpost Tele (client-side)
    [] call Recondo_fnc_initOutpostTele;
    
    // Initialize Deployable Rallypoint System (client-side)
    [] call Recondo_fnc_initDeployableRallypoint;
    
    // Apply Chat Control settings for JIP players
    [] call Recondo_fnc_applyChatSettings;
    
    // Initialize Player Limitations (client-side inventory enforcement)
    [] call Recondo_fnc_initPlayerLimitations;
};

diag_log "[RECONDO_WARS] PostInit complete";
