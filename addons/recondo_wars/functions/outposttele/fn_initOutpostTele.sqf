/*
    Recondo_fnc_initOutpostTele
    Base to Outpost Tele - Client-side initialization
    
    Description:
        Adds ACE interact actions to base teleporter objects (object interaction)
        and ACE self-interact action for returning to base from outposts.
        Uses area-based detection for return teleport (like Arsenal Area).
    
    Returns:
        Nothing
*/

// Only run on clients with interface
if (!hasInterface) exitWith {};

// Wait for outpost tele data to be defined
[{
    !isNil "RECONDO_OUTPOSTTELE_INSTANCES" &&
    !isNil "RECONDO_OUTPOSTTELE_OUTPOSTS" &&
    !isNil "RECONDO_OUTPOSTTELE_BASE_OBJECTS"
}, {
    // If no instances defined, exit silently
    if (count RECONDO_OUTPOSTTELE_INSTANCES == 0) exitWith {
        diag_log "[RECONDO_OUTPOSTTELE] No outpost teleporter modules defined.";
    };
    
    // ========================================
    // HELPER: CONVERT SIDE NUMBER TO SIDE
    // (SIDE types don't serialize through publicVariable, so we use numbers)
    // ========================================
    
    RECONDO_fnc_sideNumToSide = {
        params ["_sideNum"];
        switch (_sideNum) do {
            case 0: { east };
            case 1: { west };
            case 2: { independent };
            case 3: { civilian };
            default { nil };  // Any side or unknown
        }
    };
    
    // ========================================
    // HELPER: CHECK IF PLAYER IS IN OUTPOST AREA
    // ========================================
    
    RECONDO_fnc_isInOutpostArea = {
        params ["_unit"];
        
        private _result = [false, createHashMap];
        
        {
            private _outpostData = _x;
            private _pos = _outpostData get "position";
            private _instanceId = _outpostData get "instanceId";
            
            // Get settings for this instance
            private _settings = nil;
            {
                if ((_x get "instanceId") == _instanceId) exitWith {
                    _settings = _x;
                };
            } forEach RECONDO_OUTPOSTTELE_INSTANCES;
            
            if (isNil "_settings") then { continue };
            
            private _outpostRadius = _settings get "outpostRadius";
            private _allowedSideNum = _settings getOrDefault ["allowedSideNum", -1];
            private _allowedSide = [_allowedSideNum] call RECONDO_fnc_sideNumToSide;
            
            // Check side restriction
            if (!isNil "_allowedSide" && {side _unit != _allowedSide}) then { continue };
            
            // Check distance
            private _playerPos = getPosATL _unit;
            private _distance = _playerPos distance2D _pos;
            
            if (_distance <= _outpostRadius) exitWith {
                _result = [true, _outpostData];
            };
        } forEach RECONDO_OUTPOSTTELE_OUTPOSTS;
        
        _result
    };
    
    // ========================================
    // HELPER: GET BASE OBJECT FOR INSTANCE
    // ========================================
    
    RECONDO_fnc_getBaseObjectForInstance = {
        params ["_instanceId"];
        
        private _baseObj = objNull;
        
        {
            if ((_x get "instanceId") == _instanceId) exitWith {
                private _netId = _x get "netId";
                _baseObj = objectFromNetId _netId;
            };
        } forEach RECONDO_OUTPOSTTELE_BASE_OBJECTS;
        
        _baseObj
    };
    
    // ========================================
    // ADD ACE ACTIONS TO BASE TELEPORTER OBJECTS
    // ========================================
    
    {
        private _settings = _x;
        private _instanceId = _settings get "instanceId";
        private _allowedSideNum = _settings getOrDefault ["allowedSideNum", -1];
        private _allowedSide = [_allowedSideNum] call RECONDO_fnc_sideNumToSide;
        private _actionText = _settings get "actionText";
        private _cooldown = _settings get "cooldown";
        
        // Get outposts for this instance
        private _instanceOutposts = RECONDO_OUTPOSTTELE_OUTPOSTS select {
            (_x get "instanceId") == _instanceId
        };
        
        // Get base objects for this instance from RECONDO_OUTPOSTTELE_BASE_OBJECTS using netId
        private _instanceBaseData = RECONDO_OUTPOSTTELE_BASE_OBJECTS select {
            (_x get "instanceId") == _instanceId
        };
        
        // Add actions to each base object
        {
            private _baseData = _x;
            private _netId = _baseData get "netId";
            private _baseObject = objectFromNetId _netId;
            
            if (isNull _baseObject) then {
                diag_log format ["[RECONDO_OUTPOSTTELE] WARNING: Could not find base object with netId: %1", _netId];
                continue;
            };
            
            // Create parent action "Deploy to Outpost"
            // Pass side number since SIDE types don't serialize in ACE action params
            private _parentAction = [
                format ["Recondo_OutpostTele_Deploy_%1", _instanceId],
                "Deploy to Outpost",
                "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\move_ca.paa",
                {},  // Empty statement - uses child actions
                {
                    // Condition: Check side (convert number to side inside condition)
                    params ["_target", "_player", "_params"];
                    _params params ["_sideNum"];
                    
                    if (_sideNum < 0) then { true } else {
                        private _allowedSide = switch (_sideNum) do {
                            case 0: { east };
                            case 1: { west };
                            case 2: { independent };
                            case 3: { civilian };
                            default { nil };
                        };
                        if (isNil "_allowedSide") then { true } else { side _player == _allowedSide }
                    }
                },
                {},
                [_allowedSideNum]
            ] call ace_interact_menu_fnc_createAction;
            
            [_baseObject, 0, ["ACE_MainActions"], _parentAction, true] call ace_interact_menu_fnc_addActionToObject;
            
            // Create child actions for each outpost destination - TELEPORTS DIRECTLY
            {
                private _outpostData = _x;
                private _markerId = _outpostData get "markerId";
                private _displayName = _outpostData get "displayName";
                
                // Format action text with display name
                private _formattedText = format [_actionText, _displayName];
                
                private _outpostAction = [
                    format ["Recondo_OutpostTele_Dest_%1_%2", _instanceId, _markerId],
                    _formattedText,
                    "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\target_ca.paa",
                    {
                        // Statement: DIRECTLY TELEPORT to this outpost
                        params ["_target", "_player", "_params"];
                        _params params ["_outpostData", "_cooldown"];
                        
                        // Check cooldown
                        private _lastTeleport = _player getVariable ["RECONDO_OUTPOSTTELE_LAST_TELEPORT", 0];
                        if (_cooldown > 0 && {time - _lastTeleport < _cooldown}) exitWith {
                            private _remaining = ceil (_cooldown - (time - _lastTeleport));
                            hint format ["Teleporter on cooldown: %1 seconds remaining", _remaining];
                        };
                        
                        // Execute teleport immediately
                        [_player, _outpostData] call Recondo_fnc_teleportToOutpost;
                        
                        // Set cooldown
                        _player setVariable ["RECONDO_OUTPOSTTELE_LAST_TELEPORT", time];
                    },
                    {
                        // Condition: Always show if parent shows
                        true
                    },
                    {},
                    [_outpostData, _cooldown]
                ] call ace_interact_menu_fnc_createAction;
                
                [_baseObject, 0, ["ACE_MainActions", format ["Recondo_OutpostTele_Deploy_%1", _instanceId]], _outpostAction, true] call ace_interact_menu_fnc_addActionToObject;
                
            } forEach _instanceOutposts;
            
            diag_log format ["[RECONDO_OUTPOSTTELE] Added ACE actions to base object: %1", typeOf _baseObject];
            
        } forEach _instanceBaseData;
        
    } forEach RECONDO_OUTPOSTTELE_INSTANCES;
    
    // ========================================
    // CONTROL MARKER VISIBILITY BY SIDE
    // ========================================
    
    // Wait for player to be fully initialized (side properly assigned)
    // On dedicated servers, player side may not be set immediately at mission start
    [{
        !isNull player && 
        alive player && 
        side player != sideUnknown
    }, {
        // Player is now ready, set marker visibility
        {
            private _settings = _x;
            private _instanceId = _settings get "instanceId";
            private _allowedSideNum = _settings getOrDefault ["allowedSideNum", -1];
            private _allowedSide = [_allowedSideNum] call RECONDO_fnc_sideNumToSide;
            
            // Get outposts for this instance
            private _instanceOutposts = RECONDO_OUTPOSTTELE_OUTPOSTS select {
                (_x get "instanceId") == _instanceId
            };
            
            // Check if player is allowed to see these markers
            private _playerAllowed = true;
            if (!isNil "_allowedSide") then {
                _playerAllowed = side player == _allowedSide;
            };
            
            diag_log format ["[RECONDO_OUTPOSTTELE] Marker visibility check - player side: %1, allowed side: %2, allowed: %3", side player, _allowedSide, _playerAllowed];
            
            {
                private _markerId = _x get "markerId";
                
                // Check if marker exists before modifying
                if (getMarkerPos _markerId isEqualTo [0,0,0]) then {
                    diag_log format ["[RECONDO_OUTPOSTTELE] WARNING: Marker '%1' does not exist!", _markerId];
                } else {
                    // Set marker visibility based on side permission
                    if (_playerAllowed) then {
                        _markerId setMarkerAlphaLocal 1;
                        diag_log format ["[RECONDO_OUTPOSTTELE] Marker '%1' set VISIBLE (alpha 1)", _markerId];
                    } else {
                        _markerId setMarkerAlphaLocal 0;
                        diag_log format ["[RECONDO_OUTPOSTTELE] Marker '%1' set HIDDEN (alpha 0) - player side %2 not allowed (expected %3)", _markerId, side player, _allowedSide];
                    };
                };
            } forEach _instanceOutposts;
            
        } forEach RECONDO_OUTPOSTTELE_INSTANCES;
        
    }, [], 30, {
        // Timeout after 30 seconds - log error
        diag_log "[RECONDO_OUTPOSTTELE] ERROR: Timeout waiting for player initialization! Marker visibility not set.";
    }] call CBA_fnc_waitUntilAndExecute;
    
    // ========================================
    // ADD RETURN TO BASE SELF-INTERACT ACTION
    // ========================================
    
    // Create single action "Return to Base" - TELEPORTS DIRECTLY (no confirm)
    private _returnAction = [
        "Recondo_OutpostTele_Return",
        "Return to Base",
        "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\exit_ca.paa",
        {
            // Statement: Execute return teleport directly
            params ["_target", "_player", "_params"];
            
            // Get current outpost data
            private _result = [_player] call RECONDO_fnc_isInOutpostArea;
            _result params ["_inArea", "_outpostData"];
            
            if (!_inArea) exitWith {
                hint "You are no longer in the outpost area!";
            };
            
            private _instanceId = _outpostData get "instanceId";
            
            // Get settings for cooldown check
            private _settings = nil;
            {
                if ((_x get "instanceId") == _instanceId) exitWith {
                    _settings = _x;
                };
            } forEach RECONDO_OUTPOSTTELE_INSTANCES;
            
            if (isNil "_settings") exitWith {
                hint "Error: Could not find teleporter settings!";
            };
            
            private _cooldown = _settings get "cooldown";
            
            // Check cooldown
            private _lastTeleport = _player getVariable ["RECONDO_OUTPOSTTELE_LAST_TELEPORT", 0];
            if (_cooldown > 0 && {time - _lastTeleport < _cooldown}) exitWith {
                private _remaining = ceil (_cooldown - (time - _lastTeleport));
                hint format ["Teleporter on cooldown: %1 seconds remaining", _remaining];
            };
            
            // Get base object
            private _baseObj = [_instanceId] call RECONDO_fnc_getBaseObjectForInstance;
            
            if (isNull _baseObj) exitWith {
                hint "Error: Base teleporter not found!";
            };
            
            // Execute return teleport
            [_player, _baseObj, _settings] call Recondo_fnc_teleportToBase;
            
            // Set cooldown
            _player setVariable ["RECONDO_OUTPOSTTELE_LAST_TELEPORT", time];
        },
        {
            // Condition: Check if player is in any outpost area
            params ["_target", "_player", "_params"];
            
            private _result = [_player] call RECONDO_fnc_isInOutpostArea;
            _result select 0
        }
    ] call ace_interact_menu_fnc_createAction;
    
    ["CAManBase", 1, ["ACE_SelfActions"], _returnAction, true] call ace_interact_menu_fnc_addActionToClass;
    
    diag_log format ["[RECONDO_OUTPOSTTELE] Client initialized. %1 instances, %2 outposts available.", 
        count RECONDO_OUTPOSTTELE_INSTANCES, count RECONDO_OUTPOSTTELE_OUTPOSTS];
        
}, []] call CBA_fnc_waitUntilAndExecute;
