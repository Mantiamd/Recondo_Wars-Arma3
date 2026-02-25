/*
    Recondo_fnc_loadMarkers
    Load and restore map markers from persistence storage
    
    Description:
        Retrieves saved marker data from missionProfileNamespace and
        recreates the markers on the map with all their properties.
    
    Parameters:
        None
        
    Returns:
        NUMBER - Count of markers restored
        
    Example:
        private _count = [] call Recondo_fnc_loadMarkers;
*/

// Only run on server
if (!isServer) exitWith {
    diag_log "[RECONDO_PERSISTENCE] loadMarkers called on non-server.";
    0
};

private _settings = RECONDO_PERSISTENCE_SETTINGS;
private _debug = _settings get "enableDebug";

// Get saved marker data
private _markersData = ["markers", []] call Recondo_fnc_getSaveData;

if (count _markersData == 0) exitWith {
    if (_debug) then {
        diag_log "[RECONDO_PERSISTENCE] No markers to load.";
    };
    0
};

private _restored = 0;

{
    private _markerData = _x;
    
    private _name = _markerData get "name";
    private _pos = _markerData get "pos";
    private _type = _markerData get "type";
    private _color = _markerData get "color";
    private _text = _markerData getOrDefault ["text", ""];
    private _shape = _markerData get "shape";
    private _size = _markerData get "size";
    private _alpha = _markerData getOrDefault ["alpha", 1];
    private _dir = _markerData getOrDefault ["dir", 0];
    private _brush = _markerData getOrDefault ["brush", "Solid"];
    
    // Handle user-defined markers specially
    private _finalName = _name;
    if (_name find "_USER_DEFINED" == 0) then {
        // User-defined markers need special handling
        // Create with a new unique name in the same format
        private _channel = _markerData getOrDefault ["channel", -1];
        _finalName = format ["_USER_DEFINED #RECONDO_restored/%1/%2", _forEachIndex, _channel];
    };
    
    // Check if marker already exists
    if (markerShape _finalName != "") then {
        // Marker exists, update it
        _finalName setMarkerPos _pos;
    } else {
        // Create new marker
        createMarker [_finalName, _pos];
    };
    
    // Apply all properties
    _finalName setMarkerType _type;
    _finalName setMarkerColor _color;
    _finalName setMarkerText _text;
    _finalName setMarkerShape _shape;
    _finalName setMarkerSize _size;
    _finalName setMarkerAlpha _alpha;
    _finalName setMarkerDir _dir;
    _finalName setMarkerBrush _brush;
    
    _restored = _restored + 1;
    
} forEach _markersData;

if (_debug) then {
    diag_log format ["[RECONDO_PERSISTENCE] Restored %1 markers", _restored];
};

_restored
