/*
    Recondo_fnc_initArsenalAreas
    ACE Arsenal Area - Client-side initialization
    
    Description:
        Adds ACE self-interact action for arsenal areas.
        Checks if player is within any registered arsenal area and has permission.
    
    Returns:
        Nothing
*/

// Only run on clients with interface
if (!hasInterface) exitWith {};

// Wait for arsenal areas array to be defined (may be empty if no modules placed)
[{
    !isNil "RECONDO_ARSENALAREAS"
}, {
    // If no areas defined, exit silently
    if (count RECONDO_ARSENALAREAS == 0) exitWith {
        diag_log "[RECONDO_ARSENALAREA] No arsenal areas defined.";
    };
    
    // Create the ACE self-interact action
    private _action = [
        "Recondo_AccessAreaArsenal",                    // 0: Action name
        "Access Area Arsenal",                           // 1: Display name
        "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\armor_ca.paa",  // 2: Icon (armor/vest)
        {
            // 3: Statement - open arsenal
            params ["_target", "_player", "_params"];
            
            // Find which area the player is in
            private _areaData = _player getVariable ["RECONDO_CurrentArsenalArea", createHashMap];
            private _referenceBoxVar = _areaData getOrDefault ["referenceBoxVar", ""];
            
            if (_referenceBoxVar == "") exitWith {
                hint "No arsenal area found!";
            };
            
            private _referenceBox = missionNamespace getVariable [_referenceBoxVar, objNull];
            
            if (isNull _referenceBox) exitWith {
                hint format ["Arsenal reference box '%1' not found!", _referenceBoxVar];
            };
            
            // Open ACE Arsenal with reference box
            [_referenceBox, _player, false] call ace_arsenal_fnc_openBox;
        },
        {
            // 4: Condition - check if player is in any allowed area
            params ["_target", "_player", "_params"];
            
            private _inArea = false;
            private _foundAreaData = createHashMap;
            
            {
                private _areaData = _x;
                private _pos = _areaData get "position";
                private _width = _areaData get "width";
                private _length = _areaData get "length";
                private _height = _areaData get "height";
                private _dir = _areaData get "direction";
                private _allowedClassnames = _areaData get "allowedClassnames";
                private _referenceBoxVar = _areaData get "referenceBoxVar";
                
                // Check if player classname is allowed (empty array = all allowed)
                private _playerClassname = typeOf _player;
                private _isAllowed = (count _allowedClassnames == 0) || {_playerClassname in _allowedClassnames};
                
                if (!_isAllowed) then {
                    continue;
                };
                
                // Check if reference box exists
                private _referenceBox = missionNamespace getVariable [_referenceBoxVar, objNull];
                if (isNull _referenceBox) then {
                    continue;
                };
                
                // Check if player is within rectangular area
                private _playerPos = getPosATL _player;
                
                // Calculate relative position accounting for area rotation
                private _relX = (_playerPos select 0) - (_pos select 0);
                private _relY = (_playerPos select 1) - (_pos select 1);
                private _relZ = (_playerPos select 2) - (_pos select 2);
                
                // Rotate relative position to align with area direction
                private _dirRad = -_dir * (pi / 180);
                private _rotX = _relX * cos(_dirRad) - _relY * sin(_dirRad);
                private _rotY = _relX * sin(_dirRad) + _relY * cos(_dirRad);
                
                // Check if within bounds (centered on module position)
                private _halfWidth = _width / 2;
                private _halfLength = _length / 2;
                
                if (abs(_rotX) <= _halfWidth && abs(_rotY) <= _halfLength && _relZ >= 0 && _relZ <= _height) then {
                    _inArea = true;
                    _foundAreaData = _areaData;
                };
                
                if (_inArea) exitWith {};
            } forEach RECONDO_ARSENALAREAS;
            
            // Store area data on player for the statement to use
            _player setVariable ["RECONDO_CurrentArsenalArea", _foundAreaData];
            
            _inArea
        },
        {},                                              // 5: Insert children code
        [],                                              // 6: Action parameters
        {[0, 0, 0]},                                     // 7: Position
        2,                                               // 8: Distance
        [false, false, false, false, false]              // 9: Other parameters
    ] call ace_interact_menu_fnc_createAction;
    
    // Add action to player class (self-interaction, type 1)
    // Using "CAManBase" with inheritance so it works for all player types and respawns
    ["CAManBase", 1, ["ACE_SelfActions"], _action, true] call ace_interact_menu_fnc_addActionToClass;
    
    diag_log format ["[RECONDO_ARSENALAREA] Client initialized. %1 arsenal areas available.", count RECONDO_ARSENALAREAS];
}, []] call CBA_fnc_waitUntilAndExecute;
