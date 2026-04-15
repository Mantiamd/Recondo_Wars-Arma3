/*
    Recondo_fnc_moduleStaticWeaponLimit
    Main module initialization
    
    Description:
        Disables ACE carry on specified static weapon classnames while
        keeping drag enabled. Uses CBA class event handlers to catch
        weapons created at any time, including ACE CSW assembly.
        
        Server reads module settings and broadcasts to all clients.
        All machines register CBA class event handlers locally.
    
    Parameters:
        0: OBJECT - Logic module
        1: ARRAY - Synced units (unused)
        2: BOOL - Is activated
        
    Returns:
        Nothing
*/

params ["_logic", "_units", "_activated"];

if (!isServer) exitWith {};

if (!isNil "RECONDO_STATICWEAPONLIMIT_INITIALIZED") exitWith {
    diag_log "[RECONDO_STATICWEAPONLIMIT] WARNING: Module already initialized. Only one module should be placed.";
};

RECONDO_STATICWEAPONLIMIT_INITIALIZED = true;

private _classnamesRaw = _logic getVariable ["weaponclassnames", ""];
private _debugLogging = _logic getVariable ["debuglogging", false];
if (RECONDO_MASTER_DEBUG) then { _debugLogging = true; };

if (_classnamesRaw == "") exitWith {
    if (_debugLogging) then {
        diag_log "[RECONDO_STATICWEAPONLIMIT] No classnames specified. Module inactive.";
    };
};

private _classnames = (_classnamesRaw splitString ",") apply { trim _x } select { _x != "" };

if (count _classnames == 0) exitWith {
    if (_debugLogging) then {
        diag_log "[RECONDO_STATICWEAPONLIMIT] No valid classnames after parsing. Module inactive.";
    };
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_STATICWEAPONLIMIT] Initializing with %1 classnames: %2", count _classnames, _classnames];
};

// Broadcast to all clients (including JIP) to register handlers and start scanner
[[_classnames, _debugLogging], {
    params ["_classnames", "_debugLogging"];
    
    // Prevent duplicate registration on same machine
    if (!isNil "RECONDO_STATICWEAPONLIMIT_HANDLERS_REGISTERED") exitWith {};
    RECONDO_STATICWEAPONLIMIT_HANDLERS_REGISTERED = true;
    
    // Store classnames globally for the scanner loop
    RECONDO_STATICWEAPONLIMIT_CLASSNAMES = _classnames;
    RECONDO_STATICWEAPONLIMIT_DEBUG = _debugLogging;
    
    // Register CBA class event handlers for immediate enforcement
    {
        private _classname = _x;
        
        [_classname, "init", {
            params ["_weapon"];
            
            [_weapon, false] call ace_dragging_fnc_setCarryable;
            [_weapon, true] call ace_dragging_fnc_setDraggable;
            
        }, true, [], true] call CBA_fnc_addClassEventHandler;
        
        if (_debugLogging) then {
            diag_log format ["[RECONDO_STATICWEAPONLIMIT] Registered handler for classname: %1", _classname];
        };
        
    } forEach _classnames;
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_STATICWEAPONLIMIT] Client registered %1 CBA handler(s)", count _classnames];
    };
    
    // Start periodic scanner loop as a safety net
    [] spawn {
        private _classnames = RECONDO_STATICWEAPONLIMIT_CLASSNAMES;
        private _debugLogging = RECONDO_STATICWEAPONLIMIT_DEBUG;
        
        if (_debugLogging) then {
            diag_log "[RECONDO_STATICWEAPONLIMIT] Starting periodic scanner loop (5 second interval)";
        };
        
        while {true} do {
            sleep 5;
            
            private _fixedCount = 0;
            
            {
                private _classname = _x;
                private _objects = allMissionObjects _classname;
                
                {
                    private _weapon = _x;
                    private _canCarry = _weapon getVariable ["ace_dragging_canCarry", true];
                    
                    // Only apply if carry is not already disabled
                    if (_canCarry) then {
                        [_weapon, false] call ace_dragging_fnc_setCarryable;
                        [_weapon, true] call ace_dragging_fnc_setDraggable;
                        _fixedCount = _fixedCount + 1;
                    };
                } forEach _objects;
                
            } forEach _classnames;
            
            if (_debugLogging && _fixedCount > 0) then {
                diag_log format ["[RECONDO_STATICWEAPONLIMIT] Scanner fixed %1 weapon(s)", _fixedCount];
            };
        };
    };
    
    if (_debugLogging) then {
        diag_log "[RECONDO_STATICWEAPONLIMIT] Client initialization complete (CBA handlers + scanner)";
    };
}] remoteExec ["call", 0, true];

diag_log format ["[RECONDO_STATICWEAPONLIMIT] Module initialized. Restricted %1 weapon class(es).", count _classnames];
