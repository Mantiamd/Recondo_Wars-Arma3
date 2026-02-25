/*
    Recondo_fnc_loadCivilianPOL
    Load civilian POL data from persistence
    
    Description:
        Loads saved home assignments and document-given state.
        Called during module initialization before villages are set up.
    
    Parameters:
        None
    
    Returns:
        BOOL - True if data was loaded
*/

if (!isServer) exitWith { false };

// Check if persistence module exists
if (isNil "RECONDO_PERSISTENCE_SETTINGS") exitWith { 
    diag_log "[RECONDO_CIVPOL] No persistence module found, skipping load";
    false 
};

private _debugLogging = RECONDO_CIVPOL_SETTINGS getOrDefault ["debugLogging", false];

// ========================================
// RETRIEVE SAVED DATA
// ========================================

private _saveData = ["civilianpol", []] call Recondo_fnc_getSaveData;

if (count _saveData == 0) exitWith {
    if (_debugLogging) then {
        diag_log "[RECONDO_CIVPOL] No saved data found";
    };
    false
};

// ========================================
// RESTORE VILLAGE DATA
// ========================================

{
    private _markerName = _x getOrDefault ["markerName", ""];
    private _homes = _x getOrDefault ["homes", []];
    
    if (_markerName != "" && count _homes > 0) then {
        // Create or update village data
        private _villageData = RECONDO_CIVPOL_VILLAGES getOrDefault [_markerName, createHashMap];
        
        // Restore homes (position, job, document state)
        // Note: Building references will be re-found during village init
        _villageData set ["homes", _homes];
        
        RECONDO_CIVPOL_VILLAGES set [_markerName, _villageData];
    };
} forEach _saveData;

diag_log format ["[RECONDO_CIVPOL] Loaded %1 villages from persistence", count _saveData];

true
