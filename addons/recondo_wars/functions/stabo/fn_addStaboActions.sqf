/*
    Recondo_fnc_addStaboActions
    Adds ACE self-interaction actions to STABO-enabled helicopters
    
    Description:
        Client-side function that adds ACE self-interaction options
        for crew to drop/raise STABO rope. Also adds ACE interaction
        options for unconscious units and bodybags.
        
    Parameters:
        0: ARRAY - Array of STABO-enabled helicopters
        1: BOOL - Debug mode (optional)
        
    Returns:
        Nothing
        
    Example:
        [[_heli1, _heli2], false] call Recondo_fnc_addStaboActions;
*/

params ["_helicopters", ["_debug", false]];

// Only run on clients with interface
if (!hasInterface) exitWith {};

if (_debug) then {
    diag_log format ["[RECONDO_STABO] addStaboActions called with %1 helicopters", count _helicopters];
};

// Add ACE self-interaction actions to each helicopter
{
    private _heli = _x;
    
    // Skip if null or already has actions
    if (isNull _heli) then {
        if (_debug) then { diag_log "[RECONDO_STABO] Skipping null helicopter"; };
        continue;
    };
    
    if (_heli getVariable ["RECONDO_STABO_ActionsAdded", false]) then {
        if (_debug) then { diag_log format ["[RECONDO_STABO] Helicopter %1 already has actions", _heli]; };
        continue;
    };
    
    // Verify helicopter is STABO-enabled
    if !(_heli getVariable ["RECONDO_STABO_Enabled", false]) then {
        if (_debug) then { diag_log format ["[RECONDO_STABO] Helicopter %1 not STABO-enabled, skipping", _heli]; };
        continue;
    };
    
    private _settings = _heli getVariable ["RECONDO_STABO_Settings", RECONDO_STABO_SETTINGS];
    if (isNil "_settings") then {
        _settings = RECONDO_STABO_SETTINGS;
    };
    if (isNil "_settings") then {
        if (_debug) then { diag_log "[RECONDO_STABO] No settings found, using defaults"; };
        _settings = createHashMap;
    };
    
    private _minHeight = _settings getOrDefault ["minHeight", 3];
    private _maxHeight = _settings getOrDefault ["maxHeight", 35];
    
    if (_debug) then {
        diag_log format ["[RECONDO_STABO] Adding actions to %1, height range: %2-%3m", typeOf _heli, _minHeight, _maxHeight];
    };
    
    // Create "Drop STABO" action - using vanilla icon
    private _dropAction = [
        "RECONDO_STABO_Drop",
        "Drop STABO",
        "\a3\ui_f\data\IGUI\Cfg\Actions\arrow_down_gs.paa",
        {
            params ["_target", "_player", "_params"];
            [_target] remoteExec ["Recondo_fnc_dropStabo", 2];
        },
        {
            params ["_target", "_player", "_params"];
            _params params ["_minH", "_maxH", "_dbg"];
            
            // Must be STABO-enabled helicopter
            if !(_target getVariable ["RECONDO_STABO_Enabled", false]) exitWith { false };
            
            // Must be crew (driver or turret)
            private _isCrew = (_player == driver _target) || {
                private _turretUnits = [];
                { _turretUnits pushBack (_target turretUnit _x) } forEach (allTurrets _target);
                _player in _turretUnits
            };
            if (!_isCrew) exitWith { false };
            
            // Must not already be deployed or in hanging state
            if (_target getVariable ["RECONDO_STABO_Deployed", false]) exitWith { false };
            if (_target getVariable ["RECONDO_STABO_Hanging", false]) exitWith { false };
            
            // Check height
            private _height = (getPosATL _target) select 2;
            (_height >= _minH) && (_height <= _maxH)
        },
        {},
        [_minHeight, _maxHeight, _debug]
    ] call ace_interact_menu_fnc_createAction;
    
    [_heli, 1, ["ACE_SelfActions"], _dropAction] call ace_interact_menu_fnc_addActionToObject;
    
    // Create "Raise STABO" action - using vanilla icon
    private _raiseAction = [
        "RECONDO_STABO_Raise",
        "Raise STABO",
        "\a3\ui_f\data\IGUI\Cfg\Actions\arrow_up_gs.paa",
        {
            params ["_target", "_player", "_params"];
            [_target] remoteExec ["Recondo_fnc_raiseStabo", 2];
        },
        {
            params ["_target", "_player", "_params"];
            
            // Must be STABO-enabled helicopter
            if !(_target getVariable ["RECONDO_STABO_Enabled", false]) exitWith { false };
            
            // Must be crew (driver or turret)
            private _isCrew = (_player == driver _target) || {
                private _turretUnits = [];
                { _turretUnits pushBack (_target turretUnit _x) } forEach (allTurrets _target);
                _player in _turretUnits
            };
            if (!_isCrew) exitWith { false };
            
            // Must not be in hanging state (already raised)
            if (_target getVariable ["RECONDO_STABO_Hanging", false]) exitWith { false };
            
            // Must be deployed
            _target getVariable ["RECONDO_STABO_Deployed", false]
        },
        {}
    ] call ace_interact_menu_fnc_createAction;
    
    [_heli, 1, ["ACE_SelfActions"], _raiseAction] call ace_interact_menu_fnc_addActionToObject;
    
    // Mark as having actions added
    _heli setVariable ["RECONDO_STABO_ActionsAdded", true];
    
    if (_debug) then {
        diag_log format ["[RECONDO_STABO] Successfully added ACE actions to %1", typeOf _heli];
    };
    
} forEach _helicopters;

