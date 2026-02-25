/*
    Recondo_fnc_startWiretapRetrieve
    Client-side: Starts the wiretap retrieval process
    
    Description:
        Multi-stage progress bar sequence:
        1. Climb up pole
        2. Retrieve wiretap
        3. Climb down
        
        Uses invisible barrier for climbing effect.
    
    Parameters:
        _pole - OBJECT - The pole to retrieve wiretap from
        _player - OBJECT - The player retrieving the wiretap
*/

if (!hasInterface) exitWith {};

params [
    ["_pole", objNull, [objNull]],
    ["_player", objNull, [objNull]]
];

if (isNull _pole || isNull _player) exitWith {};

// Get settings
private _climbDuration = RECONDO_WIRETAP_SETTINGS get "climbDuration";
private _placeDuration = RECONDO_WIRETAP_SETTINGS get "placeDuration";
private _poleHeight = RECONDO_WIRETAP_SETTINGS get "poleHeight";
private _textClimbingUp = RECONDO_WIRETAP_SETTINGS get "textClimbingUp";
private _textClimbingDown = RECONDO_WIRETAP_SETTINGS get "textClimbingDown";
private _textRetrieving = RECONDO_WIRETAP_SETTINGS get "textRetrieving";
private _textCancelled = RECONDO_WIRETAP_SETTINGS get "textCancelled";

// Store original position
private _originalPos = getPosATL _player;

// Start climbing up progress bar
[
    _climbDuration,
    [_pole, _player, _originalPos, _poleHeight, _placeDuration, _textClimbingDown, _textRetrieving, _textCancelled],
    {
        // On complete - player is now "at top"
        params ["_args"];
        _args params ["_pole", "_player", "_originalPos", "_poleHeight", "_placeDuration", "_textClimbingDown", "_textRetrieving", "_textCancelled"];
        
        // Create invisible barrier at pole height
        private _polePos = getPosATL _pole;
        private _barrier = createVehicle ["Land_InvisibleBarrier_F", _polePos, [], 0, "CAN_COLLIDE"];
        _barrier setPosATL [_polePos select 0, _polePos select 1, _poleHeight];
        
        // Store barrier reference
        _player setVariable ["RECONDO_WIRETAP_barrier", _barrier, false];
        _player setVariable ["RECONDO_WIRETAP_isOnPole", true, false];
        
        // Disable collision and simulation
        _player disableCollisionWith _barrier;
        _player enableSimulation false;
        
        // Move player to platform
        _player setPosATL (getPosATL _barrier vectorAdd [0, 0, 1]);
        _player switchMove "HubSpectator_stand";
        
        // Hide player model
        [_player, true] remoteExec ["hideObjectGlobal", 2];
        
        // Start retrieving wiretap progress bar
        [
            _placeDuration,
            [_pole, _player, _originalPos, _textClimbingDown, _textCancelled],
            {
                // On complete - wiretap retrieved
                params ["_args"];
                _args params ["_pole", "_player", "_originalPos", "_textClimbingDown", "_textCancelled"];
                
                // Server-side completion
                [_pole, _player] remoteExec ["Recondo_fnc_completeWiretapRetrieve", 2];
                
                // Get climb duration for descent
                private _climbDuration = RECONDO_WIRETAP_SETTINGS get "climbDuration";
                
                // Start climbing down progress bar
                [
                    _climbDuration,
                    [_player, _originalPos],
                    {
                        // On complete - back on ground
                        params ["_args"];
                        _args params ["_player", "_originalPos"];
                        
                        // Clean up
                        private _barrier = _player getVariable ["RECONDO_WIRETAP_barrier", objNull];
                        deleteVehicle _barrier;
                        
                        // Reset player
                        _player enableSimulation false;
                        _player setPosATL _originalPos;
                        [_player, false] remoteExec ["hideObjectGlobal", 2];
                        _player switchMove "";
                        _player enableSimulation true;
                        
                        _player setVariable ["RECONDO_WIRETAP_isOnPole", false, false];
                        _player setVariable ["RECONDO_WIRETAP_barrier", nil, false];
                    },
                    {
                        // On cancel climbing down - still complete descent
                        params ["_args"];
                        _args params ["_player", "_originalPos"];
                        
                        private _barrier = _player getVariable ["RECONDO_WIRETAP_barrier", objNull];
                        deleteVehicle _barrier;
                        
                        _player enableSimulation false;
                        _player setPosATL _originalPos;
                        [_player, false] remoteExec ["hideObjectGlobal", 2];
                        _player switchMove "";
                        _player enableSimulation true;
                        
                        _player setVariable ["RECONDO_WIRETAP_isOnPole", false, false];
                    },
                    _textClimbingDown
                ] call ace_common_fnc_progressBar;
            },
            {
                // On cancel retrieving - descend without item
                params ["_args"];
                _args params ["_pole", "_player", "_originalPos", "_textClimbingDown", "_textCancelled"];
                
                hint _textCancelled;
                
                // Quick descent
                private _barrier = _player getVariable ["RECONDO_WIRETAP_barrier", objNull];
                deleteVehicle _barrier;
                
                _player enableSimulation false;
                _player setPosATL _originalPos;
                [_player, false] remoteExec ["hideObjectGlobal", 2];
                _player switchMove "";
                _player enableSimulation true;
                
                _player setVariable ["RECONDO_WIRETAP_isOnPole", false, false];
            },
            _textRetrieving
        ] call ace_common_fnc_progressBar;
    },
    {
        // On cancel climbing up
        params ["_args"];
        _args params ["_pole", "_player", "_originalPos", "_poleHeight", "_placeDuration", "_textClimbingDown", "_textRetrieving", "_textCancelled"];
        
        hint _textCancelled;
    },
    _textClimbingUp
] call ace_common_fnc_progressBar;
