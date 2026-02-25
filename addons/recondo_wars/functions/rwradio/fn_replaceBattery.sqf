/*
    Recondo_fnc_replaceBattery
    Replace battery in player's tracked radio
    
    Description:
        Replaces battery in the first tracked radio that needs it.
        Consumes a battery item from inventory.
        Called via ACE self-interaction.
    
    Parameters:
        0: OBJECT - Player
        
    Returns:
        Nothing
*/

params ["_player"];

if (isNil "RECONDO_RWR_SETTINGS") exitWith {
    hint "Radio system not initialized";
};

private _settings = RECONDO_RWR_SETTINGS;
private _radioClassnames = _settings get "radioClassnames";
private _batteryItems = _settings get "batteryItems";
private _batteryCapacity = _settings get "batteryCapacity";

// Find battery item in inventory
private _batteryItemUsed = "";
{
    if ([_player, _x] call BIS_fnc_hasItem) exitWith {
        _batteryItemUsed = _x;
    };
} forEach _batteryItems;

if (_batteryItemUsed == "") exitWith {
    hint "No battery available!";
};

// Find tracked radio that needs battery
private _radioList = [] call acre_api_fnc_getCurrentRadioList;
private _radioToReplace = "";

{
    private _radioId = _x;
    private _baseRadio = [_radioId] call acre_api_fnc_getBaseRadio;
    
    if (_baseRadio in _radioClassnames) then {
        private _batteryLevel = [_radioId] call Recondo_fnc_getBatteryLevel;
        if (_batteryLevel < _batteryCapacity) exitWith {
            _radioToReplace = _radioId;
        };
    };
} forEach _radioList;

if (_radioToReplace == "") exitWith {
    hint "All radios have full batteries!";
};

// Remove battery item from inventory
_player removeItem _batteryItemUsed;

// Request server to set battery level
[_radioToReplace, _batteryCapacity] remoteExec ["Recondo_fnc_setBatteryLevel", 2];

// Turn radio back on if it was off
[_radioToReplace, "setOnOffState", 1] call acre_sys_data_fnc_dataEvent;

// Get radio display name
private _baseRadio = [_radioToReplace] call acre_api_fnc_getBaseRadio;
private _displayName = getText (configFile >> "CfgWeapons" >> _baseRadio >> "displayName");
if (_displayName == "") then {
    _displayName = _baseRadio;
};

hint format ["%1 battery replaced!", _displayName];

if (_settings get "enableDebug") then {
    diag_log format ["[RECONDO_RWR] Battery replaced for %1 using %2", _radioToReplace, _batteryItemUsed];
};
