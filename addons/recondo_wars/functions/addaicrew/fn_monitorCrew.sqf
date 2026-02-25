/*
    Recondo_fnc_monitorCrew
    Adds ACE self-interaction actions to a vehicle for crew management
    
    Description:
        This function is called on all clients to add ACE interaction
        options for requesting and removing AI crew. The actual crew
        creation/deletion is handled server-side.
    
    Parameters:
        0: OBJECT - Target vehicle
        1: HASHMAP - Settings from module
        
    Returns:
        Nothing
        
    Note:
        Despite the name, this function handles ACE action setup.
        The actual monitoring is done via CBA_fnc_addPerFrameHandler
        in fn_requestCrew.sqf
*/

// This function is named monitorCrew for legacy/config reasons
// but actually adds ACE actions. The real monitoring happens in requestCrew.

params ["_vehicle", "_settings"];

// Validate ACE is loaded
if (!isClass (configFile >> "CfgPatches" >> "ace_interact_menu")) exitWith {
    diag_log "[RECONDO_AIC] WARNING: ACE Interact Menu not loaded. Using fallback addAction.";
    
    // Fallback to addAction if ACE not present
    private _requireLanded = _settings get "requireLanded";
    private _requireEngineOff = _settings get "requireEngineOff";
    
    // Build condition string
    private _conditionParts = ["_this == driver _target", "_target getVariable ['RECONDO_AIC_Enabled', false]"];
    if (_requireLanded) then { _conditionParts pushBack "isTouchingGround _target" };
    if (_requireEngineOff) then { _conditionParts pushBack "!(isEngineOn _target)" };
    
    private _requestCondition = (_conditionParts + ["!(_target getVariable ['RECONDO_AIC_HasCrew', false])"]) joinString " && ";
    private _removeCondition = (_conditionParts + ["_target getVariable ['RECONDO_AIC_HasCrew', false]"]) joinString " && ";
    
    _vehicle addAction [
        "<t color='#FFFF00'>Request AI Crew</t>",
        { [_this select 0, _this select 1] call Recondo_fnc_requestCrew },
        nil, 1.5, true, true, "", _requestCondition, 50
    ];
    
    _vehicle addAction [
        "<t color='#FFFF00'>Dismiss AI Crew</t>",
        { [_this select 0, _this select 1] call Recondo_fnc_removeCrew },
        nil, 1.5, true, true, "", _removeCondition, 50
    ];
};

// Get condition settings
private _requireLanded = _settings get "requireLanded";
private _requireEngineOff = _settings get "requireEngineOff";

// Condition function for Request Crew
private _requestCondition = {
    params ["_target", "_player", "_params"];
    _params params ["_requireLanded", "_requireEngineOff"];
    
    // Must be driver
    if (_player != driver _target) exitWith { false };
    
    // Must be enabled
    if !(_target getVariable ["RECONDO_AIC_Enabled", false]) exitWith { false };
    
    // Must not already have crew
    if (_target getVariable ["RECONDO_AIC_HasCrew", false]) exitWith { false };
    
    // Check landed condition
    if (_requireLanded && {!isTouchingGround _target}) exitWith { false };
    
    // Check engine condition
    if (_requireEngineOff && {isEngineOn _target}) exitWith { false };
    
    true
};

// Condition function for Remove Crew
private _removeCondition = {
    params ["_target", "_player", "_params"];
    _params params ["_requireLanded", "_requireEngineOff"];
    
    // Must be driver
    if (_player != driver _target) exitWith { false };
    
    // Must be enabled
    if !(_target getVariable ["RECONDO_AIC_Enabled", false]) exitWith { false };
    
    // Must have crew
    if !(_target getVariable ["RECONDO_AIC_HasCrew", false]) exitWith { false };
    
    // Check landed condition
    if (_requireLanded && {!isTouchingGround _target}) exitWith { false };
    
    // Check engine condition
    if (_requireEngineOff && {isEngineOn _target}) exitWith { false };
    
    true
};

// Statement for Request Crew
private _requestStatement = {
    params ["_target", "_player"];
    [_target, _player] call Recondo_fnc_requestCrew;
};

// Statement for Remove Crew
private _removeStatement = {
    params ["_target", "_player"];
    [_target, _player] call Recondo_fnc_removeCrew;
};

// Add ACE Self-Interaction Actions
// Main category action
private _crewManagementAction = [
    "RECONDO_CrewManagement",
    "Crew Management",
    "\a3\ui_f\data\IGUI\Cfg\Actions\getindriver_ca.paa",
    {},
    {
        params ["_target", "_player"];
        _player == driver _target && 
        _target getVariable ["RECONDO_AIC_Enabled", false]
    }
] call ace_interact_menu_fnc_createAction;

[_vehicle, 1, ["ACE_SelfActions"], _crewManagementAction] call ace_interact_menu_fnc_addActionToObject;

// Request Crew sub-action
private _requestAction = [
    "RECONDO_RequestCrew",
    "Request AI Crew",
    "\a3\ui_f\data\IGUI\Cfg\Actions\talk_ca.paa",
    _requestStatement,
    _requestCondition,
    {},
    [_requireLanded, _requireEngineOff]
] call ace_interact_menu_fnc_createAction;

[_vehicle, 1, ["ACE_SelfActions", "RECONDO_CrewManagement"], _requestAction] call ace_interact_menu_fnc_addActionToObject;

// Remove Crew sub-action
private _removeAction = [
    "RECONDO_RemoveCrew",
    "Dismiss AI Crew",
    "\a3\ui_f\data\IGUI\Cfg\Actions\eject_ca.paa",
    _removeStatement,
    _removeCondition,
    {},
    [_requireLanded, _requireEngineOff]
] call ace_interact_menu_fnc_createAction;

[_vehicle, 1, ["ACE_SelfActions", "RECONDO_CrewManagement"], _removeAction] call ace_interact_menu_fnc_addActionToObject;
