/*
    Recondo_fnc_classifyVehicle
    Classify detected vehicles by type
    
    Description:
        Examines detected units and returns the heaviest vehicle classification.
    
    Parameters:
        _thisList - ARRAY - List of detected units from trigger
    
    Returns:
        STRING - Vehicle classification ("Light vehicle", "APC", "Tank", "Boat")
*/

params [["_thisList", [], [[]]]];

private _heavierVehicle = -1;

{
    private _veh = vehicle _x;
    if (_veh != _x) then {
        private _objectType = (_veh call BIS_fnc_objectType) select 1;
        
        if (_heavierVehicle < 0 && (_objectType == "Car" || _objectType == "Motorcycle")) then {
            _heavierVehicle = 0;
        };
        
        if (_heavierVehicle < 1 && (_objectType == "TrackedAPC" || _objectType == "WheeledAPC")) then {
            _heavierVehicle = 1;
        };
        
        if (_heavierVehicle < 2 && _objectType == "Tank") then {
            _heavierVehicle = 2;
        };
        
        if (_heavierVehicle < 3 && (_objectType == "Ship" || _objectType == "Boat" || _objectType == "Submarine")) then {
            _heavierVehicle = 3;
        };
    };
} forEach _thisList;

private _classification = switch (_heavierVehicle) do {
    case 0: { "Light vehicle" };
    case 1: { "APC" };
    case 2: { "Tank" };
    case 3: { "Boat" };
    default { "Vehicle" };
};

_classification
