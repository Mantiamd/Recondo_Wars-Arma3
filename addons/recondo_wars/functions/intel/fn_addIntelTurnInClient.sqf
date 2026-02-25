/*
    Recondo_fnc_addIntelTurnInClient
    Client-side setup for intel turn-in ACE action
    
    Description:
        Called on clients (including JIP) to add the ACE interaction
        for turning in intel to the specified object.
    
    Parameters:
        _object - OBJECT - The object to add the action to
        _actionText - STRING - The display text for the action
    
    Returns:
        Nothing
    
    Example:
        [_intelOfficer, "Turn In Intel"] remoteExec ["Recondo_fnc_addIntelTurnInClient", 0, true];
*/

if (!hasInterface) exitWith {};

params [
    ["_object", objNull, [objNull]],
    ["_actionText", "Turn In Intel", [""]]
];

if (isNull _object) exitWith {};

// Check if action already exists on this object
private _existingActions = _object getVariable ["Recondo_Intel_ActionAdded", false];
if (_existingActions) exitWith {};

// Create the ACE action
private _action = [
    "Recondo_Intel_TurnIn",                    // Action name
    _actionText,                                // Display name
    "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\intel_ca.paa",  // Icon
    {
        // Statement - executed when action is used
        params ["_target", "_player", "_params"];
        
        // Run on server
        [_player] remoteExec ["Recondo_fnc_processTurnIn", 2];
    },
    {
        // Condition - when is action shown
        params ["_target", "_player", "_params"];
        
        // Check if player has any intel items
        private _hasIntel = [_player] call Recondo_fnc_playerHasIntel;
        _hasIntel
    },
    {},                                         // Insert children code
    [],                                         // Action parameters
    [0, 0, 0],                                  // Position offset
    2,                                          // Distance
    [false, false, false, false, false],       // Flags
    {}                                          // Modifier function
] call ace_interact_menu_fnc_createAction;

// Add the action to the object
[_object, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;

// Mark as added
_object setVariable ["Recondo_Intel_ActionAdded", true, false];

// Also add sensor turn-in action if Sensors module is active
if (!isNil "RECONDO_SENSORS_SETTINGS") then {
    private _sensorAction = [
        "Recondo_Sensor_TurnIn",
        "Turn In Sensor Data",
        "\a3\ui_f\data\igui\cfg\simpletasks\types\listen_ca.paa",
        {
            params ["_target", "_player", "_params"];
            [_player] remoteExec ["Recondo_fnc_turnInSensorData", 2];
        },
        {
            params ["_target", "_player", "_params"];
            private _sensorData = _player getVariable ["RECONDO_SENSOR_CARRIED_DATA", []];
            count _sensorData > 0
        },
        {},
        [],
        [0, 0, 0],
        2,
        [false, false, false, false, false],
        {}
    ] call ace_interact_menu_fnc_createAction;
    
    [_object, 0, ["ACE_MainActions"], _sensorAction] call ace_interact_menu_fnc_addActionToObject;
};

private _debugLogging = if (isNil "RECONDO_INTEL_SETTINGS") then { false } else { RECONDO_INTEL_SETTINGS getOrDefault ["debugLogging", false] };
if (_debugLogging) then {
    diag_log format ["[RECONDO_INTEL] Client: Added turn-in action to object: %1", _object];
};
