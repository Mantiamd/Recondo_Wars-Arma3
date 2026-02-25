/*
    Recondo_fnc_initMineKnowledge
    Initializes the mine knowledge prevention system on client
    
    Description:
        Prevents AI from gaining knowledge about players when damaged
        by player-placed mines. This is achieved by removing the shot
        parent information from mine projectiles.
        
        Runs on machines with interface (players).
    
    Parameters:
        None
        
    Returns:
        Nothing
        
    Example:
        call Recondo_fnc_initMineKnowledge;
*/

// Only run on machines with interface (players)
if (!hasInterface) exitWith {};

// Remove existing handler if present (prevents duplicates)
if (!isNil "RECONDO_AITWEAKS_MINE_EH") then {
    player removeEventHandler ["Fired", RECONDO_AITWEAKS_MINE_EH];
};

// Add event handler to intercept mine placement
RECONDO_AITWEAKS_MINE_EH = player addEventHandler ["Fired", {
    params ["", "_weapon", "", "", "", "", "_projectile"];
    
    // Only process mine placement (weapon = "Put")
    if (_weapon != "Put") exitWith {};
    
    // Get mine trigger configuration
    private _triggerClass = getText (configOf _projectile >> "mineTrigger");
    private _triggerType = getText (configFile >> "CfgMineTriggers" >> _triggerClass >> "mineTriggerType");
    
    // Skip remote/timer explosives (they need ownership for player detonation)
    if (toLower _triggerType in ["remote", "timer"]) exitWith {};
    
    // Remove shot parent information to anonymize the mine
    // This prevents AI from knowing who placed it
    [_projectile, [objNull, objNull]] remoteExec ["setShotParents", 2];
}];

// Re-add handler on respawn (player object changes)
if (isNil "RECONDO_AITWEAKS_RESPAWN_EH") then {
    RECONDO_AITWEAKS_RESPAWN_EH = player addEventHandler ["Respawn", {
        call Recondo_fnc_initMineKnowledge;
    }];
};

// Debug logging
if (!isNil "RECONDO_AITWEAKS_SETTINGS" && {RECONDO_AITWEAKS_SETTINGS get "enableDebug"}) then {
    diag_log format ["[RECONDO_AITWEAKS] Mine knowledge prevention initialized for player: %1", player];
};
