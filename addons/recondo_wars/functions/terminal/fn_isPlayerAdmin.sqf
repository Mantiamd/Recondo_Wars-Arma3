/*
    Recondo_fnc_isPlayerAdmin
    Checks if the local player has admin rights
    
    Description:
        Returns true if the player is logged in as server admin
        or has server command privileges.
    
    Parameters:
        None
    
    Returns:
        BOOL - True if player is admin
    
    Example:
        if ([] call Recondo_fnc_isPlayerAdmin) then { ... };
*/

if (!hasInterface) exitWith { false };

// Check if player is logged in as admin
// admin command returns: 0 = not admin, 1 = logged in, 2 = voted in
private _isAdmin = (admin owner player) > 0;

// Alternative check: can player use server commands
if (!_isAdmin) then {
    _isAdmin = serverCommandAvailable "#kick";
};

// For singleplayer/hosted, the host is always admin
if (!_isAdmin && !isMultiplayer) then {
    _isAdmin = true;
};

// For hosted servers, check if player is the server
if (!_isAdmin && isServer && hasInterface) then {
    _isAdmin = true;
};

_isAdmin
