/*
    Recondo_fnc_initDisableRationsAreas
    Disable ACE Rations Area - Client-side initialization
    
    Description:
        Adds ACE Field Rations status modifier that checks if player is
        within any defined no-rations area. Returns -10 to block hunger/thirst
        decrease when in area, 0 for normal behavior outside.
    
    Returns:
        Nothing
*/

// Only run on clients with interface
if (!hasInterface) exitWith {};

// Wait for areas array to be defined
[{
    !isNil "RECONDO_DISABLERATIONSAREAS"
}, {
    // If no areas defined, exit silently
    if (count RECONDO_DISABLERATIONSAREAS == 0) exitWith {
        diag_log "[RECONDO_DISABLERATIONSAREA] No disable rations areas defined.";
    };
    
    // Check if ACE Field Rations is loaded
    if (isNil "ace_field_rations_fnc_addStatusModifier") exitWith {
        diag_log "[RECONDO_DISABLERATIONSAREA] ACE Field Rations not loaded. Feature disabled.";
    };
    
    // Add status modifier that checks all defined areas
    [2, {
        private _unit = _this;
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
        } forEach RECONDO_DISABLERATIONSAREAS;
        
        // Return -10 if in area (blocks hunger/thirst decrease), 0 if outside (normal)
        if (_inArea) then {
            -10
        } else {
            0
        }
    }] call ace_field_rations_fnc_addStatusModifier;
    
    diag_log format ["[RECONDO_DISABLERATIONSAREA] Client initialized. %1 no-rations areas active.", count RECONDO_DISABLERATIONSAREAS];
}, []] call CBA_fnc_waitUntilAndExecute;
