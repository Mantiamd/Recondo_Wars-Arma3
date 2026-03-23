/*
    Recondo_fnc_initRadioClient
    Client-side initialization for RW Radio system
    
    Description:
        Sets up ACRE event handlers and ACE interactions for battery management.
        Called on all clients after module initialization.
    
    Parameters:
        None
        
    Returns:
        Nothing
*/

// Only run on clients with interface
if (!hasInterface) exitWith {};

// Wait for player and settings to be available
waitUntil {sleep 0.5; !isNull player && {!isNil "RECONDO_RWR_SETTINGS"}};

private _settings = RECONDO_RWR_SETTINGS;
private _debug = _settings get "enableDebug";

// Check if player's group is exempt
if ([player] call Recondo_fnc_isGroupExempt) exitWith {
    if (_debug) then {
        diag_log format ["[RECONDO_RWR] Player %1 in exempt group, system disabled for this player", name player];
    };
};

// Check if ACRE is available
if (isNil "acre_api_fnc_getCurrentRadioList") exitWith {
    diag_log "[RECONDO_RWR] ERROR: ACRE not detected. RW Radio system disabled.";
};

private _enableBattery = _settings get "enableBattery";
private _radioClassnames = _settings get "radioClassnames";
private _batteryItems = _settings get "batteryItems";
private _batteryCapacity = _settings get "batteryCapacity";

if (_debug) then {
    diag_log format ["[RECONDO_RWR] Initializing client for player %1", name player];
    diag_log format ["[RECONDO_RWR] Tracking radios: %1", _radioClassnames];
};

// =========================================
// ACRE EVENT HANDLERS
// =========================================

// Handle start of transmission
["acre_startedSpeaking", {
    params ["_unit", "_onRadio", "_radioId", "_speakingType"];
    
    // Only process for local player
    if (_unit != player) exitWith {};
    
    // Check if exempt
    if ([_unit] call Recondo_fnc_isGroupExempt) exitWith {};
    
    // Only process radio transmissions (not direct speech)
    if (!_onRadio || _radioId == "") exitWith {};
    
    private _settings = RECONDO_RWR_SETTINGS;
    private _radioClassnames = _settings get "radioClassnames";
    private _debug = _settings get "enableDebug";
    
    // Check if this radio type is tracked
    private _baseRadio = [_radioId] call acre_api_fnc_getBaseRadio;
    if !(_baseRadio in _radioClassnames) exitWith {
        if (_debug) then {
            diag_log format ["[RECONDO_RWR] Radio %1 not in tracked list, ignoring", _baseRadio];
        };
    };
    
    // Check battery level
    if (_settings get "enableBattery") then {
        private _batteryLevel = [_radioId] call Recondo_fnc_getBatteryLevel;
        
        if (_batteryLevel <= 0) exitWith {
            // Battery depleted - turn off radio
            [_radioId, "setOnOffState", 0] call acre_sys_data_fnc_dataEvent;
            hint "Radio battery depleted!";
            if (_debug) then {
                diag_log format ["[RECONDO_RWR] Blocked transmission - battery depleted for %1", _radioId];
            };
        };
    };
    
    // Send start transmission to server
    [serverTime, _radioId, _unit] remoteExec ["Recondo_fnc_startTransmission", 2];
    
    // Store radio ID for stop event
    player setVariable ["RECONDO_RWR_LastRadioId", _radioId, false];
    
    if (_debug) then {
        diag_log format ["[RECONDO_RWR] Started transmission on %1 (%2)", _radioId, _baseRadio];
    };
}] call CBA_fnc_addEventHandler;

// Handle end of transmission
["acre_stoppedSpeaking", {
    params ["_unit", "_onRadio"];
    
    // Only process for local player
    if (_unit != player) exitWith {};
    
    // Check if exempt
    if ([_unit] call Recondo_fnc_isGroupExempt) exitWith {};
    
    // Get the radio ID we stored at start
    private _radioId = player getVariable ["RECONDO_RWR_LastRadioId", ""];
    if (_radioId == "") exitWith {};
    
    private _settings = RECONDO_RWR_SETTINGS;
    private _radioClassnames = _settings get "radioClassnames";
    
    // Check if this radio type is tracked
    private _baseRadio = [_radioId] call acre_api_fnc_getBaseRadio;
    if !(_baseRadio in _radioClassnames) exitWith {};
    
    // Send stop transmission to server
    [_radioId, _unit] remoteExec ["Recondo_fnc_stopTransmission", 2];
    
    // Clear stored radio ID
    player setVariable ["RECONDO_RWR_LastRadioId", "", false];
    
    if (_settings get "enableDebug") then {
        diag_log format ["[RECONDO_RWR] Stopped transmission on %1", _radioId];
    };
}] call CBA_fnc_addEventHandler;

