/*
    Recondo_fnc_startWiretapPlace
    Client-side: Starts the wiretap placement process
    
    Description:
        Multi-stage progress bar sequence:
        1. Climb up pole
        2. Place wiretap
        3. Climb down
        
        Uses invisible barrier for climbing effect.
    
    Parameters:
        _pole - OBJECT - The pole to place wiretap on
        _player - OBJECT - The player placing the wiretap
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
private _wiretapItem = RECONDO_WIRETAP_SETTINGS get "wiretapItem";
private _textClimbingUp = RECONDO_WIRETAP_SETTINGS get "textClimbingUp";
private _textClimbingDown = RECONDO_WIRETAP_SETTINGS get "textClimbingDown";
private _textPlacing = RECONDO_WIRETAP_SETTINGS get "textPlacing";
private _textCancelled = RECONDO_WIRETAP_SETTINGS get "textCancelled";

// Remove wiretap from inventory
_player removeItem _wiretapItem;

// Store original position
private _originalPos = getPosATL _player;

// Start climbing up progress bar
[
    _climbDuration,
    [_pole, _player, _originalPos, _poleHeight, _placeDuration, _textClimbingDown, _textPlacing, _textCancelled, _wiretapItem],
    {
        // On complete - player is now "at top"
        params ["_args"];
        _args params ["_pole", "_player", "_originalPos", "_poleHeight", "_placeDuration", "_textClimbingDown", "_textPlacing", "_textCancelled", "_wiretapItem"];
        
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
        
        // Start placing wiretap progress bar
        [
            _placeDuration,
            [_pole, _player, _originalPos, _textClimbingDown, _textCancelled, _wiretapItem],
            {
                // On complete - wiretap placed
                params ["_args"];
                _args params ["_pole", "_player", "_originalPos", "_textClimbingDown", "_textCancelled", "_wiretapItem"];
                
                // Server-side completion
                [_pole, _player] remoteExec ["Recondo_fnc_completeWiretapPlace", 2];
                
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
                // On cancel placing - return item and descend
                params ["_args"];
                _args params ["_pole", "_player", "_originalPos", "_textClimbingDown", "_textCancelled", "_wiretapItem"];
                
                _player addItem _wiretapItem;
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
            _textPlacing
        ] call ace_common_fnc_progressBar;
    },
    {
        // On cancel climbing up - return item
        params ["_args"];
        _args params ["_pole", "_player", "_originalPos", "_poleHeight", "_placeDuration", "_textClimbingDown", "_textPlacing", "_textCancelled", "_wiretapItem"];
        
        _player addItem _wiretapItem;
        hint _textCancelled;
    },
    _textClimbingUp
] call ace_common_fnc_progressBar;
