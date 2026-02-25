/*
    Recondo_fnc_saveCivilianPOL
    Save civilian POL data to persistence
    
    Description:
        Saves home assignments and document-given state for each village.
        Called by the persistence system during auto-save.
    
    Parameters:
        None
    
    Returns:
        BOOL - True if saved successfully
*/

if (!isServer) exitWith { false };

// Check if POL system is active
if (isNil "RECONDO_CIVPOL_VILLAGES") exitWith { false };

private _debugLogging = RECONDO_CIVPOL_SETTINGS getOrDefault ["debugLogging", false];
private _saveData = [];

// ========================================
// COLLECT DATA FROM ALL VILLAGES
// ========================================

{
    private _markerName = _x;
    private _villageData = _y;
    
    private _homes = _villageData getOrDefault ["homes", []];
    
    // Only save home positions, jobs, and document state
    // Don't save runtime state like spawned units or current behavior
    private _homeSaveData = [];
    
    {
        _x params ["_homePos", "_job"];
        
        // Check if there's a spawned civilian with document state
        private _gaveDocuments = false;
        private _spawnedUnits = _villageData getOrDefault ["spawnedUnits", []];
        
        {
            if (!isNull _x && alive _x) then {
                if ((_x getVariable ["RECONDO_CIVPOL_Index", -1]) == _forEachIndex) then {
                    _gaveDocuments = _x getVariable ["RECONDO_CIVPOL_GaveDocuments", false];
                };
            };
        } forEach _spawnedUnits;
        
        _homeSaveData pushBack [_homePos, _job, _gaveDocuments];
    } forEach _homes;
    
    _saveData pushBack createHashMapFromArray [
        ["markerName", _markerName],
        ["homes", _homeSaveData]
    ];
    
} forEach RECONDO_CIVPOL_VILLAGES;

// ========================================
// SAVE TO PERSISTENCE
// ========================================

["civilianpol", _saveData] call Recondo_fnc_setSaveData;

if (_debugLogging) then {
    diag_log format ["[RECONDO_CIVPOL] Saved %1 villages to persistence", count _saveData];
};

true
