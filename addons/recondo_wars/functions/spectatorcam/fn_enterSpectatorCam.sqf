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
        player, so Esc is their way out. The display is found by diffing
        allDisplays around the Initialize call instead of relying on a
        hardcoded display idd.

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

    if (_manual) then {
        // Arm Esc-to-exit on the freshly created spectator display
        [{
            params ["_before"];
            if (!RECONDO_SPECTATORCAM_ACTIVE) exitWith {};

            private _disp = (allDisplays - _before) param [0, displayNull];
            if (isNull _disp) exitWith {
                diag_log "[RECONDO_SPECTATORCAM] WARNING: spectator display not found - Esc-to-exit unavailable";
            };

            _disp displayAddEventHandler ["KeyDown", {
                params ["", "_key"];
                if (_key == 1) then {   // DIK 1 = Esc
                    // Terminate outside the display's own event to avoid tearing it down mid-event
                    [{ [] call Recondo_fnc_exitSpectatorCam; }] call CBA_fnc_execNextFrame;
                    true
                } else { false };
            }];
        }, [_before], 1] call CBA_fnc_waitAndExecute;
    };

    if (_settings getOrDefault ["debugLogging", false]) then {
        diag_log format ["[RECONDO_SPECTATORCAM] Spectator opened (manual %1, sides %2, AI %3, free %4, 3PP %5)",
            _manual, _sides, _allowAI, _freeCam, _thirdPerson];
    };
}, [_manual], _delay] call CBA_fnc_waitAndExecute;
