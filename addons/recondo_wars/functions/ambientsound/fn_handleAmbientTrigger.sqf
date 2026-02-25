/*
    Recondo_fnc_handleAmbientTrigger
    Handles ambient sound trigger activation
    
    Description:
        Called when a unit enters an ambient sound trigger area.
        Schedules the sound to play after a delay.
        Sound originates from near the triggering unit's position
        to simulate wildlife being disturbed and revealing their position.
    
    Parameters:
        _trigger - OBJECT - The trigger that was activated
        _triggeringUnits - ARRAY - Units that activated the trigger (thisList)
    
    Returns:
        Nothing
    
    Example:
        [thisTrigger, thisList] call Recondo_fnc_handleAmbientTrigger;
*/

if (!isServer) exitWith {};

params [["_trigger", objNull, [objNull]], ["_triggeringUnits", [], [[]]]];

if (isNull _trigger) exitWith {};

private _settings = _trigger getVariable "RECONDO_AMBIENT_settings";
private _markerName = _trigger getVariable "RECONDO_AMBIENT_marker";

if (isNil "_settings") exitWith {
    diag_log "[RECONDO_AMBIENT] ERROR: No settings found on trigger";
};

private _delay = _settings get "delay";
private _debugLogging = _settings get "debugLogging";

// Find the first valid triggering unit to use as sound origin reference
private _sourceUnit = objNull;
{
    if (alive _x) exitWith { _sourceUnit = _x; };
} forEach _triggeringUnits;

// Update last triggered time (prevents re-triggering during cooldown)
_trigger setVariable ["RECONDO_AMBIENT_lastTriggered", time, false];

if (_debugLogging) then {
    private _sourceInfo = if (!isNull _sourceUnit) then { format ["near %1", _sourceUnit] } else { "at marker center" };
    diag_log format ["[RECONDO_AMBIENT] Trigger activated at %1, sound will play %2 in %3 seconds", _markerName, _sourceInfo, _delay];
};

// Schedule sound playback after delay
[{
    params ["_trigger", "_settings", "_markerName", "_sourceUnit"];
    
    if (isNull _trigger) exitWith {};
    
    private _debugLogging = _settings get "debugLogging";
    private _soundOriginDistance = _settings get "soundOriginDistance";
    private _soundOriginHeight = _settings get "soundOriginHeight";
    private _soundPos = [];
    
    // Calculate sound position based on triggering unit or fallback to marker
    if (!isNull _sourceUnit && alive _sourceUnit) then {
        // Position sound near the triggering unit (configurable offset, random direction)
        private _unitPos = getPosATL _sourceUnit;
        _soundPos = _unitPos getPos [_soundOriginDistance, random 360];
        _soundPos set [2, (_unitPos select 2) + _soundOriginHeight];
        
        if (_debugLogging) then {
            diag_log format ["[RECONDO_AMBIENT] Playing sound near triggering unit %1 at %2 (dist: %3m, height: %4m)", _sourceUnit, _soundPos, _soundOriginDistance, _soundOriginHeight];
        };
    } else {
        // Fallback to marker position if no valid unit
        private _pos = getMarkerPos _markerName;
        _soundPos = _pos getPos [random _soundOriginDistance, random 360];
        _soundPos set [2, (_pos select 2) + _soundOriginHeight];
        
        if (_debugLogging) then {
            diag_log format ["[RECONDO_AMBIENT] Playing sound at marker center (fallback) %1", _soundPos];
        };
    };
    
    // Play the sound
    [_soundPos, _settings] call Recondo_fnc_playAmbientSound;
    
}, [_trigger, _settings, _markerName, _sourceUnit], _delay] call CBA_fnc_waitAndExecute;
