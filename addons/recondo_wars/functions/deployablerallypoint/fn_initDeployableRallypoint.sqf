/*
    Recondo_fnc_initDeployableRallypoint
    Deployable Rally Point System - Client-side initialization
    
    Description:
        Adds ACE self-interaction for deploying rally points.
        Adds ACE interaction on base objects for teleporting to rallies.
        Handles respawn event for auto-teleport option.
    
    Returns:
        Nothing
*/

// Only run on clients with interface
if (!hasInterface) exitWith {};

// Wait for DRP data to be defined
[{
    !isNil "RECONDO_DRP_INITIALIZED" &&
    !isNil "RECONDO_DRP_SETTINGS" &&
    !isNil "RECONDO_DRP_BASE_OBJECTS"
}, {
    private _settings = RECONDO_DRP_SETTINGS;
    
    if (isNil "_settings") exitWith {
        diag_log "[RECONDO_DRP] No Deployable Rallypoint module placed.";
    };
    
    private _systemName = _settings get "systemName";
    private _allowedSideNum = _settings get "allowedSideNum";
    private _selectActionText = _settings get "selectActionText";
    private _autoRespawnToRally = _settings get "autoRespawnToRally";
    private _enableDebug = _settings get "enableDebug";
    
    // ========================================
    // HELPER: CONVERT SIDE NUMBER TO SIDE
    // ========================================
    
    RECONDO_DRP_fnc_sideNumToSide = {
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
    // HELPER: CHECK IF PLAYER CAN DEPLOY
    // ========================================
    
    RECONDO_DRP_fnc_canDeploy = {
        params ["_player"];
        
        // Always log to help diagnose issues
        diag_log format ["[RECONDO_DRP] canDeploy called for player: %1", name _player];
        
        private _settings = RECONDO_DRP_SETTINGS;
        if (isNil "_settings") exitWith { 
            diag_log "[RECONDO_DRP] canDeploy: Settings is nil!";
            false 
        };
        
        private _allowedSideNum = _settings get "allowedSideNum";
        private _allowedSide = [_allowedSideNum] call RECONDO_DRP_fnc_sideNumToSide;
        private _playerSide = side _player;
        
        diag_log format ["[RECONDO_DRP] canDeploy: playerSide=%1, allowedSideNum=%2, allowedSide=%3", _playerSide, _allowedSideNum, _allowedSide];
        
        // Check side restriction
        if (!isNil "_allowedSide" && {_playerSide != _allowedSide}) exitWith { 
            diag_log format ["[RECONDO_DRP] canDeploy: FAILED - Side mismatch (player: %1, allowed: %2)", _playerSide, _allowedSide];
            false 
        };
        
        // Check item requirement (use variable to avoid exitWith scope issue)
        private _requireItemEnabled = _settings get "requireItemEnabled";
        private _hasRequiredItem = true;
        
        diag_log format ["[RECONDO_DRP] canDeploy: requireItemEnabled=%1", _requireItemEnabled];
        
        if (_requireItemEnabled) then {
            private _requiredItem = _settings get "requiredItem";
            
            // Check if it's an ACRE radio (use ACRE API) or normal item (use BIS_fnc_hasItem)
            if ((_requiredItem find "ACRE_") == 0 && {!isNil "acre_api_fnc_getCurrentRadioList"}) then {
                // ACRE radio - use ACRE API to check (radios have unique instance IDs)
                private _radioList = [] call acre_api_fnc_getCurrentRadioList;
                {
                    private _baseRadio = [_x] call acre_api_fnc_getBaseRadio;
                    if (_baseRadio == _requiredItem) exitWith {
                        _hasRequiredItem = true;
                    };
                } forEach _radioList;
                
                diag_log format ["[RECONDO_DRP] canDeploy: requiredItem='%1', hasItem=%2 (ACRE API, radios: %3)", _requiredItem, _hasRequiredItem, count _radioList];
            } else {
                // Normal item - use standard check
                _hasRequiredItem = [_player, _requiredItem] call BIS_fnc_hasItem;
                
                diag_log format ["[RECONDO_DRP] canDeploy: requiredItem='%1', hasItem=%2 (BIS_fnc_hasItem)", _requiredItem, _hasRequiredItem];
            };
        };
        
        // exitWith at function scope works correctly
        if (!_hasRequiredItem) exitWith { 
            diag_log "[RECONDO_DRP] canDeploy: FAILED - Missing required item";
            false 
        };
        
        diag_log "[RECONDO_DRP] canDeploy: SUCCESS - All checks passed";
        true
    };
    
    // ========================================
    // ADD ACE SELF-ACTION FOR DEPLOYING RALLY
    // ========================================
    
    diag_log format ["[RECONDO_DRP] Creating ACE self-action: %1", _systemName];
    diag_log format ["[RECONDO_DRP] RECONDO_DRP_fnc_canDeploy defined: %1", !isNil "RECONDO_DRP_fnc_canDeploy"];
    
    private _deployAction = [
        "Recondo_DRP_Deploy",
        _systemName,
        "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\navigate_ca.paa",
        {
            // Statement: Deploy rally point
            params ["_target", "_player", "_params"];
            [_player] call Recondo_fnc_deployRallypoint;
        },
        {
            // Condition: Check if player can deploy
            params ["_target", "_player", "_params"];
            
            // Safety check - ensure function exists
            if (isNil "RECONDO_DRP_fnc_canDeploy") exitWith { 
                diag_log "[RECONDO_DRP] ERROR: canDeploy function not defined!";
                false 
            };
            
            [_player] call RECONDO_DRP_fnc_canDeploy
        }
    ] call ace_interact_menu_fnc_createAction;
    
    ["CAManBase", 1, ["ACE_SelfActions"], _deployAction, true] call ace_interact_menu_fnc_addActionToClass;
    
    diag_log format ["[RECONDO_DRP] ACE self-action added successfully: %1", _systemName];
    
    // ========================================
    // ADD ACE ACTIONS TO BASE TELEPORTER OBJECTS
    // ========================================
    
    {
        private _baseData = _x;
        private _netId = _baseData get "netId";
        private _baseObject = objectFromNetId _netId;
        
        if (isNull _baseObject) then {
            diag_log format ["[RECONDO_DRP] WARNING: Could not find base object with netId: %1", _netId];
            continue;
        };
        
        // Create parent action for selecting rally point (with dynamic children)
        private _parentAction = [
            "Recondo_DRP_SelectRally",
            _selectActionText,
            "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\navigate_ca.paa",
            {},  // No action on parent - children handle teleport
            {
                // Condition: Check side and if rallies exist
                params ["_target", "_player", "_params"];
                
                private _settings = RECONDO_DRP_SETTINGS;
                if (isNil "_settings") exitWith { false };
                
                private _allowedSideNum = _settings get "allowedSideNum";
                private _allowedSide = [_allowedSideNum] call RECONDO_DRP_fnc_sideNumToSide;
                
                // Check side restriction
                if (!isNil "_allowedSide" && {side _player != _allowedSide}) exitWith { false };
                
                // Check if any rallies exist for player's side
                private _rallies = missionNamespace getVariable ["RECONDO_DRP_RALLIES", []];
                private _playerSide = side _player;
                private _sideRallies = _rallies select { 
                    private _rallySideNum = _x get "sideNum";
                    private _rallySide = [_rallySideNum] call RECONDO_DRP_fnc_sideNumToSide;
                    !isNil "_rallySide" && {_rallySide == _playerSide}
                };
                
                count _sideRallies > 0
            },
            {
                // Dynamic children - create child action for each rally point
                params ["_target", "_player", "_params"];
                
                private _actions = [];
                private _settings = RECONDO_DRP_SETTINGS;
                if (isNil "_settings") exitWith { _actions };
                
                private _rallies = missionNamespace getVariable ["RECONDO_DRP_RALLIES", []];
                private _playerSide = side _player;
                private _markerText = _settings get "markerText";
                
                // Filter rallies for player's side
                private _sideRallies = _rallies select {
                    private _rallySideNum = _x get "sideNum";
                    private _rallySide = [_rallySideNum] call RECONDO_DRP_fnc_sideNumToSide;
                    !isNil "_rallySide" && {_rallySide == _playerSide}
                };
                
                // Create a child action for each rally
                {
                    private _rallyData = _x;
                    private _rallyIndex = _forEachIndex;
                    private _pos = _rallyData get "position";
                    private _deployedBy = _rallyData get "deployedBy";
                    
                    // Create display name (e.g., "Rally Point 1" or "Rally Point 1 (PlayerName)")
                    private _displayName = format ["%1 %2", _markerText, _rallyIndex + 1];
                    if (!isNil "_deployedBy" && {_deployedBy != ""}) then {
                        _displayName = format ["%1 (%2)", _displayName, _deployedBy];
                    };
                    
                    private _childAction = [
                        format ["Recondo_DRP_Rally_%1", _rallyIndex],
                        _displayName,
                        "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\move_ca.paa",
                        {
                            // Teleport player to rally
                            params ["_target", "_player", "_params"];
                            private _rallyData = _params select 0;
                            private _pos = _rallyData get "position";
                            
                            if (!isNil "_pos") then {
                                _player setPosATL _pos;
                                
                                private _settings = RECONDO_DRP_SETTINGS;
                                if (!isNil "_settings") then {
                                    hint format ["Teleported to %1", _settings get "markerText"];
                                };
                            };
                        },
                        { true },  // Always show if parent is visible
                        {},
                        [_rallyData]  // Pass rally data as params
                    ] call ace_interact_menu_fnc_createAction;
                    
                    _actions pushBack [_childAction, [], _target];
                } forEach _sideRallies;
                
                _actions
            }
        ] call ace_interact_menu_fnc_createAction;
        
        [_baseObject, 0, ["ACE_MainActions"], _parentAction, true] call ace_interact_menu_fnc_addActionToObject;
        
        if (_enableDebug) then {
            diag_log format ["[RECONDO_DRP] Added ACE action to base object: %1", typeOf _baseObject];
        };
        
    } forEach RECONDO_DRP_BASE_OBJECTS;
    
    // ========================================
    // SETUP RESPAWN HANDLER FOR AUTO-TELEPORT
    // ========================================
    
    if (_autoRespawnToRally) then {
        player addEventHandler ["Respawn", {
            params ["_newUnit", "_corpse"];
            
            // Delay slightly to ensure player is fully spawned
            [{
                params ["_unit"];
                
                private _settings = RECONDO_DRP_SETTINGS;
                if (isNil "_settings") exitWith {};
                
                if (!(_settings get "autoRespawnToRally")) exitWith {};
                
                // Find most recent rally for player's side
                private _rallies = missionNamespace getVariable ["RECONDO_DRP_RALLIES", []];
                private _playerSide = side _unit;
                
                private _sideRallies = _rallies select {
                    private _rallySideNum = _x get "sideNum";
                    private _rallySide = [_rallySideNum] call RECONDO_DRP_fnc_sideNumToSide;
                    !isNil "_rallySide" && {_rallySide == _playerSide}
                };
                
                if (count _sideRallies == 0) exitWith {};
                
                // Get most recent (last in array)
                private _rallyData = _sideRallies select ((count _sideRallies) - 1);
                private _pos = _rallyData get "position";
                
                if (!isNil "_pos") then {
                    _unit setPosATL _pos;
                    
                    if (_settings get "enableDebug") then {
                        diag_log format ["[RECONDO_DRP] Auto-teleported %1 to rally at %2", name _unit, _pos];
                    };
                };
            }, [_newUnit], 0.5] call CBA_fnc_waitAndExecute;
        }];
        
        if (_enableDebug) then {
            diag_log "[RECONDO_DRP] Auto-respawn to rally enabled";
        };
    };
    
    // ========================================
    // CONTROL MARKER VISIBILITY BY SIDE
    // ========================================
    
    // Wait for player side to be assigned
    [{
        !isNull player && 
        alive player && 
        side player != sideUnknown
    }, {
        // Update marker visibility based on side
        [] spawn {
            while {true} do {
                private _settings = RECONDO_DRP_SETTINGS;
                if (isNil "_settings") exitWith {};
                
                private _allowedSideNum = _settings get "allowedSideNum";
                private _allowedSide = [_allowedSideNum] call RECONDO_DRP_fnc_sideNumToSide;
                
                private _rallies = missionNamespace getVariable ["RECONDO_DRP_RALLIES", []];
                
                {
                    private _markerName = _x get "markerName";
                    private _rallySideNum = _x get "sideNum";
                    private _rallySide = [_rallySideNum] call RECONDO_DRP_fnc_sideNumToSide;
                    
                    if (isNil "_markerName" || {_markerName == ""}) then { continue };
                    
                    // Show marker if:
                    // - Module allows any side (allowedSide is nil), OR
                    // - Player is on the rally's side
                    private _showMarker = false;
                    
                    if (isNil "_allowedSide") then {
                        // Any side mode - show to rally owner's side only
                        if (!isNil "_rallySide" && {side player == _rallySide}) then {
                            _showMarker = true;
                        };
                    } else {
                        // Restricted side mode - show to allowed side
                        if (side player == _allowedSide) then {
                            _showMarker = true;
                        };
                    };
                    
                    if (_showMarker) then {
                        _markerName setMarkerAlphaLocal 1;
                    } else {
                        _markerName setMarkerAlphaLocal 0;
                    };
                } forEach _rallies;
                
                sleep 5;
            };
        };
    }, [], 30, {
        diag_log "[RECONDO_DRP] ERROR: Timeout waiting for player initialization!";
    }] call CBA_fnc_waitUntilAndExecute;
    
    diag_log format ["[RECONDO_DRP] Client initialized. %1 base teleporter objects.", count RECONDO_DRP_BASE_OBJECTS];
    
}, []] call CBA_fnc_waitUntilAndExecute;
