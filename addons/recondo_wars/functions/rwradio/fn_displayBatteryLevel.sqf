/*
    Recondo_fnc_displayBatteryLevel
    Display battery level for player's tracked radios
    
    Description:
        Shows a hint with battery level for all tracked radios the player has.
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
private _batteryCapacity = _settings get "batteryCapacity";

// Get player's radios
private _radioList = [] call acre_api_fnc_getCurrentRadioList;

private _displayText = "";
private _foundRadio = false;

{
    private _radioId = _x;
    private _baseRadio = [_radioId] call acre_api_fnc_getBaseRadio;
    
    if (_baseRadio in _radioClassnames) then {
        _foundRadio = true;
        
        private _batteryLevel = [_radioId] call Recondo_fnc_getBatteryLevel;
        private _percent = round ((_batteryLevel / _batteryCapacity) * 100);
        
        // Generate visual bar
        private _bars = "";
        private _status = "";
        
        if (_percent > 80) then {
            _bars = "[#####]";
            _status = "Full";
        } else {
            if (_percent > 60) then {
                _bars = "[####-]";
                _status = "High";
            } else {
                if (_percent > 40) then {
                    _bars = "[###--]";
                    _status = "Medium";
                } else {
                    if (_percent > 20) then {
                        _bars = "[##---]";
                        _status = "Low";
                    } else {
                        if (_percent > 0) then {
                            _bars = "[#----]";
                            _status = "Critical";
                        } else {
                            _bars = "[-----]";
                            _status = "Empty";
                        };
                    };
                };
            };
        };
        
        // Get display name for radio
        private _displayName = getText (configFile >> "CfgWeapons" >> _baseRadio >> "displayName");
        if (_displayName == "") then {
            _displayName = _baseRadio;
        };
        
        if (_displayText != "") then {
            _displayText = _displayText + "\n\n";
        };
        
        _displayText = _displayText + format ["%1\n%2: %3\nBattery: %4%5", 
            _displayName, _status, _bars, _percent, "%"];
    };
} forEach _radioList;

if (_foundRadio) then {
    hint _displayText;
} else {
    hint "No tracked radios found";
};
