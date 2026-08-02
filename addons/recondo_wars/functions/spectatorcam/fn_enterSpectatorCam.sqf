/*
    Recondo_fnc_enterSpectatorCam
    Opens the End Game Spectator camera on the local client

    Description:
        Death/unconscious entry: waits the configured death-cam delay so the
        player sees how they went down, re-checks that they are STILL dead or
        unconscious (a revive or instant respawn during the delay cancels the
        camera), then initializes BIS_fnc_EGSpectator.

        Camera options (spectatable sides, AI viewing, free camera, 3rd
        person) come from the module's DEATH CAM or OBJECT CAM attribute
        group depending on the entry path - dead players usually get the
        locked-down anti-scouting view while a base spectator station can be
        freer. All widgets stay hidden except the player list.

        Manual entry (living player via a synced spectator object): no delay,
        no death checks, and an Esc-to-exit key handler is armed on the
        spectator display - respawn will never close the camera for a living
        player, so Esc is their way out. The same handler consumes the keys
        that drive the character (movement/stance/fire, read from the user's
        actual keybinds) because the EG spectator passes keyboard input
        through to the body. The display is found by diffing allDisplays
        around the Initialize call instead of relying on a hardcoded
        display idd.

        MAP LOCKDOWN: the EG spectator side whitelist only filters the entity
        lists/cycling - the in-spectator map still shows all units and lets
        the player click ANY of them to spectate (known engine bug). When the
        entry is restricted to own side, the map control is disabled and kept
        hidden for the camera's lifetime.

        playerSide is used instead of side player because a corpse's side
        reads as CIVILIAN, which would empty the spectate whitelist.

    Parameters:
        0: _manual - BOOL - true for living players entering via a synced
           spectator object (optional, default false)

    Returns:
        Nothing
*/

params [["_manual", false, [false]]];

if (!hasInterface) exitWith {};
if (RECONDO_SPECTATORCAM_ACTIVE) exitWith {};

private _settings = missionNamespace getVariable ["RECONDO_SPECTATORCAM_SETTINGS", createHashMap];
private _delay = [_settings getOrDefault ["spectatorDelay", 3], 0] select _manual;

[{
    params ["_manual"];

    if (RECONDO_SPECTATORCAM_ACTIVE) exitWith {};

    // Death entry only opens if the player is STILL dead/unconscious
    if (!_manual
        && {alive player}
        && {!(player getVariable ["ACE_isUnconscious", false])}) exitWith {};

    RECONDO_SPECTATORCAM_ACTIVE = true;

    // Camera options come from the entry path's own attribute group
    private _settings = missionNamespace getVariable ["RECONDO_SPECTATORCAM_SETTINGS", createHashMap];
    private _prefix = ["death", "object"] select _manual;
    private _allowAI = _settings getOrDefault [_prefix + "AllowAI", false];
    private _freeCam = _settings getOrDefault [_prefix + "FreeCam", false];
    private _thirdPerson = _settings getOrDefault [_prefix + "ThirdPerson", false];
    private _sides = [
        [playerSide],
        [west, east, independent, civilian]
    ] select (_settings getOrDefault [_prefix + "AllSides", false]);

    private _before = allDisplays;

    [
        "Initialize",
        [
            player,             // spectator
            _sides,             // spectatable sides
            _allowAI,           // AI viewing
            _freeCam,           // free camera
            _thirdPerson,       // 3rd person camera
            false,              // hide focus info
            false,              // hide camera buttons
            false,              // hide controls help
            false,              // hide header
            true                // show player list
        ]
    ] call BIS_fnc_EGSpectator;

    // Post-Initialize display work: Esc-to-exit for manual entries, and killing
    // the in-spectator map when restricted to own side. The EG spectator side
    // whitelist only filters the lists/cycling - the map still shows and lets
    // players click units of ANY side to spectate them (known engine bug), so
    // "Own Side Only" is only honest with the map gone.
    private _ownSideOnly = !(_settings getOrDefault [_prefix + "AllSides", false]);
    [{
        params ["_before", "_manual", "_ownSideOnly", "_debug"];
        if (!RECONDO_SPECTATORCAM_ACTIVE) exitWith {};

        private _disp = (allDisplays - _before) param [0, displayNull];
        if (isNull _disp) exitWith {
            diag_log "[RECONDO_SPECTATORCAM] WARNING: spectator display not found - Esc-to-exit / map lockdown unavailable";
        };

        if (_manual) then {
            // The EG spectator was built for dead players and passes keyboard
            // input through to the body - a living spectator would walk around
            // blind. Build the blocklist from the user's REAL keybinds (custom
            // layouts included) and swallow those keys; chat and other UI keys
            // stay usable. Unknown action names return [] harmlessly.
            private _blockedKeys = [];
            {
                _blockedKeys append (actionKeys _x);
            } forEach [
                "MoveForward", "MoveBack", "TurnLeft", "TurnRight",
                "MoveLeft", "MoveRight", "MoveFastForward", "MoveSlowForward",
                "Stand", "Crouch", "Prone", "GetOver",
                "LeanLeft", "LeanRight", "LeanLeftToggle", "LeanRightToggle",
                "Fire", "ReloadMagazine", "ThrowGrenade",
                "GetIn", "GetOut", "Action"
            ];
            RECONDO_SPECTATORCAM_BLOCKED_KEYS = _blockedKeys;

            _disp displayAddEventHandler ["KeyDown", {
                params ["", "_key"];
                if (_key == 1) exitWith {   // DIK 1 = Esc
                    // Terminate outside the display's own event to avoid tearing it down mid-event
                    [{ [] call Recondo_fnc_exitSpectatorCam; }] call CBA_fnc_execNextFrame;
                    true
                };
                // Consume character-control keys so the body stays put
                _key in RECONDO_SPECTATORCAM_BLOCKED_KEYS
            }];
        };

        if (_ownSideOnly) then {
            private _mapCtrls = (allControls _disp) select {ctrlType _x in [100, 101]};   // CT_MAP / CT_MAP_MAIN
            if (_mapCtrls isEqualTo []) exitWith {
                diag_log "[RECONDO_SPECTATORCAM] WARNING: no map control found in spectator display - map lockdown ineffective";
            };

            {_x ctrlEnable false} forEach _mapCtrls;

            // The spectator's own map toggle re-shows the control, so a one-shot
            // hide is not enough - keep forcing it hidden for the camera's lifetime
            [{
                params ["_args", "_pfhId"];
                _args params ["_disp", "_mapCtrls"];

                if (!RECONDO_SPECTATORCAM_ACTIVE || {isNull _disp}) exitWith {
                    [_pfhId] call CBA_fnc_removePerFrameHandler;
                };
                {_x ctrlShow false} forEach _mapCtrls;
            }, 0, [_disp, _mapCtrls]] call CBA_fnc_addPerFrameHandler;

            if (_debug) then {
                diag_log format ["[RECONDO_SPECTATORCAM] Map lockdown: %1 map control(s) hidden", count _mapCtrls];
            };
        };
    }, [_before, _manual, _ownSideOnly, _settings getOrDefault ["debugLogging", false]], 1] call CBA_fnc_waitAndExecute;

    if (_settings getOrDefault ["debugLogging", false]) then {
        diag_log format ["[RECONDO_SPECTATORCAM] Spectator opened (manual %1, sides %2, AI %3, free %4, 3PP %5)",
            _manual, _sides, _allowAI, _freeCam, _thirdPerson];
    };
}, [_manual], _delay] call CBA_fnc_waitAndExecute;
