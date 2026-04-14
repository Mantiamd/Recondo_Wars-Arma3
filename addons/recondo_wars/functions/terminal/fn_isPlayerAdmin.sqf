/*
    Recondo_fnc_isPlayerAdmin
    Checks if the local player has terminal access rights
    
    Description:
        Returns true if the player is a server admin, or if role-based
        access is enabled and the player's unit classname is in the
        allowed list. Pass true as the first parameter to restrict
        the check to admin-only (ignoring role access).
    
    Parameters:
        _adminOnly - BOOL - (Optional, default false) When true, only
                     checks admin status and ignores role-based access.
    
    Returns:
        BOOL - True if player has access
    
    Examples:
        if ([] call Recondo_fnc_isPlayerAdmin) then { ... };
        if ([true] call Recondo_fnc_isPlayerAdmin) then { ... };
*/

params [["_adminOnly", false, [false]]];

if (!hasInterface) exitWith { false };

// ========================================
// ADMIN CHECK
// ========================================

private _isAdmin = (admin owner player) > 0;

if (!_isAdmin) then {
    _isAdmin = serverCommandAvailable "#kick";
};

if (!_isAdmin && !isMultiplayer) then {
    _isAdmin = true;
};

if (!_isAdmin && isServer && hasInterface) then {
    _isAdmin = true;
};

if (_isAdmin) exitWith { true };

// Admin-only mode stops here
if (_adminOnly) exitWith { false };

// ========================================
// ROLE-BASED ACCESS CHECK
// ========================================

if (isNil "RECONDO_TERMINAL_SETTINGS") exitWith { false };

private _enableRoleAccess = RECONDO_TERMINAL_SETTINGS getOrDefault ["enableRoleAccess", false];
if (!_enableRoleAccess) exitWith { false };

private _allowedClassnames = RECONDO_TERMINAL_SETTINGS getOrDefault ["allowedClassnames", []];
if (count _allowedClassnames == 0) exitWith { false };

(typeOf player) in _allowedClassnames
