/*
    Recondo_fnc_initACREJamming
    Initializes ACRE jamming on the client
    
    Description:
        Called on each client to start the ACRE jamming loop.
        Only runs if ACRE is detected. Safe to call multiple times
        (will not start duplicate loops).
    
    Parameters:
        None
    
    Returns:
        Nothing
*/

// Only run on clients with player
if (!hasInterface) exitWith {};

// Check if ACRE is loaded
if (!isClass (configFile >> "cfgPatches" >> "acre_main")) exitWith {
    diag_log "[RECONDO_JAMMER] ACRE not detected, jamming disabled for this client.";
};

// Prevent duplicate loops
if (!isNil "RECONDO_JAMMER_LOOP_RUNNING" && {RECONDO_JAMMER_LOOP_RUNNING}) exitWith {
    // Loop already running, just let it pick up new jammer data
};

RECONDO_JAMMER_LOOP_RUNNING = true;

diag_log "[RECONDO_JAMMER] Initializing ACRE jamming loop for client.";

// Start the jamming loop
[] spawn Recondo_fnc_acreJamLoop;
