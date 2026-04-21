/*
    Recondo_fnc_rpShowPlayerStats
    Independent player statistics display for Roleplayer Source module.
    Mirrors the Terminal's player stats but operates independently.
*/

if (!hasInterface) exitWith {};

private _statsLines = [];

private _playerStats = if (isNil "RECONDO_PERSISTENCE_PLAYER_STATS") then {
    nil
} else {
    RECONDO_PERSISTENCE_PLAYER_STATS
};

if (isNil "_playerStats") then {
    _statsLines pushBack "No player statistics available.";
    _statsLines pushBack "Persistence tracking may be disabled.";
} else {
    private _playerKeys = keys _playerStats;
    
    if (count _playerKeys == 0) then {
        _statsLines pushBack "No player data recorded yet.";
    } else {
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
        
        _playerData sort false;
        
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

private _bodyText = _statsLines joinString "<br/>";

if (_bodyText == "") then {
    _bodyText = "No statistics available.";
};

["PLAYER STATISTICS", _bodyText, 0, 30, "", 1] call Recondo_fnc_showIntelCard;

private _debug = if (isNil "RECONDO_RP_SOURCE_SETTINGS") then { false } else { RECONDO_RP_SOURCE_SETTINGS getOrDefault ["debugLogging", false] };
if (_debug) then {
    diag_log format ["[RECONDO_RP_SOURCE] Displayed player stats for %1 players", count _statsLines];
};
