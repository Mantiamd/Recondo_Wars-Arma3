/*
    Recondo_fnc_startVoicelineLoop
    Starts an idle-talk voiceline loop for a spawned AI group

    Description:
        Shared by the patrol/camp spawner modules (Foot Patrols, Path
        Patrols, Camps Random). While any living group member is within
        100m of a player, a random living member speaks a Vietnamese
        voiceline (vn-talks-n pool) on a jittered 30-60s cadence. Quiet
        conversation levels - audible out to ~120m, so hearing voices
        through the jungle means the patrol is nearly on top of you.

        The timer starts expired, so the first close contact speaks
        immediately. Speakers are filtered to simulation-enabled units,
        so camp sentries frozen by the simulation monitor stay silent
        until players are close enough to wake them.

        Deliberately no combat check - the whistle/radio loops don't have
        one either, and the proximity gate plus cadence keeps it from
        reading wrong in a firefight.

        Server-side; the loop only reads positions and remoteExecs the
        sound to clients, so it keeps working for groups handed to a
        Headless Client.

    Parameters:
        0: GROUP - Group to attach the voiceline loop to

    Returns:
        Nothing
*/

if (!isServer) exitWith {};

params [["_group", grpNull, [grpNull]]];

if (isNull _group) exitWith {};

// Sound pool and client-side player, built once (JIP-safe via publicVariable)
if (isNil "RECONDO_VOICELINES_SOUNDS") then {
    RECONDO_VOICELINES_SOUNDS = [];
    for "_i" from 1 to 30 do {
        RECONDO_VOICELINES_SOUNDS pushBack format ["vn-talks-n-%1%2", ["", "0"] select (_i < 10), _i];
    };
};

if (isNil "RECONDO_VOICELINES_fnc_play") then {
    RECONDO_VOICELINES_fnc_play = compileFinal "
        if (!hasInterface) exitWith {};
        params ['_unit', '_sounds'];
        if (_sounds isEqualTo []) exitWith {};
        if (player distance _unit > 120) exitWith {};
        private _sound = selectRandom _sounds;
        private _soundPath = '\recondo_wars\sounds\vn_n\' + _sound + '.ogg';
        playSound3D [_soundPath, _unit, false, getPosASL _unit, 2, 1, 120];
    ";
    publicVariable "RECONDO_VOICELINES_fnc_play";
};

[_group] spawn {
    params ["_group"];

    private _lastTalkTime = time - 999;

    while {!isNull _group && {(units _group findIf { alive _x }) != -1}} do {
        private _interval = 30 + random 30;

        if (time - _lastTalkTime >= _interval) then {
            // Frozen units (camp simulation monitor) can't be heard rustling
            // about, so they don't talk either
            private _candidates = (units _group) select { alive _x && {simulationEnabled _x} };

            private _inRange = _candidates findIf {
                private _unit = _x;
                (allPlayers findIf { alive _x && {_x distance2D _unit <= 100} }) != -1
            } != -1;

            if (_inRange) then {
                [selectRandom _candidates, RECONDO_VOICELINES_SOUNDS] remoteExec ["RECONDO_VOICELINES_fnc_play", 0];
                _lastTalkTime = time;
            };
        };

        sleep 5;
    };
};