// =========================================
// ACE SELF-INTERACTIONS
// =========================================

if (!isNil "ace_interact_menu_fnc_createAction") then {
    
    // Create main category
    private _radioCategory = [
        "RECONDO_RWR_Category",
        "Radio Battery",
        "\a3\Modules_F_Curator\Data\iconLightning_ca.paa",
        {},
        {
            !([_player] call Recondo_fnc_isGroupExempt) &&
            {!isNil "RECONDO_RWR_SETTINGS"} &&
            {RECONDO_RWR_SETTINGS get "enableBattery"}
        }
    ] call ace_interact_menu_fnc_createAction;
    
    ["Man", 1, ["ACE_SelfActions"], _radioCategory, true] call ace_interact_menu_fnc_addActionToClass;
    
    // Check battery action
    private _checkBatteryAction = [
        "RECONDO_RWR_CheckBattery",
        "Check Battery Level",
        "\a3\Modules_F_Curator\Data\iconLightning_ca.paa",
        {
            params ["_target", "_player"];
            [_player] call Recondo_fnc_displayBatteryLevel;
        },
        {
            params ["_target", "_player"];
            if ([_player] call Recondo_fnc_isGroupExempt) exitWith {false};
            if (isNil "RECONDO_RWR_SETTINGS") exitWith {false};
            
            private _radioClassnames = RECONDO_RWR_SETTINGS get "radioClassnames";
            private _radioList = [] call acre_api_fnc_getCurrentRadioList;
            
            // Check if player has any tracked radio
            private _hasTrackedRadio = false;
            {
                private _baseRadio = [_x] call acre_api_fnc_getBaseRadio;
                if (_baseRadio in _radioClassnames) exitWith {
                    _hasTrackedRadio = true;
                };
            } forEach _radioList;
            
            _hasTrackedRadio
        }
    ] call ace_interact_menu_fnc_createAction;
    
    ["Man", 1, ["ACE_SelfActions", "RECONDO_RWR_Category"], _checkBatteryAction, true] call ace_interact_menu_fnc_addActionToClass;
    
    // Replace battery action
    private _replaceBatteryAction = [
        "RECONDO_RWR_ReplaceBattery",
        "Replace Battery",
        "x\zen\addons\context_actions\ui\add_ca.paa",
        {
            params ["_target", "_player"];
            [_player] call Recondo_fnc_replaceBattery;
        },
        {
            params ["_target", "_player"];
            if ([_player] call Recondo_fnc_isGroupExempt) exitWith {false};
            if (isNil "RECONDO_RWR_SETTINGS") exitWith {false};
            
            private _settings = RECONDO_RWR_SETTINGS;
            private _radioClassnames = _settings get "radioClassnames";
            private _batteryItems = _settings get "batteryItems";
            private _batteryCapacity = _settings get "batteryCapacity";
            
            // Check if player has battery item
            private _hasBatteryItem = false;
            {
                if ([_player, _x] call BIS_fnc_hasItem) exitWith {
                    _hasBatteryItem = true;
                };
            } forEach _batteryItems;
            
            if (!_hasBatteryItem) exitWith {false};
            
            // Check if player has tracked radio that needs battery
            private _radioList = [] call acre_api_fnc_getCurrentRadioList;
            private _needsBattery = false;
            {
                private _baseRadio = [_x] call acre_api_fnc_getBaseRadio;
                if (_baseRadio in _radioClassnames) then {
                    private _batteryLevel = [_x] call Recondo_fnc_getBatteryLevel;
                    if (_batteryLevel < _batteryCapacity) exitWith {
                        _needsBattery = true;
                    };
                };
            } forEach _radioList;
            
            _needsBattery
        }
    ] call ace_interact_menu_fnc_createAction;
    
    ["Man", 1, ["ACE_SelfActions", "RECONDO_RWR_Category"], _replaceBatteryAction, true] call ace_interact_menu_fnc_addActionToClass;
    
    if (_debug) then {
        diag_log "[RECONDO_RWR] ACE interactions added";
    };
};

if (_debug) then {
    diag_log "[RECONDO_RWR] Client initialization complete";
};
