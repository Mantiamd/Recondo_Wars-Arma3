/*
    Recondo_fnc_initSpectatorObjects
    ACE Spectator Object - Client-side initialization
    
    Description:
        Waits for spectator object settings and adds ACE interactions to configured objects.
    
    Returns:
        Nothing
*/

if (!hasInterface) exitWith {};

// Wait for settings to be available
[{
    !isNil "RECONDO_SPECTATOROBJECTS" && {count RECONDO_SPECTATOROBJECTS > 0}
}, {
    private _spectatorObjects = RECONDO_SPECTATOROBJECTS;
    
    // Process each spectator object configuration
    {
        private _settings = _x;
        private _objectVarName = _settings get "objectVarName";
        private _actionText = _settings get "actionText";
        private _debug = _settings get "enableDebug";
        
        // Find the object by variable name
        private _object = missionNamespace getVariable [_objectVarName, objNull];
        
        if (isNull _object) then {
            diag_log format ["[RECONDO_SPECTATOR] WARNING: Object '%1' not found!", _objectVarName];
        } else {
            // Create ACE action for this object
            private _action = [
                format ["RECONDO_Spectator_%1", _objectVarName],  // Action ID
                _actionText,                                       // Action text
                "",  // No icon
                {
                    // Statement - enter spectator
                    params ["_target", "_player", "_params"];
                    _params params ["_settings"];
                    
                    [_settings] call Recondo_fnc_enterSpectator;
                },
                {
                    // Condition - always available when looking at object
                    true
                },
                {},                                                // Insert children
                [_settings]                                        // Parameters
            ] call ace_interact_menu_fnc_createAction;
            
            // Add action to the object
            [_object, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;
            
            if (_debug) then {
                diag_log format ["[RECONDO_SPECTATOR] Added ACE action to object: %1", _objectVarName];
            };
        };
    } forEach _spectatorObjects;
    
}, []] call CBA_fnc_waitUntilAndExecute;