// Add ACE interaction for unconscious units (only add once globally)
if (isNil "RECONDO_STABO_UnconActions") then {
    RECONDO_STABO_UnconActions = true;
    
    if (_debug) then {
        diag_log "[RECONDO_STABO] Adding global unconscious/bodybag ACE actions";
    };
    
    private _unconsciousAction = [
        "RECONDO_STABO_LoadUncon",
        "Attach to STABO",
        "\a3\ui_f\data\IGUI\Cfg\Actions\arrow_up_gs.paa",
        {
            params ["_target", "_player", "_params"];
            [_target, _player] call Recondo_fnc_attachUnconscious;
        },
        {
            params ["_target", "_player", "_params"];
            
            // Target must be unconscious
            if !(_target getVariable ["ACE_isUnconscious", false]) exitWith { false };
            
            // Find nearby STABO helicopters with deployed rope
            private _settings = RECONDO_STABO_SETTINGS;
            if (isNil "_settings") exitWith { false };
            
            private _searchRadius = _settings getOrDefault ["searchRadius", 50];
            private _nearbyHelis = (position _target) nearEntities ["Helicopter", _searchRadius];
            
            private _validHeli = _nearbyHelis findIf {
                (_x getVariable ["RECONDO_STABO_Deployed", false]) &&
                (_x getVariable ["RECONDO_STABO_Enabled", false])
            };
            
            _validHeli != -1
        },
        {}
    ] call ace_interact_menu_fnc_createAction;
    
    ["CAManBase", 0, ["ACE_MainActions"], _unconsciousAction, true] call ace_interact_menu_fnc_addActionToClass;
    
    // Add ACE interaction for bodybags
    private _bodybagAction = [
        "RECONDO_STABO_LoadBodybag",
        "Attach to STABO",
        "\a3\ui_f\data\IGUI\Cfg\Actions\arrow_up_gs.paa",
        {
            params ["_target", "_player", "_params"];
            [_target, _player] call Recondo_fnc_attachBodybag;
        },
        {
            params ["_target", "_player", "_params"];
            
            // Find nearby STABO helicopters with deployed rope
            private _settings = RECONDO_STABO_SETTINGS;
            if (isNil "_settings") exitWith { false };
            
            private _searchRadius = _settings getOrDefault ["searchRadius", 50];
            private _nearbyHelis = (position _target) nearEntities ["Helicopter", _searchRadius];
            
            private _validHeli = _nearbyHelis findIf {
                (_x getVariable ["RECONDO_STABO_Deployed", false]) &&
                (_x getVariable ["RECONDO_STABO_Enabled", false])
            };
            
            _validHeli != -1
        },
        {}
    ] call ace_interact_menu_fnc_createAction;
    
    ["ACE_bodyBagObject", 0, ["ACE_MainActions"], _bodybagAction, true] call ace_interact_menu_fnc_addActionToClass;
};

