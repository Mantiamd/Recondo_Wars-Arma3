/*
    Recondo_fnc_findNearestValidPOW
    Finds the nearest valid POW within range of a turn-in point
    
    Description:
        Searches for units within range that match the POW criteria
        (side OR classname filter) and have not been turned in yet.
        Returns the nearest valid unit.
    
    Parameters:
        _turnInObject - OBJECT - The turn-in point
        _radius - NUMBER - Search radius
    
    Returns:
        OBJECT - Nearest valid POW or objNull if none found
*/

params [
    ["_turnInObject", objNull, [objNull]],
    ["_radius", 10, [0]]
];

if (isNull _turnInObject) exitWith { objNull };

// Get POW settings
private _settings = if (isNil "RECONDO_INTELITEMS_SETTINGS") then { 
    createHashMap 
} else { 
    RECONDO_INTELITEMS_SETTINGS 
};

private _powTargetSide = _settings getOrDefault ["powTargetSide", east];
private _powClassnames = _settings getOrDefault ["powClassnames", []];
private _debugLogging = _settings getOrDefault ["debugLogging", false];

private _turnInPos = getPos _turnInObject;

// Find all units within radius
private _nearbyUnits = _turnInPos nearEntities [["CAManBase"], _radius];

// Filter to valid POWs
private _validPOWs = [];

{
    private _unit = _x;
    
    // Skip if already turned in
    if (_unit getVariable ["RECONDO_POW_TurnedIn", false]) then {
        continue;
    };
    
    // Skip if not alive
    if (!alive _unit) then {
        continue;
    };
    
    // Skip players
    if (isPlayer _unit) then {
        continue;
    };
    
    // Check if matches criteria (OR logic)
    private _matchesSide = false;
    private _matchesClassname = false;
    
    // Check side filter using CONFIG side (not runtime side)
    // This is important because ACE captive changes runtime side to civilian
    if (isNil "_powTargetSide") then {
        // "Any" side selected
        _matchesSide = true;
    } else {
        // Get the unit's original side from config (doesn't change when captured)
        private _configSideNum = getNumber (configFile >> "CfgVehicles" >> typeOf _unit >> "side");
        // Config values: 0 = OPFOR, 1 = BLUFOR, 2 = Independent, 3 = Civilian
        private _configSide = switch (_configSideNum) do {
            case 0: { east };
            case 1: { west };
            case 2: { independent };
            case 3: { civilian };
            default { sideUnknown };
        };
        _matchesSide = (_configSide == _powTargetSide);
    };
    
    // Check classname filter
    if (count _powClassnames > 0) then {
        private _unitType = typeOf _unit;
        _matchesClassname = (_unitType in _powClassnames);
    };
    
    // OR logic: matches if either condition is true
    // If no classnames configured, only check side
    private _isValid = if (count _powClassnames == 0) then {
        _matchesSide
    } else {
        _matchesSide || _matchesClassname
    };
    
    if (_isValid) then {
        _validPOWs pushBack _unit;
    };
} forEach _nearbyUnits;

// Return nearest valid POW
if (count _validPOWs == 0) exitWith { objNull };

// Sort by distance
_validPOWs = [_validPOWs, [], { _x distance _turnInPos }, "ASCEND"] call BIS_fnc_sortBy;

private _nearestPOW = _validPOWs select 0;

if (_debugLogging) then {
    diag_log format ["[RECONDO_INTELITEMS] Found %1 valid POWs near turn-in point, nearest: %2 at %3m", 
        count _validPOWs, 
        typeOf _nearestPOW, 
        round (_nearestPOW distance _turnInPos)
    ];
};

_nearestPOW
