/*
    Recondo_fnc_removeRallypoint
    Remove/pack a rally point
    
    Description:
        Called when a rally point is packed via the action on the tent.
        Removes the tent object, deletes the marker, and updates the rally array.
    
    Parameters:
        0: OBJECT - The rally tent object to remove
    
    Returns:
        Nothing
    
    Execution:
        Server only (called via remoteExec)
*/

if (!isServer) exitWith {};

params [["_tent", objNull, [objNull]]];

if (isNull _tent) exitWith {
    diag_log "[RECONDO_DRP] ERROR: removeRallypoint called with null tent!";
};

private _settings = RECONDO_DRP_SETTINGS;
if (isNil "_settings") exitWith {
    diag_log "[RECONDO_DRP] ERROR: Settings not initialized!";
};

private _enableDebug = _settings get "enableDebug";
private _enablePersistence = _settings get "enablePersistence";

// ========================================
// FIND AND REMOVE FROM RALLIES ARRAY
// ========================================

private _rallies = missionNamespace getVariable ["RECONDO_DRP_RALLIES", []];
private _tentNetId = netId _tent;
private _newRallies = [];
private _removedMarker = "";

{
    private _rallyTentNetId = _x get "tentNetId";
    
    if (_rallyTentNetId == _tentNetId) then {
        // This is the rally to remove
        _removedMarker = _x get "markerName";
        
        // Delete marker
        if (!isNil "_removedMarker" && {_removedMarker != ""} && {getMarkerColor _removedMarker != ""}) then {
            deleteMarker _removedMarker;
        };
        
        if (_enableDebug) then {
            diag_log format ["[RECONDO_DRP] Removing rally: %1", _removedMarker];
        };
    } else {
        // Keep this rally
        _newRallies pushBack _x;
    };
} forEach _rallies;

// ========================================
// DELETE TENT OBJECT
// ========================================

if (!isNull _tent) then {
    deleteVehicle _tent;
};

// ========================================
// UPDATE GLOBAL RALLIES
// ========================================

RECONDO_DRP_RALLIES = _newRallies;
publicVariable "RECONDO_DRP_RALLIES";

// ========================================
// SAVE TO PERSISTENCE
// ========================================

if (_enablePersistence) then {
    [] call Recondo_fnc_saveRallypoints;
};

// ========================================
// LOG
// ========================================

if (_enableDebug) then {
    diag_log format ["[RECONDO_DRP] Rally removed. Remaining rallies: %1", count RECONDO_DRP_RALLIES];
};
