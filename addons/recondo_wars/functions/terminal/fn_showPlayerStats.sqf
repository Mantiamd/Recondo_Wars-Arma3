/*
    Recondo_fnc_showPlayerStats
    Displays all player statistics via Intel Card
    
    Description:
        Gathers stats for all players from the persistence system
        and displays them using the Intel Card system.
    
    Parameters:
        None
    
    Returns:
        Nothing
*/

if (!hasInterface) exitWith {};

// Gather player stats
private _statsLines = [];

// Check if persistence tracking is available
private _playerStats = if (isNil "RECONDO_PERSISTENCE_PLAYER_STATS") then {
    nil
} else {
    RECONDO_PERSISTENCE_PLAYER_STATS
};

if (isNil "_playerStats") then {
    _statsLines pushBack "No player statistics available.";
    _statsLines pushBack "Persistence tracking may be disabled.";
} else {
    // Get all tracked players
    private _playerKeys = keys _playerStats;
    
    if (count _playerKeys == 0) then {
        _statsLines pushBack "No player data recorded yet.";
    } else {
        // Sort by kills (descending)
        private _playerData = [];
        {
            private _uid = _x;
            private _stats = _playerStats get _uid;
            
            if (!isNil "_stats") then {
                private _name = _stats getOrDefault ["name", "Unknown"];
                private _kills = _stats getOrDefault ["kills", 0];
                private _deaths = _stats getOrDefault ["deaths", 0];
                private _disconnects = _stats getOrDefault ["disconnects", 0];
                
                _playerData pushBack [_name, _kills, _deaths, _disconnects];
            };
        } forEach _playerKeys;
        
        // Sort by kills descending
        _playerData sort false;
        
        // Format each player's stats
        {
            _x params ["_name", "_kills", "_deaths", "_disconnects"];
            
            private _kd = if (_deaths > 0) then {
                _kills / _deaths
            } else {
                _kills
            };
            
            private _statLine = format ["%1 - K: %2  D: %3  K/D: %4",
                _name, _kills, _deaths, (_kd toFixed 1)];
            
            _statsLines pushBack _statLine;
        } forEach _playerData;
    };
};

// Build display text
private _bodyText = _statsLines joinString "<br/>";

if (_bodyText == "") then {
    _bodyText = "No statistics available.";
};

// Show Intel Card
// Parameters: [title, body, priority, duration, sound, color]
// Colors: 0 = orange, 1 = blue, 2 = green, 3 = red
["PLAYER STATISTICS", _bodyText, 0, 30, "", 1] call Recondo_fnc_showIntelCard;

private _debugLogging = if (isNil "RECONDO_TERMINAL_SETTINGS") then { false } else { RECONDO_TERMINAL_SETTINGS getOrDefault ["debugLogging", false] };
if (_debugLogging) then {
    diag_log format ["[RECONDO_TERMINAL] Displayed player stats for %1 players", count _statsLines];
};
