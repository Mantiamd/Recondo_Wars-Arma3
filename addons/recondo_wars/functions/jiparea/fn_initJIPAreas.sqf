/*
    Recondo_fnc_initJIPAreas
    JIP to Group Leader Area - Client-side initialization
    
    Description:
        Adds ACE self-interact action for JIP teleport areas.
        Allows players to teleport to their group leader (or random member if leader).
    
    Returns:
        Nothing
*/

// Only run on clients with interface
if (!hasInterface) exitWith {};

// Wait for JIP areas array to be defined
[{
    !isNil "RECONDO_JIPAREAS"
}, {
    // If no areas defined, exit silently
    if (count RECONDO_JIPAREAS == 0) exitWith {
        diag_log "[RECONDO_JIPAREA] No JIP areas defined.";
    };
    
    // Helper function to check if player is in any JIP area
    RECONDO_fnc_isInJIPArea = {
        params ["_unit"];
        
        private _inArea = false;
        
        {
            private _areaData = _x;
            private _pos = _areaData get "position";
            private _width = _areaData get "width";
            private _length = _areaData get "length";
            private _height = _areaData get "height";
            private _dir = _areaData get "direction";
            
            // Get player position
            private _playerPos = getPosATL _unit;
            
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
            };
            
            if (_inArea) exitWith {};
        } forEach RECONDO_JIPAREAS;
        
        _inArea
    };
    
    // Create the confirmation action (child)
    private _actionConfirm = [
        "Recondo_JIP_Confirm",
        "Confirm Teleport",
        "\a3\3den\data\controls\ctrlmenu\picturecheckboxenabled_ca.paa",
        {
            // Statement - execute teleport
            params ["_target", "_player", "_params"];
            
            private _leader = leader group _player;
            private _groupUnits = units group _player;
            
            // If player is leader, teleport to random group member
            if (_player == _leader) then {
                // Remove the leader from possible targets
                _groupUnits = _groupUnits - [_leader];
                
                // Check if there are other group members
                if (count _groupUnits == 0) exitWith {
                    hint "No other group members found!";
                };
                
                // Filter out dead units
                _groupUnits = _groupUnits select {alive _x};
                
                if (count _groupUnits == 0) exitWith {
                    hint "No alive group members found!";
                };
                
                // Select random group member
                private _randomMember = selectRandom _groupUnits;
                
                // Check if target is in a vehicle
                if (vehicle _randomMember != _randomMember) then {
                    _player moveInAny vehicle _randomMember;
                } else {
                    playSoundUI ["Transition1", 1];
                    [_player, _randomMember] spawn {
                        params ["_unit", "_target"];
                        _unit playActionNow "PlayerProne";
                        sleep 2;
                        _unit setPos (getPos _target);
                    };
                };
                
                // Announce to all players
                systemChat format ["%1 has joined in progress and teleported to %2!", name _player, name _randomMember];
            } else {
                // Regular member teleporting to leader
                if (!alive _leader) exitWith {
                    hint "Group leader is dead!";
                };
                
                // Check if leader is in a vehicle
                if (vehicle _leader != _leader) then {
                    _player moveInAny vehicle _leader;
                } else {
                    playSoundUI ["Transition1", 1];
                    [_player, _leader] spawn {
                        params ["_unit", "_target"];
                        _unit playActionNow "PlayerProne";
                        sleep 2;
                        _unit setPos (getPos _target);
                    };
                };
                
                // Announce to all players
                systemChat format ["%1 has joined in progress and teleported to %2!", name _player, name _leader];
            };
        },
        {
            // Condition - same as parent (in JIP area)
            params ["_target", "_player", "_params"];
            [_player] call RECONDO_fnc_isInJIPArea
        }
    ] call ace_interact_menu_fnc_createAction;
    
    // Create the main teleport action (parent)
    private _actionMain = [
        "Recondo_JIP_Teleport",
        "Teleport - JIP",
        "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\move_ca.paa",
        {},  // Empty statement - uses child actions
        {
            // Condition - check if player is in any JIP area
            params ["_target", "_player", "_params"];
            [_player] call RECONDO_fnc_isInJIPArea
        }
    ] call ace_interact_menu_fnc_createAction;
    
    // Add main action to player class (self-interaction, type 1)
    ["CAManBase", 1, ["ACE_SelfActions"], _actionMain, true] call ace_interact_menu_fnc_addActionToClass;
    
    // Add confirm action as child of main action
    ["CAManBase", 1, ["ACE_SelfActions", "Recondo_JIP_Teleport"], _actionConfirm, true] call ace_interact_menu_fnc_addActionToClass;
    
    diag_log format ["[RECONDO_JIPAREA] Client initialized. %1 JIP areas available.", count RECONDO_JIPAREAS];
}, []] call CBA_fnc_waitUntilAndExecute;