// Add ACE self-interaction for ground players to request STABO from AI pilots (only add once globally)
if (isNil "RECONDO_STABO_GroundRequestActions") then {
    RECONDO_STABO_GroundRequestActions = true;
    
    if (_debug) then {
        diag_log "[RECONDO_STABO] Adding global ground request ACE self-actions";
    };
    
    // Get ground request settings
    private _settings = RECONDO_STABO_SETTINGS;
    private _groundRadius = if (!isNil "_settings") then { _settings getOrDefault ["groundRequestRadius", 50] } else { 50 };
    private _groundMinHeight = if (!isNil "_settings") then { _settings getOrDefault ["groundRequestMinHeight", 5] } else { 5 };
    private _groundMaxHeight = if (!isNil "_settings") then { _settings getOrDefault ["groundRequestMaxHeight", 50] } else { 50 };
    
    // Create parent category "STABO" - only visible to players ON THE GROUND (not in vehicles)
    private _staboCategory = [
        "RECONDO_STABO_Category",
        "STABO",
        "\a3\ui_f\data\IGUI\Cfg\Actions\arrow_down_gs.paa",
        {},
        {
            params ["_target", "_player", "_params"];
            
            // Must be on foot (not in any vehicle)
            if (vehicle _player != _player) exitWith { false };
            
            // Read settings from global
            private _gSettings = RECONDO_STABO_SETTINGS;
            private _radius = if (!isNil "_gSettings") then { _gSettings getOrDefault ["groundRequestRadius", 50] } else { 50 };
            private _maxH = if (!isNil "_gSettings") then { _gSettings getOrDefault ["groundRequestMaxHeight", 50] } else { 50 };
            
            // Check if any valid STABO helicopter is nearby
            private _nearbyHelis = (position _player) nearEntities ["Helicopter", _radius + _maxH];
            
            // Use forEach with flag instead of findIf (ACE scoping workaround)
            private _found = false;
            {
                if (_found) then { continue };
                private _heli = _x;
                
                // Must be STABO-enabled
                if !(_heli getVariable ["RECONDO_STABO_Enabled", false]) then { continue };
                
                // Get deployment state
                private _deployed = _heli getVariable ["RECONDO_STABO_Deployed", false];
                private _hanging = _heli getVariable ["RECONDO_STABO_Hanging", false];
                
                // Must have AI pilot (driver is not a player)
                private _pilot = driver _heli;
                if (isNull _pilot) then { continue };
                if (isPlayer _pilot) then { continue };
                
                // Must be friendly to player
                private _playerSide = side group _player;
                private _pilotSide = side group _pilot;
                if !([_playerSide, _pilotSide] call BIS_fnc_sideIsFriendly) then { continue };
                
                // Check horizontal distance (2D) - hardcoded 50m radius
                private _heliPos = position _heli;
                private _playerPos = position _player;
                private _horizDist = sqrt (((_heliPos select 0) - (_playerPos select 0))^2 + ((_heliPos select 1) - (_playerPos select 1))^2);
                if (_horizDist > 50) then { continue };
                
                // Check altitude difference (heli must be 5-50m above player)
                private _heliAlt = (getPosATL _heli) select 2;
                private _playerAlt = (getPosATL _player) select 2;
                private _altDiff = _heliAlt - _playerAlt;
                
                if ((_altDiff < 5) || (_altDiff > 50)) then { continue };
                
                // Valid if: can drop (not deployed) OR can raise (deployed but not hanging)
                if ((!_deployed) || (_deployed && !_hanging)) then { _found = true };
            } forEach _nearbyHelis;
            
            _found
        },
        {}
    ] call ace_interact_menu_fnc_createAction;
    
    ["CAManBase", 1, ["ACE_SelfActions"], _staboCategory, true] call ace_interact_menu_fnc_addActionToClass;
    
    // Create child action "Hey Pilot! Drop STABO!"
    private _requestDropAction = [
        "RECONDO_STABO_RequestDrop",
        "Hey Pilot! Drop STABO!",
        "\a3\ui_f\data\IGUI\Cfg\Actions\arrow_down_gs.paa",
        {
            params ["_target", "_player", "_params"];
            
            // Find the valid helicopter and request STABO drop
            // Read settings from global
            private _gSettings = RECONDO_STABO_SETTINGS;
            private _radius = if (!isNil "_gSettings") then { _gSettings getOrDefault ["groundRequestRadius", 50] } else { 50 };
            private _maxH = if (!isNil "_gSettings") then { _gSettings getOrDefault ["groundRequestMaxHeight", 50] } else { 50 };
            
            private _nearbyHelis = (position _player) nearEntities ["Helicopter", _radius + _maxH];
            
            {
                private _heli = _x;
                
                // Must be STABO-enabled
                if !(_heli getVariable ["RECONDO_STABO_Enabled", false]) then { continue };
                
                // Must NOT already have STABO deployed
                if (_heli getVariable ["RECONDO_STABO_Deployed", false]) then { continue };
                
                // Must have AI pilot
                private _pilot = driver _heli;
                if (isNull _pilot) then { continue };
                if (isPlayer _pilot) then { continue };
                
                // Must be friendly to player
                if !([side group player, side group _pilot] call BIS_fnc_sideIsFriendly) then { continue };
                
                // Check horizontal distance - hardcoded 50m radius
                private _heliPos = position _heli;
                private _playerPos = position player;
                private _horizDist = sqrt (((_heliPos select 0) - (_playerPos select 0))^2 + ((_heliPos select 1) - (_playerPos select 1))^2);
                if (_horizDist > 50) then { continue };
                
                // Check altitude difference (5-50m above player)
                private _heliAlt = (getPosATL _heli) select 2;
                private _playerAlt = (getPosATL player) select 2;
                private _altDiff = _heliAlt - _playerAlt;
                
                if ((_altDiff >= 5) && (_altDiff <= 50)) exitWith {
                    // Request STABO drop on this helicopter
                    [_heli] remoteExec ["Recondo_fnc_dropStabo", 2];
                };
            } forEach _nearbyHelis;
        },
        {
            // Condition: shows when valid heli nearby that can drop
            params ["_target", "_player", "_params"];
            
            // Must be on foot
            if (vehicle _player != _player) exitWith { false };
            
            // Read settings from global
            private _gSettings = RECONDO_STABO_SETTINGS;
            private _radius = if (!isNil "_gSettings") then { _gSettings getOrDefault ["groundRequestRadius", 50] } else { 50 };
            private _maxH = if (!isNil "_gSettings") then { _gSettings getOrDefault ["groundRequestMaxHeight", 50] } else { 50 };
            
            private _nearbyHelis = (position _player) nearEntities ["Helicopter", _radius + _maxH];
            
            // Use forEach with flag instead of findIf (ACE scoping workaround)
            private _found = false;
            {
                if (_found) then { continue };
                private _heli = _x;
                
                if !(_heli getVariable ["RECONDO_STABO_Enabled", false]) then { continue };
                if (_heli getVariable ["RECONDO_STABO_Deployed", false]) then { continue };
                
                private _pilot = driver _heli;
                if (isNull _pilot) then { continue };
                if (isPlayer _pilot) then { continue };
                
                // Must be friendly to player
                private _playerSide = side group _player;
                private _pilotSide = side group _pilot;
                if !([_playerSide, _pilotSide] call BIS_fnc_sideIsFriendly) then { continue };
                
                // Check horizontal distance - hardcoded 50m radius
                private _heliPos = position _heli;
                private _playerPos = position _player;
                private _horizDist = sqrt (((_heliPos select 0) - (_playerPos select 0))^2 + ((_heliPos select 1) - (_playerPos select 1))^2);
                if (_horizDist > 50) then { continue };
                
                // Check altitude (5-50m above player)
                private _heliAlt = (getPosATL _heli) select 2;
                private _playerAlt = (getPosATL _player) select 2;
                private _altDiff = _heliAlt - _playerAlt;
                
                if ((_altDiff >= 5) && (_altDiff <= 50)) then { _found = true };
            } forEach _nearbyHelis;
            
            _found
        },
        {}
    ] call ace_interact_menu_fnc_createAction;
    
    ["CAManBase", 1, ["ACE_SelfActions", "RECONDO_STABO_Category"], _requestDropAction, true] call ace_interact_menu_fnc_addActionToClass;
    
    // Create child action "Hey Pilot! Raise STABO!"
    private _requestRaiseAction = [
        "RECONDO_STABO_RequestRaise",
        "Hey Pilot! Raise STABO!",
        "\a3\ui_f\data\IGUI\Cfg\Actions\arrow_up_gs.paa",
        {
            params ["_target", "_player", "_params"];
            
            // Find the valid helicopter and request STABO raise
            // Read settings from global
            private _gSettings = RECONDO_STABO_SETTINGS;
            private _radius = if (!isNil "_gSettings") then { _gSettings getOrDefault ["groundRequestRadius", 50] } else { 50 };
            private _maxH = if (!isNil "_gSettings") then { _gSettings getOrDefault ["groundRequestMaxHeight", 50] } else { 50 };
            
            private _nearbyHelis = (position _player) nearEntities ["Helicopter", _radius + _maxH];
            
            {
                private _heli = _x;
                
                // Must be STABO-enabled
                if !(_heli getVariable ["RECONDO_STABO_Enabled", false]) then { continue };
                
                // Must have STABO deployed (opposite of drop request)
                if !(_heli getVariable ["RECONDO_STABO_Deployed", false]) then { continue };
                
                // Must NOT be in hanging state (already raised)
                if (_heli getVariable ["RECONDO_STABO_Hanging", false]) then { continue };
                
                // Must have AI pilot
                private _pilot = driver _heli;
                if (isNull _pilot) then { continue };
                if (isPlayer _pilot) then { continue };
                
                // Must be friendly to player
                if !([side group player, side group _pilot] call BIS_fnc_sideIsFriendly) then { continue };
                
                // Check horizontal distance - hardcoded 50m radius
                private _heliPos = position _heli;
                private _playerPos = position player;
                private _horizDist = sqrt (((_heliPos select 0) - (_playerPos select 0))^2 + ((_heliPos select 1) - (_playerPos select 1))^2);
                if (_horizDist > 50) then { continue };
                
                // Check altitude difference (5-50m above player)
                private _heliAlt = (getPosATL _heli) select 2;
                private _playerAlt = (getPosATL player) select 2;
                private _altDiff = _heliAlt - _playerAlt;
                
                if ((_altDiff >= 5) && (_altDiff <= 50)) exitWith {
                    // Request STABO raise on this helicopter
                    [_heli] remoteExec ["Recondo_fnc_raiseStabo", 2];
                };
            } forEach _nearbyHelis;
        },
        {
            // Condition: shows when valid heli with deployed STABO is nearby
            params ["_target", "_player", "_params"];
            
            // Must be on foot
            if (vehicle _player != _player) exitWith { false };
            
            // Read settings from global
            private _gSettings = RECONDO_STABO_SETTINGS;
            private _radius = if (!isNil "_gSettings") then { _gSettings getOrDefault ["groundRequestRadius", 50] } else { 50 };
            private _maxH = if (!isNil "_gSettings") then { _gSettings getOrDefault ["groundRequestMaxHeight", 50] } else { 50 };
            
            private _nearbyHelis = (position _player) nearEntities ["Helicopter", _radius + _maxH];
            
            // Use forEach with flag instead of findIf (ACE scoping workaround)
            private _found = false;
            {
                if (_found) then { continue };
                private _heli = _x;
                
                if !(_heli getVariable ["RECONDO_STABO_Enabled", false]) then { continue };
                
                // Must have STABO deployed
                if !(_heli getVariable ["RECONDO_STABO_Deployed", false]) then { continue };
                
                // Must NOT be in hanging state
                if (_heli getVariable ["RECONDO_STABO_Hanging", false]) then { continue };
                
                private _pilot = driver _heli;
                if (isNull _pilot) then { continue };
                if (isPlayer _pilot) then { continue };
                
                // Must be friendly to player
                private _playerSide = side group _player;
                private _pilotSide = side group _pilot;
                if !([_playerSide, _pilotSide] call BIS_fnc_sideIsFriendly) then { continue };
                
                // Check horizontal distance - hardcoded 50m radius
                private _heliPos = position _heli;
                private _playerPos = position _player;
                private _horizDist = sqrt (((_heliPos select 0) - (_playerPos select 0))^2 + ((_heliPos select 1) - (_playerPos select 1))^2);
                if (_horizDist > 50) then { continue };
                
                // Check altitude (5-50m above player)
                private _heliAlt = (getPosATL _heli) select 2;
                private _playerAlt = (getPosATL _player) select 2;
                private _altDiff = _heliAlt - _playerAlt;
                
                if ((_altDiff >= 5) && (_altDiff <= 50)) then { _found = true };
            } forEach _nearbyHelis;
            
            _found
        },
        {}
    ] call ace_interact_menu_fnc_createAction;
    
    ["CAManBase", 1, ["ACE_SelfActions", "RECONDO_STABO_Category"], _requestRaiseAction, true] call ace_interact_menu_fnc_addActionToClass;
    
    if (_debug) then {
        diag_log format ["[RECONDO_STABO] Ground request actions added (radius: %1m, height: %2-%3m)", _groundRadius, _groundMinHeight, _groundMaxHeight];
    };
};

if (_debug) then {
    diag_log "[RECONDO_STABO] addStaboActions completed";
};
