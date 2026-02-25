/*
    Recondo_fnc_civilianPOLInteract
    Handle player interaction with POL civilian
    
    Description:
        When player talks to civilian, shows a response based on
        profession. Has chance to give documents.
    
    Parameters:
        _target - OBJECT - The civilian being talked to
        _player - OBJECT - The player interacting
    
    Returns:
        Nothing
*/

params [
    ["_target", objNull, [objNull]],
    ["_player", objNull, [objNull]]
];

if (isNull _target || isNull _player) exitWith {};

private _debugLogging = RECONDO_CIVPOL_SETTINGS getOrDefault ["debugLogging", false];
private _documentDropChance = RECONDO_CIVPOL_SETTINGS getOrDefault ["documentDropChance", 10];
private _documentClass = RECONDO_CIVPOL_SETTINGS getOrDefault ["documentClass", "ACE_Documents"];

private _job = _target getVariable ["RECONDO_CIVPOL_Job", "Farmer"];
private _gaveDocuments = _target getVariable ["RECONDO_CIVPOL_GaveDocuments", false];

// ========================================
// STOP CIVILIAN BRIEFLY
// ========================================

_target disableAI "MOVE";
doStop _target;

// Face the player
_target lookAt _player;

// ========================================
// SELECT RESPONSE BASED ON PROFESSION
// ========================================

private _responses = [];

switch (_job) do {
    case "Farmer": {
        _responses = [
            "I am just a farmer, working the fields to feed my family.",
            "Please, I mind my own business. The fields need tending.",
            "We grow rice and vegetables here. That is all I know.",
            "I wake with the sun and work until dark. Simple life.",
            "The harvest has been poor this year. Times are hard.",
            "I know nothing of war. I only know the soil."
        ];
    };
    case "Fisherman": {
        _responses = [
            "I am a fisherman. The waters are my life.",
            "Please, I just catch fish to feed the village.",
            "The currents have been strange lately. Fish are scarce.",
            "My father was a fisherman. His father too. It is all I know.",
            "I set my nets at dawn and return at dusk. Simple work.",
            "The sea provides, when she is kind."
        ];
    };
    default {
        _responses = [
            "I am just trying to survive. Please, leave me be.",
            "I know nothing. I see nothing. I say nothing.",
            "Times are hard. We do what we must.",
            "Please, I have a family to care for.",
            "I mind my own business. You should do the same."
        ];
    };
};

// Select random response
private _response = selectRandom _responses;

// Show response to player
hint _response;

// Also show in system chat for other nearby players
format ["%1: ""%2""", name _target, _response] remoteExec ["systemChat", _player];

// ========================================
// DOCUMENT DROP CHANCE
// ========================================

if (!_gaveDocuments && (random 100 < _documentDropChance)) then {
    // Mark that this civilian gave documents (won't give again)
    _target setVariable ["RECONDO_CIVPOL_GaveDocuments", true, true];
    
    // Small delay for immersion
    [{
        params ["_target", "_player", "_documentClass", "_debugLogging"];
        
        // Check if player can carry
        if (_player canAdd _documentClass) then {
            _player addItem _documentClass;
            
            // Show message
            hint "The civilian nervously hands you some papers...";
            "The civilian hands you some documents..." remoteExec ["systemChat", _player];
        } else {
            // Drop on ground
            private _holder = createVehicle ["GroundWeaponHolder", getPos _target, [], 0, "CAN_COLLIDE"];
            _holder addItemCargoGlobal [_documentClass, 1];
            
            hint "The civilian drops some papers at your feet...";
            "The civilian drops some documents..." remoteExec ["systemChat", _player];
        };
        
        if (_debugLogging) then {
            diag_log format ["[RECONDO_CIVPOL] Civilian gave documents to %1", name _player];
        };
        
    }, [_target, _player, _documentClass, _debugLogging], 1.5] call CBA_fnc_waitAndExecute;
};

// ========================================
// RESUME CIVILIAN MOVEMENT AFTER DELAY
// ========================================

[{
    params ["_target"];
    
    if (!isNull _target && alive _target && !(_target getVariable ["RECONDO_CIVPOL_Fleeing", false])) then {
        _target enableAI "MOVE";
    };
    
}, [_target], 3] call CBA_fnc_waitAndExecute;
